# Presentable Components Development Guide

## Overview

Presentable components are UI elements that appear above or overlay the normal app content, such as modals, popovers, tooltips, and action sheets. This guide establishes patterns and best practices for implementing these components in the DCFlight framework.

## Core Principles

### 1. Full Abstraction Layer Control
- **No Default Spacing**: Native components should NOT add automatic margins, padding, or safe area constraints
- **Raw Canvas**: Provide the full available space to the abstraction layer (Dart) for layout control
- **User Intent**: Only apply spacing/margins when explicitly requested via props

### 2. Visibility State Management
- **Complete Hiding**: When `visible: false`, the component and its children must be completely hidden
- **Layout Removal**: Hidden components should not participate in layout calculations or event handling
- **Display Property**: Use `'display': visible ? 'flex' : 'none'` in Dart to control visibility

### 3. DRY (Don't Repeat Yourself) Implementation
- **Reusable Patterns**: Common presentation logic should be abstracted into reusable components
- **Consistent Behavior**: All presentable components should follow the same visibility and layout patterns

## Implementation Patterns

### Dart Side (Abstraction Layer)

```dart
// Example modal component structure
class DCFModal extends DCFWidget {
  const DCFModal({
    Key? key,
    required this.visible,
    this.cornerRadius = 16.0,
    this.children = const [],
    // ... other props
  }) : super(key: key);

  @override
  Map<String, dynamic> getProps() {
    return {
      // ✅ CRITICAL: Display property controls visibility
      'display': visible ? 'flex' : 'none',
      'visible': visible,
      'cornerRadius': cornerRadius,
      // ✅ No automatic margins/padding - user controls layout
    };
  }
}
```

### Native Side (iOS Swift)

#### Component Structure

```swift
class DCFPresentableComponent: NSObject, DCFComponent {
    // Track presented instances
    static var presentedInstances: [String: PresentableViewController] = [:]
    
    func createView(props: [String: Any]) -> UIView {
        // Create hidden placeholder view
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = false
        
        updateView(view, withProps: props)
        return view
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        let viewId = String(view.hash)
        let isVisible = extractVisibility(from: props)
        
        if isVisible {
            presentOverlay(from: view, props: props, viewId: viewId)
        } else {
            dismissOverlay(from: view, viewId: viewId)
        }
        
        return true
    }
}
```

#### Content Layout Rules

```swift
private func layoutContent(in overlayVC: UIViewController, children: [UIView]) {
    // ✅ RULE 1: Give FULL modal space to abstraction layer
    let contentFrame = overlayVC.view.bounds // NO safe area reduction
    
    if children.count == 1, let child = children.first {
        // Single child fills entire space
        child.frame = contentFrame
        child.translatesAutoresizingMaskIntoConstraints = true
        
        // Make visible (opposite of placeholder state)
        child.isHidden = false
        child.alpha = 1.0
    }
    
    // ✅ RULE 2: Force layout updates for Yoga
    child.setNeedsLayout()
    child.layoutIfNeeded()
}
```

#### Visibility Management

```swift
func setChildren(_ view: UIView, childViews: [UIView], viewId: String) -> Bool {
    // Store children in placeholder (hidden from main UI)
    view.subviews.forEach { $0.removeFromSuperview() }
    childViews.forEach { childView in
        view.addSubview(childView)
        // ✅ Hide in placeholder view
        childView.isHidden = true
        childView.alpha = 0.0
    }
    
    // If overlay is presented, move children and make visible
    if let overlayVC = Self.presentedInstances[viewId] {
        moveChildrenToOverlay(overlayVC: overlayVC, children: childViews)
    }
    
    return true
}
```

#### Property Handling

```swift
private func extractCornerRadius(from props: [String: Any]) -> CGFloat {
    var cornerRadius: CGFloat = 16.0 // Default
    
    if let radius = props["cornerRadius"] as? CGFloat {
        cornerRadius = radius
    } else if let radius = props["cornerRadius"] as? Double {
        cornerRadius = CGFloat(radius)
    } else if let radius = props["cornerRadius"] as? Int {
        cornerRadius = CGFloat(radius)
    } else if let radius = props["cornerRadius"] as? NSNumber {
        cornerRadius = CGFloat(radius.doubleValue)
    }
    
    return cornerRadius
}
```

## Specific Component Types

### Modals

**Key Requirements:**
- Sheet presentations must respect `cornerRadius` prop via `preferredCornerRadius`
- Full-screen presentations use layer corner radius
- No automatic safe area margins - let abstraction layer control spacing

**Example Implementation:**
```swift
// Sheet configuration
if #available(iOS 16.0, *), let sheet = modalVC.sheetPresentationController {
    let cornerRadius = extractCornerRadius(from: props)
    sheet.preferredCornerRadius = cornerRadius
}

// Also apply to view layer for non-sheet presentations
modalVC.view.layer.cornerRadius = cornerRadius
modalVC.view.layer.masksToBounds = true
```

### Popovers

**Key Requirements:**
- Position relative to source view or coordinates
- Respect arrow direction preferences
- Handle dismissal on outside tap

**Example Implementation:**
```swift
if let popoverController = alertController.popoverPresentationController {
    popoverController.sourceView = sourceView
    popoverController.sourceRect = sourceRect
    popoverController.permittedArrowDirections = arrowDirections
}
```

### Tooltips

**Key Requirements:**
- Lightweight presentation without dimming background
- Auto-dismissal after timeout
- Position calculation to stay within screen bounds

### Action Sheets

**Key Requirements:**
- Bottom presentation on phones, popover on tablets
- Support for custom actions and styling
- Proper iPad adaptation

## Common Patterns

### State Synchronization

```swift
// Always sync children between placeholder and presented view
private func syncChildrenState(from placeholder: UIView, to presented: UIViewController) {
    let children = placeholder.subviews
    
    // Clear existing content
    presented.view.subviews.forEach { $0.removeFromSuperview() }
    
    // Move and show children
    children.forEach { child in
        child.removeFromSuperview()
        presented.view.addSubview(child)
        child.isHidden = false
        child.alpha = 1.0
    }
}
```

### Dismissal Handling

```swift
// Handle both programmatic and user-initiated dismissal
func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    moveChildrenBackToPlaceholder()
    removeFromTracking()
    propagateEvent(on: sourceView, eventName: "onDismiss", data: [:])
}
```

## Testing Guidelines

### Unit Tests
- Test visibility state changes
- Verify children movement between placeholder and presented views
- Check property application (corner radius, dimensions, etc.)

### Integration Tests
- Test with various content types and sizes
- Verify behavior on different device orientations
- Test dismissal scenarios (user swipe, programmatic, etc.)

### Manual Testing Checklist
- [ ] Component completely hidden when `visible: false`
- [ ] Children fill available space when using flex/100% sizing
- [ ] Corner radius applied correctly for all presentation styles
- [ ] No unwanted margins/padding unless explicitly set
- [ ] Smooth animations during show/hide transitions
- [ ] Proper cleanup when component is unmounted

## Best Practices

### Performance
- Reuse view controllers when possible
- Avoid creating heavy content until actually needed
- Clean up references to prevent memory leaks

### Accessibility
- Ensure proper focus management when presentable appears
- Support VoiceOver navigation within presented content
- Handle dismiss gestures appropriately

### Platform Consistency
- Follow platform-specific presentation patterns
- Adapt layouts for different screen sizes and orientations
- Respect user accessibility settings

## Common Pitfalls

### ❌ Wrong: Automatic Safe Area Application
```swift
// Don't do this - forces unwanted margins
let safeArea = view.safeAreaInsets
contentFrame = view.bounds.inset(by: safeArea)
```

### ✅ Correct: Full Space to Abstraction Layer
```swift
// Do this - let Dart control spacing
let contentFrame = view.bounds
child.frame = contentFrame
```

### ❌ Wrong: Ignoring Display Property
```swift
// Don't do this - overrides visibility control
view.isHidden = false // Hardcoded visibility
```

### ✅ Correct: Respecting Display Property
```swift
// Do this - honor abstraction layer visibility
let isVisible = extractVisibility(from: props)
if isVisible { present() } else { dismiss() }
```

### ❌ Wrong: Inconsistent Corner Radius
```swift
// Don't do this - only applies to one presentation style
view.layer.cornerRadius = radius
```

### ✅ Correct: Comprehensive Corner Radius
```swift
// Do this - applies to all presentation styles
view.layer.cornerRadius = radius
if let sheet = sheetController {
    sheet.preferredCornerRadius = radius
}
```

## Legacy Pattern Reference

### The Placeholder View Pattern (Original DCFlight Pattern)

All presentable components use a "placeholder view" that acts as an anchor in the main UI while the actual content is presented elsewhere.

### Original Placeholder View Implementation

```swift
func createView(props: [String: Any]) -> UIView {
    // Create a simple placeholder view
    let view = UIView()
    
    // Set the view as hidden but don't override its geometry
    view.isHidden = true
    view.backgroundColor = UIColor.clear
    view.isUserInteractionEnabled = false
    
    let _ = updateView(view, withProps: props)
    return view
}
```

**Key Points:**
- Placeholder is hidden from main UI (`isHidden = true`)
- Clear background and no user interaction
- Serves as container for children when not presented

### Original Visibility Management Pattern

Handle visibility state with proper type checking:

```swift
func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
    // Check if component should be visible (handle multiple types)
    var isVisible = false
    if let visible = props["visible"] as? Bool {
        isVisible = visible
    } else if let visible = props["visible"] as? Int {
        isVisible = visible == 1
    } else if let visible = props["visible"] as? NSNumber {
        isVisible = visible.boolValue
    }
    
    if isVisible {
        presentContent(from: view, props: props)
    } else {
        dismissContent(from: view)
    }
    
    return true
}
```

## Conclusion

Following these guidelines ensures that presentable components provide maximum flexibility to the abstraction layer while maintaining consistent behavior across the framework. The key is to provide a "raw canvas" approach where the native layer handles presentation mechanics, but the abstraction layer retains full control over content layout and spacing.
    } else {
        dismissContent(from: view)
    }
    
    view.applyStyles(props: props)
    return true
}
```

### 3. **Child Management Pattern**

Implement proper child storage and movement:

```swift
func setChildren(_ view: UIView, childViews: [UIView], viewId: String) -> Bool {
    // Store children in placeholder but keep them hidden from main UI
    view.subviews.forEach { $0.removeFromSuperview() }
    childViews.forEach { childView in
        view.addSubview(childView)
        // Hide children in placeholder view (they'll be shown when moved to presented content)
        childView.isHidden = true
        childView.alpha = 0.0
    }
    
    // If content is currently presented, move children to presented view
    if let presentedView = getCurrentPresentedView(for: viewId) {
        addChildrenToPresentedContent(presentedView: presentedView, childViews: childViews)
    }
    
    return true
}
```

### 4. **Content Layout Pattern**

Give full control to the abstraction layer:

```swift
private func addChildrenToPresentedContent(presentedView: UIView, childViews: [UIView]) {
    // Clear existing content children
    presentedView.subviews.forEach { subview in
        // Don't remove system views (keep platform chrome)
        if subview.tag != 999 && subview.tag != 998 {
            subview.removeFromSuperview()
        }
    }
    
    let availableFrame = presentedView.bounds
    
    if childViews.count == 1, let childView = childViews.first {
        // Single child gets full space
        childView.removeFromSuperview()
        childView.translatesAutoresizingMaskIntoConstraints = true
        presentedView.addSubview(childView)
        
        // Make visible and give full frame
        childView.isHidden = false
        childView.alpha = 1.0
        childView.frame = CGRect(
            x: 0, y: 0,
            width: availableFrame.width,
            height: availableFrame.height
        )
    } else {
        // Multiple children - stack or arrange as appropriate
        layoutMultipleChildren(childViews, in: presentedView, availableFrame: availableFrame)
    }
}
```

## Implementation Examples

### Modal Component Pattern

```swift
class DCFModalComponent: NSObject, DCFComponent {
    static var presentedModals: [String: DCFModalViewController] = [:]
    
    // ... standard createView, updateView, setChildren methods ...
    
    private func presentModal(from view: UIView, props: [String: Any], viewId: String) {
        let modalVC = DCFModalViewController()
        modalVC.modalProps = props
        modalVC.sourceView = view
        modalVC.viewId = viewId
        
        // Configure modal presentation style
        configureModalPresentation(modalVC, props: props)
        
        // Store reference before presenting
        DCFModalComponent.presentedModals[viewId] = modalVC
        
        // Present modal
        if let topViewController = getTopViewController() {
            topViewController.present(modalVC, animated: true) {
                propagateEvent(on: view, eventName: "onShow", data: [:])
            }
        }
    }
}
```

### Popover Component Pattern

```swift
class DCFPopoverComponent: NSObject, DCFComponent {
    static var presentedPopovers: [String: UIPopoverPresentationController] = [:]
    
    private func presentPopover(from view: UIView, props: [String: Any], viewId: String) {
        let popoverContentVC = UIViewController()
        popoverContentVC.modalPresentationStyle = .popover
        
        guard let popoverController = popoverContentVC.popoverPresentationController else {
            return
        }
        
        // Configure popover anchor
        popoverController.sourceView = view.superview ?? view
        popoverController.sourceRect = view.frame
        
        // Configure popover properties
        configurePopoverProperties(popoverController, props: props)
        
        // Present popover
        if let topViewController = getTopViewController() {
            topViewController.present(popoverContentVC, animated: true)
        }
    }
}
```

### Alert Component Pattern

```swift
class DCFAlertComponent: NSObject, DCFComponent {
    private func presentAlert(from view: UIView, props: [String: Any]) {
        let title = props["title"] as? String
        let message = props["message"] as? String
        let alertStyle = parseAlertStyle(props["style"] as? String)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        
        // Add actions if specified
        if let actions = props["actions"] as? [[String: Any]] {
            for actionProps in actions {
                let action = createAlertAction(from: actionProps, sourceView: view)
                alertController.addAction(action)
            }
        }
        
        // Present alert
        if let topViewController = getTopViewController() {
            topViewController.present(alertController, animated: true)
        }
    }
}
```

## Dart Side Implementation Pattern

### Component Structure

```dart
class DCFYourPresentable extends StatelessComponent {
  final bool visible;
  final Function(Map<dynamic, dynamic>)? onShow;
  final Function(Map<dynamic, dynamic>)? onDismiss;
  final List<DCFComponentNode> children;
  final LayoutProps layout;
  final StyleSheet style;
  
  // Component-specific props
  final String? customProperty;
  
  DCFYourPresentable({
    super.key,
    required this.visible,
    this.onShow,
    this.onDismiss,
    this.children = const [],
    this.layout = const LayoutProps(),
    this.style = const StyleSheet(),
    this.customProperty,
  });

  @override
  DCFComponentNode render() {
    Map<String, dynamic> eventMap = {};
    
    if (onShow != null) eventMap['onShow'] = onShow;
    if (onDismiss != null) eventMap['onDismiss'] = onDismiss;
    
    Map<String, dynamic> props = {
      'visible': visible,
      'customProperty': customProperty,
      ...layout.toMap(),
      ...style.toMap(),
      ...eventMap,
    };
    
    // 🔥 CRITICAL: Always enforce display property based on visibility
    props['display'] = visible ? 'flex' : 'none';
    
    return DCFElement(
      type: 'YourPresentable',
      props: props,
      children: children,
    );
  }
}
```

### Display Property Pattern

**Critical Implementation Detail:** Always set the display property based on visibility to ensure proper hiding behavior:

```dart
// 🔥 CRITICAL FIX: Always enforce display property based on visibility
// This ensures style.toMap() cannot override the visibility-based display setting
props['display'] = visible ? 'flex' : 'none';
```

This pattern ensures:
- `visible: false` → `display: 'none'` → Component completely hidden from layout
- `visible: true` → `display: 'flex'` → Component properly presented

## Component-Specific Considerations

### Modals
- Use `UIModalPresentationController` or sheet presentation
- Support detents for iOS 15+ sheet modals
- Handle user dismissal gestures properly
- Manage child visibility during drag gestures

### Popovers
- Use `UIPopoverPresentationController`
- Configure anchor point and arrow direction
- Size content based on children or specified dimensions
- Handle iPad vs iPhone behavior differences

### Alerts
- Use `UIAlertController`
- Support different alert styles (alert, actionSheet)
- Add actions and text fields as needed
- Handle alert-specific sizing and presentation

### Bottom Sheets
- Can use modal with custom detents
- Or implement custom presentation controller
- Handle drag gestures and snap points
- Consider safe area insets

### Tooltips
- Use popover with tooltip styling
- Auto-dismiss on outside tap
- Position relative to anchor element
- Keep content concise and readable

## Best Practices

### 1. **Consistent Event Handling**
```swift
// Always propagate events at appropriate times
topViewController.present(presentedController, animated: true) {
    propagateEvent(on: view, eventName: "onShow", data: [:])
}

// Handle dismissal events
presentedController.dismiss(animated: true) {
    propagateEvent(on: view, eventName: "onDismiss", data: [:])
}
```

### 2. **Proper Memory Management**
```swift
// Track presented instances
static var presentedInstances: [String: YourPresentationType] = [:]

// Store reference before presenting
presentedInstances[viewId] = presentedInstance

// Remove reference when dismissed
presentedInstances.removeValue(forKey: viewId)
```

### 3. **Graceful Fallbacks**
```swift
// Always check for top view controller
guard let topViewController = getTopViewController() else {
    print("❌ Could not find view controller to present from")
    return
}

// Handle presentation failures
topViewController.present(presentedController, animated: true) {
    // Success callback
} catch {
    // Remove from tracking if presentation failed
    presentedInstances.removeValue(forKey: viewId)
}
```

### 4. **Platform Version Handling**
```swift
// Use availability checks for new features
if #available(iOS 15.0, *) {
    modalVC.modalPresentationStyle = .pageSheet
    // Configure sheet detents
} else {
    // Fallback for older iOS versions
    modalVC.modalPresentationStyle = .formSheet
}
```

## Testing Checklist

When implementing a new presentable component:

- [ ] `visible: false` properly hides content (display: none behavior)
- [ ] `visible: true` presents content with children visible
- [ ] Children are invisible in placeholder, visible when presented
- [ ] Dismissal moves children back to placeholder correctly
- [ ] Events (onShow, onDismiss) fire at correct times
- [ ] Multiple show/hide cycles work correctly
- [ ] User dismissal (tap outside, gestures) handled properly
- [ ] Platform-specific features work as expected
- [ ] Memory management (no leaks when dismissed)
- [ ] Accessibility features work correctly
- [ ] Different child counts and layouts work properly

## Common Pitfalls to Avoid

1. **Don't** move children during dismissal animations - wait for completion
2. **Don't** override the display property after setting it based on visibility
3. **Don't** assume a specific view controller hierarchy - always find the top controller
4. **Don't** forget to remove tracking references when dismissing
5. **Don't** add system-specific padding/margins - let abstraction layer control layout
6. **Don't** forget to handle both programmatic and user-initiated dismissals
7. **Don't** ignore platform version differences - always provide fallbacks

## Future Enhancements

Consider these patterns for advanced features:

- **Animation Control**: Custom transition animations
- **Focus Management**: Automatic focus handling for accessibility
- **State Persistence**: Maintaining state across presentations
- **Multi-Instance Support**: Multiple simultaneous presentations
- **Custom Anchoring**: More flexible positioning options
- **Responsive Behavior**: Adaptive sizing based on content and screen size
