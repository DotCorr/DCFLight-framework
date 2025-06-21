# DCFlight Primitives Documentation Index

📚 **Complete guide to DCFlight primitive components and development**

## 📖 Documentation Structure

### 🚀 Getting Started
- **[Main Primitives Guide](./README.md)** - Overview of all available primitives and their purposes
- **[API Reference](./API_REFERENCE.md)** - Detailed API documentation for each component

### 🛠️ Development Resources
- **[Component Development Guidelines](../module_dev_guidelines/COMPONENT_DEVELOPMENT_GUIDELINES.md)** - How to create new primitives
- **[Component Development Roadmap](../module_dev_guidelines/COMPONENT_DEVELOPMENT_ROADMAP.md)** - Framework development roadmap
- **[Presentable Components Guide](../module_dev_guidelines/PRESENTABLE_COMPONENTS_GUIDE.md)** - UI component best practices

## 🎯 Quick Navigation

### By Use Case
- **Layout**: DCFView, DCFModal, DCFFlatList, DCFScrollView, DCFSafeAreaView
- **Input**: DCFTextInput, DCFButton, DCFToggle, DCFCheckbox, DCFSlider, DCFSegmentedControl, DCFDropdown
- **Display**: DCFText, DCFImage, DCFSvg, DCFIcon, DCFSpinner, DCFWebView
- **Interaction**: DCFTouchableOpacity, DCFGestureDetector, DCFAnimatedView, DCFAlert

### By Complexity
- **Basic**: DCFView, DCFText, DCFButton, DCFImage, DCFIcon
- **Intermediate**: DCFTextInput, DCFToggle, DCFCheckbox, DCFSlider, DCFDropdown, DCFSpinner
- **Advanced**: DCFModal, DCFFlatList, DCFSegmentedControl, DCFGestureDetector, DCFWebView, DCFAlert

## 🆕 What's New in v0.0.2

### ✅ Added
- **DCFWebView** - Native web content rendering with full JavaScript support
- **DCFAlert** - Native alert dialogs with customizable buttons and actions
- **DCFModal** - Enhanced modal behavior with proper backdrop and lifecycle management
- **DCFSegmentedControl** - Native segmented control with icon and text support
- **DCFSlider** - Native slider with customizable range and step values
- **DCFSpinner** - Native activity indicators with size and color customization
- **DCFDropdown** - Cross-platform dropdown/picker component
- Improved component lifecycle management and memory handling
- Enhanced error handling and validation across all components

### 🔧 Improved
- **DCFWebView** - Fixed threading issues and delegate management for reliable web content loading
- **Component Registration** - Streamlined native component registration system
- **Memory Management** - Better component cleanup and resource management
- **Error Handling** - More robust error handling across all native components
- **Documentation** - Updated API documentation and examples

### ❌ Removed
- **DCFUrlWrapperView** - Removed due to reliability issues with touch forwarding and gesture detection
  - **Migration**: Use `DCFGestureDetector` with manual URL opening for tap-to-open-URL functionality

### 🐛 Fixed
- DCFWebView blank/white screen issue resolved
- Threading issues in native component lifecycle
- Memory leaks in component delegation
- Gesture detection conflicts in complex view hierarchies

## 🚀 Adding New Primitives

**Want to contribute new primitive components to DCFlight?**

👉 **Start here**: [Component Development Guidelines](../module_dev_guidelines/COMPONENT_DEVELOPMENT_GUIDELINES.md)

This comprehensive guide covers:
- Framework architecture and patterns
- Step-by-step component creation
- Testing and validation procedures
- Documentation requirements
- Contribution workflow

### Quick Links for Contributors
1. **[Development Guidelines](../module_dev_guidelines/COMPONENT_DEVELOPMENT_GUIDELINES.md)** - Complete development process
2. **[Roadmap](../module_dev_guidelines/COMPONENT_DEVELOPMENT_ROADMAP.md)** - Planned features and priorities
3. **[StyleSheet Reference](../module_dev_guidelines/STYLESHEET_REFERENCE.md)** - Styling system documentation

## 📋 Component Checklist

When working with DCFlight primitives, ensure:

- [ ] **Proper Import**: Import from `dcf_primitives` package
- [ ] **Color Format**: Use hex strings (#RRGGBB or #AARRGGBB)
- [ ] **Asset Paths**: Use Flutter asset path format
- [ ] **Adaptive Theming**: Consider `adaptive: true` for system integration
- [ ] **Event Handling**: Implement proper callback functions
- [ ] **StyleSheet**: Use StyleSheet for consistent styling

## 🔍 Finding Components

### By Native iOS Equivalent
- **UIView** → DCFView
- **UILabel** → DCFText  
- **UITextField/UITextView** → DCFTextInput
- **UIButton** → DCFButton, DCFTouchableOpacity
- **UISwitch** → DCFToggle
- **UISlider** → DCFSlider
- **UISegmentedControl** → DCFSegmentedControl
- **UIImageView** → DCFImage, DCFSvg, DCFIcon
- **UIActivityIndicatorView** → DCFSpinner
- **UITableView** → DCFFlatList
- **UIScrollView** → DCFScrollView
- **UIWebView/WKWebView** → DCFWebView
- **Modal Presentation** → DCFModal
- **UIAlertController** → DCFAlert

### By Flutter Widget Equivalent
- **Container** → DCFView
- **Text** → DCFText
- **TextField** → DCFTextInput
- **ElevatedButton** → DCFButton
- **Switch** → DCFToggle
- **Slider** → DCFSlider
- **Image** → DCFImage
- **CircularProgressIndicator** → DCFSpinner
- **ListView** → DCFFlatList
- **GestureDetector** → DCFGestureDetector
- **WebView** → DCFWebView

## 📞 Support & Community

- **Issues**: Report bugs and request features via the project repository
- **Contributions**: Follow the development guidelines for contributing new primitives
- **Documentation**: Help improve these docs by suggesting clarifications

---

**Ready to build amazing native experiences with DCFlight primitives!** 🚀
