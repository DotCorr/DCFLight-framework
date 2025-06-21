/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:dcflight/framework/renderer/interface/interface.dart' show PlatformInterface;
import 'package:dcflight/framework/renderer/vdom/component/component_node.dart';
import 'package:dcflight/framework/renderer/vdom/component/dcf_element.dart';
import 'vdom.dart';

/// Main API for VDOM operations
/// This class provides a simplified interface to the VDOM implementation
class VDomAPI {
  /// Singleton instance
  static final VDomAPI _instance = VDomAPI._();
  static VDomAPI get instance => _instance;
  
  /// Internal VDOM implementation
  late final VDom _vdom;
  
  /// Ready completer
  final Completer<void> _readyCompleter = Completer<void>();
  
  /// Private constructor
  VDomAPI._() {
    // Will be initialized explicitly with init()
  }
  
  /// Initialize the VDOM API with a platform interface
  Future<void> init(PlatformInterface platformInterface) async {
    try {
      _vdom = VDom(platformInterface);
      await _vdom.isReady;
      _readyCompleter.complete();
    } catch (e) {
      _readyCompleter.completeError(e);
      rethrow;
    }
  }
  
  /// Future that completes when the VDOM is ready
  Future<void> get isReady => _readyCompleter.future;
  
  /// Create a root component
  Future<void> createRoot(DCFComponentNode component) async {
    await isReady;
    return _vdom.createRoot(component);
  }
  
  /// Create an element
  DCFElement createElement(
    String type, {
    Map<String, dynamic>? props,
    List<DCFComponentNode>? children,
    String? key,
  }) {
    return DCFElement(
      type: type,
      props: props ?? {},
      children: children ?? [],
      key: key,
    );
  }
  
  // REMOVED: calculateLayout method
  // Layout is now calculated automatically when layout props change
  
  /// Render a node to native UI
  Future<String?> renderToNative(DCFComponentNode node,
      {String? parentViewId, int? index}) async {
    await isReady;
    return _vdom.renderToNative(node, parentViewId: parentViewId, index: index);
  }
  
  /// Create a portal container with the specified ID and properties
  Future<String> createPortal(String portalId, {
    String? parentViewId,
    Map<String, dynamic>? props,
    int? index,
  }) async {
    await isReady;
    return _vdom.createPortal(portalId, 
      parentViewId: parentViewId ?? 'root',
      props: props ?? {},
      index: index ?? 0);
  }
  
  /// Get the current child view IDs of a target container
  /// This allows portal content to be appended rather than replaced
  List<String> getCurrentChildren(String targetViewId) {
    return _vdom.getCurrentChildren(targetViewId);
  }

  /// Update a target container's children (for portal content)
  /// This ensures the native bridge call goes through the VDOM system
  Future<void> updateTargetChildren(String targetViewId, List<String> childViewIds) async {
    await isReady;
    // Use the VDOM's public method to maintain proper integration
    await _vdom.updateViewChildren(targetViewId, childViewIds);
  }
  
  /// Delete orphaned views (for portal cleanup)
  Future<void> deleteViews(List<String> viewIds) async {
    await isReady;
    await _vdom.deleteViews(viewIds);
  }
  
  /// Log VDOM state for debugging
  void debugLog(String message) {
    if (kDebugMode) {
      print('VDOM: $message');
    }
  }
}
