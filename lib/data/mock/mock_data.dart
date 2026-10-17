import '../models/address.dart';
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/coupon.dart';
import '../models/order_model.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/review.dart';
import '../models/vendor.dart';
import '../models/wallet_tx.dart';

class MockData {
  MockData._();

  static String img(String seed) => 'https://picsum.photos/seed/$seed/700/700';

  static const List<ProductCategory> categories = [
    ProductCategory(
      id: 'c1',
      name: 'إلكترونيات',
      icon: '📱',
      colorHex: 'FFF3E0',
      subcategories: ['جوالات', 'لابتوبات', 'سماعات', 'شاشات', 'أجهزة لوحية'],
      imageAsset: 'assets/xpress/images/categories/electronics.svg',
    ),
    ProductCategory(
      id: 'c2',
      name: 'أزياء',
      icon: '👗',
      colorHex: 'FCE4EC',
      subcategories: [
        'ملابس نسائية',
        'ملابس رجالية',
        'أحذية',
        'حقائب',
        'إكسسوارات',
      ],
      imageAsset: 'assets/xpress/images/categories/fashion.svg',
    ),
    ProductCategory(
      id: 'c3',
      name: 'المنزل',
      icon: '🛋️',
      colorHex: 'E8F5E9',
      subcategories: ['أثاث', 'مطبخ', 'ديكور', 'مفروشات', 'إضاءة'],
      imageAsset: 'assets/xpress/images/categories/home.svg',
    ),
    ProductCategory(
      id: 'c4',
      name: 'رياضة',
      icon: '⚽',
      colorHex: 'E3F2FD',
      subcategories: ['لياقة', 'كرة القدم', 'دراجات', 'تخييم', 'سباحة'],
      imageAsset: 'assets/xpress/images/categories/sports.svg',
    ),
    ProductCategory(
      id: 'c5',
      name: 'جمال',
      icon: '💄',
      colorHex: 'F3E5F5',
      subcategories: ['عطور', 'عناية بالبشرة', 'مكياج', 'عناية بالشعر'],
      imageAsset: 'assets/xpress/images/categories/beauty.svg',
    ),
    ProductCategory(
      id: 'c6',
      name: 'أطفال',
      icon: '🧸',
      colorHex: 'FFFDE7',
      subcategories: ['ألعاب', 'ملابس أطفال', 'عربات', 'مستلزمات مدرسية'],
      imageAsset: 'assets/xpress/images/categories/kids.svg',
    ),
    ProductCategory(
      id: 'c7',
      name: 'سيارات',
      icon: '🚗',
      colorHex: 'ECEFF1',
      subcategories: ['قطع غيار', 'إكسسوارات', 'زيوت', 'إطارات'],
      imageAsset: 'assets/xpress/images/categories/cars.svg',
    ),
    ProductCategory(
      id: 'c8',
      name: 'ساعات',
      icon: '⌚',
      colorHex: 'FFF8E1',
      subcategories: ['ساعات رجالية', 'ساعات نسائية', 'ساعات ذكية'],
      imageAsset: 'assets/xpress/images/categories/watches.svg',
    ),
  ];

  static const List<Vendor> vendors = [
    Vendor(
      id: 'v1',
      name: 'متجر النخبة',
      avatarUrl: 'https://picsum.photos/seed/vendor1/200/200',
      rating: 4.8,
      followers: 15200,
      verified: true,
      badge: 'بائع مميز',
      location: 'القاهرة',
    ),
    Vendor(
      id: 'v2',
      name: 'عالم التقنية',
      avatarUrl: 'https://picsum.photos/seed/vendor2/200/200',
      rating: 4.6,
      followers: 8400,
      verified: true,
      location: 'الجيزة',
    ),
    Vendor(
      id: 'v3',
      name: 'دار الأزياء',
      avatarUrl: 'https://picsum.photos/seed/vendor3/200/200',
      rating: 4.9,
      followers: 23100,
      verified: true,
      badge: 'الأعلى تقييمًا',
      location: 'الإسكندرية',
    ),
    Vendor(
      id: 'v4',
      name: 'بيت الصحة',
      avatarUrl: 'https://picsum.photos/seed/vendor4/200/200',
      rating: 4.4,
      followers: 3100,
      location: 'المنصورة',
    ),
  ];

  static final List<Product> products = [
    Product(
      id: 'p1',
      title: 'آيفون 15 برو ماكس 256 جيجابايت — تيتانيوم طبيعي',
      images: ['p1a', 'p1b', 'p1c', 'p1d'].map(img).toList(),
      price: 52999,
      oldPrice: 59999,
      rating: 4.8,
      reviewsCount: 1243,
      soldCount: 8500,
      freeShipping: true,
      vendor: vendors[0],
      categoryId: 'c1',
      description:
          'هاتف ذكي بمعالج سريع وكاميرا احترافية بدقة 48 ميجابكسل، إطار تيتانيوم خفيف، وشاشة عالية الدقة لعرض سلس.',
      colors: ['تيتانيوم', 'أسود', 'أزرق'],
      specifications: [
        'الشاشة: 6.7 بوصة OLED',
        'المعالج: A17 Pro',
        'الذاكرة: 256 جيجابايت',
        'البطارية: 4400 مللي أمبير',
        'الضمان: سنتان',
      ],
    ),
    Product(
      id: 'p2',
      title: 'سماعات AirPods Pro عازلة للضوضاء بشحن ماغسيفي',
      images: ['p2a', 'p2b', 'p2c'].map(img).toList(),
      price: 7499,
      oldPrice: 8999,
      rating: 4.7,
      reviewsCount: 856,
      soldCount: 5200,
      freeShipping: true,
      vendor: vendors[1],
      categoryId: 'c1',
      description:
          'صوت نقي وعزل تام للضوضاء مع بطارية تدوم حتى 30 ساعة وشحن سريع.',
      colors: ['أبيض', 'أسود'],
      specifications: [
        'النوع: داخل الأذن',
        'البطارية: 30 ساعة',
        'الاتصال: بلوتوث 5.3',
      ],
    ),
    Product(
      id: 'p3',
      title: 'حقيبة يد جلد طبيعي فاخرة — تصميم عصري',
      images: ['p3a', 'p3b', 'p3c', 'p3d'].map(img).toList(),
      price: 2499,
      oldPrice: 3999,
      rating: 4.9,
      reviewsCount: 2100,
      soldCount: 12400,
      vendor: vendors[2],
      categoryId: 'c2',
      description:
          'حقيبة أنيقة من الجلد الطبيعي بخياطة يدوية متينة، مناسبة لكل المناسبات.',
      colors: ['بني', 'أسود', 'بيج'],
      specifications: ['المادة: جلد طبيعي', 'الحجم: متوسط', 'جيوب داخلية: 3'],
    ),
    Product(
      id: 'p4',
      title: 'ساعة ذكية رياضية مقاومة للماء مع تتبع النشاط',
      images: ['p4a', 'p4b', 'p4c'].map(img).toList(),
      price: 1999,
      oldPrice: 3499,
      rating: 4.6,
      reviewsCount: 640,
      soldCount: 3900,
      freeShipping: true,
      vendor: vendors[1],
      categoryId: 'c1',
      description:
          'تتبع الخطوات ونبضات القلب والنوم، مع شاشة تعمل باللمس وبطارية تدوم 7 أيام.',
      colors: ['أسود', 'فضي', 'وردي'],
      specifications: [
        'مقاومة الماء: 5ATM',
        'البطارية: 7 أيام',
        'الشاشة: AMOLED',
      ],
    ),
    Product(
      id: 'p5',
      title: 'طقم أواني طهي مضاد للالتصاق — 10 قطع',
      images: ['p5a', 'p5b', 'p5c'].map(img).toList(),
      price: 1899,
      oldPrice: 2999,
      rating: 4.5,
      reviewsCount: 410,
      soldCount: 2300,
      vendor: vendors[3],
      categoryId: 'c3',
      description:
          'طقم متكامل من الستانلس ستيل بطبقة مضادة للالتصاق، مناسب لكل أنواع المواقد.',
      specifications: [
        'عدد القطع: 10',
        'المادة: ستانلس ستيل',
        'مناسب لـ: جميع المواقد',
      ],
    ),
    Product(
      id: 'p6',
      title: 'حذاء رياضي للجري خفيف الوزن ومريح',
      images: ['p6a', 'p6b', 'p6c', 'p6d'].map(img).toList(),
      price: 999,
      oldPrice: 1499,
      rating: 4.7,
      reviewsCount: 980,
      soldCount: 6700,
      freeShipping: true,
      vendor: vendors[2],
      categoryId: 'c4',
      description:
          'حذاء بتصميم عصري ونعل مرن ماصّ للصدمات، مثالي للجري والتمارين اليومية.',
      colors: ['أسود', 'رمادي', 'أزرق'],
      specifications: ['النوع: جري', 'المقاسات: 39-45', 'النعل: مطاط مرن'],
    ),
    Product(
      id: 'p7',
      title: 'ذراع تحكم ألعاب لاسلكي مع اهتزاز للجوال والكمبيوتر',
      images: ['p7a', 'p7b', 'p7c'].map(img).toList(),
      price: 1299,
      oldPrice: 2099,
      rating: 4.6,
      reviewsCount: 350,
      soldCount: 1800,
      vendor: vendors[1],
      categoryId: 'c1',
      description:
          'ذراع تحكم بلوتوث مع اهتزاز رؤوس مزدوج ودعم واسع للألعاب على الجوال والكمبيوتر.',
      colors: ['أسود', 'أبيض'],
      specifications: [
        'الاتصال: بلوتوث 5.1',
        'البطارية: 20 ساعة',
        'متوافق مع: iOS/Android/Windows',
      ],
    ),
    Product(
      id: 'p8',
      title: 'مجموعة ألعاب أطفال تعليمية 30 قطعة — خشب آمن',
      images: ['p8a', 'p8b', 'p8c'].map(img).toList(),
      price: 899,
      oldPrice: 1299,
      rating: 4.4,
      reviewsCount: 620,
      soldCount: 2400,
      freeShipping: true,
      vendor: vendors[3],
      categoryId: 'c6',
      description:
          'مجموعة ألعاب تعليمية من الخشب الطبيعي بحواف آمنة، تنمية ذكاء الطفل ومهاراته الحركية.',
      specifications: [
        'عدد القطع: 30',
        'العمر المناسب: 3+',
        'المادة: خشب طبيعي',
      ],
    ),
  ];

  static List<Review> reviews() => [
    Review(
      id: 'r1',
      productId: 'p1',
      userName: 'سارة العتيبي',
      rating: 5,
      comment:
          'منتج رائع والجودة ممتازة، وصل بسرعة والتغليف احترافي. أنصح به بشدة!',
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Review(
      id: 'r2',
      productId: 'p1',
      userName: 'خالد المطيري',
      rating: 4,
      comment:
          'جيد جدًا مقابل السعر، لكن التوصيل تأخر يوم. بشكل عام تجربة مرضية.',
      date: DateTime.now().subtract(const Duration(days: 9)),
    ),
    Review(
      id: 'r3',
      productId: 'p2',
      userName: 'منى الشهراني',
      rating: 5,
      comment: 'عزل ممتاز للضوضاء في المشوار، صوتها واضح جدًا والبطارية تكفي.',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: 'r4',
      productId: 'p2',
      userName: 'عبدالله الغامدي',
      rating: 4,
      comment: 'مريحة للأذن مع ضمان، لكن الحساسية تحتاج تعديل بسيط.',
      date: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Review(
      id: 'r5',
      productId: 'p3',
      userName: 'ريم القحطاني',
      rating: 5,
      comment: 'الجلد أصلي ولمعانه جميل، أحببت الحجم.',
      date: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Review(
      id: 'r6',
      productId: 'p4',
      userName: 'مشاعل الدوسري',
      rating: 4,
      comment: 'دقة التتبع جيدة والشكل أنيق، مناسبة للرياضة.',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Review(
      id: 'r7',
      productId: 'p6',
      userName: 'محمد الكندي',
      rating: 5,
      comment: 'خفيفة جدًا في الجري والنعل مرن، أكثر من رائعة.',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static List<Address> addresses() => [
    Address(
      id: 'a1',
      label: 'المنزل',
      fullName: 'أحمد محمد',
      phone: '+20 100 123 4567',
      city: 'القاهرة',
      district: 'مدينة نصر',
      street: 'شارع عباس العقاد',
      details: 'عمارة 12، الدور الثالث، شقة 8',
      isDefault: true,
    ),
    Address(
      id: 'a2',
      label: 'العمل',
      fullName: 'أحمد محمد',
      phone: '+20 100 123 4567',
      city: 'القاهرة',
      district: 'التجمع الخامس',
      street: 'شارع 90 الشمالي',
      details: 'مبنى السيادة، الدور 5',
    ),
    Address(
      id: 'a3',
      label: 'بيت العائلة',
      fullName: 'محمود محمد',
      phone: '+20 111 987 6543',
      city: 'الجيزة',
      district: 'المهندسين',
      street: 'شارع جامعة الدول',
    ),
  ];

  static List<Order> orders() {
    final now = DateTime.now().subtract(const Duration(days: 2));
    return [
      Order(
        id: 'XP123456789',
        date: now,
        shipments: [
          OrderShipment(
            vendorName: 'متجر النخبة',
            vendorAvatar: 'https://picsum.photos/seed/vendor1/200/200',
            status: OrderStatus.outForDelivery,
            itemTitles: ['آيفون 15 برو ماكس'],
            productIds: ['p1'],
            itemCount: 1,
            amount: 52999,
            trackingNo: 'XP987654321Q',
          ),
        ],
        subtotal: 52999,
        shipping: 0,
        discount: 2200,
        total: 50799,
        addressSummary: 'القاهرة، مدينة نصر، شارع عباس العقاد',
        paymentLabel: 'بطاقة بنكية',
        escrowHeld: true,
      ),
      Order(
        id: 'XP987654321',
        date: now.subtract(const Duration(days: 9)),
        shipments: [
          OrderShipment(
            vendorName: 'عالم التقنية',
            vendorAvatar: 'https://picsum.photos/seed/vendor2/200/200',
            status: OrderStatus.delivered,
            itemTitles: ['سماعات AirPods Pro', 'ذراع تحكم ألعاب'],
            productIds: ['p2', 'p7'],
            itemCount: 2,
            amount: 8798,
            trackingNo: 'XP123456788Q',
          ),
        ],
        subtotal: 8798,
        shipping: 0,
        discount: 439,
        total: 8359,
        addressSummary: 'القاهرة، مدينة نصر، شارع عباس العقاد',
        paymentLabel: 'بطاقة بنكية',
        escrowHeld: false,
        reviewed: true,
      ),
    ];
  }

  static List<WalletTransaction> walletTransactions() {
    final now = DateTime.now();
    return [
      WalletTransaction(
        id: 'w1',
        type: WalletTxType.topup,
        title: 'إيداع رصيد بالبطاقة',
        amount: 3500,
        date: now.subtract(const Duration(days: 1)),
      ),
      WalletTransaction(
        id: 'w2',
        type: WalletTxType.hold,
        title: 'حجز مبلغ — طلب #XP123456789',
        amount: -50799,
        date: now,
      ),
      WalletTransaction(
        id: 'w3',
        type: WalletTxType.release,
        title: 'تحرير مبلغ — طلب #XP987654321',
        amount: 4379,
        date: now.subtract(const Duration(days: 5)),
      ),
      WalletTransaction(
        id: 'w4',
        type: WalletTxType.refund,
        title: 'استرداد — منتج مرتجع',
        amount: 999,
        date: now.subtract(const Duration(days: 12)),
      ),
    ];
  }

  /// Shipping partners
  static const List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'pm1',
      type: PaymentType.card,
      label: 'بطاقة بنكية',
      last4: '3948',
      isDefault: true,
    ),
    PaymentMethod(
      id: 'pm2',
      type: PaymentType.cod,
      label: 'الدفع عند الاستلام',
    ),
    PaymentMethod(id: 'pm3', type: PaymentType.wallet, label: 'محفظة XPRESS'),
  ];

  static List<Coupon> coupons() {
    final soon = DateTime.now().add(const Duration(days: 15));
    return [
      Coupon(
        code: 'XPRESS20',
        description: 'خصم 20% على الإلكترونيات',
        value: 20,
        isPercent: true,
        minOrder: 5000,
        expiry: soon,
      ),
      Coupon(
        code: 'SAVE50',
        description: 'خصم 50 ج.م',
        value: 50,
        minOrder: 300,
        expiry: soon,
        isPercent: false,
      ),
      Coupon(
        code: 'NEW100',
        description: 'خصم 100 ج.م للعملاء الجدد',
        value: 100,
        minOrder: 1000,
        expiry: soon,
        isPercent: false,
      ),
    ];
  }

  static const AppUser user = AppUser(
    id: 'u1',
    name: 'أحمد محمد',
    phone: '+20 100 123 4567',
    email: 'ahmed@example.com',
    avatarUrl: 'https://picsum.photos/seed/me/200/200',
    city: 'القاهرة',
    role: UserRole.admin,
  );

  static List<AppNotification> notifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n1',
        title: 'شحنتك في الطريق 🚚',
        body: 'طلبك XP123456789 وصل إلى القاهرة وجارٍ التوصيل اليوم.',
        date: now.subtract(const Duration(hours: 2)),
        kind: NotificationKind.order,
      ),
      AppNotification(
        id: 'n2',
        title: 'عرض فلاش ساخن 🔥',
        body: 'خصومات تصل إلى 15% على الإلكترونيات لفترة محدودة خلال 24 ساعة.',
        date: now.subtract(const Duration(hours: 6)),
        kind: NotificationKind.promo,
      ),
      AppNotification(
        id: 'n3',
        title: 'تم إيداع المبلغ',
        body: 'أُضيف 1500 ج.م إلى محفظتك بنجاح.',
        date: now.subtract(const Duration(days: 1)),
        kind: NotificationKind.wallet,
        read: true,
      ),
      AppNotification(
        id: 'n4',
        title: 'مرحبًا بك في XPRESS 👋',
        body: 'أنشئ حسابك واحصل على خصم 100 ج.م على أول طلب. بداية رائعة!',
        date: now.subtract(const Duration(days: 3)),
        kind: NotificationKind.system,
        read: true,
      ),
    ];
  }
}
