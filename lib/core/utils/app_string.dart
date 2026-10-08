/// Poori app ke saare texts yahin se badlo.
/// Path: lib/core/constants/app_strings.dart
abstract final class AppStrings {
  // ---------------- Common ----------------
  static const String shop_ease = 'Shop Ease';
  static const String retry = 'Retry';
  static const String seeAll = 'See All';
  static const String filter = 'Filter';
  static const String clear = 'Clear';
  static const String searchHint = 'Search products...';

  // ---------------- Login (static credentials) ----------------
  static const String demoUser = 'admin';
  static const String demoPass = '123456';
  static const String demoUserCredential = 'https://dummyjson.com/icon/admin/128';

  static const String loginTitle = 'Welcome Back!';
  static const String loginSubtitle = 'Login to continue shopping';
  static const String username = 'Username';
  static const String password = 'Password';
  static const String loginButton = 'Login';
  static const String demoHint = 'Demo: $demoUser / $demoPass';
  static const String loginSuccess = 'Login Successful!';
  static const String loginFailed = 'Invalid username or password!';
  static const String usernameRequired = 'UserName is Mandatory';
  static const String usernameTooShort = 'min. 3 character';
  static const String passwordRequired = 'Passoerd is Mandatory';
  static const String passwordTooShort =
      'Password atleast have 6 character';

  // ---------------- Dashboard / Home ----------------
  static const String greetingMorning = 'Good Morning,';
  static const String greetingAfternoon = 'Good Afternoon,';
  static const String greetingEvening = 'Good Evening,';
  static const String shopper = 'Shopper 👋';
  static const String notifications = 'Notifications';
  static const String bannerTitle = 'Big Deals';
  static const String bannerSubtitle = 'Up to 50% OFF';
  static const String shopNow = 'Shop Now';
  static const String popularProducts = 'Popular Products';


  // ---------------- Bottom navigation ----------------
  static const String navHome = 'Home';
  static const String navProduct = 'Product';
  static const String navFavorites = 'Favorites';
  static const String navProfile = 'Profile';

  // ---------------- Product listing ----------------
  static const String allProductsLoaded = 'Sab products dikh gaye';

  // ---------------- Favorites ----------------
  static const String favoritesTitle = 'Favorites';
  static const String noFavorites = 'No Favorites';

  // ---------------- Product detail ----------------
  static const String description = 'Description';
  static const String specifications = 'Specifications';
  static const String warranty = 'Warranty';
  static const String shipping = 'Shipping';
  static const String returns = 'Returns';
  static const String minOrder = 'Min. order';
  static const String sku = 'SKU';
  static const String weight = 'Weight';
  static const String dimensions = 'Dimensions';
  static const String total = 'Total';
  static const String addToCart = 'Add to Cart';
  static const String outOfStock = 'Out of Stock';
  static const String inStock = 'In Stock';
  static String reviewsCount(int n) => 'Reviews ($n)';
  static String unitsLeft(int n) => '$n units left';
  static String discountOff(String percent) => '$percent% OFF';
  static String minOrderUnits(int n) => '$n unit(s)';

  // ---------------- Profile ----------------
  static const String profile = 'Profile';
  static const String guest = 'Guest';
  static const String settings = 'Settings';
  static const String darkTheme = 'Dark theme';
  static const String logout = 'Logout';

  // ---------------- Network errors ----------------
  static const String errTimeout = 'Connection timeout. Try Again.';
  static const String errNoInternet = 'Check Internet connection ';
  static const String errSomethingWrong = 'Something Went Wrong';
  static String errServer(int? code) => 'Server error ($code).';
}