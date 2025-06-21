/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';

/// An animated view component implementation using StatelessComponent
class DCFAnimatedView extends StatelessComponent {
  /// Child nodes
  final List<DCFComponentNode> children;
  
  /// The layout properties
  final LayoutProps layout;
  
  /// The style properties
  final StyleSheet styleSheet;
  
  /// The animation configuration
  final Map<String, dynamic> animation;
  
  /// Event handlers
  final Map<String, dynamic>? events;
  
  /// Animation end event handler - receives `Map<dynamic, dynamic>` with animation data
  final Function(Map<dynamic, dynamic>)? onAnimationEnd;
  
  /// Whether to use adaptive theming
  final bool adaptive;
  
  /// Create an animated view component
  DCFAnimatedView({
    required this.children,
    required this.animation,
    this.layout = const LayoutProps(padding: 8),
    this.styleSheet = const StyleSheet(),
    this.onAnimationEnd,
    this.events,
    this.adaptive = true,
    super.key,
  });
  
  @override
  DCFComponentNode render() {
    // Create an events map for callbacks
    Map<String, dynamic> eventMap = events ?? {};
    
    if (onAnimationEnd != null) {
      eventMap['onAnimationEnd'] = onAnimationEnd;
    }
    
    return DCFElement(
      type: 'AnimatedView',
      props: {
        'animation': animation,
        'adaptive': adaptive,
        ...layout.toMap(),
        ...styleSheet.toMap(),
        ...eventMap,
      },
      children: children,
    );
  }
}
