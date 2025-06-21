/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';

/// 🚀 DCF Spinner/Activity Indicator Component
/// 
/// A spinner component that provides native platform activity indicator behavior.
/// Supports different sizes and colors with adaptive theming.
class DCFSpinner extends StatelessComponent {
  /// Whether the spinner is animating
  final bool animating;
  
  /// Size style of the spinner
  final String style;
  
  /// Color of the spinner
  final Color? color;
  
  /// Whether to hide when stopped
  final bool hidesWhenStopped;
  
  /// Whether to use adaptive theming (system colors)
  final bool adaptive;
  
  /// The layout properties
  final LayoutProps layout;
  
  /// The style properties  
  final StyleSheet styleSheet;
  
  /// Event handlers
  final Map<String, dynamic>? events;

  DCFSpinner({
    super.key,
    this.animating = true,
    this.style = 'medium',
    this.color,
    this.hidesWhenStopped = true,
    this.adaptive = true,
    this.layout = const LayoutProps(),
    this.styleSheet = const StyleSheet(),
    this.events,
  });

  @override
  DCFComponentNode render() {
    // Create an events map for callbacks
    Map<String, dynamic> eventMap = events ?? {};
    
    Map<String, dynamic> props = {
      'animating': animating,
      'style': style,
      'hidesWhenStopped': hidesWhenStopped,
      'adaptive': adaptive,
      ...layout.toMap(),
      ...styleSheet.toMap(),
      ...eventMap,
    };
    
    // Add color property if provided
    if (color != null) {
      props['color'] = '#${color!.value.toRadixString(16).padLeft(8, '0')}';
    }
    
    return DCFElement(
      type: 'Spinner',
      props: props,
      children: [],
    );
  }
}

/// Spinner style constants
class DCFSpinnerStyle {
  static const String small = 'small';
  static const String medium = 'medium';
  static const String large = 'large';
}
