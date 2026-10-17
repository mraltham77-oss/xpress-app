/// كل نصوص الواجهة بالعربية في مكان واحد (single source of truth).
/// لاحقًا يمكن استبدالها بنظام l10n (.arb) دون تغيير الواجهات.
class AppStrings {
  AppStrings._();

  static const String appName = 'XPRESS';
  static const String brandTagline = 'تسوّق أذكى .. عيش أسهل';

  // Navigation
  static const String home = 'الرئيسية';
  static const String categories = 'الأقسام';
  static const String cart = 'السلة';
  static const String orders = 'طلباتي';
  static const String account = 'حسابي';
  static const String wishlistNav = 'المفضلة';

  // Home
  static const String searchHint = 'ابحث عن منتج، متجر، أو فئة...';
  static const String flashDeals = 'عروض فلاش';
  static const String endsIn = 'تبقى للعرض';
  static const String seeAll = 'عرض الكل';
  static const String recommendedForYou = 'مقترح لك';
  static const String topDeals = 'أقوى العروض';
  static const String newArrivals = 'وصل حديثًا';
  static const String freeShipping = 'شحن مجاني';
  static const String sponsored = 'إعلان مُموّل';

  // Product
  static const String addToCart = 'أضف إلى السلة';
  static const String buyNow = 'اشترِ الآن';
  static const String soldBy = 'يُشحن من';
  static const String safePayment = 'دفع آمن — المبلغ محتجز حتى الاستلام';
  static const String expectedDelivery = 'التوصيل المتوقع';
  static const String days = 'أيام';
  static const String quantity = 'الكمية';
  static const String color = 'اللون';
  static const String size = 'المقاس';
  static const String addedToCart = 'تمت الإضافة إلى السلة';
  static const String viewCart = 'عرض السلة';
  static const String productDetails = 'تفاصيل المنتج';
  static const String reviews = 'التقييمات';
  static const String chatSeller = 'دردشة مع البائع';
  static const String inStock = 'متوفر';
  static const String outOfStock = 'غير متوفر';
  static const String sold = 'مبيعة';
  static const String description = 'الوصف';
  static const String specifications = 'المواصفات';
  static const String rating = 'التقييم';

  // Cart
  static const String cartTitle = 'سلة التسوق';
  static const String emptyCart = 'سلتك فارغة';
  static const String emptyCartHint = 'ابدأ بإضافة منتجاتك المفضلة';
  static const String startShopping = 'ابدأ التسوق';
  static const String subtotal = 'المجموع الفرعي';
  static const String shipping = 'الشحن';
  static const String discount = 'الخصم';
  static const String total = 'الإجمالي';
  static const String checkout = 'إتمام الشراء';
  static const String continueShopping = 'متابعة التسوق';
  static const String selectAll = 'تحديد الكل';
  static const String applyCoupon = 'هل لديك كوبون خصم؟';
  static const String shippedFromDifferentStore = 'يُشحن من متجر مختلف';

  // Wallet
  static const String myWallet = 'محفظتي';
  static const String availableBalance = 'الرصيد المتاح';
  static const String heldAmount = 'مبلغ محتجز (طلبات جارية)';
  static const String deposit = 'إيداع';
  static const String withdraw = 'سحب';
  static const String recentTransactions = 'آخر العمليات';
  static const String escrow = 'الدفع الآمن';
  static const String escrowDesc =
      'أموالك محفوظة بحساب وسيط حتى تأكيد الاستلام';

  // Orders
  static const String myOrders = 'طلباتي';
  static const String allOrders = 'الكل';
  static const String toShip = 'قيد التحضير';
  static const String toReceive = 'قيد التوصيل';
  static const String toReview = 'بانتظار التقييم';
  static const String trackOrder = 'تتبع الطلب';
  static const String confirmReceipt = 'تأكيد الاستلام';
  static const String orderNumber = 'رقم الطلب';
  static const String trackingNumber = 'رقم التتبع';
  static const String trackShipment = 'تتبع الشحنة';

  // Order statuses
  static const String statusPending = 'قيد المراجعة';
  static const String statusProcessing = 'قيد التحضير';
  static const String statusShipped = 'تم الشحن';
  static const String statusOutForDelivery = 'جارٍ التوصيل';
  static const String statusDelivered = 'تم التوصيل';
  static const String statusCancelled = 'ملغي';

  // Account
  static const String settings = 'الإعدادات';
  static const String addresses = 'عناوين التوصيل';
  static const String wishlist = 'المفضلة';
  static const String coupons = 'كوبوناتي';
  static const String notifications = 'الإشعارات';
  static const String language = 'اللغة';
  static const String helpCenter = 'مركز المساعدة';
  static const String about = 'عن التطبيق';
  static const String becomeSeller = 'كن بائعًا';
  static const String logout = 'تسجيل الخروج';
  static const String login = 'تسجيل الدخول';
  static const String register = 'إنشاء حساب';
  static const String guest = 'زائر';

  // Common
  static const String currency = 'ج.م';
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String retry = 'إعادة المحاولة';
  static const String loading = 'جارٍ التحميل...';
  static const String errorGeneric = 'حدث خطأ، حاول مرة أخرى';
  static const String noResults = 'لا توجد نتائج';
  static const String seeMore = 'المزيد';
  static const String sar = 'ج.م';

  // Filters / sort
  static const String sortBy = 'ترتيب حسب';
  static const String filter = 'تصفية';
  static const String bestMatch = 'الأكثر ملاءمة';
  static const String priceLowHigh = 'السعر: من الأقل للأعلى';
  static const String priceHighLow = 'السعر: من الأعلى للأقل';
  static const String bestRating = 'الأعلى تقييمًا';
  static const String mostSold = 'الأكثر مبيعًا';
  static const String priceRange = 'نطاق السعر';
  static const String minRating = 'أقل تقييم';
  static const String freeShippingOnly = 'شحن مجاني فقط';
  static const String inStockOnly = 'المتوفر فقط';
  static const String clearFilters = 'مسح الفلاتر';
  static const String applyFilters = 'تطبيق';
  static const String andUp = 'وأعلى';
  static const String productsCount = 'منتج';

  // Auth
  static const String loginTitle = 'تسجيل الدخول';
  static const String loginSubtitle = 'سجّل دخولك للمتابعة إلى XPRESS';
  static const String email = 'البريد الإلكتروني';
  static const String phone = 'رقم الجوال';
  static const String password = 'كلمة المرور';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String fullName = 'الاسم الكامل';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String noAccount = 'ليس لديك حساب؟';
  static const String haveAccount = 'لديك حساب بالفعل؟';
  static const String signUp = 'إنشاء حساب';
  static const String signIn = 'دخول';
  static const String or = 'أو';
  static const String continueWithGoogle = 'المتابعة بحساب Google';
  static const String continueAsGuest = 'الدخول كزائر';
  static const String resetPassword = 'استعادة كلمة المرور';
  static const String resetPasswordHint = 'أدخل بريدك وسنرسل لك رمز التحقق';
  static const String sendCode = 'إرسال الرمز';
  static const String otpTitle = 'رمز التحقق';
  static const String otpSubtitle = 'أدخل الرمز المكوّن من 4 أرقام المُرسل إلى';
  static const String resendCode = 'إعادة إرسال الرمز';
  static const String verify = 'تحقق';
  static const String newPassword = 'كلمة المرور الجديدة';
  static const String changePassword = 'تغيير كلمة المرور';
  static const String passwordUpdated = 'تم تحديث كلمة المرور بنجاح';
  static const String termsAgree = 'أوافق على الشروط والأحكام وسياسة الخصوصية';
  static const String weakPassword =
      'كلمة المرور ضعيفة جدًا (8 أحرف على الأقل)';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String invalidPhone = 'رقم الجوال غير صحيح';
  static const String passwordsMismatch = 'كلمتا المرور غير متطابقتين';
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidOtp = 'رمز التحقق غير صحيح';
  static const String demoOtpHint = 'رمز تجريبي: 1234';

  // Admin
  static const String adminDashboard = 'لوحة التحكم';
  static const String adminOverview = 'نظرة عامة';
  static const String adminProducts = 'المنتجات';
  static const String adminCategories = 'الأقسام';
  static const String adminInventory = 'المخزون';
  static const String adminPromotions = 'العروض';
  static const String adminOrders = 'الطلبات';
  static const String adminRevenue = 'الإيرادات';
  static const String adminSales = 'المبيعات';
  static const String adminLowStock = 'مخزون منخفض';
  static const String adminOutOfStock = 'نفد المخزون';
  static const String adminAddProduct = 'إضافة منتج';
  static const String adminEditProduct = 'تعديل المنتج';
  static const String adminDeleteProduct = 'حذف المنتج';
  static const String adminNewPromotion = 'عرض جديد';
  static const String adminApprove = 'اعتماد';
  static const String adminReject = 'رفض';
  static const String adminActive = 'نشِط';
  static const String adminInactive = 'موقوف';
  static const String adminAccessDenied = 'هذه المنطقة مخصّصة للمشرفين فقط';
}
