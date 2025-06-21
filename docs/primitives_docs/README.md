# DCFlight Primitives Documentation

Welcome to the DCFlight Primitives documentation! This guide covers all available primitive components in the `dcf_primitives` package and how to use them effectively.

## 🎯 Overview

DCFlight provides a comprehensive set of primitive components that map directly to native iOS controls, ensuring optimal performance and native user experience. Each primitive is designed to be:

- **Native First**: Direct mapping to UIKit components
- **Performant**: Minimal overhead with native rendering
- **Adaptive**: Automatic light/dark mode support
- **Consistent**: Unified API patterns across all components

## 📚 Available Primitives

### Layout & Container Components

#### DCFView
**Purpose**: Basic container component, equivalent to UIView
- **Use Case**: Layout containers, wrappers, visual grouping
- **Features**: StyleSheet support, background colors, borders, shadows
- **Adaptive**: Automatic background color adaptation

#### DCFModal
**Purpose**: Modal presentation layer for overlays and dialogs
- **Use Case**: Dialogs, popups, full-screen overlays
- **Features**: Smooth animations, proper child management, backdrop handling
- **Recent Improvements**: Enhanced stacking behavior, better child preservation

#### DCFFlatList
**Purpose**: High-performance list rendering for large datasets
- **Use Case**: Large lists, feeds, data tables
- **Features**: Cell recycling, scroll performance optimization
- **Native Mapping**: UITableView/UICollectionView

#### DCFScrollView
**Purpose**: Scrollable container with native scroll performance
- **Use Case**: Scrollable content, custom scroll behaviors
- **Features**: Native scroll performance, gesture handling

### Input Components

#### DCFTextInput
**Purpose**: Text input fields for user data entry
- **Use Case**: Forms, search fields, text areas
- **Features**: 
  - Single-line and multi-line support
  - Placeholder styling with `ColorUtilities`
  - Selection color customization
  - Adaptive theming

#### DCFButton
**Purpose**: Clickable button component
- **Use Case**: Actions, navigation, form submission
- **Features**: Touch feedback, styling support, event handling
- **Adaptive**: System color adaptation

#### DCFCheckbox
**Purpose**: Boolean input with custom styling
- **Use Case**: Forms, settings, multi-selection
- **Features**: Custom colors for checked/unchecked states
- **Color Management**: Uses `ColorUtilities` for consistent theming

#### DCFToggle
**Purpose**: Switch/toggle control for boolean values
- **Use Case**: Settings, feature toggles, preferences
- **Features**: 
  - Track color customization (active/inactive)
  - Thumb color customization  
  - Native UISwitch behavior
- **Color Management**: Unified `ColorUtilities` integration

#### DCFSlider
**Purpose**: Range input control for numeric values
- **Use Case**: Volume controls, brightness, numeric input
- **Features**:
  - Min/max value configuration
  - Track and thumb color customization
  - Value change events (start, change, complete)
- **Color Management**: Uses `ColorUtilities` for theming

#### DCFSegmentedControl (NEW in v0.0.2)
**Purpose**: Multi-option selection control
- **Use Case**: Tab-like selection, filter options, view modes
- **Features**:
  - Text-based segments
  - **Icon support** via `iconAssets` property
  - Mixed content (icon + text fallback)
  - Full color customization
  - Selection change events

#### DCFDropdown
**Purpose**: Dropdown selection component
- **Use Case**: Select lists, option pickers
- **Features**: Native picker integration, placeholder support
- **Adaptive**: System color theming

### Display Components

#### DCFText
**Purpose**: Text rendering with font and styling support
- **Use Case**: Labels, paragraphs, headings
- **Features**:
  - Custom font loading from assets
  - Font weight support (100-900)
  - Color customization with `ColorUtilities`
  - Number of lines control

#### DCFImage
**Purpose**: Image display component
- **Use Case**: Photos, graphics, icons
- **Features**: Content mode control, scaling options
- **Asset Loading**: Proper Flutter asset bundle integration

#### DCFSvg
**Purpose**: SVG vector graphics rendering
- **Use Case**: Icons, scalable graphics, illustrations
- **Features**:
  - Tint color support
  - Adaptive background handling
  - Asset loading from Flutter bundles
- **Color Management**: Uses `ColorUtilities` for tinting

#### DCFIcon
**Purpose**: Icon component for common UI elements
- **Use Case**: Navigation icons, status indicators
- **Features**: System icon integration, custom styling

#### DCFSpinner
**Purpose**: Activity indicator for loading states
- **Use Case**: Loading screens, progress indication
- **Features**:
  - Color customization via `ColorUtilities`
  - Hide when stopped option
  - Adaptive system colors

#### DCFWebView (NEW in v0.0.2)
**Purpose**: Native web content rendering
- **Use Case**: Web pages, HTML content, embedded websites
- **Features**: 
  - WKWebView integration with full JavaScript support
  - Loading state management and error handling
  - Custom headers and user agent support
  - Proper delegate lifecycle management
- **Recent Fixes**: Resolved threading issues and blank screen problems

### Interaction Components

#### DCFTouchableOpacity
**Purpose**: Touchable wrapper with opacity feedback
- **Use Case**: Custom buttons, interactive areas
- **Features**: Touch feedback, opacity animation

#### DCFGestureDetector
**Purpose**: Advanced gesture recognition
- **Use Case**: Swipes, pinches, complex interactions
- **Features**: Multi-gesture support, custom gesture handling

#### DCFAnimatedView
**Purpose**: View with animation capabilities
- **Use Case**: Transitions, animated layouts
- **Features**: Property animations, transition effects

#### DCFAlert
**Purpose**: System alert dialogs
- **Use Case**: Confirmations, notifications, errors
- **Features**: Native alert presentation, action handling

## 🔧 Technical Architecture

### Color Management
All primitives use the centralized `ColorUtilities.color(fromHexString:)` method from the framework layer for consistent color handling across:
- Hex string parsing (#RRGGBB, #AARRGGBB)
- Flutter Color object support
- Named color support
- Transparent color handling

### Asset Loading
Components follow the standard Flutter asset loading pattern:
```swift
let key = sharedFlutterViewController?.lookupKey(forAsset: assetPath)
let mainBundle = Bundle.main
let path = mainBundle.path(forResource: key, ofType: nil)
```

### Adaptive Theming
Most components support automatic light/dark mode adaptation via the `adaptive` property:
- `adaptive: true` (default) - Uses system colors
- `adaptive: false` - Uses explicit colors

## 📖 Adding New Primitives

To add new primitive components to the framework, please refer to the **Module Development Guidelines**:

👉 **[Component Development Guidelines](../module_dev_guidelines/COMPONENT_DEVELOPMENT_GUIDELINES.md)**

👉 **[Component Development Roadmap](../module_dev_guidelines/COMPONENT_DEVELOPMENT_ROADMAP.md)**

These guides provide comprehensive instructions for:
- Creating new primitive components
- Following framework conventions
- Implementing proper asset loading
- Using shared utilities
- Testing and validation
- Documentation standards

## 🚀 Getting Started

1. **Import the primitives package** in your DCFlight project
2. **Use components** in your Dart code via the component API
3. **Style with StyleSheet** for consistent theming
4. **Leverage adaptive properties** for system integration

For detailed API documentation and examples, see the individual component files in:
- **iOS Implementation**: `packages/dcf_primitives/ios/Classes/Components/`
- **Dart API**: `packages/dcf_primitives/lib/src/components/`

## 📝 Recent Updates (v0.0.2)

- ✅ Added DCFSegmentedControl with icon support
- ✅ Removed DCFSwipeableView and DCFAnimatedText (deprecated)
- ✅ Unified color management across all components
- ✅ Enhanced modal behavior and child management
- ✅ Improved asset loading consistency

---

**Questions or need help?** Check the module development guidelines or contribute to the framework by adding new primitives following our established patterns!
