-- =====================================================================
--  XPRESS — ترقية v3  (أدمن حقيقي + موافقة على التجار + بيانات صفر)
-- =====================================================================
--  الخطوات:
--    1) شغّل schema.sql (لو لسه ما شغّلتهوش).
--    2) الصق هذا الملف كله في Supabase -> SQL Editor -> Run (مرة واحدة).
--  هذا الملف يشمل كل ما في schema_v2 أيضًا، فلا تحتاج تشغيل v2 منفصلة.
-- =====================================================================

-- ─────────────── 1) المتاجر: ملكية + حالة الموافقة ───────────────
alter table public.vendors
  add column if not exists owner_id uuid references auth.users (id) on delete set null;
alter table public.vendors
  add column if not exists description text default '';
alter table public.vendors
  add column if not exists category text default '';
alter table public.vendors
  add column if not exists phone text default '';
alter table public.vendors
  add column if not exists rejection_reason text default '';
alter table public.vendors
  add column if not exists status text not null default 'pending';

-- قيد الحالة (نتجاهل الخطأ لو موجود مسبقًا).
do $$
begin
  alter table public.vendors
    add constraint vendors_status_check
    check (status in ('pending', 'approved', 'rejected'));
exception when others then null;
end $$;

-- ─────────────── 2) المنتجات والطلبات ───────────────
alter table public.products
  add column if not exists owner_id uuid references auth.users (id) on delete cascade;
alter table public.orders
  add column if not exists store_ids text[] default '{}';
alter table public.orders
  add column if not exists customer_name text default '';
alter table public.orders
  add column if not exists customer_phone text default '';

create index if not exists vendors_owner_idx on public.vendors (owner_id);
create index if not exists vendors_status_idx on public.vendors (status);
create index if not exists products_owner_idx on public.products (owner_id);

-- ─────────────── 3) إعدادات التطبيق (كود الأدمن السري) ───────────────
create table if not exists public.app_config (
  key   text primary key,
  value text not null
);

-- ⚠️ غيّر الكود ده لأي كود سري تختاره قبل النشر.
insert into public.app_config (key, value)
values ('admin_code', 'XPRESS-ADMIN-2026')
on conflict (key) do update set value = excluded.value;

alter table public.app_config enable row level security;
-- بدون أي policy: لا يمكن لأي عميل قراءته إطلاقًا.

-- ─────────────── 4) دوال مساعدة (أدمن) ───────────────
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- يتحوّل المستخدم الحالي إلى أدمن بكود سري (مرة واحدة فقط: أول أدمن).
create or replace function public.claim_admin(p_code text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text;
  v_admin_exists boolean;
begin
  if auth.uid() is null then
    raise exception 'سجّل الدخول أولًا';
  end if;

  select value into v_code from public.app_config where key = 'admin_code';
  if v_code is null or p_code is null or btrim(p_code) <> v_code then
    return false;
  end if;

  select exists (select 1 from public.profiles where role = 'admin')
    into v_admin_exists;
  if v_admin_exists then
    return false; -- يوجد أدمن بالفعل
  end if;

  update public.profiles set role = 'admin' where id = auth.uid();
  return true;
end;
$$;

-- الأدمن يوافق / يرفض متجرًا (يرقّي صاحبه إلى بائع عند القبول).
create or replace function public.review_store(
  p_store_id text,
  p_approve  boolean,
  p_reason   text default ''
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner uuid;
begin
  if not public.is_admin() then
    raise exception 'غير مصرّح لك';
  end if;

  update public.vendors
  set status = case when p_approve then 'approved' else 'rejected' end,
      verified = p_approve,
      rejection_reason = coalesce(p_reason, '')
  where id = p_store_id
  returning owner_id into v_owner;

  if v_owner is not null and p_approve then
    update public.profiles
    set role = 'seller'
    where id = v_owner and role <> 'admin';
  end if;
end;
$$;

-- تغيير حالة شحنة داخل طلب (البائع صاحب المتجر أو الأدمن).
create or replace function public.set_shipment_status(
  p_order_id text,
  p_store_id text,
  p_status   text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not (
    public.is_admin()
    or exists (
      select 1 from public.vendors v
      where v.id = p_store_id and v.owner_id = auth.uid()
    )
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

-- عند فتح متجر: يصبح المستخدم بائعًا (والمنتجات تنتظر موافقة الأدمن للظهور).
create or replace function public.set_my_role_seller()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set role = 'seller'
  where id = auth.uid() and role = 'customer';
end;
$$;

-- ─────────────── 5) سياسات الأمان (RLS) ───────────────
alter table public.vendors    enable row level security;
alter table public.categories enable row level security;
alter table public.products   enable row level security;
alter table public.profiles   enable row level security;
alter table public.addresses  enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders     enable row level security;

-- المتاجر: القراءة عامة للمتاجر المعتمدة فقط (+ صاحبها + الأدمن).
drop policy if exists "catalog read vendors" on public.vendors;
drop policy if exists "vendors read" on public.vendors;
create policy "vendors read" on public.vendors
  for select using (
    public.is_admin()
    or owner_id = auth.uid()
    or status = 'approved'
  );

drop policy if exists "vendors insert own" on public.vendors;
create policy "vendors insert own" on public.vendors
  for insert with check (auth.uid() = owner_id);

drop policy if exists "vendors update own" on public.vendors;
create policy "vendors update own" on public.vendors
  for update using (auth.uid() = owner_id);

drop policy if exists "vendors admin" on public.vendors;
create policy "vendors admin" on public.vendors
  for all using (public.is_admin()) with check (public.is_admin());

-- الأقسام: قراءة عامة، الكتابة للأدمن فقط.
drop policy if exists "catalog read categories" on public.categories;
drop policy if exists "categories read" on public.categories;
create policy "categories read" on public.categories
  for select using (true);

drop policy if exists "categories admin" on public.categories;
create policy "categories admin" on public.categories
  for all using (public.is_admin()) with check (public.is_admin());

-- المنتجات: تظهر فقط لو متجرها معتمد (+ صاحبها + الأدمن).
drop policy if exists "catalog read products" on public.products;
drop policy if exists "products read" on public.products;
create policy "products read" on public.products
  for select using (
    public.is_admin()
    or owner_id = auth.uid()
    or exists (
      select 1 from public.vendors v
      where v.id = products.vendor_id and v.status = 'approved'
    )
  );

drop policy if exists "products insert own" on public.products;
create policy "products insert own" on public.products
  for insert with check (auth.uid() = owner_id);

drop policy if exists "products update own" on public.products;
create policy "products update own" on public.products
  for update using (auth.uid() = owner_id);

drop policy if exists "products delete own" on public.products;
create policy "products delete own" on public.products
  for delete using (auth.uid() = owner_id);

drop policy if exists "products admin" on public.products;
create policy "products admin" on public.products
  for all using (public.is_admin()) with check (public.is_admin());

-- الملفات الشخصية: صاحبها + الأدمن.
drop policy if exists "profiles select own" on public.profiles;
create policy "profiles select own" on public.profiles
  for select using (auth.uid() = id);

drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own" on public.profiles
  for insert with check (auth.uid() = id);

drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own" on public.profiles
  for update using (auth.uid() = id);

drop policy if exists "profiles admin read" on public.profiles;
create policy "profiles admin read" on public.profiles
  for select using (public.is_admin());

-- العناوين / السلة / الطلبات.
drop policy if exists "addresses owner" on public.addresses;
create policy "addresses owner" on public.addresses
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "cart owner" on public.cart_items;
create policy "cart owner" on public.cart_items
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "orders owner" on public.orders;
create policy "orders owner" on public.orders
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "orders seller read" on public.orders;
create policy "orders seller read" on public.orders
  for select using (
    exists (
      select 1 from public.vendors v
      where v.owner_id = auth.uid() and v.id = any (orders.store_ids)
    )
  );

drop policy if exists "orders admin" on public.orders;
create policy "orders admin" on public.orders
  for all using (public.is_admin()) with check (public.is_admin());

-- ─────────────── 6) تصفير كل البيانات الحقيقية ───────────────
-- (مطلوب: نبدأ من صفر ونضيف بياناتنا الحقيقية بأنفسنا)
-- لو أردت الاحتفاظ بأي بيانات، اكتب -- أمام السطور.
delete from public.products;
delete from public.vendors;
delete from public.orders;
delete from public.cart_items;

-- ملاحظة: الأقسام (categories) تُترك كبنية للتطبيق، ويمكن للأدمن
-- إدارتها/إضافة أقسام جديدة من داخل التطبيق نفسه.
