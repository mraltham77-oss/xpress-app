-- =====================================================================
--  XPRESS — ترقية v2 (متاجر حقيقية + منتجات حقيقية + حالات الطلب)
-- =====================================================================
--  شغّل ملف schema.sql أولاً (إن لم تكن شغّلته)، ثم الصق هذا الملف كله
--  في Supabase -> SQL Editor -> Run (مرة واحدة).
-- =====================================================================

-- 1) متجر لكل بائع (نستخدم جدول vendors كجدول المتاجر)
alter table public.vendors
  add column if not exists owner_id uuid references auth.users (id) on delete set null;
alter table public.vendors
  add column if not exists description text default '';
alter table public.vendors
  add column if not exists category text default '';

-- 2) ملكية المنتجات (من أنشأ المنتج)
alter table public.products
  add column if not exists owner_id uuid references auth.users (id) on delete cascade;

-- 3) بيانات الطلب: المتاجر المشاركة + اسم العميل
alter table public.orders
  add column if not exists store_ids text[] default '{}';
alter table public.orders
  add column if not exists customer_name text default '';

create index if not exists vendors_owner_idx on public.vendors (owner_id);
create index if not exists products_owner_idx on public.products (owner_id);

-- 4) سياسات الكتابة للبائع على متجره -------------------------------------
drop policy if exists "vendors insert own" on public.vendors;
create policy "vendors insert own" on public.vendors
  for insert with check (auth.uid() = owner_id);

drop policy if exists "vendors update own" on public.vendors;
create policy "vendors update own" on public.vendors
  for update using (auth.uid() = owner_id);

-- 5) سياسات الكتابة للبائع على منتجاته -----------------------------------
drop policy if exists "products insert own" on public.products;
create policy "products insert own" on public.products
  for insert with check (auth.uid() = owner_id);

drop policy if exists "products update own" on public.products;
create policy "products update own" on public.products
  for update using (auth.uid() = owner_id);

drop policy if exists "products delete own" on public.products;
create policy "products delete own" on public.products
  for delete using (auth.uid() = owner_id);

-- 6) البائع يشوف الطلبات التي تحتوي منتجات متجره --------------------------
drop policy if exists "orders seller read" on public.orders;
create policy "orders seller read" on public.orders
  for select using (
    exists (
      select 1
      from public.vendors v
      where v.owner_id = auth.uid()
        and v.id = any (orders.store_ids)
    )
  );

-- 7) دالة يغيّر بها البائع حالة شحنة داخل الطلب ----------------------------
create or replace function public.set_shipment_status(
  p_order_id text,
  p_store_id text,
  p_status text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1 from public.vendors v
    where v.id = p_store_id and v.owner_id = auth.uid()
  ) then
    raise exception 'غير مصرّح لك بتعديل هذا الطلب';
  end if;

  if p_status not in (
    'pending', 'processing', 'shipped', 'outForDelivery', 'delivered', 'cancelled'
  ) then
    raise exception 'حالة غير صحيحة';
  end if;

  update public.orders o
  set shipments = (
    select coalesce(
      jsonb_agg(
        case
          when sh->>'vendorId' = p_store_id
            then jsonb_set(sh, '{status}', to_jsonb(p_status))
          else sh
        end
      ),
      '[]'::jsonb
    )
    from jsonb_array_elements(o.shipments) as sh
  )
  where o.id = p_order_id
    and p_store_id = any (o.store_ids);

  if not found then
    raise exception 'لم يتم العثور على الطلب';
  end if;
end;
$$;

-- 8) تحديث دور المستخدم إلى "بائع" عند فتح متجر ---------------------------
create or replace function public.set_my_role_seller()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles set role = 'seller' where id = auth.uid();
end;
$$;
