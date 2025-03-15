class MarginSizes {
  static const double small = 8.0;
  static const double moderate = 12.0;
  static const double medium = 16.0;
  static const double verticalCard = 8.0;
  static const double horizontalCard = 16.0;
  static const double modalTop = 10.0;
  static const double formSpacing = 24.0;
  
  // New specific size names replacing old ones
  static const double sectionSpacing =
      4.0; // For small spacing between section text and instruction (CreateOrderScreen)
  static const double filterChipSpacing =
      8.0; // For spacing between filter chips (ManageOrdersScreen, OrderTrackingScreen)
  static const double logoSpacing =
      12.0; // For spacing between logo elements (AppLogoWidget)  static const double cardElementSpacing = 8.0; // Renamed from filterChipSpacing, for spacing between card elements
  static const double cardElementSpacing =
      8.0; // Renamed from filterChipSpacing, for spacing between card elements
  static const double cardContentSpacing =
      12.0; // Renamed from logoSpacing, for spacing between logo and content
  static const double formFieldSpacing =
      16.0; // For spacing between form fields (PriceManagementScreen, CreateOrderScreen)
  static const double cardMargin =
      16.0; // Renamed from formFieldSpacing, for card outer margin
  static const double screenEdgeSpacing =
      24.0; // For top/bottom spacing in screens (RegisterScreen, LoginScreen)
}
