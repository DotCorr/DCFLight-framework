# Changelog

All notable changes to the DCF Primitives package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2025-01-16

### Added
- **DCFWebView** - Native web content rendering with WKWebView integration
  - Full JavaScript support and modern web standards
  - Proper delegate management and lifecycle handling
  - Customizable navigation controls and loading states
- **DCFAlert** - Native alert dialogs with customizable actions
  - Support for multiple buttons and custom styling
  - Native platform integration (UIAlertController on iOS)
- **DCFModal** - Enhanced modal presentation system
  - Improved backdrop handling and animation
  - Better child component lifecycle management
- **DCFSegmentedControl** - Native segmented control component
  - Icon and text segment support
  - Customizable styling and selection handling
- **DCFSlider** - Native slider component
  - Configurable min/max values and step increments
  - Custom thumb and track styling
- **DCFSpinner** - Native activity indicator component
  - Size and color customization
  - Smooth animations and proper lifecycle management
- **DCFDropdown** - Cross-platform dropdown/picker component
  - Support for custom option rendering
  - Keyboard navigation and accessibility

### Fixed
- **DCFWebView Threading Issues** - Resolved blank/white screen problems
  - Fixed main thread enforcement for UI updates
  - Improved delegate lifecycle management
  - Better error handling for failed web content loading
- **Memory Management** - Enhanced component cleanup and resource management
  - Proper delegate deallocation in native components
  - Reduced memory leaks in complex view hierarchies
- **Component Registration** - Streamlined native component registration system
  - More reliable component initialization
  - Better error handling during component setup

### Removed
- **DCFUrlWrapperView** - Removed due to fundamental reliability issues
  - Touch forwarding conflicts in complex view hierarchies
  - Inconsistent gesture detection behavior
  - **Migration**: Use `DCFGestureDetector` with manual URL opening instead

### Breaking Changes
- **DCFUrlWrapperView** component has been completely removed
  - Replace with `DCFGestureDetector` + `url_launcher` for tap-to-open-URL functionality
  - See updated examples in the template app for migration patterns

### Improved
- Enhanced error handling and validation across all components
- Better component lifecycle management and memory efficiency
- Improved documentation with updated API references and examples
- More consistent API patterns across the primitive set

### Platform Support
- ✅ iOS (UIKit) - Full support with enhanced stability
- 🚧 Android - In development
- 🚧 macOS, Windows, Linux - Planned for future releases

---

## [0.0.1] - 2025-06-16

## [0.0.1] - 2025-06-16

### Added
- Initial pre-release of DCF Primitives component library
- Complete set of cross-platform UI components:
  - **Basic Components**: DCFView, DCFText, DCFImage, DCFIcon, DCFSVG
  - **Input Components**: DCFButton, DCFTextInput, DCFCheckbox, DCFToggle
  - **Layout Components**: DCFScrollView, DCFFlatList, DCFSafeAreaView
  - **Interactive Components**: DCFTouchableOpacity, DCFGestureDetector
  - **Animation Components**: DCFAnimatedView
- Type-safe component APIs with comprehensive prop support
- Adaptive theming system for automatic light/dark mode support
- Native iOS implementation with UIKit components
- Event handling system with type-safe callbacks
- Layout system based on Flexbox/Yoga
- StyleSheet system for component styling
- Built-in icon library with 1000+ icons
- SVG rendering support
- Image caching and loading
- Gesture recognition system

### Features
- Cross-platform component architecture
- React-like development experience in Dart
- Native performance with direct view rendering
- Comprehensive documentation and examples
- MIT license for open source usage

### Platform Support
- ✅ iOS (UIKit) - Basic support
- 🚧 Android - Planned for future releases
- 🚧 macOS, Windows, Linux - Planned for future releases

### Known Issues
- This is a pre-release version intended for early testing
- Android platform implementation is in development
- Some advanced components still in development
- Documentation and examples are being expanded

### Breaking Changes
- None (initial release)

### Migration Guide
- This is the initial release, no migration needed

---

**Note**: DCF Primitives is an early-stage framework. The API may change in future releases as we gather feedback and improve the framework. Use in production at your own discretion.