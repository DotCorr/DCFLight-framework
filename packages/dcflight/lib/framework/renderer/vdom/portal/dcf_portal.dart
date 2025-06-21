/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'dart:async';
import 'package:dcflight/framework/renderer/vdom/component/component.dart';
import 'package:dcflight/framework/renderer/vdom/component/component_node.dart';
import 'package:dcflight/framework/renderer/vdom/component/fragment.dart';
import 'package:dcflight/framework/renderer/vdom/component/dcf_element.dart';
import 'package:dcflight/framework/renderer/vdom/portal/enhanced_portal_manager.dart';
import 'package:flutter/foundation.dart';

/// DCFPortal component for rendering children into a different DOM tree location
/// Similar to React's createPortal, this allows rendering components outside 
/// their normal parent-child hierarchy
class DCFPortal extends StatefulComponent {
  final String targetId;
  final List<DCFComponentNode> children;
  final Map<String, dynamic>? metadata;
  final int priority;
  final bool createTargetIfMissing;
  final Function(String portalId)? onMount;
  final Function(String portalId)? onUnmount;

  DCFPortal({
    required this.targetId,
    required this.children,
    this.metadata,
    this.priority = 0,
    this.createTargetIfMissing = false,
    this.onMount,
    this.onUnmount,
    super.key,
  });

  @override
  DCFComponentNode render() {
    final portalIdState = useState<String?>(null, 'portalId');
    final portalManager = EnhancedPortalManager.instance;

    if (kDebugMode) {
      print('🎭 DCFPortal.render() called - targetId: $targetId, children: ${children.length}, key: $key');
    }

    // Effect to create portal on mount and handle updates
    useEffect(() {
      if (kDebugMode) {
        print('🔥 DCFPortal: Mount effect RUNNING - targetId: $targetId, key: $key');
        print('🔥 DCFPortal: Mount effect - Current portalId state: ${portalIdState.state}');
      }

      Future<void> createPortal() async {
        try {
          if (kDebugMode) {
            print('🔥 DCFPortal: Creating portal for targetId: $targetId');
          }
          
          final portalId = await portalManager.createPortal(
            targetId: targetId,
            children: children,
            metadata: metadata,
            priority: priority,
            createTargetIfMissing: createTargetIfMissing,
            onMount: onMount,
            onUnmount: onUnmount,
          );
          
          if (kDebugMode) {
            print('🔥 DCFPortal: Portal created successfully with ID: $portalId');
          }
          
          portalIdState.setState(portalId);
        } catch (e) {
          if (kDebugMode) {
            print('❌ DCFPortal: Failed to create portal: $e');
          }
        }
      }

      createPortal();

      // Cleanup function
      return () {
        if (kDebugMode) {
          print('🧹 DCFPortal: Mount effect CLEANUP CALLED - targetId: $targetId, key: $key');
          print('🧹 DCFPortal: Mount effect cleanup - portalId to remove: ${portalIdState.state}');
        }
        
        if (portalIdState.state != null) {
          if (kDebugMode) {
            print('🧹 DCFPortal: Removing portal ${portalIdState.state}');
          }
          
          portalManager.removePortal(portalIdState.state!).catchError((e) {
            if (kDebugMode) {
              print('❌ DCFPortal: Failed to destroy portal: $e');
            }
          });
        } else {
          if (kDebugMode) {
            print('⚠️ DCFPortal: Mount effect cleanup called but no portalId to remove');
          }
        }
      };
    }, dependencies: []); // Only run once on mount/unmount

    // Separate effect to update portal when properties change
    useEffect(() {
      // Calculate dependencies fresh each time
      final childrenLength = children.length;
      final childrenHash = childrenLength == 0 ? 'empty' : children.map((c) => c.hashCode).join(',');
      
      if (kDebugMode) {
        print('🔄 DCFPortal: Update effect RUNNING - targetId: $targetId, key: $key');
        print('🔄 DCFPortal: Update effect - portalId: ${portalIdState.state}, children.length: $childrenLength');
        print('🔄 DCFPortal: Children content: ${children.map((c) => c.runtimeType.toString()).toList()}');
        print('🔄 DCFPortal: Children hash: $childrenHash');
      }
      
      if (portalIdState.state != null) {
        // Use a microtask to ensure the update happens after the current render cycle
        Future.microtask(() {
          try {
            if (kDebugMode) {
              print('🔄 DCFPortal: Updating portal ${portalIdState.state} with $childrenLength children');
            }
            
            portalManager.updatePortal(
              portalId: portalIdState.state!,
              children: children,
              metadata: metadata,
              priority: priority,
            );
          } catch (e) {
            if (kDebugMode) {
              print('❌ DCFPortal: Failed to update portal: $e');
            }
          }
        });
      } else {
        if (kDebugMode) {
          print('⚠️ DCFPortal: Update effect triggered but no portal ID available yet');
        }
      }
      
      // Return cleanup function for this effect
      return () {
        if (kDebugMode) {
          print('🧹 DCFPortal: Update effect CLEANUP CALLED - targetId: $targetId, key: $key');
          print('🧹 DCFPortal: Update effect cleanup - was updating portalId: ${portalIdState.state}');
          print('🧹 DCFPortal: Update effect cleanup - children count was: $childrenLength');
        }
      };
    }, dependencies: ['${children.length}-${children.map((c) => c.runtimeType).join(',')}']); // Use string-based dependency that changes with content

    // Return a placeholder fragment that doesn't render anything
    // The actual content is rendered through the portal system
    return DCFFragment(
      children: [],
      metadata: {
        'isPortalPlaceholder': true,
        'targetId': targetId,
        'portalId': portalIdState.state,
      },
    );
  }
}

/// DCFPortalTarget component for creating portal targets
class DCFPortalTarget extends StatefulComponent {
  final String targetId;
  final Map<String, dynamic>? metadata;
  final int priority;
  final List<DCFComponentNode> children;

  DCFPortalTarget({
    required this.targetId,
    this.metadata,
    this.priority = 0,
    this.children = const [],
    super.key,
  });

  @override
  DCFComponentNode render() {
    final portalManager = EnhancedPortalManager.instance;
    final elementRef = useRef<DCFElement?>(null);
    final isRegisteredRef = useRef<bool>(false);

    // Effect to register/unregister target after the element is created and has a view ID
    useEffect(() {
      void attemptRegistration() {
        final isRegistered = isRegisteredRef.current ?? false;
        final element = elementRef.current;
        
        if (!isRegistered && element?.nativeViewId != null) {
          final actualViewId = element!.nativeViewId!;
          
          if (kDebugMode) {
            print('🎯 DCFPortalTarget: Registering target $targetId with actual view ID: $actualViewId');
          }
          
          portalManager.registerTarget(
            targetId: targetId,
            nativeViewId: actualViewId,
            metadata: metadata,
            priority: priority,
          );
          
          isRegisteredRef.current = true;
        }
      }

      // Try to register immediately if view ID is already available
      attemptRegistration();

      // Set up a polling mechanism to check for view ID assignment
      // This is necessary because the view ID is assigned asynchronously during rendering
      Timer? pollTimer;
      final isRegistered = isRegisteredRef.current ?? false;
      if (!isRegistered) {
        pollTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
          attemptRegistration();
          final currentRegistered = isRegisteredRef.current ?? false;
          if (currentRegistered) {
            timer.cancel();
          }
        });
        
        // Cancel polling after 1 second to avoid infinite polling
        Timer(Duration(seconds: 1), () {
          pollTimer?.cancel();
          final finalRegistered = isRegisteredRef.current ?? false;
          if (!finalRegistered && kDebugMode) {
            print('⚠️ DCFPortalTarget: Failed to get view ID for target $targetId within timeout');
          }
        });
      }

      // Cleanup function
      return () {
        pollTimer?.cancel();
        final isRegistered = isRegisteredRef.current ?? false;
        if (isRegistered) {
          // Delay unregistration to allow portal cleanup to complete
          Future.microtask(() {
            portalManager.unregisterTarget(targetId);
          });
          isRegisteredRef.current = false;
        }
      };
    }, dependencies: [targetId, nativeViewId, priority]); // Re-run when these change

    // Create the element that will be our portal target
    final element = DCFElement(
      type: 'View', // Use View component to create a native container(why not fragment or any conceptual/virtual element? Cause portal is porting nodes that already exits into actual native componets so we need a real view to port to)
      props: {
        'isPortalTarget': true,
        'targetId': targetId,
        'backgroundColor': 'transparent',
        'flex': 1,
        "width": "100%",
        "height": "100%",
      },
      children: children,
    );
    
    // Store reference to the element so we can access its view ID later
    elementRef.current = element;
    
    return element;
  }
}
