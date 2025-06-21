/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'store.dart';

/// Base hook class for all hook types
abstract class Hook {
  /// Clean up the hook when component unmounts
  void dispose() {}
}

/// State hook for managing component state
class StateHook<T> extends Hook {
  /// Current value of the state
  T _value;

  /// Name for debugging
  final String? _name;

  /// Schedule update function to trigger re-render
  final Function() _scheduleUpdate;

  /// Create a state hook
  StateHook(this._value, this._name, this._scheduleUpdate);

  /// Get the current value
  T get state => _value;

  /// Set the value and trigger update
  void setState(T newValue) {
    // Only update and trigger render if value actually changed
    if (_value != newValue) {
      _value = newValue;
      
      if (kDebugMode) {
        final name = _name != null ? ' ($_name)' : '';
        developer.log('State changed$name: $newValue', name: 'StateHook');
      }
      
      // Schedule a component update
      _scheduleUpdate();
    }
  }
  
  @override
  void dispose() {
    // Nothing to dispose for simple state
  }
  
  @override
  String toString() {
    final name = _name != null ? ' ($_name)' : '';
    return 'StateHook$name: $_value';
  }
}

/// Effect hook for side effects in components
class EffectHook extends Hook {
  /// The effect function
  final Function()? Function() _effect;

  /// Dependencies array - when these change, effect runs again
  List<dynamic> _dependencies;

  /// Cleanup function returned by the effect
  Function()? _cleanup;

  /// Previous dependencies for comparison
  List<dynamic>? _prevDeps;

  /// Create an effect hook
  EffectHook(this._effect, this._dependencies);
  
  /// Update dependencies - called during reconciliation
  void updateDependencies(List<dynamic> newDependencies) {
    if (kDebugMode) {
      print('🔄 EffectHook: updateDependencies called');
      print('🔄 EffectHook: Previous deps: $_dependencies');
      print('🔄 EffectHook: New deps: $newDependencies');
    }
    _dependencies = newDependencies;
  }

  /// Run the effect if needed based on dependency changes
  void runEffect() {
    // Run effect if first time or dependencies changed
    if (_prevDeps == null || !_areEqualDeps(_dependencies, _prevDeps!)) {
      if (kDebugMode) {
        print('🔥 EffectHook: Running effect - first time: ${_prevDeps == null}, deps changed: ${_prevDeps != null ? !_areEqualDeps(_dependencies, _prevDeps!) : false}');
        print('🔥 EffectHook: Previous deps: $_prevDeps');
        print('🔥 EffectHook: Current deps: $_dependencies');
      }
      
      // Clean up previous effect if needed
      if (_cleanup != null) {
        if (kDebugMode) {
          print('🧹 EffectHook: Running cleanup function');
        }
        try {
          _cleanup!();
        } catch (e) {
          if (kDebugMode) {
            print('❌ EffectHook: Error during cleanup: $e');
          }
        }
        _cleanup = null;
      }

      // Run the effect and store cleanup
      try {
        _cleanup = _effect();
        if (kDebugMode) {
          print('✅ EffectHook: Effect executed, cleanup function: ${_cleanup != null ? 'provided' : 'none'}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ EffectHook: Error during effect execution: $e');
        }
      }
      
      // Update previous dependencies
      _prevDeps = List<dynamic>.from(_dependencies);
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('🧹 EffectHook: Disposing effect hook - cleanup function exists: ${_cleanup != null}');
    }
    // Run cleanup if it exists
    if (_cleanup != null) {
      if (kDebugMode) {
        print('🧹 EffectHook: Running cleanup function during dispose');
      }
      try {
        _cleanup!();
        if (kDebugMode) {
          print('✅ EffectHook: Cleanup function executed successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ EffectHook: Error during dispose cleanup: $e');
        }
      }
      _cleanup = null;
    } else {
      if (kDebugMode) {
        print('⚠️ EffectHook: No cleanup function to run during dispose');
      }
    }
  }

  /// Compare two dependency arrays for equality
  bool _areEqualDeps(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    
    return true;
  }
}

/// Reference object wrapper
class RefObject<T> {
  /// Current value
  T? _value;

  /// Create a ref object
  RefObject([this._value]);

  /// Get current value
  T? get current => _value;
  
  /// Set current value
  set current(T? value) {
    _value = value;
  }
}

/// Ref hook for storing mutable references
class RefHook<T> extends Hook {
  /// The ref object
  final RefObject<T> ref;

  /// Create a ref hook
  RefHook([T? initialValue]) : ref = RefObject<T>(initialValue);
  
  @override
  void dispose() {
    // Nothing to dispose for refs
  }
}

/// Store hook for connecting to global state
class StoreHook<T> extends Hook {
  /// The store
  final Store<T> _store;
  
  /// Component information for tracking
  final String? _componentId;
  final String? _componentType;
  
  /// Get the store (for hook validation)
  Store<T> get store => _store;
  
  /// State change callback
  final Function() _onChange;
  
  /// Listener function reference for unsubscribing
  late final void Function(T) _listener;
  
  /// Flag to track if we're subscribed to prevent double subscription
  bool _isSubscribed = false;
  
  /// Debounce flag to prevent multiple rapid updates
  bool _updatePending = false;

  /// Create a store hook
  StoreHook(this._store, this._onChange, [this._componentId, this._componentType]) {
    // Track hook access for usage validation
    if (_componentId != null && _componentType != null) {
      _store.trackHookAccess(_componentId, _componentType);
    }
    
    // Create listener function that triggers component update with debouncing
    _listener = (T _) {
      // Prevent multiple rapid-fire updates by debouncing
      if (_updatePending) {
        return;
      }
      
      _updatePending = true;
      
      // Use microtask to batch multiple store updates together
      Future.microtask(() {
        if (_updatePending && _isSubscribed) {
          _updatePending = false;
          _onChange();
        }
      });
    };
    
    // Subscribe to store changes only once
    if (!_isSubscribed) {
      _store.subscribe(_listener);
      _isSubscribed = true;
    }
  }

  /// Get current state
  T get state => _store.state;
  
  /// Update store state
  void setState(T newState) {
    _store.setState(newState);
  }
  
  /// Update store state with a function
  void updateState(T Function(T) updater) {
    _store.updateState(updater);
  }

  @override
  void dispose() {
    // Unsubscribe from store on disposal
    if (_isSubscribed) {
      _store.unsubscribe(_listener);
      _isSubscribed = false;
    }
    _updatePending = false;
  }
}
