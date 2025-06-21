/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';

/// A gesture detector component implementation using StatelessComponent
class DCFGestureDetector extends StatelessComponent {
  /// Child nodes
  final List<DCFComponentNode> children;
  
  /// The layout properties
  final LayoutProps layout;
  
  /// The styleSheet properties
  final StyleSheet styleSheet;
  
  /// Event handlers
  final Map<String, dynamic>? events;
  
  /// Tap event handler - receives Map<dynamic, dynamic> with gesture data
  final Function(Map<dynamic, dynamic>)? onTap;
  
  /// Long press event handler - receives Map<dynamic, dynamic> with gesture data
  final Function(Map<dynamic, dynamic>)? onLongPress;
  
  /// Swipe left event handler - receives Map<dynamic, dynamic> with gesture data
  final Function(Map<dynamic, dynamic>)? onSwipeLeft;
  
  /// Swipe right event handler - receives Map<dynamic, dynamic> with gesture data
  final Function(Map<dynamic, dynamic>)? onSwipeRight;
  
  /// Swipe up event handler - receives Map<dynamic, dynamic> with gesture data
  final Function(Map<dynamic, dynamic>)? onSwipeUp;
  
  /// Swipe down event handler - receives Map<dynamic, dynamic> with gesture data
  final Function(Map<dynamic, dynamic>)? onSwipeDown;
  
  /// Pan start event handler - receives Map<dynamic, dynamic> with gesture data
  final Function(Map<dynamic, dynamic>)? onPanStart;
  
  /// Pan update event handler - receives Map<dynamic, dynamic> with gesture data
  final Function(Map<dynamic, dynamic>)? onPanUpdate;
  
  /// Pan end event handler - receives Map<dynamic, dynamic> with gesture data
  final Function(Map<dynamic, dynamic>)? onPanEnd;
  
  /// Whether to use adaptive theming
  final bool adaptive;
  
  /// Create a gesture detector component
  DCFGestureDetector({
    required this.children,
    this.layout = const LayoutProps(padding: 8, height: 50,width: 200),
    this.styleSheet = const StyleSheet(),
    this.onTap,
    this.onLongPress,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.events,
    this.adaptive = true,
    super.key,
  });
  
  @override
  DCFComponentNode render() {
    // Create an events map for callbacks
    Map<String, dynamic> eventMap = events ?? {};
    
    if (onTap != null) {
      eventMap['onTap'] = onTap;
    }
    
    if (onLongPress != null) {
      eventMap['onLongPress'] = onLongPress;
    }
    
    if (onSwipeLeft != null) {
      eventMap['onSwipeLeft'] = onSwipeLeft;
    }
    
    if (onSwipeRight != null) {
      eventMap['onSwipeRight'] = onSwipeRight;
    }
    
    if (onSwipeUp != null) {
      eventMap['onSwipeUp'] = onSwipeUp;
    }
    
    if (onSwipeDown != null) {
      eventMap['onSwipeDown'] = onSwipeDown;
    }
    
    if (onPanStart != null) {
      eventMap['onPanStart'] = onPanStart;
    }
    
    if (onPanUpdate != null) {
      eventMap['onPanUpdate'] = onPanUpdate;
    }
    
    if (onPanEnd != null) {
      eventMap['onPanEnd'] = onPanEnd;
    }
    
    return DCFElement(
      type: 'GestureDetector',
      props: {
        'adaptive': adaptive,
        ...layout.toMap(),
        ...styleSheet.toMap(),
        ...eventMap,
      },
      children: children,
    );
  }
}
