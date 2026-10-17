-- =====================================================================
--  XPRESS — مخطط قاعدة بيانات Supabase (الخطة المجانية)
-- =====================================================================
--  طريقة الاستخدام:
--   1) أنشئ مشروعًا مجانيًا على https://supabase.com
--   2) افتح  SQL Editor  ->  الصق كل هذا الملف  ->  Run
--   3) من Project Settings -> API انسخ:
--        - Project URL        (SUPABASE_URL)
--        - anon public key    (SUPABASE_ANON_KEY)
--   4) شغّل التطبيق ممرّرًا المفتاحين عبر --dart-define:
--        flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
--        flutter build web --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
--
--  بدون المفتاحين يعمل التطبيق تلقائيًا في الوضع المحلي (بيانات تجريبية).
-- =====================================================================

-- ─────────────────────────────── الجداول ───────────────────────────────

create table if not exists public.vendors (
  id          text primary key,
  name        text not null,
  avatar_url  text default '',
  rating      numeric(3,2) default 0,
  followers   integer default 0,
  verified    boolean default false,
  badge       text,
  location    text default 'القاهرة',
  created_at  timestamptz default now()
);

create table if not exists public.categories (
  id            text primary key,
  name          text not null,
  icon          text default '',
  color_hex     text default 'FFFFFF',
  subcategories text[] default '{}',
  image_asset   text default '',
  sort_order    integer default 0,
  created_at    timestamptz default now()
);

create table if not exists public.products (
  id             text primary key,
  title          text not null,
  images         text[] default '{}',
  price          numeric(12,2) default 0,
  old_price      numeric(12,2),
  rating         numeric(3,2) default 0,
  reviews_count  integer default 0,
  sold_count     integer default 0,
  stock          integer default 0,
  free_shipping  boolean default false,
  vendor_id      text references public.vendors (id) on delete set null,
  category_id    text references public.categories (id) on delete set null,
  description    text default '',
  colors         text[] default '{}',
  specifications text[] default '{}',
  created_at     timestamptz default now()
);

create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  name       text default '',
  phone      text default '',
  city       text default 'القاهرة',
  role       text default 'customer' check (role in ('customer', 'seller', 'admin')),
  created_at timestamptz default now()
);

create table if not exists public.addresses (
  id         text primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  label      text default '',
  full_name  text default '',
  phone      text default '',
  city       text default '',
  district   text default '',
  street     text default '',
  details    text default '',
  is_default boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.cart_items (
  id         bigserial primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  product_id text not null,
  quantity   integer not null default 1,
  color      text,
  size       text,
  selected   boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.orders (
  id              text primary key,
  user_id         uuid not null references auth.users (id) on delete cascade,
  date            timestamptz default now(),
  shipments       jsonb default '[]',
  total           numeric(12,2) default 0,
  subtotal        numeric(12,2) default 0,
  shipping        numeric(12,2) default 0,
  discount        numeric(12,2) default 0,
  address_summary text default '',
  payment_label   text default '',
  escrow_held     boolean default true,
  reviewed        boolean default false,
  created_at      timestamptz default now()
);

create index if not exists addresses_user_idx on public.addresses (user_id);
create index if not exists cart_user_idx on public.cart_items (user_id);
create index if not exists orders_user_idx on public.orders (user_id, date desc);
create index if not exists products_category_idx on public.products (category_id);

-- ─────────────────── إنشاء ملف شخصي تلقائيًا عند التسجيل ───────────────────

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, name, phone, city, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'phone', ''),
    'القاهرة',
    'customer'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ────────────────────────────── أمان الصفوف (RLS) ──────────────────────────────

alter table public.vendors    enable row level security;
alter table public.categories enable row level security;
alter table public.products   enable row level security;
alter table public.profiles   enable row level security;
alter table public.addresses  enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders     enable row level security;

-- الكتالوج: قراءة عامة (يديرها مسؤول المشروع من لوحة Supabase / service_role)
drop policy if exists "catalog read vendors" on public.vendors;
create policy "catalog read vendors" on public.vendors
  for select using (true);

drop policy if exists "catalog read categories" on public.categories;
create policy "catalog read categories" on public.categories
  for select using (true);

drop policy if exists "catalog read products" on public.products;
create policy "catalog read products" on public.products
  for select using (true);

-- الملف الشخصي: المستخدم يقرأ ويحدّث ملفه فقط
drop policy if exists "profiles select own" on public.profiles;
create policy "profiles select own" on public.profiles
  for select using (auth.uid() = id);

drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own" on public.profiles
  for insert with check (auth.uid() = id);

drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own" on public.profiles
  for update using (auth.uid() = id);

-- العناوين / السلة / الطلبات: ملك المستخدم فقط
drop policy if exists "addresses owner" on public.addresses;
create policy "addresses owner" on public.addresses
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "cart owner" on public.cart_items;
create policy "cart owner" on public.cart_items
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "orders owner" on public.orders;
create policy "orders owner" on public.orders
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ───────────────────────────── بيانات أولية ─────────────────────────────
-- الأقسام الثمانية (بنفس معرّفات التطبيق حتى تتوافق مع منتجات الواجهة).

insert into public.categories (id, name, icon, color_hex, subcategories, image_asset, sort_order) values
  ('c1', 'إلكترونيات', '📱', 'FFF3E0', '{جوالات,لابتوبات,سماعات,شاشات,أجهزة لوحية}', 'assets/xpress/images/categories/electronics.svg', 1),
  ('c2', 'أزياء',      '👗', 'FCE4EC', '{ملابس نسائية,ملابس رجالية,أحذية,حقائب,إكسسوارات}', 'assets/xpress/images/categories/fashion.svg', 2),
  ('c3', 'المنزل',     '🛋️', 'E8F5E9', '{أثاث,مطبخ,ديكور,مفروشات,إضاءة}', 'assets/xpress/images/categories/home.svg', 3),
  ('c4', 'رياضة',      '⚽', 'E3F2FD', '{لياقة,كرة القدم,دراجات,تخييم,سباحة}', 'assets/xpress/images/categories/sports.svg', 4),
  ('c5', 'جمال',       '💄', 'F3E5F5', '{عطور,عناية بالبشرة,مكياج,عناية بالشعر}', 'assets/xpress/images/categories/beauty.svg', 5),
  ('c6', 'أطفال',      '🧸', 'FFFDE7', '{ألعاب,ملابس أطفال,عربات,مستلزمات مدرسية}', 'assets/xpress/images/categories/kids.svg', 6),
  ('c7', 'سيارات',     '🚗', 'ECEFF1', '{قطع غيار,إكسسوارات,زيوت,إطارات}', 'assets/xpress/images/categories/cars.svg', 7),
  ('c8', 'ساعات',      '⌚', 'FFF8E1', '{ساعات رجالية,ساعات نسائية,ساعات ذكية}', 'assets/xpress/images/categories/watches.svg', 8)
on conflict (id) do update set
  name = excluded.name,
  icon = excluded.icon,
  color_hex = excluded.color_hex,
  subcategories = excluded.subcategories,
  image_asset = excluded.image_asset,
  sort_order = excluded.sort_order;

-- ملاحظة: اترك جدول products فارغًا الآن ليستمر التطبيق في عرض المنتجات
-- التجريبية. لإضافة منتجات حقيقية، أدخل بائعًا ثم منتجات، مثال:
--
-- insert into public.vendors (id, name, verified) values ('v1', 'متجر XPRESS', true);
-- insert into public.products (id, title, images, price, old_price, vendor_id, category_id, description)
-- values ('p1', 'هاتف ذكي', '{https://.../phone.png}', 12999, 14999, 'v1', 'c1', 'وصف المنتج');
