class AppConstants {
  // App Info
  static const String appName = 'DeliSwift';
  static const String appVersion = '1.0.0';

  // API Keys (replace with your actual keys)
  // NOTE: Consider restricting this key in Google Cloud Console (Android package + SHA-1, Web referrers) and avoid committing it to public repos.
  static const String googleMapsApiKey = 'AIzaSyDE9vDJrB2-4E-_FROvWyhi6M9HiwHpqII';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String restaurantsCollection = 'restaurants';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String deliveryPersonsCollection = 'delivery_persons';
  static const String categoriesCollection = 'categories';

  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String onboardingKey = 'onboarding_done';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 10;
  static const int restaurantsPageSize = 8;

  // Delivery
  static const double freeDeliveryThreshold = 50.0;
  static const double defaultDeliveryFee = 5.0;
  static const String currencySymbol = 'ر.س';

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusOnWay = 'on_way';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  // Image Placeholders
  static const String placeholderImage =
      'https://via.placeholder.com/300x200.png';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}

class AppAssets {
  // Animations (Lottie)
  static const String splashAnimation = 'assets/animations/splash.json';
  static const String loadingAnimation = 'assets/animations/animation.png';
  static const String emptyAnimation = 'assets/animations/empty.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String deliveryAnimation = 'assets/animations/delivery.json';
  static const String errorAnimation = 'assets/animations/error.json';

  // Images
  static const String logoImage = 'assets/images/logo.png';
  static const String onboarding1 = 'assets/images/onboarding1.png';
  static const String onboarding2 = 'assets/images/onboarding2.png';
  static const String onboarding3 = 'assets/images/onboarding3.png';

  // Icons
  static const String homeIcon = 'assets/icons/home.png';
  static const String cartIcon = 'assets/icons/cart.svg';
  static const String ordersIcon = 'assets/icons/orders.svg';
  static const String profileIcon = 'assets/icons/profile.svg';
}
