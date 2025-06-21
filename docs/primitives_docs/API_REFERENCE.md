# DCFlight Primitives - Component API Reference

This document provides detailed API information for each primitive component in the DCFlight framework.

## � Adaptive Theming

All DCFlight primitives support adaptive theming through the `adaptive` property. When set to `true` (default), components automatically adapt their appearance based on the current system theme (light/dark mode).

```dart
// Enable adaptive theming (default)
DCFText("Hello", textProps: DCFTextProps(adaptive: true))

// Disable adaptive theming
DCFText("Hello", textProps: DCFTextProps(adaptive: false, color: Colors.red))
```

## �🎛️ Input Components

### DCFTextInput
**Native Mapping**: UITextField / UITextView

#### Properties
```dart
DCFTextInput({
  String? value,                    // Current text value
  String? defaultValue,             // Default text value
  String? placeholder,              // Placeholder text
  Color? placeholderTextColor,      // Placeholder text color
  DCFTextInputType inputType,       // Input type (text, email, etc.)
  DCFKeyboardType keyboardType,     // Keyboard type
  bool multiline = false,           // Single vs multi-line input
  int? numberOfLines,               // Number of lines
  bool secureTextEntry = false,     // Password field
  Color? textColor,                 // Text color
  Color? selectionColor,            // Cursor/selection color
  bool editable = true,             // Input enabled state
  bool adaptive = true,             // Use adaptive theming
  Function(String)? onChangeText,   // Text change callback
  Function(Map)? onSubmitEditing,   // Submit callback
  Function(Map)? onFocus,           // Focus callback
  Function(Map)? onBlur,            // Blur callback
})
```

#### Example Usage
```dart
DCFTextInput(
  placeholder: "Enter your name",
  placeholderTextColor: Colors.grey,
  textColor: Colors.black,
  adaptive: true,  // Automatically adapts to system theme
  onChangeText: (value) => print("Text: $value"),
)
```

### DCFToggle
**Native Mapping**: UISwitch

#### Properties
```dart
DCFToggle({
  bool value = false,               // Current switch state
  Color? activeTrackColor,          // Track color when ON
  Color? inactiveTrackColor,        // Track color when OFF
  Color? activeThumbColor,          // Thumb color when ON
  Color? inactiveThumbColor,        // Thumb color when OFF
  bool enabled = true,              // Switch enabled state
  bool adaptive = true,             // Use adaptive theming
  Function(bool)? onValueChanged,   // Value change callback
})
```

### DCFCheckbox
**Native Mapping**: Custom UIView

#### Properties
```dart
DCFCheckbox({
  bool checked = false,             // Current checked state
  Color? checkedColor,              // Color when checked
  Color? uncheckedColor,            // Color when unchecked
  Color? checkmarkColor,            // Checkmark color
  double size = 24.0,               // Checkbox size
  bool enabled = true,              // Checkbox enabled state
  bool adaptive = true,             // Use adaptive theming
  Function(bool)? onChanged,        // State change callback
})
```

### DCFSlider
**Native Mapping**: UISlider

#### Properties
```dart
DCFSlider({
  double value = 0.0,               // Current slider value
  double minimumValue = 0.0,        // Minimum value
  double maximumValue = 1.0,        // Maximum value
  double? step,                     // Step increment
  Color? minimumTrackTintColor,     // Left track color
  Color? maximumTrackTintColor,     // Right track color
  Color? thumbTintColor,            // Thumb color
  bool disabled = false,            // Disabled state
  bool adaptive = true,             // Use adaptive theming
  Function(double)? onValueChanged, // Value change callback
  Function(double)? onSlidingStart, // Slide start callback
  Function(double)? onSlidingComplete, // Slide end callback
})
```

### DCFSegmentedControl ⭐ NEW
**Native Mapping**: UISegmentedControl

#### Properties
```dart
DCFSegmentedControl({
  List<String> segments = const ['Segment 1'], // Segment titles
  List<String>? iconAssets,         // Optional icon assets for each segment
  int selectedIndex = 0,            // Currently selected index
  bool enabled = true,              // Control enabled state
  Color? backgroundColor,           // Background color
  Color? selectedTintColor,         // Selected segment color (iOS 13+)
  Color? tintColor,                 // Text color for selected segment
  bool adaptive = true,             // Use adaptive theming
  Function(Map<dynamic, dynamic>)? onSelectionChange, // Selection callback
})
```

#### Example with Icons
```dart
DCFSegmentedControl(
  segments: ['Home', 'Search', 'Profile'],
  iconAssets: ['assets/icons/home.svg', 'assets/icons/search.svg', 'assets/icons/profile.svg'],
  selectedIndex: 0,
  backgroundColor: Color(0xFFF0F0F0),
  selectedTintColor: Color(0xFF007AFF),
  adaptive: true,  // Adapts to system theme
  onSelectionChange: (data) {
    print("Selected: ${data['selectedIndex']} - ${data['selectedTitle']}");
  },
)
```

### DCFDropdown
**Native Mapping**: UIButton + UIPickerView

#### Properties
```dart
DCFDropdown({
  List<String> options = const [],  // Dropdown options
  String? selectedValue,            // Currently selected value
  String? placeholder,              // Placeholder text
  String? placeholderColor,         // Placeholder color (hex)
  bool visible = false,             // Dropdown visibility
  Function(String)? onChanged,      // Selection change callback
})
```

## 🎨 Display Components

### DCFText
**Native Mapping**: UILabel

#### Properties
```dart
DCFText({
  String content = '',              // Text content
  DCFTextProps textProps,           // Text properties
})

// DCFTextProps
DCFTextProps({
  String? fontFamily,               // Font family name
  bool isFontAsset = false,         // Load font from assets
  double? fontSize,                 // Font size
  String? fontWeight,               // Font weight (100-900, bold, normal)
  Color? color,                     // Text color
  int? numberOfLines,               // Max lines (0 = unlimited)
  String? textAlign,                // Text alignment
  bool adaptive = true,             // Use adaptive theming
})
```

#### Example with Custom Font and Adaptive Theming
```dart
DCFText(
  content: "Adaptive Text",
  textProps: DCFTextProps(
    fontFamily: "assets/fonts/custom-font.ttf",
    isFontAsset: true,
    fontSize: 18,
    fontWeight: "600",
    adaptive: true,  // Auto-adapts color to system theme
  ),
)
```

### DCFImage
**Native Mapping**: UIImageView

#### Properties
```dart
DCFImage({
  String? asset,                    // Image asset path
  String? backgroundColor,          // Background color (hex)
  ContentMode contentMode = ContentMode.scaleAspectFit, // Scaling mode
})
```

### DCFSVG
**Native Mapping**: UIImageView

#### Properties
```dart
DCFSVG({
  DCFSVGProps svgProps,             // SVG properties
})

// DCFSVGProps
DCFSVGProps({
  String source,                    // SVG asset path or URL
  bool isAsset = false,             // Whether source is an asset
  double? width,                    // SVG width
  double? height,                   // SVG height
  bool adaptive = true,             // Use adaptive theming for colors
})
```

#### Example with Adaptive Theming
```dart
DCFSVG(
  svgProps: DCFSVGProps(
    source: "assets/icons/star.svg",
    isAsset: true,
    width: 24,
    height: 24,
    adaptive: true,  // SVG colors adapt to system theme
  ),
)
```

### DCFSpinner
**Native Mapping**: UIActivityIndicatorView

#### Properties
```dart
DCFSpinner({
  bool animating = true,            // Animation state
  Color? color,                     // Spinner color
  bool hidesWhenStopped = true,     // Hide when not animating
  bool adaptive = true,             // Use adaptive theming
})
```

### DCFIcon
**Native Mapping**: UIImageView

#### Properties
```dart
DCFIcon({
  String? iconName,                 // System icon name
  String? color,                    // Icon color (hex)
  double? size,                     // Icon size
})
```

## 📦 Container Components

### DCFView
**Native Mapping**: UIView

#### Properties
```dart
DCFView({
  String? backgroundColor,          // Background color (hex)
  bool adaptive = true,             // Adaptive theming
  List<Widget> children = const [], // Child components
})
```

### DCFModal
**Native Mapping**: Custom modal presentation

#### Properties
```dart
DCFModal({
  bool visible = false,             // Modal visibility
  String? backgroundColor,          // Background color (hex)
  bool dismissOnBackdropTap = true, // Dismiss on backdrop tap
  Function()? onDismiss,           // Dismiss callback
  List<Widget> children = const [], // Modal content
})
```

### DCFFlatList
**Native Mapping**: UITableView

#### Properties
```dart
DCFFlatList({
  List<dynamic> data = const [],    // Data source
  Widget Function(dynamic item, int index)? itemBuilder, // Item builder
  double? itemHeight,               // Fixed item height
  bool scrollEnabled = true,        // Scroll enabled
  Function(int)? onItemTap,        // Item tap callback
})
```

## 🤝 Interaction Components

### DCFTouchableOpacity
**Native Mapping**: UIButton (custom)

#### Properties
```dart
DCFTouchableOpacity({
  double activeOpacity = 0.6,       // Opacity when pressed
  Function()? onPressed,            // Press callback
  List<Widget> children = const [], // Child components
})
```

### DCFGestureDetector
**Native Mapping**: UIGestureRecognizer

#### Properties
```dart
DCFGestureDetector({
  Function()? onTap,                // Tap callback
  Function()? onDoubleTap,          // Double tap callback
  Function(DragDetails)? onPanStart, // Pan start callback
  Function(DragDetails)? onPanUpdate, // Pan update callback
  Function(DragDetails)? onPanEnd,   // Pan end callback
  List<Widget> children = const [], // Child components
})
```

### DCFAnimatedView
**Native Mapping**: UIView + Core Animation

#### Properties
```dart
DCFAnimatedView({
  Duration duration = const Duration(milliseconds: 300), // Animation duration
  Curve curve = Curves.easeInOut,   // Animation curve
  String? backgroundColor,          // Background color (hex)
  double? opacity,                  // View opacity
  List<Widget> children = const [], // Child components
})
```

### DCFAlert
**Native Mapping**: UIAlertController

#### Properties
```dart
DCFAlert({
  bool visible = false,             // Alert visibility
  String? title,                    // Alert title
  String? message,                  // Alert message
  DCFAlertStyle style = DCFAlertStyle.alert, // Alert vs action sheet style
  List<DCFAlertTextField>? textFields, // Input fields
  List<DCFAlertAction>? actions,    // Alert actions
  bool dismissible = true,          // Can dismiss by tapping outside
  bool adaptive = true,             // Use adaptive theming
  Function(Map)? onShow,           // Alert shown callback
  Function(Map)? onDismiss,        // Alert dismissed callback
  Function(Map)? onActionPress,    // Action pressed callback
  Function(Map)? onTextFieldChange, // Text field change callback
})
```

### DCFWebView ⭐ NEW
**Native Mapping**: WKWebView

#### Properties
```dart
DCFWebView({
  String? url,                      // URL to load
  String? htmlString,               // HTML content to render
  Map<String, String>? headers,     // HTTP headers
  bool javaScriptEnabled = true,    // Enable JavaScript
  bool domStorageEnabled = true,    // Enable DOM storage
  bool allowsInlineMediaPlayback = true, // Allow inline media
  bool mediaPlaybackRequiresUserAction = false, // Autoplay policy
  String? userAgent,                // Custom user agent
  Color? backgroundColor,           // Background color
  bool adaptive = true,             // Use adaptive theming
  Function(Map)? onLoadStart,       // Load started callback
  Function(Map)? onLoadEnd,         // Load finished callback
  Function(Map)? onLoadError,       // Load error callback
  Function(Map)? onProgress,        // Loading progress callback
  Function(Map)? onNavigationStateChange, // Navigation state callback
})
```

#### Example Usage
```dart
DCFWebView(
  url: "https://flutter.dev",
  javaScriptEnabled: true,
  headers: {"Authorization": "Bearer token"},
  onLoadEnd: (data) => print("Loaded: ${data['url']}"),
  onLoadError: (error) => print("Error: ${error['description']}"),
)
```

#### Static Helper Methods
```dart
// Simple alert with OK button
DCFAlert.simple(
  title: "Success",
  message: "Operation completed",
  adaptive: true,
)

// Text input alert
DCFAlert.textInput(
  title: "Enter Name",
  placeholder: "Your name",
  confirmText: "Save",
  adaptive: true,
  onConfirm: (text) => print("Name: $text"),
)

// Login alert with username/password
DCFAlert.login(
  title: "Login Required",
  adaptive: true,
  onLogin: (username, password) => print("Login: $username"),
)

// Confirmation alert
DCFAlert.confirmation(
  title: "Confirm Action",
  message: "Are you sure?",
  adaptive: true,
  onConfirm: (_) => print("Confirmed"),
)

// Destructive action alert
DCFAlert.destructive(
  title: "Delete Item",
  message: "This cannot be undone",
  destructiveText: "Delete",
  adaptive: true,
  onDestructive: (_) => print("Deleted"),
)
```

## 🎯 Common Patterns

### Color Management
All components use the centralized `ColorUtilities` for color conversion:
```dart
// All color properties accept hex strings
color: "#FF5733"        // RGB
color: "#80FF5733"      // ARGB with alpha
color: "transparent"    // Named colors
color: "red"           // System colors
```

### Asset Loading
Assets are loaded using Flutter's asset system:
```dart
// For images and SVGs
asset: "assets/images/logo.png"
asset: "assets/icons/star.svg"

// For fonts
fontFamily: "assets/fonts/custom-font.ttf"
isFontAsset: true
```

### Adaptive Theming
Most components support automatic theme adaptation:
```dart
adaptive: true  // Uses system colors (default)
adaptive: false // Uses explicit colors only
```

---

**Need more details?** Check the implementation files in `packages/dcf_primitives/` for complete API specifications and native implementation details.
