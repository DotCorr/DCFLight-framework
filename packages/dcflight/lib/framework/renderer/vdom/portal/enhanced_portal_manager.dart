/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dcflight/framework/renderer/vdom/component/component_node.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_api.dart';

/// Enhanced Portal Manager with React-like capabilities
/// Supports:
/// - Multiple portals per target
/// - Portal nesting
/// - Event bubbling through portals
/// - Portal priority/layering
/// - Dynamic target creation
/// - Portal state preservation during reconciliation
class EnhancedPortalManager {
  static final EnhancedPortalManager _instance = EnhancedPortalManager._internal();
  static EnhancedPortalManager get instance => _instance;
  EnhancedPortalManager._internal();

  /// Access to the VDOM API for proper portal operations
  VDomAPI get _vdomApi => VDomAPI.instance;

  /// Map of target IDs to their portal containers
  final Map<String, PortalTarget> _portalTargets = {};
  
  /// Map of portal instances to their metadata
  final Map<String, PortalInstance> _activePortals = {};
  
  /// Map of queued portals waiting for their targets
  final Map<String, List<PortalInstance>> _queuedPortals = {};
  
  /// Global portal counter for unique IDs
  int _portalCounter = 0;
  
  /// Portal operation lock to prevent race conditions
  bool _operationInProgress = false;
  final List<Future<void> Function()> _pendingOperations = [];

  /// Register a portal target
  void registerTarget({
    required String targetId,
    required String nativeViewId,
    Map<String, dynamic>? metadata,
    int priority = 0,
  }) {
    if (kDebugMode) {
      print('🎯 EnhancedPortalManager: Registering target: $targetId (viewId: $nativeViewId)');
    }
    
    _portalTargets[targetId] = PortalTarget(
      targetId: targetId,
      nativeViewId: nativeViewId,
      metadata: metadata ?? {},
      priority: priority,
    );
    
    // Process any queued portals for this target immediately
    Future.microtask(() => _processQueuedPortalsForTarget(targetId));
  }

  /// Unregister a portal target
  Future<void> unregisterTarget(String targetId) async {
    await _executeWithLock(() async {
      if (kDebugMode) {
        print('🗑️ EnhancedPortalManager: Unregistering target: $targetId');
      }
      
      // Clean up all portals for this target
      final portalsToCleanup = _activePortals.values
          .where((portal) => portal.targetId == targetId)
          .toList();
      
      for (final portal in portalsToCleanup) {
        await _cleanupPortalInstance(portal);
      }
      
      _portalTargets.remove(targetId);
      _queuedPortals.remove(targetId);
    });
  }

  /// Create a portal instance
  Future<String> createPortal({
    required String targetId,
    required List<DCFComponentNode> children,
    Map<String, dynamic>? metadata,
    int priority = 0,
    bool createTargetIfMissing = false,
    Function(String portalId)? onMount,
    Function(String portalId)? onUnmount,
  }) async {
    final portalId = 'portal_${++_portalCounter}_${DateTime.now().millisecondsSinceEpoch}';
    
    final portalInstance = PortalInstance(
      portalId: portalId,
      targetId: targetId,
      children: children,
      metadata: metadata ?? {},
      priority: priority,
      createTargetIfMissing: createTargetIfMissing,
      onMount: onMount,
      onUnmount: onUnmount,
    );
    
    await _executeWithLock(() async {
      await _registerPortalInstance(portalInstance);
    });
    
    return portalId;
  }

  /// Update portal content
  Future<void> updatePortal({
    required String portalId,
    List<DCFComponentNode>? children,
    Map<String, dynamic>? metadata,
    int? priority,
  }) async {
    await _executeWithLock(() async {
      final portal = _activePortals[portalId];
      if (portal == null) {
        if (kDebugMode) {
          print('⚠️ EnhancedPortalManager: Portal not found for update: $portalId');
        }
        return;
      }
      
      if (kDebugMode) {
        print('🔄 EnhancedPortalManager: Updating portal: $portalId');
      }
      
      // Clean up existing content
      await _cleanupPortalContent(portal);
      
      // Update portal instance
      final updatedPortal = portal.copyWith(
        children: children,
        metadata: metadata,
        priority: priority,
      );
      
      _activePortals[portalId] = updatedPortal;
      
      // Re-render with new content
      await _renderPortalContent(updatedPortal);
    });
  }

  /// Remove a portal
  Future<void> removePortal(String portalId) async {
    await _executeWithLock(() async {
      final portal = _activePortals[portalId];
      if (portal == null) return;
      
      if (kDebugMode) {
        print('🗑️ EnhancedPortalManager: Removing portal: $portalId');
      }
      
      await _cleanupPortalInstance(portal);
    });
  }

  /// Get all portals for a target (useful for debugging)
  List<PortalInstance> getPortalsForTarget(String targetId) {
    return _activePortals.values
        .where((portal) => portal.targetId == targetId)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// Check if a target exists
  bool hasTarget(String targetId) {
    return _portalTargets.containsKey(targetId);
  }

  /// Get portal information for debugging and inspection
  Map<String, dynamic> getPortalInfo() {
    return {
      'targets': _portalTargets.keys.toList(),
      'activePortals': _activePortals.length,
      'queuedPortals': _queuedPortals.values.expand((list) => list).length,
      'portalsByTarget': _portalTargets.keys.map((targetId) {
        final portals = getPortalsForTarget(targetId);
        return {
          'targetId': targetId,
          'portalCount': portals.length,
          'portals': portals.map((p) => {
            'id': p.portalId,
            'priority': p.priority,
            'childrenCount': p.children.length,
          }).toList(),
        };
      }).toList(),
    };
  }

  /// Get all portal IDs for a specific target
  List<String> getPortalIdsForTarget(String targetId) {
    return _activePortals.values
        .where((portal) => portal.targetId == targetId)
        .map((portal) => portal.portalId)
        .toList();
  }

  /// Execute operation with lock to prevent race conditions
  Future<void> _executeWithLock(Future<void> Function() operation) async {
    if (_operationInProgress) {
      // Queue the operation
      final completer = Completer<void>();
      _pendingOperations.add(() async {
        await operation();
        completer.complete();
      });
      return completer.future;
    }
    
    _operationInProgress = true;
    
    try {
      await operation();
      
      // Process any pending operations
      while (_pendingOperations.isNotEmpty) {
        final pendingOp = _pendingOperations.removeAt(0);
        await pendingOp();
      }
    } finally {
      _operationInProgress = false;
    }
  }

  /// Register a portal instance
  Future<void> _registerPortalInstance(PortalInstance portal) async {
    if (kDebugMode) {
      print('🚀 EnhancedPortalManager: Registering portal ${portal.portalId} for target: ${portal.targetId}');
    }
    
    // CRITICAL FIX: Before registering a new portal, check if there are any orphaned
    // portals for the same target that should be cleaned up. This handles the case
    // where portal components are conditionally rendered and old instances aren't
    // properly cleaned up.
    await _cleanupOrphanedPortalsForTarget(portal.targetId);
    
    _activePortals[portal.portalId] = portal;
    
    final target = _portalTargets[portal.targetId];
    if (target == null) {
      if (portal.createTargetIfMissing) {
        await _createMissingTarget(portal.targetId);
      } else {
        _queuePortal(portal);
        return;
      }
    }

    await _renderPortalContent(portal);
    portal.onMount?.call(portal.portalId);
  }

  /// Render portal content to target
  Future<void> _renderPortalContent(PortalInstance portal) async {
    final target = _portalTargets[portal.targetId];
    if (target == null) {
      if (kDebugMode) {
        print('⚠️ EnhancedPortalManager: Target not found for portal: ${portal.portalId}');
      }
      return;
    }
    
    try {
      if (kDebugMode) {
        print('🎯 EnhancedPortalManager: Rendering ${portal.children.length} children to target: ${portal.targetId}');
      }
      
      // Render each child as a separate tree
      final renderedViewIds = <String>[];
      
      for (int i = 0; i < portal.children.length; i++) {
        final child = portal.children[i];
        
        try {
          final childViewId = await _vdomApi.renderToNative(
            child,
            parentViewId: target.nativeViewId,
            index: null, // Let the portal manager handle positioning
          );
          
          if (childViewId != null && childViewId.isNotEmpty) {
            renderedViewIds.add(childViewId);
            if (kDebugMode) {
              print('✅ EnhancedPortalManager: Rendered portal child $i with viewId: $childViewId');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ EnhancedPortalManager: Error rendering portal child $i: $e');
          }
        }
      }
      
      if (renderedViewIds.isNotEmpty) {
        // Store rendered view IDs for cleanup
        portal.renderedViewIds = renderedViewIds;
        
        // Update target with all portal content organized by priority
        await _updateTargetWithPortalContent(target);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ EnhancedPortalManager: Error rendering portal content: $e');
      }
    }
  }

  /// Update target with all portal content, respecting priority
  Future<void> _updateTargetWithPortalContent(PortalTarget target) async {
    try {
      // Get all portals for this target, sorted by priority
      final portals = getPortalsForTarget(target.targetId);
      
      // Collect all rendered view IDs in priority order
      final allPortalViewIds = <String>[];
      for (final portal in portals) {
        if (portal.renderedViewIds.isNotEmpty) {
          allPortalViewIds.addAll(portal.renderedViewIds);
        }
      }
      
      // Get existing non-portal children
      final currentChildren = _vdomApi.getCurrentChildren(target.nativeViewId);
      final existingChildren = currentChildren
          .where((viewId) => !_isPortalViewId(viewId))
          .toList();
      
      // Combine existing + portal content
      final newChildren = [...existingChildren, ...allPortalViewIds];
      
      if (kDebugMode) {
        print('🔄 EnhancedPortalManager: Updating target ${target.targetId} with ${newChildren.length} children');
        print('  - Existing: ${existingChildren.length}');
        print('  - Portal: ${allPortalViewIds.length}');
      }
      
      // Update target container
      await _vdomApi.updateTargetChildren(target.nativeViewId, newChildren);
    } catch (e) {
      if (kDebugMode) {
        print('❌ EnhancedPortalManager: Error updating target with portal content: $e');
      }
    }
  }

  /// Check if a view ID belongs to a portal
  bool _isPortalViewId(String viewId) {
    return _activePortals.values
        .any((portal) => portal.renderedViewIds.contains(viewId));
  }

  /// Create a missing target
  Future<void> _createMissingTarget(String targetId) async {
    try {
      if (kDebugMode) {
        print('🆕 EnhancedPortalManager: Creating missing target: $targetId');
      }
      
      final nativeViewId = await _vdomApi.createPortal(
        targetId,
        parentViewId: 'root',
        props: {
          'isAutoCreatedPortalTarget': true,
          'targetId': targetId,
        },
        index: 0,
      );
      
      registerTarget(
        targetId: targetId,
        nativeViewId: nativeViewId,
        metadata: {'autoCreated': true},
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ EnhancedPortalManager: Error creating missing target: $e');
      }
    }
  }

  /// Queue a portal for later processing
  void _queuePortal(PortalInstance portal) {
    if (!_queuedPortals.containsKey(portal.targetId)) {
      _queuedPortals[portal.targetId] = [];
    }
    _queuedPortals[portal.targetId]!.add(portal);
    
    if (kDebugMode) {
      print('⏳ EnhancedPortalManager: Queued portal ${portal.portalId} for target: ${portal.targetId}');
    }
  }

  /// Process queued portals for a target
  Future<void> _processQueuedPortalsForTarget(String targetId) async {
    final queuedPortals = _queuedPortals[targetId];
    if (queuedPortals == null || queuedPortals.isEmpty) return;
    
    if (kDebugMode) {
      print('🔄 EnhancedPortalManager: Processing ${queuedPortals.length} queued portals for target: $targetId');
    }
    
    for (final portal in queuedPortals) {
      await _renderPortalContent(portal);
      portal.onMount?.call(portal.portalId);
    }
    
    _queuedPortals.remove(targetId);
  }

  /// Clean up portal instance
  Future<void> _cleanupPortalInstance(PortalInstance portal) async {
    await _cleanupPortalContent(portal);
    _activePortals.remove(portal.portalId);
    portal.onUnmount?.call(portal.portalId);
  }

  /// Clean up portal content
  Future<void> _cleanupPortalContent(PortalInstance portal) async {
    if (portal.renderedViewIds.isEmpty) return;
    
    try {
      if (kDebugMode) {
        print('🧹 EnhancedPortalManager: Cleaning up ${portal.renderedViewIds.length} view IDs for portal: ${portal.portalId}');
      }
      
      // Store view IDs to delete
      final viewIdsToDelete = List<String>.from(portal.renderedViewIds);
      
      // Clear rendered view IDs first
      portal.renderedViewIds.clear();
      
      final target = _portalTargets[portal.targetId];
      if (target != null) {
        // Update target by removing portal content
        await _updateTargetWithPortalContent(target);
        
        // Explicitly delete the orphaned views
        try {
          await _vdomApi.deleteViews(viewIdsToDelete);
          if (kDebugMode) {
            print('✅ EnhancedPortalManager: Deleted ${viewIdsToDelete.length} orphaned views');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ EnhancedPortalManager: Error deleting views (may be normal): $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ EnhancedPortalManager: Error cleaning up portal content: $e');
      }
    }
  }

  /// Clean up orphaned portals for a specific target
  /// This prevents portal accumulation when components are conditionally rendered
  Future<void> _cleanupOrphanedPortalsForTarget(String targetId) async {
    if (kDebugMode) {
      print('🧹 EnhancedPortalManager: Checking for orphaned portals on target: $targetId');
    }
    
    final portalsForTarget = _activePortals.values
        .where((portal) => portal.targetId == targetId)
        .toList();
    
    if (portalsForTarget.length > 2) { // Allow some reasonable number
      if (kDebugMode) {
        print('⚠️ EnhancedPortalManager: Found ${portalsForTarget.length} portals for target $targetId, cleaning up oldest ones');
      }
      
      // Sort by creation time (older portal IDs have smaller timestamps)
      portalsForTarget.sort((a, b) => a.portalId.compareTo(b.portalId));
      
      // Keep only the 2 most recent portals, cleanup the rest
      final portalsToCleanup = portalsForTarget.take(portalsForTarget.length - 2).toList();
      
      for (final portal in portalsToCleanup) {
        if (kDebugMode) {
          print('🗑️ EnhancedPortalManager: Cleaning up orphaned portal: ${portal.portalId}');
        }
        await _cleanupPortalInstance(portal);
      }
    }
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'activePortals': _activePortals.length,
      'portalTargets': _portalTargets.length,
      'queuedPortals': _queuedPortals.values.fold(0, (sum, list) => sum + list.length),
      'operationInProgress': _operationInProgress,
      'pendingOperations': _pendingOperations.length,
      'targets': _portalTargets.keys.toList(),
      'portals': _activePortals.keys.toList(),
    };
  }
}

/// Represents a portal target
class PortalTarget {
  final String targetId;
  final String nativeViewId;
  final Map<String, dynamic> metadata;
  final int priority;

  PortalTarget({
    required this.targetId,
    required this.nativeViewId,
    required this.metadata,
    this.priority = 0,
  });
}

/// Represents a portal instance
class PortalInstance {
  final String portalId;
  final String targetId;
  final List<DCFComponentNode> children;
  final Map<String, dynamic> metadata;
  final int priority;
  final bool createTargetIfMissing;
  final Function(String portalId)? onMount;
  final Function(String portalId)? onUnmount;
  
  /// View IDs of rendered content (for cleanup)
  List<String> renderedViewIds = [];

  PortalInstance({
    required this.portalId,
    required this.targetId,
    required this.children,
    required this.metadata,
    this.priority = 0,
    this.createTargetIfMissing = false,
    this.onMount,
    this.onUnmount,
  });

  PortalInstance copyWith({
    List<DCFComponentNode>? children,
    Map<String, dynamic>? metadata,
    int? priority,
  }) {
    return PortalInstance(
      portalId: portalId,
      targetId: targetId,
      children: children ?? this.children,
      metadata: metadata ?? this.metadata,
      priority: priority ?? this.priority,
      createTargetIfMissing: createTargetIfMissing,
      onMount: onMount,
      onUnmount: onUnmount,
    )..renderedViewIds = List.from(renderedViewIds);
  }
}
