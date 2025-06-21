/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';
export 'package:dcf_primitives/src/components/dictionary/dcf_icons_dict.dart';

/// Icon properties
class DCFIconProps {
  /// The name of the icon
  final String name;

  /// Size of the icon
  // final double size;

  /// Color of the icon
  final Color? color;

  /// Package where the icon is defined
  final String package;

  /// Whether to use adaptive theming
  final bool adaptive;

  /// Create icon props
  const DCFIconProps({
    required this.name,
    // this.size = 24.0,
    this.color,
    this.package = 'dcf_primitives',
    this.adaptive = true,
  });

  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      // 'size': size,
      'package': package,
      'isRelativePath': false,
      'adaptive': adaptive,
      if (color != null) 'color': '#${color!.value.toRadixString(16).padLeft(8, '0')}',
    };
  }
}

/// An icon component implementation using StatelessComponent
class DCFIcon extends StatelessComponent {
  /// The icon properties
  final DCFIconProps iconProps;

  /// The layout properties
  final LayoutProps layout;

  /// The styleSheet properties
  final StyleSheet styleSheet;

  /// Event handlers
  final Map<String, dynamic>? events;

  /// Load event handler - receives Map<dynamic, dynamic> with icon load data
  final Function(Map<dynamic, dynamic>)? onLoad;

  /// Error event handler - receives Map<dynamic, dynamic> with error data
  final Function(Map<dynamic, dynamic>)? onError;

  /// Create an icon component
  DCFIcon({
    required this.iconProps,
    this.layout = const LayoutProps(height: 20, width: 20),
    this.styleSheet = const StyleSheet(),
    this.onLoad,
    this.onError,
    this.events,
    super.key,
  });

  @override
  DCFComponentNode render() {
    // Create an events map for callbacks
    Map<String, dynamic> eventMap = events ?? {};

    if (onLoad != null) {
      eventMap['onLoad'] = onLoad;
    }

    if (onError != null) {
      eventMap['onError'] = onError;
    }

    return DCFElement(
      type: 'DCFIcon',
      props: {
        ...iconProps.toMap(),
        ...layout.toMap(),
        ...styleSheet.toMap(),
        ...eventMap,
      },
      children: [],
    );
  }
}
