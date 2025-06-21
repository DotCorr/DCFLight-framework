/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dcflight/framework/renderer/vdom/component/component_node.dart';
import 'state_hook.dart';
import 'store.dart';

/// Stateful component with hooks and lifecycle methods
abstract class StatefulComponent extends DCFComponentNode {
  /// Unique ID for this component instance
  final String instanceId;

  /// Type name for debugging
  final String typeName;

  /// The rendered node from the component
  DCFComponentNode? _renderedNode;

  /// Whether the component is mounted
  bool _isMounted = false;

  /// Whether the component is currently updating to prevent cascading updates
  bool _isUpdating = false;

  /// Current hook index during rendering
  int _hookIndex = 0;

  /// List of hooks
  final List<Hook> _hooks = [];

  /// Function to schedule updates when state changes
  Function() scheduleUpdate = () {};

  /// Create a stateful component
  StatefulComponent({super.key})
      : instanceId = '${DateTime.now().millisecondsSinceEpoch}.${Random().nextDouble()}',
        typeName = _extractTypeName() {
    scheduleUpdate = _defaultScheduleUpdate;
  }

  /// Extract the component type name from the class
  static String _extractTypeName() {
    // Get the class name directly using runtimeType would be better, but
    // this works in the constructor. We'll use runtime type in a better way.
    final stackTrace = StackTrace.current.toString();
    final lines = stackTrace.split('\n');
    
    // Look for the first line that doesn't contain constructor calls
    for (final line in lines.skip(1)) {
      final match = RegExp(r'(\w+Component)').firstMatch(line);
      if (match != null) {
        return match.group(1)!;
      }
    }
    
    // Fallback to a generic name
    return 'UnknownComponent';
  }

  /// Default no-op schedule update function (replaced by VDOM)
  void _defaultScheduleUpdate() {
    if (kDebugMode) {
      print('Warning: scheduleUpdate called before component was registered with VDOM');
    }
  }

  /// Render the component - must be implemented by subclasses
  DCFComponentNode render();
  
  /// Get the rendered node (lazily render if necessary)
  @override
  DCFComponentNode get renderedNode {
    if (_renderedNode == null) {
      prepareForRender();
      _renderedNode = render();
      
      if (_renderedNode != null) {
        _renderedNode!.parent = this;
      }
    }
    return _renderedNode!;
  }
  
  /// Set the rendered node
  @override
  set renderedNode(DCFComponentNode? node) {
    _renderedNode = node;
    if (_renderedNode != null) {
      _renderedNode!.parent = this;
    }
  }

  /// Get whether the component is mounted
  bool get isMounted => _isMounted;

  /// Called when the component is mounted
  @override
  void componentDidMount() {
    _isMounted = true;
  }

  /// Called when the component will unmount
  @override
  void componentWillUnmount() {
    // Clean up hooks first
    for (final hook in _hooks) {
      hook.dispose();
    }
    _hooks.clear();
    
    // Clean up any remaining store subscriptions via StoreManager
    // This is a safety net in case hooks didn't clean up properly
    try {
      if (kDebugMode) {
        print('Cleaning up store subscriptions for component $instanceId');
      }
      // Note: StoreManager cleanup will be handled by individual hooks
    } catch (e) {
      if (kDebugMode) {
        print('Error during store cleanup: $e');
      }
    }
    
    _isMounted = false;
  }

  /// Called after the component updates
  void componentDidUpdate(Map<String, dynamic> prevProps) {}

  /// Reset hook state for next render
  void prepareForRender() {
    _hookIndex = 0;
  }

  /// Create a state hook
  StateHook<T> useState<T>(T initialValue, [String? name]) {
    if (_hookIndex >= _hooks.length) {
      // Create new hook
      final hook = StateHook<T>(initialValue, name, () {
        scheduleUpdate();
      });
      _hooks.add(hook);
    }
    
    // Get the hook (either existing or newly created)
    final hook = _hooks[_hookIndex] as StateHook<T>;
    _hookIndex++;
    
    return hook;
  }

  /// Create an effect hook
  void useEffect(Function()? Function() effect,
      {List<dynamic> dependencies = const []}) {
    if (_hookIndex >= _hooks.length) {
      // Create new hook
      final hook = EffectHook(effect, dependencies);
      _hooks.add(hook);
    } else {
      // Update dependencies for existing hook
      final hook = _hooks[_hookIndex] as EffectHook;
      hook.updateDependencies(dependencies);
    }
    
    _hookIndex++;
  }

  /// Create a ref hook
  RefObject<T> useRef<T>([T? initialValue]) {
    if (_hookIndex >= _hooks.length) {
      // Create new hook
      final hook = RefHook<T>(initialValue);
      _hooks.add(hook);
    }
    
    // Get the hook (either existing or newly created)
    final hook = _hooks[_hookIndex] as RefHook<T>;
    _hookIndex++;
    
    return hook.ref;
  }

  /// Create a store hook for global state
  StoreHook<T> useStore<T>(Store<T> store) {
    if (_hookIndex >= _hooks.length) {
      // Create new hook with update protection and component tracking
      final hook = StoreHook<T>(store, () {
        // Only schedule update if component is mounted and not already updating
        if (_isMounted && !_isUpdating) {
          _isUpdating = true;
          scheduleUpdate();
          // Reset updating flag after microtask to prevent rapid successive updates
          Future.microtask(() {
            _isUpdating = false;
          });
        }
      }, instanceId, typeName);
      _hooks.add(hook);
    }
    
    // Get the hook (either existing or newly created)
    final hook = _hooks[_hookIndex] as StoreHook<T>;
    
    // Verify this hook is for the same store to prevent mismatches
    if (hook.store != store) {
      if (kDebugMode) {
        print('Warning: Store hook mismatch detected, disposing old hook and creating new one');
      }
      // Dispose the old hook and create a new one
      hook.dispose();
      final newHook = StoreHook<T>(store, () {
        if (_isMounted && !_isUpdating) {
          _isUpdating = true;
          scheduleUpdate();
          Future.microtask(() {
            _isUpdating = false;
          });
        }
      }, instanceId, typeName);
      _hooks[_hookIndex] = newHook;
      _hookIndex++;
      return newHook;
    }
    
    _hookIndex++;
    return hook;
  }

  /// Run effects after render - called by VDOM
  void runEffectsAfterRender() {
    if (kDebugMode && runtimeType.toString().contains('Portal')) {
      print('🎯 runEffectsAfterRender called for $runtimeType - ${_hooks.length} hooks');
    }
    
    for (var i = 0; i < _hooks.length; i++) {
      final hook = _hooks[i];
      if (hook is EffectHook) {
        if (kDebugMode && runtimeType.toString().contains('Portal')) {
          print('🎯 Running effect hook $i for $runtimeType');
        }
        hook.runEffect();
      }
    }
  }
  
  /// Implement VDomNode methods
  
  @override
  DCFComponentNode clone() {
    // Components can't be cloned easily due to state, hooks, etc.
    throw UnsupportedError("Stateful components cannot be cloned directly.");
  }
  
  @override
  bool equals(DCFComponentNode other) {
    if (other is! StatefulComponent) return false;
    // Components are considered equal if they're the same type with the same key
    return runtimeType == other.runtimeType && key == other.key;
  }
  
  @override
  void mount(DCFComponentNode? parent) {
    this.parent = parent;
    
    // Ensure the component has rendered
    final node = renderedNode;
    
    // Mount the rendered content
    node.mount(this);
  }
  
  @override
  void unmount() {
    // Unmount the rendered content if any
    if (_renderedNode != null) {
      _renderedNode!.unmount();
      _renderedNode = null;
    }
    
    // Component lifecycle method
    componentWillUnmount();
  }

  @override
  String toString() {
    return '$typeName($instanceId)';
  }
}

/// Stateless component without hooks or state
abstract class StatelessComponent extends DCFComponentNode {
  /// Unique ID for this component instance
  final String instanceId;

  /// Type name for debugging
  final String typeName;

  /// The rendered node from the component
  DCFComponentNode? _renderedNode;

  /// Whether the component is mounted
  bool _isMounted = false;

  /// Create a stateless component
  StatelessComponent({super.key})
      : instanceId = '${DateTime.now().millisecondsSinceEpoch}.${Random().nextDouble()}',
        typeName = StackTrace.current.toString().split('\n')[1].split(' ')[0];

  /// Render the component - must be implemented by subclasses
  DCFComponentNode render();
  
  /// Get the rendered node (lazily render if necessary)
  @override
  DCFComponentNode get renderedNode {
    _renderedNode ??= render();
    
    if (_renderedNode != null) {
      _renderedNode!.parent = this;
    }
    
    return _renderedNode!;
  }
  
  /// Set the rendered node
  @override
  set renderedNode(DCFComponentNode? node) {
    _renderedNode = node;
    if (_renderedNode != null) {
      _renderedNode!.parent = this;
    }
  }

  /// Get whether the component is mounted
  bool get isMounted => _isMounted;

  /// Called when the component is mounted
  @override
  void componentDidMount() {
    _isMounted = true;
  }

  /// Called when the component will unmount
  @override
  void componentWillUnmount() {
    _isMounted = false;
  }
  
  /// Implement VDomNode methods
  
  @override
  DCFComponentNode clone() {
    // Components can't be cloned easily
    throw UnsupportedError("Stateless components cannot be cloned directly.");
  }
  
  @override
  bool equals(DCFComponentNode other) {
    if (other is! StatelessComponent) return false;
    // Components are equal if they're the same type with the same key
    return runtimeType == other.runtimeType && key == other.key;
  }
  
  @override
  void mount(DCFComponentNode? parent) {
    this.parent = parent;
    
    // Ensure the component has rendered
    final node = renderedNode;
    
    // Mount the rendered content
    node.mount(this);
  }
  
  @override
  void unmount() {
    // Unmount the rendered content if any
    if (_renderedNode != null) {
      _renderedNode!.unmount();
      _renderedNode = null;
    }
    
    // Component lifecycle method
    componentWillUnmount();
  }

  @override
  String toString() {
    return '$typeName($instanceId)';
  }
}
