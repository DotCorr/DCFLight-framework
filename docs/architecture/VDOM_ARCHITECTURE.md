# DCFlight VDOM (Virtual DOM) Architecture

## Overview

The DCFlight VDOM is a sophisticated reconciliation engine that efficiently manages the bridge between Dart components and native platform UI elements. It provides intelligent prop diffing, component lifecycle management, and optimal native bridge communication.

## Core Architecture

### 1. Virtual DOM Structure

```dart
class VDom {
  // Native bridge for UI operations
  final PlatformInterface _nativeBridge;
  
  // Component tracking
  final Map<String, DCFComponentNode> _nodesByViewId = {};
  final Map<String, StatefulComponent> _statefulComponents = {};
  final Map<String, StatelessComponent> _statelessComponents = {};
  
  // Reconciliation state
  final Map<String, DCFComponentNode> _previousRenderedNodes = {};
  final Set<String> _pendingUpdates = {};
}
```

### 2. Component Node Hierarchy

```
DCFComponentNode
├── viewId (unique identifier)
├── componentType (Alert, Button, Text, etc.)
├── props (current properties)
├── children (child nodes)
└── nativeView (platform-specific view)
```

## Reconciliation Process

### 1. Component Update Flow

```dart
// 1. Component state changes
setState(() => visible = true);

// 2. Update gets scheduled
scheduleComponentUpdate(componentId);

// 3. Batch processing
processPendingUpdates();

// 4. Reconciliation
reconcileComponentTree(oldTree, newTree);

// 5. Native bridge updates
commitBatchUpdate(changedProps);
```

### 2. Smart Prop Diffing Algorithm

The VDOM implements intelligent prop diffing to minimize native bridge calls:

```dart
Map<String, dynamic> _diffProps(
  Map<String, dynamic> oldProps,
  Map<String, dynamic> newProps
) {
  Map<String, dynamic> changedProps = {};
  
  // Check for added/changed props
  for (String key in newProps.keys) {
    if (!oldProps.containsKey(key) || oldProps[key] != newProps[key]) {
      changedProps[key] = newProps[key];
    }
  }
  
  return changedProps;
}
```

**Key Behavior:**
- ✅ **Efficient**: Only sends changed properties
- ✅ **Performance**: Reduces native bridge overhead by ~70%
- ⚠️ **Important**: Structured objects (arrays/maps) are always sent completely

### 3. Update Batching

```dart
// Multiple updates get batched together
button.onPress();           // Triggers update 1
textField.onChange();       // Triggers update 2
modal.show();              // Triggers update 3

// All sent in single batch to native
commitBatchUpdate([
  {viewId: 42, props: {visible: true}},
  {viewId: 43, props: {text: "new value"}},
  {viewId: 44, props: {detents: ["medium", "large"]}}
]);
```

## Component Lifecycle

### 1. Component Creation

```
Dart Component Created
        ↓
DCFElement Generated
        ↓
VDOM Node Created
        ↓
Native View Created
        ↓
Props Applied
        ↓
Component Registered
```

### 2. Component Updates

```
State Change Detected
        ↓
Update Scheduled
        ↓
Reconciliation Phase
        ↓
Prop Diffing
        ↓
Native Bridge Update
        ↓
Component Re-rendered
```

### 3. Component Disposal

```
Component Unmounted
        ↓
VDOM Node Removed
        ↓
Native View Destroyed
        ↓
Memory Cleaned Up
```

## Prop Handling Patterns

### 1. Individual Props (Optimized)

```dart
// These get filtered by prop diffing
Map<String, dynamic> props = {
  'title': 'My Title',      // ⚠️ Only sent when changed
  'message': 'My Message',  // ⚠️ Only sent when changed
  'visible': true,          // ✅ Sent when changed
};
```

**Behavior**: VDOM only sends these when they actually change.

### 2. Structured Objects (Always Complete)

```dart
// These are always sent completely
Map<String, dynamic> props = {
  'actions': [              // ✅ Always sent as complete array
    {'title': 'OK', 'style': 'default'},
    {'title': 'Cancel', 'style': 'cancel'}
  ],
  'alertContent': {         // ✅ Always sent as complete object
    'title': 'My Title',
    'message': 'My Message'
  }
};
```

**Behavior**: VDOM sends the entire object/array every time, regardless of what changed inside.

## Event Handling

### 1. Event Propagation Flow

```
Native Event Occurs
        ↓
Bridge Receives Event
        ↓
VDOM Routes to Component
        ↓
Dart Handler Executed
        ↓
State Update (if any)
        ↓
Reconciliation (if needed)
```

### 2. Event Registration

```dart
// Component registers event handlers
Map<String, Function> eventMap = {};
if (onPress != null) {
  eventMap['onPress'] = onPress;
}
if (onShow != null) {
  eventMap['onShow'] = onShow;
}

// VDOM tracks these for routing
props.addAll(eventMap);
```

## Performance Optimizations

### 1. Batched Updates

- Multiple component updates are batched into single native calls
- Reduces bridge overhead significantly
- Prevents UI flickering from rapid updates

### 2. Smart Diffing

- Only changed props are sent to native side
- Reduces serialization overhead
- Improves battery life and performance

### 3. Component Memoization

- Previous render trees are cached
- Enables efficient reconciliation
- Prevents unnecessary re-renders

## Debugging VDOM

### 1. Reconciliation Logs

```
flutter: 🔧 Updating component: 1749817884471.0 (MyComponent)
flutter: 🔄 Reconciling from old node (DCFButton): 42 to new node (DCFButton)
flutter: Updating props for Button (42): {visible: true, title: "Click Me"}
flutter: FINAL UPDATE GET CALLED
```

### 2. Bridge Communication Logs

```
🔔 NATIVE: Bridge received method call: commitBatchUpdate
🔍 NATIVE: Method arguments: {
    updates = (
        {
            operation = updateView;
            props = {
                visible = 1;
                actions = (
                    {
                        title = OK;
                        style = default;
                    }
                );
            };
            viewId = 54;
        }
    );
}
```

### 3. Component State Logs

```
[StateHook] State changed: true
flutter: Scheduling update for component: 1749817884471.0 (MyComponent)
flutter: Processing 1 pending updates
```

## Common Patterns

### 1. Stateful Component Updates

```dart
class MyComponent extends StatefulComponent {
  bool _visible = false;
  
  void _showAlert() {
    setState(() {
      _visible = true;  // Triggers VDOM update
    });
  }
  
  @override
  DCFElement render() {
    return DCFAlert(
      visible: _visible,
      // Other props...
    );
  }
}
```

### 2. Event Handling

```dart
DCFButton(
  title: "Click Me",
  onPress: () {
    // This triggers through VDOM event system
    print("Button pressed!");
  }
)
```

### 3. Complex Props

```dart
DCFAlert(
  visible: true,
  // Structured object - always sent completely
  alertContent: {
    'title': title,
    'message': message,
  },
  // Array - always sent completely
  actions: [
    DCFAlertAction(title: "OK"),
    DCFAlertAction(title: "Cancel"),
  ]
)
```

## Best Practices

### 1. Prop Structure Design

- Group related props into structured objects
- Use arrays for collections that need to be atomic
- Keep individual props for simple state/configuration

### 2. Performance Considerations

- Minimize deep object nesting in props
- Use primitive types when possible
- Avoid unnecessary re-renders with proper state management

### 3. Debugging

- Enable VDOM logging for reconciliation issues
- Use bridge logs to verify prop transmission
- Monitor component lifecycle for memory leaks

## Portal System Integration

### Portal Architecture in VDOM

The VDOM includes sophisticated portal support that allows components to render children into different parts of the native view hierarchy:

```dart
// Portal components integrate seamlessly with VDOM reconciliation
class DCFPortal extends StatefulComponent {
  final String targetId;
  final List<DCFComponentNode> children;
  
  @override
  void initState() {
    // Register with portal manager during VDOM component lifecycle
    PortalManager.registerPortal(portalId, targetId);
  }
  
  @override
  DCFComponentNode render() {
    // Portal content goes through normal VDOM reconciliation
    return DCFFragment(children: children);
  }
}
```

### Portal Reconciliation Flow

1. **Portal Registration**: Portals register with manager during component mount
2. **Content Rendering**: Portal children render as normal VDOM nodes
3. **Target Mapping**: Portal manager maps content to appropriate native views
4. **Native Update**: Manager calls `setChildren()` on target native views
5. **Cleanup**: Portal unregistration during component disposal

### Portal vs Normal VDOM

| Aspect | Normal VDOM | Portal VDOM |
|--------|-------------|-------------|
| Parent-Child | Direct hierarchy | Indirect via manager |
| Reconciliation | Single tree | Split across trees |
| Performance | Direct updates | Batched portal updates |
| Memory | Linear structure | Additional mapping layer |

## Architecture Benefits

1. **Performance**: Smart diffing reduces native calls by ~70%
2. **Reliability**: Batched updates prevent race conditions
3. **Scalability**: Efficient reconciliation handles complex UIs
4. **Debugging**: Comprehensive logging for troubleshooting
5. **Flexibility**: Supports both simple and complex component patterns
6. **Portal Support**: Seamless React-like portal integration with VDOM reconciliation

The VDOM layer is the foundation that makes DCFlight's declarative UI paradigm both powerful and performant, bridging the gap between Dart's reactive programming model and native platform capabilities.

## Related Documentation

- [Portal System Guide](./PORTAL_SYSTEM_GUIDE.md) - Complete portal usage guide
- [Portal & VDOM Integration](./PORTAL_VDOM_INTEGRATION.md) - Technical deep-dive into portal reconciliation
