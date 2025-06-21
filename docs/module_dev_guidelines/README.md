# DCFlight Module Development Guidelines

## 📋 **Overview**

This folder contains comprehensive guidelines for developing custom components and modules for the DCFlight framework. These guidelines ensure consistency, performance, and seamless integration with the DCFlight ecosystem.

## 📚 **Documentation**

### **🚀 [Component Development Roadmap](./COMPONENT_DEVELOPMENT_ROADMAP.md)**
Your complete journey from concept to production-ready component:
- Quick start express setup (5 minutes)
- Phase-by-phase development guide
- Success milestones and checklists
- Common pitfalls and solutions
- Pro tips and best practices
- Community resources and support

### **🏗️ [Component Development Guidelines](./COMPONENT_DEVELOPMENT_GUIDELINES.md)**
Complete guide for building DCFlight-compatible components and modules:

#### **Protocol Implementation**
- Required `DCFComponent` protocol implementation
- Optional `ComponentMethodHandler` protocol
- Component registration process with `DCFComponentRegistry`
- Naming conventions and best practices

#### **Event Handling**
- Universal `propagateEvent()` system usage
- Event normalization requirements ("on" prefix convention)
- Event data structure standards
- Performance optimization techniques

#### **Adaptive Theming**
- Mandatory `adaptive` flag implementation
- System color usage for light/dark mode compatibility
- StyleSheet integration patterns
- Compliance requirements and testing

#### **Props and Performance**
- Component-specific props handling
- StyleSheet application order
- Memory management and cleanup
- Error handling and validation

### **🎭 [Presentable Components Guide](./PRESENTABLE_COMPONENTS_GUIDE.md)**
Specialized guide for implementing components that present outside the normal view hierarchy:

#### **Core Patterns**
- Placeholder view pattern for anchoring
- Visibility management with proper display handling
- Child management between placeholder and presented states
- Content layout with full abstraction layer control

#### **Implementation Examples**
- Modal components (sheets, full-screen)
- Popover components (tooltips, dropdowns)
- Alert components (system alerts, custom dialogs)
- Bottom sheet components
- Custom overlay components

#### **DRY Compliance**
- Consistent patterns across all presentable types
- Proper event propagation (onShow, onDismiss)
- Memory management and tracking
- Platform-specific optimizations

## 🎯 **Quick Start for Module Developers**

### **1. Component Implementation Template**

```swift
import UIKit
import dcflight

class YourCustomComponent: NSObject, DCFComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        let view = YourCustomView()
        
        // ✅ REQUIRED: Implement adaptive theming
        let isAdaptive = props["adaptive"] as? Bool ?? true
        if isAdaptive {
            if #available(iOS 13.0, *) {
                view.backgroundColor = UIColor.systemBackground
            } else {
                view.backgroundColor = UIColor.white
            }
        } else {
            view.backgroundColor = UIColor.clear
        }
        
        updateView(view, withProps: props)
        return view
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Handle component-specific props
        
        // ✅ REQUIRED: Apply StyleSheet properties last
        view.applyStyles(props: props)
        return true
    }
}
```

### **2. Event Handling Template**

```swift
@objc func handleCustomAction(_ sender: UIView) {
    // ✅ REQUIRED: Use propagateEvent() with "on" prefix
    propagateEvent(on: sender, eventName: "onCustomAction", data: [
        "timestamp": Date().timeIntervalSince1970,
        "customData": "your_data_here"
    ])
}
```

### **3. Module Registration Template**

```swift
@objc public class YourModule: NSObject {
    @objc public static func registerWithRegistrar(_ registrar: FlutterPluginRegistrar) {
        registerComponents()
    }
    
    @objc public static func registerComponents() {
        DCFComponentRegistry.shared.registerComponent("YourComponent", componentClass: YourCustomComponent.self)
        NSLog("✅ YourModule: Components registered successfully")
    }
}
```

## ✅ **Compliance Checklist**

Before submitting your module, ensure:

### **Component Protocol Compliance**
- [ ] Implements `DCFComponent` protocol correctly
- [ ] Uses proper component registration
- [ ] Follows naming conventions

### **Event System Compliance**
- [ ] Uses `propagateEvent()` for all events
- [ ] All event names start with "on" prefix
- [ ] Includes proper event data structure

### **Adaptive Theming Compliance**
- [ ] Implements `adaptive` flag support
- [ ] Uses system colors for adaptive components
- [ ] Provides iOS < 13.0 fallbacks

### **Integration Compliance**
- [ ] Calls `view.applyStyles(props: props)` for StyleSheet integration
- [ ] Handles component-specific props before StyleSheet application
- [ ] Includes proper error handling and validation

## 🚀 **Development Workflow**

### **1. Setup**
1. Create your component class implementing `DCFComponent`
2. Set up module registration file
3. Configure build system integration

### **2. Implementation**
1. Implement `createView()` with adaptive theming
2. Implement `updateView()` with props handling
3. Add event handlers using `propagateEvent()`
4. Test component functionality

### **3. Testing**
1. Test adaptive theming in light/dark modes
2. Verify event handling works correctly
3. Test props integration and StyleSheet application
4. Validate component registration

### **4. Documentation**
1. Document component props and events
2. Provide usage examples
3. Include testing instructions
4. Create migration guide if applicable

## 🛡️ **Non-Compliance Consequences**

Failure to follow these guidelines results in:
- ❌ Module merge request rejection
- ❌ Framework inconsistencies
- ❌ Poor user experience
- ❌ Performance issues
- ❌ Ecosystem fragmentation

## 🎯 **Success Benefits**

Following these guidelines ensures:
- ✅ Seamless framework integration
- ✅ Consistent theming and events
- ✅ High performance components
- ✅ Easy maintenance and updates
- ✅ Community adoption and support

## 🔗 **Related Documentation**

### **Architecture**
- [`/docs/architecture/`](../architecture/) - Core framework architecture
- Event lifecycle and normalization systems
- Adaptive theming system requirements

### **Component Guidelines**
- [`/docs/components/`](../components/) - Component-specific guidelines
- Props handling patterns and performance tips
- StyleSheet integration best practices

### **Styling System**
- [`/docs/styling/`](../styling/) - Complete styling documentation
- Color system and theming guidelines
- Adaptive design principles

### **Testing**
- [`/docs/testing/`](../testing/) - Testing guidelines and tools
- Component testing patterns
- Performance testing requirements

## 📞 **Support**

### **Development Questions**
1. Check the component development guidelines
2. Review architecture documentation
3. Examine existing component examples
4. Consult styling system documentation

### **Implementation Examples**
- See `/packages/dcf_primitives/ios/Classes/Components/` for reference implementations
- Review primitive components for best practices
- Check event handling patterns in existing components

This module development documentation ensures that all DCFlight modules maintain the framework's high standards of quality, consistency, and performance.
