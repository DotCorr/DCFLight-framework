/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dcflight/framework/renderer/vdom/component/component_node.dart';
import 'package:dcflight/framework/renderer/vdom/component/component.dart';
import 'package:dcflight/framework/renderer/vdom/portal/enhanced_portal_manager.dart';

/// Explicit Portal API 
/// 
/// This API provides explicit control over portal lifecycle without relying
/// on component state or reconciliation. It's more resilient and predictable.
/// 
/// Usage:
/// ```dart
/// // Create and show content in a portal
/// final portalId = await ExplicitPortalAPI.add(
///   targetId: 'modal-root',
///   content: [DCFText('Hello Portal!')],
/// );
/// 
/// // Update portal content
/// await ExplicitPortalAPI.update(portalId, [DCFText('Updated content!')]);
/// 
/// // Remove portal content
/// await ExplicitPortalAPI.remove(portalId);
/// ```
class ExplicitPortalAPI {
  static final EnhancedPortalManager _portalManager = EnhancedPortalManager.instance;
  
  /// Add content to a portal target
  /// Returns a portal ID that can be used to update or remove the content
  static Future<String> add({
    required String targetId,
    required List<DCFComponentNode> content,
    Map<String, dynamic>? metadata,
    int priority = 0,
    bool createTargetIfMissing = false,
    Function(String portalId)? onMount,
    Function(String portalId)? onUnmount,
  }) async {
    if (kDebugMode) {
      print('🎯 ExplicitPortalAPI: Adding content to target: $targetId');
    }
    
    return await _portalManager.createPortal(
      targetId: targetId,
      children: content,
      metadata: metadata ?? {},
      priority: priority,
      createTargetIfMissing: createTargetIfMissing,
      onMount: onMount,
      onUnmount: onUnmount,
    );
  }
  
  /// Update portal content
  static Future<void> update(
    String portalId, 
    List<DCFComponentNode> content, {
    Map<String, dynamic>? metadata,
    int? priority,
  }) async {
    if (kDebugMode) {
      print('🔄 ExplicitPortalAPI: Updating portal: $portalId');
    }
    
    return await _portalManager.updatePortal(
      portalId: portalId,
      children: content,
      metadata: metadata,
      priority: priority,
    );
  }
  
  /// Remove portal content
  static Future<void> remove(String portalId) async {
    if (kDebugMode) {
      print('🗑️ ExplicitPortalAPI: Removing portal: $portalId');
    }
    
    return await _portalManager.removePortal(portalId);
  }
  
  /// Remove all portals from a target
  static Future<void> clearTarget(String targetId) async {
    if (kDebugMode) {
      print('🧹 ExplicitPortalAPI: Clearing all portals from target: $targetId');
    }
    
    final portalIds = _portalManager.getPortalIdsForTarget(targetId);
    for (final portalId in portalIds) {
      await _portalManager.removePortal(portalId);
    }
  }
  
  /// Check if a portal exists
  static bool exists(String portalId) {
    // We'll use the debug info to check if portal exists since _activePortals is private
    final debugInfo = _portalManager.getDebugInfo();
    final portals = debugInfo['portals'] as List<String>? ?? [];
    return portals.contains(portalId);
  }
  
  /// Check if a target exists
  static bool hasTarget(String targetId) {
    return _portalManager.hasTarget(targetId);
  }
  
  /// Get portal information for debugging
  static Map<String, dynamic> getDebugInfo() {
    return _portalManager.getDebugInfo();
  }
  
  /// Get all portal IDs for a target
  static List<String> getPortalIds(String targetId) {
    return _portalManager.getPortalIdsForTarget(targetId);
  }
  
  /// Register a portal target
  static void registerTarget({
    required String targetId,
    required String nativeViewId,
    Map<String, dynamic>? metadata,
    int priority = 0,
  }) {
    _portalManager.registerTarget(
      targetId: targetId,
      nativeViewId: nativeViewId,
      metadata: metadata,
      priority: priority,
    );
  }
  
  /// Unregister a portal target
  static Future<void> unregisterTarget(String targetId) async {
    return await _portalManager.unregisterTarget(targetId);
  }
}

/// Portal Hook - provides React-like portal functionality within components(experimental)
/// 
/// This hook manages portal lifecycle automatically within component lifecycle.
/// Use this when you want portal content to be managed by component state,
/// but with the resilience of explicit add/remove underneath.
/// 
/// Usage:
/// ```dart
/// class MyComponent extends StatefulComponent {
///   @override
///   DCFComponentNode render() {
///     final portal = usePortal('modal-root');
///     
///     useEffect(() {
///       if (shouldShowModal) {
///         portal.show([DCFText('Modal content')]);
///       } else {
///         portal.hide();
///       }
///     }, [shouldShowModal]);
///     
///     return DCFText('Regular component content');
///   }
/// }
/// ```
class PortalController {
  final String targetId;
  String? _currentPortalId;
  
  PortalController(this.targetId);
  
  /// Show content in the portal
  Future<void> show(
    List<DCFComponentNode> content, {
    Map<String, dynamic>? metadata,
    int priority = 0,
    Function(String portalId)? onMount,
    Function(String portalId)? onUnmount,
  }) async {
    // Hide existing content first
    await hide();
    
    _currentPortalId = await ExplicitPortalAPI.add(
      targetId: targetId,
      content: content,
      metadata: metadata,
      priority: priority,
      onMount: onMount,
      onUnmount: onUnmount,
    );
  }
  
  /// Update portal content
  Future<void> update(
    List<DCFComponentNode> content, {
    Map<String, dynamic>? metadata,
    int? priority,
  }) async {
    if (_currentPortalId != null) {
      await ExplicitPortalAPI.update(
        _currentPortalId!,
        content,
        metadata: metadata,
        priority: priority,
      );
    }
  }
  
  /// Hide portal content
  Future<void> hide() async {
    if (_currentPortalId != null) {
      await ExplicitPortalAPI.remove(_currentPortalId!);
      _currentPortalId = null;
    }
  }
  
  /// Check if portal is currently showing content
  bool get isShowing => _currentPortalId != null;
  
  /// Get current portal ID
  String? get portalId => _currentPortalId;
}

/// Portal Hook Mixin - provides portal functionality to components
/// 
/// Mix this into your StatefulComponent to get access to portal functionality
/// that's automatically cleaned up when the component unmounts.
/// 
/// Usage:
/// ```dart
/// class MyComponent extends StatefulComponent with PortalHookMixin {
///   @override
///   DCFComponentNode render() {
///     final portal = usePortal('modal-root');
///     // ... use portal
///   }
/// }
/// ```
mixin PortalHookMixin on StatefulComponent {
  final Map<String, PortalController> _portalControllers = {};
  
  /// Get or create a portal controller for the given target
  PortalController usePortal(String targetId) {
    if (!_portalControllers.containsKey(targetId)) {
      _portalControllers[targetId] = PortalController(targetId);
      
      // Set up cleanup on unmount using useEffect
      useEffect(() {
        return () {
          _portalControllers[targetId]?.hide();
          _portalControllers.remove(targetId);
        };
      }, dependencies: []);
    }
    return _portalControllers[targetId]!;
  }
}
