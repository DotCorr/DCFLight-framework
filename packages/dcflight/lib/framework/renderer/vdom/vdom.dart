/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:dcflight/framework/renderer/interface/interface.dart' show PlatformInterface;
import 'package:dcflight/framework/renderer/vdom/component/component.dart';
import 'package:dcflight/framework/renderer/vdom/component/error_boundary.dart';
export 'package:dcflight/framework/renderer/vdom/component/store.dart';
import 'package:dcflight/framework/renderer/vdom/component/dcf_element.dart';
import 'package:dcflight/framework/renderer/vdom/component/component_node.dart';
import 'package:dcflight/framework/renderer/vdom/component/fragment.dart';

/// Virtual DOM implementation with efficient reconciliation and state handling
class VDom {
  /// Native bridge for UI operations
  final PlatformInterface _nativeBridge;
  
  /// Whether the VDom is ready for use
  final Completer<void> _readyCompleter = Completer<void>();

  /// Counter for generating unique view IDs
  int _viewIdCounter = 1;
  
  /// Map of view IDs to their associated VDomNodes
  final Map<String, DCFComponentNode> _nodesByViewId = {};
  
  /// Map to track component instances by their instance ID
  final Map<String, StatefulComponent> _statefulComponents = {};
  
  /// Map to track components by their instance ID
  final Map<String, StatelessComponent> _statelessComponents = {};
  
  /// Map to track previous rendered nodes for components (for proper reconciliation)
  final Map<String, DCFComponentNode> _previousRenderedNodes = {};
  
  /// Pending component updates for batching
  final Set<String> _pendingUpdates = {};
  
  /// Flag to track if an update batch is scheduled
  bool _isUpdateScheduled = false;

  /// Flag to track batch updates in progress
  bool _batchUpdateInProgress = false;
  
  
  /// Root component for the application
  DCFComponentNode? rootComponent;
  
  /// Error boundary registry
  final Map<String, ErrorBoundary> _errorBoundaries = {};

  /// Create a new VDom instance with the provided native bridge
  VDom(this._nativeBridge) {
    _initialize();
  }

  /// Initialize the VDom with the native bridge
  Future<void> _initialize() async {
    try {
      // Initialize bridge
      final success = await _nativeBridge.initialize();
      if (!success) {
        throw Exception('Failed to initialize native bridge');
      }
      
      // Register event handler
      _nativeBridge.setEventHandler(_handleNativeEvent);
      
      // Mark as ready
      _readyCompleter.complete();
      
      if (kDebugMode) {
        developer.log('VDOM initialized successfully', name: 'VDOM');
      }
    } catch (e) {
      _readyCompleter.completeError(e);
      if (kDebugMode) {
        developer.log('Failed to initialize VDom: $e', name: 'VDom', error: e);
      }
    }
  }

  /// Future that completes when VDom is ready
  Future<void> get isReady => _readyCompleter.future;

  /// Generate a unique view ID
  String _generateViewId() {
    return (_viewIdCounter++).toString();
  }
  
  /// Register a component in the VDOM
  void registerComponent(DCFComponentNode component) {
    if (component is StatefulComponent) {
      _statefulComponents[component.instanceId] = component;
      component.scheduleUpdate = () => _scheduleComponentUpdate(component);
    } else if (component is StatelessComponent) {
      _statelessComponents[component.instanceId] = component;
    }
    
    // Register error boundary if applicable
    if (component is ErrorBoundary) {
      _errorBoundaries[component.instanceId] = component;
    }
  }
  
  /// Handle a native event by finding the appropriate component and calling its handler
  void _handleNativeEvent(
      String viewId, String eventType, Map<dynamic, dynamic> eventData) {
    final node = _nodesByViewId[viewId];
    if (node == null) {
      if (kDebugMode) {
        developer.log('⚠️ No node found for viewId: $viewId. Available viewIds: ${_nodesByViewId.keys.toList()}', name: 'VDom');
      }
      return;
    }

    if (kDebugMode) {
      developer.log('🎯 Handling event: $eventType for viewId: $viewId, node type: ${node.runtimeType}', name: 'VDom');
    }

    if (node is DCFElement) {
      // Try multiple event handler formats to ensure compatibility
      final eventHandlerKeys = [
        eventType,                    // exact match (e.g., 'onScroll')
        'on${eventType.substring(0, 1).toUpperCase()}${eventType.substring(1)}', // onEventName format
        eventType.toLowerCase(),      // lowercase
        'on${eventType.toLowerCase().substring(0, 1).toUpperCase()}${eventType.toLowerCase().substring(1)}' // normalized
      ];
      
      if (kDebugMode) {
        developer.log('🔍 Trying event handler keys: $eventHandlerKeys', name: 'VDom');
        developer.log('🔍 Available props: ${node.props.keys.toList()}', name: 'VDom');
      }
      
      for (final key in eventHandlerKeys) {
        if (node.props.containsKey(key) && node.props[key] is Function) {
          if (kDebugMode) {
            developer.log('✅ Found event handler for key: $key', name: 'VDom');
          }
          _executeEventHandler(node.props[key], eventData);
          return;
        }
      }
      
      if (kDebugMode) {
        developer.log('❌ No event handler found for event: $eventType', name: 'VDom');
      }
    }
  }

  /// Execute an event handler with proper error handling and flexible signatures
  void _executeEventHandler(Function handler, Map<dynamic, dynamic> eventData) {
    try {
      // Use reflection to determine the function signature and call appropriately
      // This approach handles ANY function signature dynamically
      
      // Try calling with Map<String, dynamic> first (most common for events)
      try {
        // Use Function.apply for maximum flexibility - handles any signature
        if (eventData.isNotEmpty) {
          // Try with eventData as the first parameter
          Function.apply(handler, [eventData]);
        } else {
          // Try with no parameters for simple events
          Function.apply(handler, []);
        }
        return;
      } catch (e) {
        // If that fails, try other common patterns
      }
      
      // // Try specific patterns for common event types
      // if (eventData.containsKey('text')) {
      //   // Handle TextInput onChangeText events that expect a string parameter
      //   try {
      //     final text = eventData['text'] as String? ?? '';
      //     Function.apply(handler, [text]);
      //     return;
      //   } catch (e) {
      //     // Continue to next pattern
      //   }
      // }
      
      if (eventData.containsKey('width') && eventData.containsKey('height')) {
        // Handle onContentSizeChange events that might expect (double, double)
        try {
          final width = eventData['width'] as double? ?? 0.0;
          final height = eventData['height'] as double? ?? 0.0;
          Function.apply(handler, [width, height]);
          return;
        } catch (e) {
          // Continue to next pattern
        }
      }
      
      // Try with no parameters (for simple click events)
      try {
        Function.apply(handler, []);
        return;
      } catch (e) {
        // Continue to final fallback
      }
      
      // Final fallback - try dynamic invocation
      try {
        (handler as dynamic)(eventData);
      } catch (e) {
        if (kDebugMode) {
          developer.log('❌ Could not execute event handler with any signature: $e', 
              name: 'VDom', error: e);
        }
      }
      
    } catch (e, stack) {
      if (kDebugMode) {
        developer.log('❌ Error executing event handler: $e', 
            name: 'VDom', error: e, stackTrace: stack);
      }
    }
  }

  /// Schedule a component update when state changes
  /// This is a key method that triggers UI updates after state changes
  void _scheduleComponentUpdate(StatefulComponent component) {
    if (kDebugMode) {
      print('Scheduling update for component: ${component.instanceId} (${component.runtimeType})');
    }
    
    // Verify component is still registered
    if (!_statefulComponents.containsKey(component.instanceId)) {
      if (kDebugMode) {
        print('Warning: Attempting to update unregistered component: ${component.instanceId}');
      }
      // Re-register the component to ensure it's tracked
      registerComponent(component);
    }
    
    // Only add this specific component to the update queue
    // Don't cascade to parent components to prevent infinite loops
    _pendingUpdates.add(component.instanceId);
    
    // Only schedule a new update if one isn't already scheduled
    if (!_isUpdateScheduled) {
      _isUpdateScheduled = true;

      // Schedule updates asynchronously to batch multiple updates
      // Use a very short delay to allow multiple state changes to be batched together
      // but maintain responsiveness
      Future.microtask(_processPendingUpdates);
    }
  }

  /// Process all pending component updates in a batch
  Future<void> _processPendingUpdates() async {
    // Prevent re-entry during batch processing
    if (_batchUpdateInProgress) {
      return;
    }
    
    _batchUpdateInProgress = true;
    
    try {
      if (_pendingUpdates.isEmpty) {
        _isUpdateScheduled = false;
        _batchUpdateInProgress = false;
        return;
      }

      if (kDebugMode) {
        print('Processing ${_pendingUpdates.length} pending updates');
      }

      // Copy the pending updates to allow for new ones during processing
      final updates = Set<String>.from(_pendingUpdates);
      _pendingUpdates.clear();
      
      // Start batch update in native layer
      await _nativeBridge.startBatchUpdate();
      
      try {
        // Process each component update
        for (final componentId in updates) {
          await _updateComponentById(componentId);
        }
        
        // Commit all batched updates at once
        await _nativeBridge.commitBatchUpdate();
        
        // Layout is now calculated automatically when layout props change
        // No manual layout calculation needed
      } catch (e) {
        // Cancel batch if there's an error
        await _nativeBridge.cancelBatchUpdate();
        rethrow;
      }

      // Check if new updates were scheduled during processing
      if (_pendingUpdates.isNotEmpty) {
        // Process new updates in next microtask
        if (kDebugMode) {
          print('Scheduling another update batch for ${_pendingUpdates.length} components');
        }
        Future.microtask(_processPendingUpdates);
      } else {
        _isUpdateScheduled = false;
      }
    } catch (e, stack) {
      if (kDebugMode) {
        developer.log('Error processing updates: $e', 
            name: 'VDom', error: e, stackTrace: stack);
      }
    } finally {
      _batchUpdateInProgress = false;
    }
  }

  /// Update a component by its ID
  Future<void> _updateComponentById(String componentId) async {
    final component = _statefulComponents[componentId] ?? _statelessComponents[componentId];
    if (component == null) {
      if (kDebugMode) {
        print('⚠️ Cannot update component - not found: $componentId');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🔧 Updating component: $componentId (${component.runtimeType})');
      }
      
      // Perform component-specific update preparation
      if (component is StatefulComponent) {
        component.prepareForRender();
      }

      // Store the previous rendered node before re-rendering
      final oldRenderedNode = component.renderedNode;
      
      // Store a reference to the old rendered node for proper reconciliation
      if (oldRenderedNode != null) {
        _previousRenderedNodes[componentId] = oldRenderedNode;
        if (kDebugMode) {
          print('📝 Stored previous rendered node: ${oldRenderedNode.runtimeType} (key: ${oldRenderedNode.key})');
        }
      }
      
      // Force re-render by clearing cached rendered node
      component.renderedNode = null;
      final newRenderedNode = component.renderedNode;
      
      if (kDebugMode) {
        print('🆕 New rendered node: ${newRenderedNode?.runtimeType} (key: ${newRenderedNode?.key})');
      }
      
      if (newRenderedNode == null) {
        if (kDebugMode) {
          developer.log('Component rendered null: $componentId', name: 'VDom');
        }
        return;
      }

      // Set parent relationship for the new rendered node
      newRenderedNode.parent = component;
      
      // Reconcile trees to apply minimal changes
      final previousRenderedNode = _previousRenderedNodes[componentId];
      if (previousRenderedNode != null) {
        // Find parent native view ID and index for replacement
        final parentViewId = _findParentViewId(component);
        
        if (kDebugMode) {
          print('🔄 Reconciling from old node (${previousRenderedNode.runtimeType}): ' +
              '${previousRenderedNode.effectiveNativeViewId} to new node (${newRenderedNode.runtimeType})');
          print('🔑 Key comparison: "${previousRenderedNode.key}" vs "${newRenderedNode.key}"');
        }
        
        if (previousRenderedNode.effectiveNativeViewId == null || parentViewId == null) {
          // For problematic components or when we don't have required IDs, use standard reconciliation
          await _reconcile(previousRenderedNode, newRenderedNode);
          
          // Update contentViewId reference from old to new
          if (previousRenderedNode.effectiveNativeViewId != null) {
            component.contentViewId = previousRenderedNode.effectiveNativeViewId;
          }
        } else {
          // Reconcile to preserve structure and update props efficiently
          await _reconcile(previousRenderedNode, newRenderedNode);
          
          // Update contentViewId reference
          component.contentViewId = previousRenderedNode.effectiveNativeViewId;
        }
        
        // Clean up the stored previous rendered node
        _previousRenderedNodes.remove(componentId);
      } else {
        // No previous rendering, create from scratch
        final parentViewId = _findParentViewId(component);
        if (parentViewId != null) {
          if (kDebugMode) {
            print('Creating new rendered node for component with parent: $parentViewId');
          }
          final newViewId = await renderToNative(newRenderedNode, parentViewId: parentViewId);
          if (newViewId != null) {
            component.contentViewId = newViewId;
          }
        } else if (kDebugMode) {
          print('Cannot create new rendered node: parent viewId not found');
        }
      }

      // Run lifecycle methods
      if (component is StatefulComponent) {
        component.componentDidUpdate({});
        component.runEffectsAfterRender();
      }
    } catch (e, stack) {
      if (kDebugMode) {
        developer.log('Error updating component: $e', 
            name: 'VDom', error: e, stackTrace: stack);
      }
    }
  }

  // REMOVED: calculateAndApplyLayout method
  // Layout is now calculated automatically when layout props change

  /// Render a node to native UI
  Future<String?> renderToNative(DCFComponentNode node,
      {String? parentViewId, int? index}) async {
    await isReady;

    try {
      // Handle Fragment nodes
      if (node is DCFFragment) {
        // Mount the fragment
        if (!node.isMounted) {
          node.mount(node.parent);
        }
        
        // Check if this fragment is a portal placeholder
        if (node.metadata != null && node.metadata!['isPortalPlaceholder'] == true) {
          // This is a portal placeholder fragment - the enhanced portal manager
          // handles rendering the children to the target
          final targetId = node.metadata!['targetId'] as String?;
          final portalId = node.metadata!['portalId'] as String?;
          
          if (targetId != null && portalId != null) {
            // Portal placeholder fragments don't render anything here
            // The enhanced portal manager handles all the portal logic
            
            if (kDebugMode) {
              print('🎯 VDom: Portal placeholder fragment for target: $targetId, portal: $portalId');
            }
            
            return null; // Portal placeholders have no native view
          }
        }
        
        // Check if this fragment is a portal target
        if (node.metadata != null && node.metadata!['isPortalTarget'] == true) {
          final targetId = node.metadata!['targetId'] as String?;
          
          if (targetId != null) {
            if (kDebugMode) {
              print('🎯 VDom: Portal target fragment: $targetId');
            }
            
            // For portal targets, we should render normally but also allow
            // the portal manager to inject content
            // The enhanced portal manager will handle the portal content injection
          }
        }
        
        // Regular fragment - render children directly to parent
        int childIndex = index ?? 0;
        final childIds = <String>[];
        
        for (final child in node.children) {
          final childId = await renderToNative(
            child,
            parentViewId: parentViewId,
            index: childIndex++,
          );
          
          if (childId != null && childId.isNotEmpty) {
            childIds.add(childId);
          }
        }
        
        // Store child IDs for cleanup later
        node.childViewIds = childIds;
        
        return null; // Fragments don't have their own native view ID
      }

      // Handle Component nodes
      if (node is StatefulComponent || node is StatelessComponent) {
        try {
          // Register the component
          registerComponent(node);
          
          // Get the rendered content
          final renderedNode = node.renderedNode;
          if (renderedNode == null) {
            throw Exception('Component rendered null');
          }
          
          // Set parent relationship
          renderedNode.parent = node;

          // Render the content
          final viewId = await renderToNative(renderedNode, parentViewId: parentViewId, index: index);
          
          // Store the view ID
          node.contentViewId = viewId;
          
          // Call lifecycle method if not already mounted
          if (node is StatefulComponent && !node.isMounted) {
            node.componentDidMount();
          } else if (node is StatelessComponent && !node.isMounted) {
            node.componentDidMount();
          }
          
          // Run effects for stateful components
          if (node is StatefulComponent) {
            node.runEffectsAfterRender();
          }
          
          return viewId;
        } catch (error, stackTrace) {
          // Try to find nearest error boundary
          final errorBoundary = _findNearestErrorBoundary(node);
          if (errorBoundary != null) {
            errorBoundary.handleError(error, stackTrace);
            return null; // Error handled by boundary
          }
          
          // No error boundary, propagate error
          rethrow;
        }
      } 
      // Handle Element nodes
      else if (node is DCFElement) {
        return await _renderElementToNative(node, parentViewId: parentViewId, index: index);
      } 
      // Handle EmptyVDomNode
      else if (node is EmptyVDomNode) {
        return null; // Empty nodes don't create native views
      }

      return null;
    } catch (e, stack) {
      if (kDebugMode) {
        developer.log('Error rendering node: $e', 
            name: 'VDom', error: e, stackTrace: stack);
      }
      return null;
    }
  }

  /// Render an element to native UI
  Future<String?> _renderElementToNative(DCFElement element,
      {String? parentViewId, int? index}) async {
    // Use existing view ID or generate a new one
    final viewId = element.nativeViewId ?? _generateViewId();

    // Store map from view ID to node
    _nodesByViewId[viewId] = element;
    element.nativeViewId = viewId;

    // Create the view
    final success = await _nativeBridge.createView(viewId, element.type, element.props);
    if (!success) {
      if (kDebugMode) {
        developer.log('Failed to create view: $viewId of type ${element.type}',
            name: 'VDom');
      }
      return null;
    }

    // If parent is specified, attach to parent
    if (parentViewId != null) {
      await _nativeBridge.attachView(viewId, parentViewId, index ?? 0);
    }

    // Register event listeners
    final eventTypes = element.eventTypes;
    if (eventTypes.isNotEmpty) {
      await _nativeBridge.addEventListeners(viewId, eventTypes);
    }

    // Render children
    final childIds = <String>[];

    for (var i = 0; i < element.children.length; i++) {
      final childId = await renderToNative(element.children[i], parentViewId: viewId, index: i);
      if (childId != null && childId.isNotEmpty) {
        childIds.add(childId);
      }
    }

    // Set children order
    if (childIds.isNotEmpty) {
      await _nativeBridge.setChildren(viewId, childIds);
    }

    return viewId;
  }

  /// Reconcile two nodes by efficiently updating only what changed
  Future<void> _reconcile(DCFComponentNode oldNode, DCFComponentNode newNode) async {
    // Transfer important parent reference first
    newNode.parent = oldNode.parent;
    
    if (kDebugMode) {
      print('Reconciling ${oldNode.runtimeType} to ${newNode.runtimeType}');
      print('Old key: ${oldNode.key}, New key: ${newNode.key}');
    }

    // If the node types are completely different, replace the node entirely
    if (oldNode.runtimeType != newNode.runtimeType) {
      if (kDebugMode) {
        print('Different node types: ${oldNode.runtimeType} -> ${newNode.runtimeType}');
      }
      await _replaceNode(oldNode, newNode);
      return;
    }

    // CRITICAL HOT RELOAD FIX: If the keys are different, replace the component entirely
    // This ensures that when we change component keys (like 'app_1' to 'app_2'), 
    // a completely new component instance is created instead of trying to update the existing one
    if (oldNode.key != newNode.key) {
      if (kDebugMode) {
        print('Different keys detected: ${oldNode.key} -> ${newNode.key}, replacing component');
      }
      await _replaceNode(oldNode, newNode);
      return;
    }

    // Handle different node types
    if (oldNode is DCFElement && newNode is DCFElement) {
      // If different element types, we need to replace it
      if (oldNode.type != newNode.type) {
        await _replaceNode(oldNode, newNode);
      } else {
        // Same element type - update props and children only
        await _reconcileElement(oldNode, newNode);
      }
    } 
    // Handle component nodes
    else if (oldNode is StatefulComponent && newNode is StatefulComponent) {
      // Transfer important properties between nodes
      newNode.nativeViewId = oldNode.nativeViewId;
      newNode.contentViewId = oldNode.contentViewId;
      
      // Update component tracking
      _statefulComponents[newNode.instanceId] = newNode;
      newNode.scheduleUpdate = oldNode.scheduleUpdate;
      
      // Register the new component instance
      registerComponent(newNode);
      
      // Handle reconciliation of the rendered trees
      final oldRenderedNode = oldNode.renderedNode;
      final newRenderedNode = newNode.renderedNode;
      
      // Standard reconciliation for components
      await _reconcile(oldRenderedNode, newRenderedNode);
        }
    // Handle stateless components
    else if (oldNode is StatelessComponent && newNode is StatelessComponent) {
      // Transfer IDs
      newNode.nativeViewId = oldNode.nativeViewId;
      newNode.contentViewId = oldNode.contentViewId;
      
      // Handle reconciliation of the rendered trees
      final oldRenderedNode = oldNode.renderedNode;
      final newRenderedNode = newNode.renderedNode;
      
      await _reconcile(oldRenderedNode, newRenderedNode);
        }
    // Handle Fragment nodes
    else if (oldNode is DCFFragment && newNode is DCFFragment) {
      // Transfer children relationships
      newNode.parent = oldNode.parent;
      newNode.childViewIds = oldNode.childViewIds;
      
      // Reconcile fragment children directly since fragments don't have native view IDs
      if (oldNode.children.isNotEmpty || newNode.children.isNotEmpty) {
        // Find the parent view ID to reconcile children against
        final parentViewId = _findParentViewId(oldNode);
        if (parentViewId != null) {
          await _reconcileFragmentChildren(parentViewId, oldNode.children, newNode.children);
        }
      }
    }
    // Handle empty nodes
    else if (oldNode is EmptyVDomNode && newNode is EmptyVDomNode) {
      // Nothing to do for empty nodes
      return;
    }
  }
  
  // No special handling for specific component types - all components are treated equally
  
  /// Replace a node entirely
  Future<void> _replaceNode(DCFComponentNode oldNode, DCFComponentNode newNode) async {
    if (kDebugMode) {
      print('🔄 Replacing node: ${oldNode.runtimeType} (key: ${oldNode.key}) -> ${newNode.runtimeType} (key: ${newNode.key})');
    }
    
    // CRITICAL HOT RELOAD FIX: Properly dispose of old component instances
    await _disposeOldComponent(oldNode);
    
    // Can't replace if the old node has no view ID
    if (oldNode.effectiveNativeViewId == null) {
      return;
    }

    // Find parent info for placing the new node
    final parentViewId = _findParentViewId(oldNode);
    if (parentViewId == null) {
      if (kDebugMode) {
        developer.log('Failed to find parent ID for node replacement', name: 'VDom');
      }
      return;
    }

    // Find index of node in parent
    final index = _findNodeIndexInParent(oldNode);

    // CRITICAL FIX: Temporarily exit batch mode to ensure atomic delete+create
    // This prevents createView from being queued while deleteView executes immediately
    final wasBatchMode = _batchUpdateInProgress;
    if (wasBatchMode) {
      // Temporarily commit current batch to ensure proper ordering
      await _nativeBridge.commitBatchUpdate();
      _batchUpdateInProgress = false;
    }

    try {
      // Store the old view ID and event types for reuse
      final oldViewId = oldNode.effectiveNativeViewId!;
      final oldEventTypes = (oldNode is DCFElement) ? oldNode.eventTypes : <String>[];
      final newEventTypes = (newNode is DCFElement) ? newNode.eventTypes : <String>[];
      
      // Special case: If new node is a component that renders a fragment (like DCFPortal)
      if (newNode is StatefulComponent || newNode is StatelessComponent) {
        final renderedNode = newNode.renderedNode;
        if (renderedNode is DCFFragment) {
          if (kDebugMode) {
            print('🎯 Component renders fragment - deleting old view ID: $oldViewId');
          }
          
          // Delete the old view since the component renders a fragment
          await _nativeBridge.deleteView(oldViewId);
          _nodesByViewId.remove(oldViewId);
          
          // Render the component normally to parent
          await renderToNative(newNode, parentViewId: parentViewId, index: index);
          
          if (kDebugMode) {
            print('✅ Component-to-fragment replacement completed');
          }
          return;
        }
      }
      
      // CRITICAL EVENT FIX: Instead of deleting and recreating the view,
      // reuse the same view ID to preserve native event listener connections
      newNode.nativeViewId = oldViewId;
      
      // Update the mapping to point to the new node IMMEDIATELY
      _nodesByViewId[oldViewId] = newNode;
      
      if (kDebugMode) {
        print('🔄 Reusing view ID $oldViewId for node replacement');
        print('🎯 Old events: $oldEventTypes');
        print('🎯 New events: $newEventTypes');
      }
      
      // Only update event listeners if they changed
      final oldEventSet = Set<String>.from(oldEventTypes);
      final newEventSet = Set<String>.from(newEventTypes);
      
      if (oldEventSet.length != newEventSet.length || !oldEventSet.containsAll(newEventSet)) {
        // Remove old event listeners that are no longer needed
        final eventsToRemove = oldEventSet.difference(newEventSet);
        if (eventsToRemove.isNotEmpty) {
          if (kDebugMode) {
            print('🗑️ Removing obsolete event listeners: $eventsToRemove');
          }
          await _nativeBridge.removeEventListeners(oldViewId, eventsToRemove.toList());
        }
        
        // Add new event listeners
        final eventsToAdd = newEventSet.difference(oldEventSet);
        if (eventsToAdd.isNotEmpty) {
          if (kDebugMode) {
            print('➕ Adding new event listeners: $eventsToAdd');
          }
          await _nativeBridge.addEventListeners(oldViewId, eventsToAdd.toList());
        }
      }
      
      // Delete the old view completely (this will create a new native view)
      await _nativeBridge.deleteView(oldViewId);
      
      // Create the new view with the preserved view ID
      final newViewId = await renderToNative(newNode, parentViewId: parentViewId, index: index);
      
      // Verify the view creation was successful
      if (newViewId != null && newViewId.isNotEmpty) {
        if (kDebugMode) {
          print('✅ New view created with preserved ID: $newViewId');
          print('🎯 _nodesByViewId mapping confirmed for: $newViewId -> ${_nodesByViewId[newViewId]?.runtimeType}');
        }
      } else {
        if (kDebugMode) {
          print('❌ Failed to create new view for node replacement');
        }
      }
    } finally {
      // Resume batch mode if we were previously in batch mode
      if (wasBatchMode) {
        await _nativeBridge.startBatchUpdate();
        _batchUpdateInProgress = true;
      }
    }
    
    if (kDebugMode) {
      print('✅ Node replacement completed');
    }
  }

  /// Dispose of old component instance and clean up its state
  Future<void> _disposeOldComponent(DCFComponentNode oldNode) async {
    if (kDebugMode) {
      print('🗑️ Disposing old component: ${oldNode.runtimeType} (${oldNode.key})');
    }
    
    try {
      // Handle StatefulComponent disposal
      if (oldNode is StatefulComponent) {
        if (kDebugMode) {
          print('🗑️ Cleaning up StatefulComponent: ${oldNode.instanceId}');
        }
        
        // Remove from component tracking FIRST to prevent further updates
        _statefulComponents.remove(oldNode.instanceId);
        _pendingUpdates.remove(oldNode.instanceId);
        _previousRenderedNodes.remove(oldNode.instanceId);
        
        // Call lifecycle cleanup
        try {
          oldNode.componentWillUnmount();
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error during componentWillUnmount: $e');
          }
        }
        
        // Recursively dispose rendered content
        await _disposeOldComponent(oldNode.renderedNode);
              
        if (kDebugMode) {
          print('✅ StatefulComponent disposed: ${oldNode.instanceId}');
        }
      }
      // Handle StatelessComponent disposal  
      else if (oldNode is StatelessComponent) {
        if (kDebugMode) {
          print('🗑️ Cleaning up StatelessComponent: ${oldNode.instanceId}');
        }
        
        // Remove from component tracking
        _statelessComponents.remove(oldNode.instanceId);
        
        // Call lifecycle cleanup
        try {
          oldNode.componentWillUnmount();
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error during componentWillUnmount: $e');
          }
        }
        
        // Recursively dispose rendered content
        await _disposeOldComponent(oldNode.renderedNode);
              
        if (kDebugMode) {
          print('✅ StatelessComponent disposed: ${oldNode.instanceId}');
        }
      }
      // Handle DCFElement disposal
      else if (oldNode is DCFElement) {
        // Recursively dispose child components
        for (final child in oldNode.children) {
          await _disposeOldComponent(child);
        }
      }
      
      // Remove from view tracking
      if (oldNode.effectiveNativeViewId != null) {
        _nodesByViewId.remove(oldNode.effectiveNativeViewId);
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error disposing component: $e');
      }
    }
  }

  /// Find a node's parent view ID
  String? _findParentViewId(DCFComponentNode node) {
    DCFComponentNode? current = node.parent;
    
    // Find the first parent with a native view ID
    while (current != null) {
      final viewId = current.effectiveNativeViewId;
      if (viewId != null && viewId.isNotEmpty) {
        return viewId;
      }
      current = current.parent;
    }
    
    // Default to root if no parent found
    return "root";
  }

  /// Find a node's index in its parent's children
  int _findNodeIndexInParent(DCFComponentNode node) {
    // Can't determine index without parent
    if (node.parent == null) return 0;
    
    // Only element parents can have indexed children
    if (node.parent is! DCFElement) return 0;
    
    final parent = node.parent as DCFElement;
    return parent.children.indexOf(node);
  }

  /// Reconcile an element - update props and children
  Future<void> _reconcileElement(DCFElement oldElement, DCFElement newElement) async {
    // Update properties if the element has a native view
    if (oldElement.nativeViewId != null) {
      // Copy native view ID to new element for tracking
      newElement.nativeViewId = oldElement.nativeViewId;
      
      // CRITICAL FIX: Always update the tracking map to maintain event handler lookup
      // This ensures scroll views and other event-emitting components stay connected
      _nodesByViewId[oldElement.nativeViewId!] = newElement;
      
      // CRITICAL EVENT FIX: Handle event registration changes during reconciliation
      final oldEventTypes = oldElement.eventTypes;
      final newEventTypes = newElement.eventTypes;
      
      // Check if event types have changed
      final oldEventSet = Set<String>.from(oldEventTypes);
      final newEventSet = Set<String>.from(newEventTypes);
      
      if (oldEventSet.length != newEventSet.length || !oldEventSet.containsAll(newEventSet)) {
        if (kDebugMode) {
          print('🎯 Event types changed for ${oldElement.type} (${oldElement.nativeViewId}):');
          print('  Old events: $oldEventTypes');
          print('  New events: $newEventTypes');
        }
        
        // Remove old event listeners that are no longer needed
        final eventsToRemove = oldEventSet.difference(newEventSet);
        if (eventsToRemove.isNotEmpty) {
          await _nativeBridge.removeEventListeners(oldElement.nativeViewId!, eventsToRemove.toList());
        }
        
        // Add new event listeners
        final eventsToAdd = newEventSet.difference(oldEventSet);
        if (eventsToAdd.isNotEmpty) {
          await _nativeBridge.addEventListeners(oldElement.nativeViewId!, eventsToAdd.toList());
        }
      }
      
      // Find changed props using proper diffing algorithm
      final changedProps = _diffProps(oldElement.props, newElement.props);
      
   
      
      // Update props if there are changes
      if (changedProps.isNotEmpty) {
        if (kDebugMode) {
          print('Updating props for ${oldElement.type} (${oldElement.nativeViewId}): $changedProps');
        }
        
        // Update the native view
        await _nativeBridge.updateView(oldElement.nativeViewId!, changedProps);
      }
      
      // Now reconcile children with the most efficient algorithm
      await _reconcileChildren(oldElement, newElement);
    }
  }

  /// Compute differences between two prop maps
  Map<String, dynamic> _diffProps(Map<String, dynamic> oldProps, Map<String, dynamic> newProps) {
    final changedProps = <String, dynamic>{};
    
    // Find added or changed props
    for (final entry in newProps.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // Skip function handlers - they're managed separately by event system
      if (value is Function) continue;
      
      // Add to changes if prop is new or has different value
      if (!oldProps.containsKey(key) || oldProps[key] != value) {
        changedProps[key] = value;
      }
    }
    
    // Find removed props (set to null to delete)
    for (final key in oldProps.keys) {
      if (!newProps.containsKey(key) && oldProps[key] is! Function) {
        changedProps[key] = null;
      }
    }
    
    // Handle event handlers - preserve them if not changed
    for (final key in oldProps.keys) {
      if (key.startsWith('on') && 
          oldProps[key] is Function &&
          !newProps.containsKey(key)) {
        changedProps[key] = oldProps[key];
      }
    }
    
    return changedProps;
  }

  /// Reconcile children with keyed optimization
  Future<void> _reconcileChildren(DCFElement oldElement, DCFElement newElement) async {
    final oldChildren = oldElement.children;
    final newChildren = newElement.children;
    
    // Fast path: no children
    if (oldChildren.isEmpty && newChildren.isEmpty) return;
    
    // Check if children have keys for optimized reconciliation
    final hasKeys = _childrenHaveKeys(newChildren);
    
    if (hasKeys) {
      await _reconcileKeyedChildren(
        oldElement.nativeViewId!, 
        oldChildren, 
        newChildren
      );
    } else {
      await _reconcileSimpleChildren(
        oldElement.nativeViewId!, 
        oldChildren, 
        newChildren
      );
    }
  }

  /// Check if any children have explicit keys
  bool _childrenHaveKeys(List<DCFComponentNode> children) {
    if (children.isEmpty) return false;
    
    for (var child in children) {
      if (child.key != null) return true;
    }
    
    return false;
  }

  /// Reconcile fragment children directly without a container element
  Future<void> _reconcileFragmentChildren(String parentViewId, 
      List<DCFComponentNode> oldChildren, List<DCFComponentNode> newChildren) async {
    // Use the same reconciliation logic as elements but for fragment children
    final hasKeys = _childrenHaveKeys(newChildren);
    
    if (hasKeys) {
      await _reconcileKeyedChildren(parentViewId, oldChildren, newChildren);
    } else {
      await _reconcileSimpleChildren(parentViewId, oldChildren, newChildren);
    }
  }

  /// Reconcile children with keys for optimal reordering
  Future<void> _reconcileKeyedChildren(String parentViewId, 
      List<DCFComponentNode> oldChildren, List<DCFComponentNode> newChildren) async {
    // Create map of old children by key for O(1) lookup
    final oldChildrenMap = <String?, DCFComponentNode>{};
    final oldChildOrderByKey = <String?, int>{};
    for (int i = 0; i < oldChildren.length; i++) {
      final oldChild = oldChildren[i];
      final key = oldChild.key ?? i.toString(); // Use index for null keys
      oldChildrenMap[key] = oldChild;
      oldChildOrderByKey[key] = i;
    }
    
    // Track children that need to be in final list
    final updatedChildIds = <String>[];
    final processedOldChildren = <DCFComponentNode>{};
    bool hasStructuralChanges = false;
    
    // Process each new child
    for (int i = 0; i < newChildren.length; i++) {
      final newChild = newChildren[i];
      final key = newChild.key ?? i.toString();
      final oldChild = oldChildrenMap[key];
      
      String? childViewId;
      
      if (oldChild != null) {
        // Mark as processed
        processedOldChildren.add(oldChild);
        
        // Update existing child
        await _reconcile(oldChild, newChild);
        
        // Get the view ID (which might come from different sources)
        childViewId = oldChild.effectiveNativeViewId;
        
        // Check if the position changed (reordering)
        final oldIndex = oldChildOrderByKey[key];
        if (oldIndex != null && oldIndex != i) {
          hasStructuralChanges = true;
          // Update position if needed
          if (childViewId != null) {
            await _moveChild(childViewId, parentViewId, i);
          }
        }
      } else {
        // Create new child - this is a structural change
        hasStructuralChanges = true;
        childViewId = await renderToNative(newChild, parentViewId: parentViewId, index: i);
      }
      
      // Add to updated children list
      if (childViewId != null) {
        updatedChildIds.add(childViewId);
      }
    }
    
    // Remove old children that aren't in the new list
    for (var oldChild in oldChildren) {
      if (!processedOldChildren.contains(oldChild)) {
        hasStructuralChanges = true; // Removal is a structural change
        
        // CRITICAL FIX: Call componentWillUnmount on removed components
        try {
          oldChild.componentWillUnmount();
          if (kDebugMode) {
            print('🗑️ Called componentWillUnmount on removed keyed child: ${oldChild.runtimeType}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error during componentWillUnmount on removed keyed child: $e');
          }
        }
        
        final viewId = oldChild.effectiveNativeViewId;
        if (viewId != null) {
          await _nativeBridge.deleteView(viewId);
          _nodesByViewId.remove(viewId);
        }
      }
    }
    
    // Only call setChildren if there were structural changes (additions, removals, or reorders)
    if (hasStructuralChanges && updatedChildIds.isNotEmpty) {
      if (kDebugMode) {
        print('🔄 Calling setChildren due to structural changes in keyed reconciliation');
      }
      await _nativeBridge.setChildren(parentViewId, updatedChildIds);
    }
  }

  /// Reconcile children without keys (simpler algorithm)
  Future<void> _reconcileSimpleChildren(String parentViewId, 
      List<DCFComponentNode> oldChildren, List<DCFComponentNode> newChildren) async {
    final updatedChildIds = <String>[];
    final commonLength = math.min(oldChildren.length, newChildren.length);
    bool hasStructuralChanges = false;
    
    // Update common children
    for (int i = 0; i < commonLength; i++) {
      final oldChild = oldChildren[i];
      final newChild = newChildren[i];
      
      // Reconcile the child
      await _reconcile(oldChild, newChild);
      
      // Add to updated children
      final childViewId = oldChild.effectiveNativeViewId;
      if (childViewId != null) {
        updatedChildIds.add(childViewId);
      }
    }
    
    // Handle length differences
    if (newChildren.length > oldChildren.length) {
      // Add any extra new children - this is a structural change
      hasStructuralChanges = true;
      for (int i = commonLength; i < newChildren.length; i++) {
        final childViewId = await renderToNative(
          newChildren[i], 
          parentViewId: parentViewId, 
          index: i
        );
        
        if (childViewId != null) {
          updatedChildIds.add(childViewId);
        }
      }
    } else if (oldChildren.length > newChildren.length) {
      // Remove any extra old children - this is a structural change
      hasStructuralChanges = true;
      for (int i = commonLength; i < oldChildren.length; i++) {
        final oldChild = oldChildren[i];
        
        // CRITICAL FIX: Call componentWillUnmount on removed components
        try {
          oldChild.componentWillUnmount();
          if (kDebugMode) {
            print('🗑️ Called componentWillUnmount on removed child: ${oldChild.runtimeType}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error during componentWillUnmount on removed child: $e');
          }
        }
        
        final viewId = oldChild.effectiveNativeViewId;
        if (viewId != null) {
          await _nativeBridge.deleteView(viewId);
          _nodesByViewId.remove(viewId);
        }
      }
    }
    
    // Only call setChildren if there were structural changes (additions or removals)
    if (hasStructuralChanges && updatedChildIds.isNotEmpty) {
      if (kDebugMode) {
        print('🔄 Calling setChildren due to structural changes in simple reconciliation');
      }
      await _nativeBridge.setChildren(parentViewId, updatedChildIds);
    }
  }

  /// Move a child to a specific index in its parent
  Future<void> _moveChild(String childId, String parentId, int index) async {
    // Detach and then attach again at the right position
    await _nativeBridge.detachView(childId);
    await _nativeBridge.attachView(childId, parentId, index);
  }

  /// Find the nearest error boundary
  ErrorBoundary? _findNearestErrorBoundary(DCFComponentNode node) {
    DCFComponentNode? current = node;
    
    while (current != null) {
      if (current is ErrorBoundary) {
        return current;
      }
      current = current.parent;
    }
    
    return null;
  }

  /// Create the root component for the application
  Future<void> createRoot(DCFComponentNode component) async {
    if (kDebugMode) {
      print('🌱 Creating root with component: ${component.runtimeType} (key: ${component.key})');
    }
    
    // If there's already a root component, reconcile instead of just replacing
    if (rootComponent != null) {
      if (kDebugMode) {
        print('🔄 Existing root found, performing reconciliation...');
        print('🔄 Old root: ${rootComponent!.runtimeType} (key: ${rootComponent!.key})');
        print('🔄 New root: ${component.runtimeType} (key: ${component.key})');
      }
      
      // Perform reconciliation between old and new root
      await _reconcile(rootComponent!, component);
      
      // Update the root component reference
      rootComponent = component;
    } else {
      // First time creating root
      if (kDebugMode) {
        print('🆕 First time creating root component');
      }
      rootComponent = component;
      
      // Register the component with this VDOM
      registerComponent(component);
      
      // Render to native
      await renderToNative(component, parentViewId: "root");
    }
    
    if (kDebugMode) {
      print('✅ Root creation/update completed');
    }
  }

  /// Create a portal container with optimized properties for portaling
  Future<String> createPortal(String portalId, {
    required String parentViewId,
    Map<String, dynamic>? props,
    int? index,
  }) async {
    await isReady;
    
    if (kDebugMode) {
      print('🚪 VDom: Creating portal container: $portalId');
    }
    
    // Create portal-specific properties
    final portalProps = {
      'portalId': portalId,
      'isPortalContainer': true,
      'backgroundColor': 'transparent',
      'clipsToBounds': false, // Allow content to overflow if needed
      'userInteractionEnabled': true,
      ...(props ?? {}),
    };
    
    try {
      // Create the portal container view using regular View type for native compatibility
      await _nativeBridge.createView(portalId, 'View', portalProps);
      
      // Attach to parent
      await _nativeBridge.attachView(portalId, parentViewId, index ?? 0);
      
      if (kDebugMode) {
        print('✅ VDom: Successfully created portal container: $portalId');
      }
      
      return portalId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ VDom: Error creating portal container: $e');
      }
      rethrow;
    }
  }
  
  /// Get the current child view IDs of a view (for portal management)
  List<String> getCurrentChildren(String viewId) {
    final node = _nodesByViewId[viewId];
    if (node is DCFElement) {
      // For elements, get the child view IDs from their children
      final childViewIds = <String>[];
      for (final child in node.children) {
        final childViewId = child.effectiveNativeViewId;
        if (childViewId != null) {
          childViewIds.add(childViewId);
        }
      }
      return childViewIds;
    }
    return [];
  }

  /// Update children of a view (for portal management)
  Future<void> updateViewChildren(String viewId, List<String> childIds) async {
    await isReady;
    await _nativeBridge.setChildren(viewId, childIds);
  }
  
  /// Delete views (for portal cleanup)
  Future<void> deleteViews(List<String> viewIds) async {
    await isReady;
    for (final viewId in viewIds) {
      await _nativeBridge.deleteView(viewId);
      _nodesByViewId.remove(viewId);
    }
  }
}
