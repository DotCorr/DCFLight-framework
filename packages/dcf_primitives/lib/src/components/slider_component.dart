/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';

/// 🚀 DCF Slider Component
/// 
/// A slider component that provides native platform behavior.
/// Supports custom styling, range, and step values with adaptive theming.
class DCFSlider extends StatelessComponent {
  /// Current value of the slider
  final double value;
  
  /// Minimum value of the slider
  final double minimumValue;
  
  /// Maximum value of the slider
  final double maximumValue;
  
  /// Step value for discrete increments
  final double? step;
  
  /// Called when slider value changes
  final Function(Map<dynamic, dynamic>)? onValueChange;
  
  /// Called when user starts sliding
  final Function(Map<dynamic, dynamic>)? onSlidingStart;
  
  /// Called when user finishes sliding
  final Function(Map<dynamic, dynamic>)? onSlidingComplete;
  
  /// Whether the slider is disabled
  final bool disabled;
  
  /// Whether to use adaptive theming (system colors)
  final bool adaptive;
  
  /// Color of the minimum track (left side)
  final Color? minimumTrackTintColor;
  
  /// Color of the maximum track (right side)  
  final Color? maximumTrackTintColor;
  
  /// Color of the thumb
  final Color? thumbTintColor;
  
  /// The layout properties
  final LayoutProps layout;
  
  /// The style properties  
  final StyleSheet styleSheet;
  
  /// Event handlers
  final Map<String, dynamic>? events;

  DCFSlider({
    super.key,
    required this.value,
    this.minimumValue = 0.0,
    this.maximumValue = 1.0,
    this.step,
    this.onValueChange,
    this.onSlidingStart,
    this.onSlidingComplete,
    this.disabled = false,
    this.adaptive = true,
    this.minimumTrackTintColor,
    this.maximumTrackTintColor,
    this.thumbTintColor,
    this.layout = const LayoutProps(),
    this.styleSheet = const StyleSheet(),
    this.events,
  });

  @override
  DCFComponentNode render() {
    // Create an events map for callbacks
    Map<String, dynamic> eventMap = events ?? {};
    
    if (onValueChange != null) {
      eventMap['onValueChange'] = onValueChange;
    }
    
    if (onSlidingStart != null) {
      eventMap['onSlidingStart'] = onSlidingStart;
    }
    
    if (onSlidingComplete != null) {
      eventMap['onSlidingComplete'] = onSlidingComplete;
    }
    
    Map<String, dynamic> props = {
      'value': value,
      'minimumValue': minimumValue,
      'maximumValue': maximumValue,
      'disabled': disabled,
      'adaptive': adaptive,
      ...layout.toMap(),
      ...styleSheet.toMap(),
      ...eventMap,
    };
    
    // Add optional properties
    if (step != null) {
      props['step'] = step;
    }
    
    // Add color properties if provided
    if (minimumTrackTintColor != null) {
      props['minimumTrackTintColor'] = '#${minimumTrackTintColor!.value.toRadixString(16).padLeft(8, '0')}';
    }
    
    if (maximumTrackTintColor != null) {
      props['maximumTrackTintColor'] = '#${maximumTrackTintColor!.value.toRadixString(16).padLeft(8, '0')}';
    }
    
    if (thumbTintColor != null) {
      props['thumbTintColor'] = '#${thumbTintColor!.value.toRadixString(16).padLeft(8, '0')}';
    }
    
    return DCFElement(
      type: 'Slider',
      props: props,
      children: [],
    );
  }
}
