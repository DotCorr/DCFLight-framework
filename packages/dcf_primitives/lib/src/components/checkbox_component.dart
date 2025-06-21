/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';

/// 🚀 DCF Checkbox Component
///
/// A checkbox component that provides native platform behavior.
/// Supports custom styling, sizes, and colors with adaptive theming.
class DCFCheckbox extends StatelessComponent {
  /// Current checked state of the checkbox
  final bool checked;

  /// Called when checkbox state changes
  final Function(Map<dynamic, dynamic>)? onValueChange;

  /// Whether the checkbox is disabled
  final bool disabled;

  /// Whether to use adaptive theming (system colors)
  final bool adaptive;

  /// Color when checkbox is checked
  final Color? activeColor;

  /// Color when checkbox is unchecked
  final Color? inactiveColor;

  /// Color of the checkmark
  final Color? checkmarkColor;

  /// Size of the checkbox
  final String size;

  /// Style preset for the checkbox (renamed from style to avoid conflict with StyleSheet)
  final String checkboxStyle;

  /// The layout properties
  final LayoutProps layout;

  /// The style properties
  final StyleSheet styleSheet;

  /// Event handlers
  final Map<String, dynamic>? events;

  DCFCheckbox({
    super.key,
    required this.checked,
    this.onValueChange,
    this.disabled = false,
    this.adaptive = false,
    this.activeColor,
    this.inactiveColor,
    this.checkmarkColor,
    this.size = 'medium',
    this.checkboxStyle = 'default',
    this.layout = const LayoutProps(),
    this.styleSheet = const StyleSheet(
        borderWidth: 2, borderColor: Colors.grey, borderRadius: 8),
    this.events,
  });

  @override
  DCFComponentNode render() {
    // Create an events map for callbacks
    Map<String, dynamic> eventMap = events ?? {};

    if (onValueChange != null) {
      eventMap['onValueChange'] = onValueChange;
    }

    Map<String, dynamic> props = {
      'checked': checked,
      'disabled': disabled,
      'size': size,
      'checkboxStyle': checkboxStyle,
      ...layout.toMap(),
      ...styleSheet.toMap(),
      ...eventMap,
    };

    // Add color properties if provided
    if (activeColor != null) {
      props['activeColor'] =
          '#${activeColor!.value.toRadixString(16).padLeft(8, '0')}';
    }

    if (inactiveColor != null) {
      props['inactiveColor'] =
          '#${inactiveColor!.value.toRadixString(16).padLeft(8, '0')}';
    }

    if (checkmarkColor != null) {
      props['checkmarkColor'] =
          '#${checkmarkColor!.value.toRadixString(16).padLeft(8, '0')}';
    }

    return DCFElement(
      type: 'Checkbox',
      props: props,
      children: [],
    );
  }
}

/// Checkbox size constants
class DCFCheckboxSize {
  static const String small = 'small';
  static const String medium = 'medium';
  static const String large = 'large';
}

/// Checkbox style presets
class DCFCheckboxStyle {
  static const String defaultStyle = 'default';
  static const String material = 'material';
  static const String cupertino = 'cupertino';
  static const String custom = 'custom';
}
