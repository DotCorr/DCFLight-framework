/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';

/// SVG properties
class DCFSVGProps {
  /// The SVG source (asset or URL)
  final String source;
  
  /// Whether the source is an asset
  final bool isAsset;
  
  /// The width of the SVG
  final double? width;
  
  /// The height of the SVG
  final double? height;
  
  /// Whether to use adaptive theming
  final bool adaptive;
  
  /// Create SVG props
  const DCFSVGProps({
    required this.source,
    this.isAsset = false,
    this.width,
    this.height,
    this.adaptive = true,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'isAsset': isAsset,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      'adaptive': adaptive,
    };
  }
}

/// An SVG component implementation using StatelessComponent
class DCFSVG extends StatelessComponent {
  /// The SVG properties
  final DCFSVGProps svgProps;
  
  /// The layout properties
  final LayoutProps layout;
  
  /// The style properties
  final StyleSheet styleSheet;
  
  /// Event handlers
  final Map<String, dynamic>? events;
  
  /// Create an SVG component
  DCFSVG({
    required this.svgProps,
       this.layout = const LayoutProps(
     height: 20,width: 20
    ),
    this.styleSheet = const StyleSheet(),
    this.events,
    super.key,
  });
  
  @override
  DCFComponentNode render() {
    return DCFElement(
      type: 'Svg',
      props: {
        ...svgProps.toMap(),
        ...layout.toMap(),
        ...styleSheet.toMap(),
        ...(events ?? {}),
      },
      children: [],
    );
  }
}
