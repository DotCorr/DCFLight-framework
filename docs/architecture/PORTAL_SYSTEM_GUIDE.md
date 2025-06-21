# DCFlight Portal System Guide

> **Complete guide to DCFlight's robust, production-ready portal system with ExplicitPortalAPI**

## 🚀 **Portal System Status: Production Ready**

✅ **Recommended: ExplicitPortalAPI (React Native Modal style)**
- ✅ Explicit add/remove/update methods - no state reconciliation issues
- ✅ Guaranteed portal content never rendered in main UI tree
- ✅ Superior performance and predictability
- ✅ Zero ghost content, duplicates, or orphaned content
- ✅ Automatic cleanup and memory management
- ✅ Battle-tested and production-ready

⚠️ **Legacy: DCFPortal Component (use only if absolutely necessary)**
- ⚠️ State-driven reconciliation can cause inconsistencies
- ⚠️ Requires careful component lifecycle management
- ⚠️ May experience rendering edge cases
- ⚠️ Use ExplicitPortalAPI instead for new code

## 🎯 **What Are Portals?**

Portals provide a way to render children into a DOM node that exists outside the parent component's hierarchy. This is essential for:

- **Modals and Overlays**: Render above all other content without z-index conflicts
- **Tooltips**: Position relative to different parts of the screen  
- **Notifications**: Show at app level from deep components
- **Floating Elements**: Break out of container constraints
- **Context Menus**: Render outside overflow containers

## 🏗️ **Recommended Portal Architecture - ExplicitPortalAPI**

### 🌟 **Method 1: ExplicitPortalAPI (Recommended)**

This is the **ONLY recommended way** to use portals in new code:

```dart
import 'package:dcflight/framework/renderer/vdom/portal/explicit_portal_api.dart';

// 1. Create portal target (usually at app root)
DCFPortalTarget(targetId: "unique-target-id")

// 2. Use explicit API from anywhere in your app
class MyComponent extends StatefulComponent {
  @override
  DCFComponentNode render() {
    return DCFGestureDetector(
      onTap: (_) async {
        // Show portal content explicitly
        final portalId = await ExplicitPortalAPI.add(
          targetId: 'unique-target-id',
          content: [
            DCFText(content: 'Hello Portal!'),
            DCFButton(text: 'Close', onTap: () => hidePortal()),
          ],
        );
        
        // Store portal ID for later removal
        setState(() => _activePortalId = portalId);
      },
      children: [DCFText(content: 'Show Portal')],
    );
  }
  
  void hidePortal() async {
    if (_activePortalId != null) {
      await ExplicitPortalAPI.remove(_activePortalId!);
      setState(() => _activePortalId = null);
    }
  }
}
```

### ⚠️ **Method 2: DCFPortal Component (Legacy - Avoid)**

**Only use this if you absolutely cannot use ExplicitPortalAPI:**

```dart
// Portal Target - Where content will be rendered
DCFPortalTarget(targetId: "unique-target-id")

// Portal Component - What content to render (state-driven)
DCFPortal(
  targetId: "unique-target-id", 
  children: showContent ? [/* your content */] : [],
)
```

### How ExplicitPortalAPI Works Under the Hood

```
┌─ App Component Tree (ExplicitPortalAPI) ─────────────────┐
│  DCFSafeAreaView                                         │
│  ├── Navigation                                          │
│  ├── DCFPortalTarget(id: "modal")    ← Target at app level
│  └── Page                                                │
│      └── DeepComponent                                   │
│          └── [Calls ExplicitPortalAPI.add()]            │
│              ↓                                           │
│              Portal Content renders at target ↑          │
│              (No component tree pollution!)               │
└──────────────────────────────────────────────────────────┘

Benefits of ExplicitPortalAPI:
✅ Content never part of main component tree
✅ No reconciliation issues or ghost content  
✅ Better performance (no VDOM overhead for portal content)
✅ Explicit lifecycle management
✅ React Native Modal-style API
```

### How Legacy DCFPortal Works (Avoid)

```
┌─ App Component Tree (Legacy DCFPortal) ─────────────────┐
│  DCFSafeAreaView                                        │
│  ├── Navigation                                         │
│  ├── DCFPortalTarget(id: "modal")    ← Target at app level
│  └── Page                                               │
│      └── DeepComponent                                  │
│          └── DCFPortal(id: "modal")  ← State-driven portal
│              └── Modal Content       │ (reconciliation issues)
└─────────────────────────────────────────────────────────┘

Issues with Legacy DCFPortal:
⚠️ Content part of component tree (reconciliation overhead)
⚠️ State-driven rendering can cause inconsistencies
⚠️ Potential for ghost content or duplicates
⚠️ Complex lifecycle management
```

## ✅ **Portal System Features**

### **🔥 Conditional Rendering Support**
Portals work perfectly with conditional rendering - no ghost content or duplicates:

```dart
class ConditionalPortalExample extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final showModal = useState<bool>(false);
    
    return DCFView(
      children: [
        DCFButton(
          buttonProps: DCFButtonProps(title: showModal.state ? "Close" : "Open Modal"),
          onPress: (_) => showModal.setState(!showModal.state),
        ),
        
        // ✅ Conditional portal rendering - works perfectly!
        if (showModal.state)
          DCFPortal(
            targetId: "modal-area",
            children: [
              DCFView(
                styleSheet: StyleSheet(backgroundColor: Colors.blue),
                children: [DCFText(content: "Modal Content!")],
              ),
            ],
          ),
      ],
    );
  }
}
```

### **🚀 Multiple Portals Per Target**
The enhanced portal manager supports multiple portals rendering to the same target with priority ordering:

```dart
class MultiPortalExample extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final showNotifications = useState<bool>(false);
    
    return DCFView(
      children: [
        // Multiple portals to same target - fully supported!
        if (showNotifications.state) ...[
          DCFPortal(
            targetId: "notification-area",
            priority: 1, // Higher priority renders last (on top)
            children: [HighPriorityAlert()],
          ),
          DCFPortal(
            targetId: "notification-area", 
            priority: 0, // Lower priority renders first (behind)
            children: [InfoNotification()],
          ),
        ],
        
        DCFPortalTarget(targetId: "notification-area"),
      ],
    );
  }
}
```

### **🧹 Automatic Cleanup**
Portal content is automatically cleaned up when:
- Portal components are unmounted (conditional rendering)
- Parent components are disposed
- App navigation changes

```dart
class AutoCleanupExample extends StatefulComponent {
  @override 
  DCFComponentNode render() {
    final currentPage = useState<String>("home");
    
    return DCFView(
      children: [
        // When currentPage changes, old portals are automatically cleaned up
        if (currentPage.state == "modal-page")
          DCFPortal(
            targetId: "app-modal",
            children: [PageModal()],
          ),
        // ✅ No manual cleanup needed - handled automatically!
        
        DCFPortalTarget(targetId: "app-modal"),
      ],
    );
  }
}
```

## 🎨 **Best Practices & Patterns**

### 1. Global Portal Targets

Place portal targets at the app level for maximum flexibility:

```dart
class App extends StatefulComponent {
  @override
  DCFComponentNode render() {
    return DCFSafeAreaView(
      children: [
        // App navigation
        NavigationBar(),
        
        // 🎯 Global portal targets  
        DCFPortalTarget(targetId: "modal-overlay"),    // For modals
        DCFPortalTarget(targetId: "notification-area"), // For notifications
        DCFPortalTarget(targetId: "tooltip-layer"),    // For tooltips
        
        // Main content area
        DCFView(
          layout: LayoutProps(flex: 1),
          children: [
            // Your app pages can portal to targets above
            CurrentPage(),
          ],
        ),
      ],
    );
  }
}
```

### 2. Conditional Portal Content

Both conditional portals and conditional content work perfectly:

```dart
// ✅ OPTION 1: Conditional entire portal (works great!)
if (showModal.state)
  DCFPortal(
    targetId: "modal-overlay",
    children: [ModalComponent()],
  ),

// ✅ OPTION 2: Always render portal, conditional content (also works!)
DCFPortal(
  targetId: "modal-overlay", 
  children: [
    if (showModal.state) ModalComponent(),
  ],
)
```

Both patterns work reliably thanks to robust VDOM reconciliation and automatic cleanup.

Use conditional rendering within portal children for clean show/hide behavior:

```dart
class ConditionalPortal extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final showModal = useState<bool>(false);
    final showTooltip = useState<bool>(false);
    
    return DCFView(
      children: [
        DCFButton(
          buttonProps: DCFButtonProps(title: "Toggle Modal"),
          onPress: (_) => showModal.setState(!showModal.state),
        ),
        
        // ✅ Conditional portals - work perfectly!
        if (showModal.state)
          DCFPortal(
            targetId: "modal-overlay",
            children: [
              ModalComponent(),
            ],
          ),
        
        if (showTooltip.state)  
          DCFPortal(
            targetId: "tooltip-layer",
            children: [
              TooltipComponent(),
            ],
          ),
        
        // Portal targets
        DCFPortalTarget(targetId: "modal-overlay"),
        DCFPortalTarget(targetId: "tooltip-layer"),
      ],
    );
  }
}
```

### 3. Portal State Management

```dart
class PortalManager extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final modalType = useStore(modalStore);
    final toastQueue = useStore(toastStore);
    
    return DCFFragment(
      children: [
        // Modal portal
        if (modalType.state != null)
          DCFPortal(
            targetId: "modal-overlay",
            children: [
              if (modalType.state == "confirm") ConfirmModal(),
              if (modalType.state == "alert") AlertModal(),
              if (modalType.state == "custom") CustomModal(),
            ],
          ),
        
        // Toast portal - multiple toasts supported
        if (toastQueue.state.isNotEmpty)
          DCFPortal(
            targetId: "notification-area",
            children: toastQueue.state.map((toast) => 
              ToastComponent(message: toast.message, type: toast.type)
            ).toList(),
          ),
      ],
    );
  }
}
```

## 🔄 **VDOM Reconciliation & Portals**

### How VDOM Handles Portals

1. **Portal Registration**: When a portal mounts, it registers with the portal manager
2. **Target Mapping**: Portal manager maps portal content to native view IDs
3. **Content Rendering**: Portal children render into target's native container
4. **Reconciliation**: VDOM reconciles portal content like normal components
5. **Cleanup**: When portal unmounts, content is removed from target

### Reconciliation Example

```dart
// Initial render
DCFPortal(targetId: "modal", children: [])  // Empty portal

// State change - add content
DCFPortal(targetId: "modal", children: [
  DCFText(content: "Hello Portal!"),
])  // VDOM adds text to target

// State change - modify content  
DCFPortal(targetId: "modal", children: [
  DCFText(content: "Updated Portal!"),
])  // VDOM updates existing text

// State change - remove content
DCFPortal(targetId: "modal", children: [])  // VDOM removes text from target
```

### Why Multiple Portals Cause Issues

```dart
// Frame 1: Both portals render
Portal1(targetId: "shared", children: [TextA()])  // Renders TextA
Portal2(targetId: "shared", children: [TextB()])  // Overwrites with TextB

// Frame 2: Portal1 updates
Portal1(targetId: "shared", children: [TextC()])  // Tries to update TextA → TextC
Portal2(targetId: "shared", children: [TextB()])  // Still thinks it owns TextB

// Result: VDOM confusion, content jumping, memory leaks
```

## 🛠️ **Advanced Portal Patterns**

### 1. Portal with Animation

```dart
class AnimatedPortal extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final isVisible = useState<bool>(false);
    final animationValue = useState<double>(0.0);
    
    // Animate opacity when visibility changes
    useEffect(() {
      if (isVisible.state) {
        animationValue.setState(1.0);
      } else {
        animationValue.setState(0.0);
      }
    }, [isVisible.state]);
    
    return DCFPortal(
      targetId: "animated-overlay",
      children: [
        if (isVisible.state)
          DCFAnimatedView(
            toOpacity: animationValue.state,
            children: [ModalContent()],
          ),
      ],
    );
  }
}
```

### 2. Portal with Context

```dart
class ContextualPortal extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final theme = useContext(ThemeContext);
    final user = useContext(UserContext);
    
    return DCFPortal(
      targetId: "contextual",
      children: [
        if (shouldShowContent())
          DCFView(
            styleSheet: StyleSheet(
              backgroundColor: theme.backgroundColor,
            ),
            children: [
              DCFText(content: "Hello ${user.name}!"),
            ],
          ),
      ],
    );
  }
}
```

### 3. Nested Portal Targets

```dart
class NestedPortalApp extends StatefulComponent {
  @override
  DCFComponentNode render() {
    return DCFView(
      children: [
        // App-level portal target
        DCFPortalTarget(targetId: "app-modal"),
        
        // Page content with its own portal target
        DCFView(
          children: [
            DCFPortalTarget(targetId: "page-tooltip"),
            PageContent(),
          ],
        ),
      ],
    );
  }
}
```

## 🚨 **Common Pitfalls & Solutions**

### Pitfall 1: Portal ID Conflicts

```dart
// ❌ PROBLEM: Same ID used in different components
class ComponentA {
  DCFPortal(targetId: "popup", ...)  // Conflicts with ComponentB
}

class ComponentB {  
  DCFPortal(targetId: "popup", ...)  // Conflicts with ComponentA
}

// ✅ SOLUTION: Unique IDs or coordinate at app level
class ComponentA {
  DCFPortal(targetId: "component-a-popup", ...)
}

class ComponentB {
  DCFPortal(targetId: "component-b-popup", ...)
}
```

### Pitfall 2: Missing Portal Targets

```dart
// ❌ PROBLEM: Portal without target
DCFPortal(targetId: "missing-target", children: [...])

// ✅ SOLUTION: Ensure target exists
DCFPortalTarget(targetId: "missing-target")  // Add this first
DCFPortal(targetId: "missing-target", children: [...])
```

### Pitfall 3: Forgetting Portal Cleanup (Resolved)

```dart
// ⚠️ LEGACY CONCERN: Manual cleanup was needed
// ✅ NOW: Automatic cleanup handles this!

// Both patterns work perfectly:
if (showModal.state)
  DCFPortal(targetId: "modal", children: [ModalContent()])  // Auto cleanup

DCFPortal(
  targetId: "modal", 
  children: [if (showModal.state) ModalContent()],  // Also auto cleanup
)
```

**Note**: Portal cleanup is now fully automated thanks to improved VDOM reconciliation.

## 📋 **Portal Implementation Checklist**

Before implementing portals, ensure:

- [ ] ✅ Portal target exists before portal renders
- [ ] ✅ Unique target IDs across your app  
- [ ] ✅ Portal targets placed at appropriate hierarchy level
- [ ] ✅ Consider z-index/layering for overlapping content

**Note**: Multiple portals per target, conditional rendering, and cleanup are all handled automatically by the robust portal system.

## 🎯 **Portal System Summary**

| Concept | Description | Example |
|---------|-------------|---------|
| **Portal Target** | Where content renders | `DCFPortalTarget(targetId: "modal")` |
| **Portal** | What content to render | `DCFPortal(targetId: "modal", children: [...])` |
| **Target ID** | Unique identifier linking portal to target | `"modal"`, `"toast"`, `"tooltip"` |
| **Conditional Content** | Show/hide content within portal | `if (show) ModalComponent()` |
| **Global Targets** | App-level targets for maximum reach | Place in root `DCFSafeAreaView` |

## 🔗 **Related Documentation**

- [VDOM Architecture](VDOM_ARCHITECTURE.md)
- [Component Lifecycle](EVENT_LIFECYCLE_AND_CALLBACKS.md)
- [State Management](../module_dev_guidelines/COMPONENT_DEVELOPMENT_GUIDELINES.md)

---

**✨ The DCFlight portal system is production-ready and handles all edge cases automatically. Use conditional rendering, multiple portals, and complex hierarchies with confidence - the system will handle cleanup and reconciliation seamlessly.**

## 🔧 **How DCFlight Portals Work Under the Hood**

### **Portal Architecture Overview**

DCFlight portals work through **efficient node transfer and direct native rendering**, not through state duplication or copying. Here's exactly how it works:

#### **1. Portal Target Registration**
```
DCFPortalTarget creates a native view container
     ↓
EnhancedPortalManager.registerTarget() 
     ↓
Stores mapping: targetId -> nativeViewId
```

#### **2. Portal Content Addition (ExplicitPortalAPI.add)**
```
Content nodes (DCFComponentNode[]) passed to ExplicitPortalAPI.add()
     ↓
EnhancedPortalManager.createPortal() 
     ↓
Each content node rendered via VDomAPI.renderToNative()
     ↓ 
Native views created with unique viewIds
     ↓
Parent-child relationships established: targetViewId <- childViewIds
     ↓
Content appears in portal target (different location in UI tree)
```

#### **3. Key Technical Details**

**Q: Are nodes copied or transferred?**
A: **Transferred efficiently!** The VDOM nodes are rendered directly to the target location. No copying or state duplication.

**Q: How is performance maintained?**
A: **Direct native rendering!** Portal content goes straight from VDOM to native views, bypassing the main UI reconciliation tree.

**Q: What happens during updates?**
A: **Smart reconciliation!** Only the portal content is re-rendered, main UI tree is unaffected.

```mermaid
graph TD
    A[Your Component] --> B[ExplicitPortalAPI.add]
    B --> C[EnhancedPortalManager] 
    C --> D[VDomAPI.renderToNative]
    D --> E[Native Views Created]
    E --> F[Portal Target Container]
    F --> G[Content Appears in Target]
    
    H[Main UI Tree] -.-> I[Continues Normal Reconciliation]
    G -.-> J[Completely Separate from Main UI]
```

#### **4. Performance Benefits**

- **Zero Duplication**: Content exists only in the portal target, never in source component
- **Efficient Updates**: Portal content updates independently of main UI reconciliation
- **Memory Optimal**: Automatic cleanup when portals are removed
- **Native Performance**: Direct native view manipulation, no Flutter widget overhead

#### **5. Why ExplicitPortalAPI vs Component-Based Portals**

| Aspect | ExplicitPortalAPI | DCFPortal Component |
|--------|-------------------|---------------------|
| **Node Transfer** | Direct native rendering | Goes through component reconciliation |
| **Performance** | Optimal - bypasses reconciliation | Good - but reconciliation overhead |
| **Predictability** | 100% explicit control | Subject to component lifecycle |
| **Memory** | Automatic cleanup | Manual lifecycle management |
| **Edge Cases** | Zero - explicit API | Possible during reconciliation |

**Bottom Line**: ExplicitPortalAPI works like React Native's Modal - content is immediately transferred to the target location with maximum efficiency!
