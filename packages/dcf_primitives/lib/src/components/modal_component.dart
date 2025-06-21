/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';

/// Modal header action button configuration
class DCFModalHeaderAction {
  /// The title of the action button
  final String title;
  
  /// Optional icon asset for the action
  final String? iconAsset;
  
  /// Custom action handler - follows DCFlight event conventions
  final Function(Map<dynamic, dynamic>)? onTap;
  
  const DCFModalHeaderAction({
    required this.title,
    this.iconAsset,
    this.onTap,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      if (iconAsset != null) 'iconAsset': iconAsset,
    };
  }
}

/// Modal header configuration
class DCFModalHeader {
  /// The title text
  final String title;
  
  /// Font family for the title
  final String? fontFamily;
  
  /// Font size for the title
  final double? fontSize;
  
  /// Font weight for the title
  final String? fontWeight;
  
  /// Title text color
  final Color? titleColor;
  
  /// Prefix (left) actions
  final List<DCFModalHeaderAction>? prefixActions;
  
  /// Suffix (right) actions
  final List<DCFModalHeaderAction>? suffixActions;
  
  /// Whether to use adaptive theming
  final bool adaptive;
  
  const DCFModalHeader({
    required this.title,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.titleColor,
    this.prefixActions,
    this.suffixActions,
    this.adaptive = true,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontSize != null) 'fontSize': fontSize,
      if (fontWeight != null) 'fontWeight': fontWeight,
      if (titleColor != null) 'titleColor': '#${titleColor!.value.toRadixString(16).padLeft(8, '0')}',
      if (prefixActions != null) 'prefixActions': prefixActions!.map((action) => action.toMap()).toList(),
      if (suffixActions != null) 'suffixActions': suffixActions!.map((action) => action.toMap()).toList(),
      'adaptive': adaptive,
    };
  }
}

/// 🚀 DCF Modal Component - React Portal Style
/// 
/// A modal component that uses portals for rendering, just like React.
/// The modal content is automatically portaled to 'modal-root' host.
/// 
/// Usage:
/// ```dart
/// DCFModal(
///   visible: isModalVisible,
///   children: [
///     DCFText("Modal content")
///   ],
/// )
/// ```
/// 
/// Make sure your app is wrapped in DCFPortalProvider for modals to work:
/// ```dart
/// DCFPortalProvider(
///   children: [
///     YourApp(),
///   ],
/// )
/// ```
class DCFModal extends StatelessComponent {
  /// Whether the modal is visible
  final bool visible;
  
  /// Modal header configuration (replaces simple title)
  final DCFModalHeader? header;
  
  /// List of detent configurations
  /// Available options: ["small", "medium", "large", "compact", "half", "full"]
  final List<String>? detents;
  
  /// Selected detent index (0-based)
  final int? selectedDetentIndex;
  
  /// Whether to show the drag indicator (grabber)
  final bool showDragIndicator;
  
  /// Corner radius for the modal
  final double? cornerRadius;
  
  /// Whether the modal can be dismissed
  final bool isDismissible;
  
  /// Whether background tap dismisses the modal
  final bool allowsBackgroundDismiss;
  
  /// Transition style for modal presentation
  /// Available options: "coverVertical", "flipHorizontal", "crossDissolve", "partialCurl"
  final String? transitionStyle;
  
  /// Whether the modal captures status bar appearance
  final bool? capturesStatusBarAppearance;
  
  /// Whether this modal defines the presentation context
  final bool? definesPresentationContext;
  
  /// Whether this modal provides transition context style
  final bool? providesTransitionContext;
  
  /// Called when modal is shown
  final Function(Map<dynamic, dynamic>)? onShow;
  
  /// Called when modal is dismissed
  final Function(Map<dynamic, dynamic>)? onDismiss;
  
  /// Called when modal is opened
  final Function(Map<dynamic, dynamic>)? onOpen;
  
  /// Called when a header action is tapped
  final Function(Map<dynamic, dynamic>)? onHeaderAction;
  
  /// Child components to display inside the modal
  final List<DCFComponentNode> children;

  /// The layout properties
  final LayoutProps layout;
  
  /// The style properties  
  final StyleSheet style;
  
  /// Event handlers
  final Map<String, dynamic>? events;

  DCFModal({
    super.key,
    required this.visible,
    this.header,
    this.detents,
    this.selectedDetentIndex,
    this.showDragIndicator = true,
    this.cornerRadius,
    this.isDismissible = true,
    this.allowsBackgroundDismiss = true,
    this.transitionStyle,
    this.capturesStatusBarAppearance,
    this.definesPresentationContext,
    this.providesTransitionContext,
    this.onShow,
    this.onDismiss,
    this.onOpen,
    this.onHeaderAction,
    this.children = const [],
    this.layout = const LayoutProps(),
    this.style = const StyleSheet(),
    this.events,
  });

  @override
  DCFComponentNode render() {
    print('🎭 DCFModal.render() called - visible: $visible, key: $key');
    
    // Create event map for callbacks
    Map<String, dynamic> eventMap = events ?? {};
    
    if (onShow != null) {
      eventMap['onShow'] = onShow;
    }
    
    if (onDismiss != null) {
      eventMap['onDismiss'] = onDismiss;
    }
    
    if (onOpen != null) {
      eventMap['onOpen'] = onOpen;
    }
    
    if (onHeaderAction != null) {
      eventMap['onHeaderAction'] = onHeaderAction;
    }
    
    // Store header action callbacks for native side to use
    if (header?.prefixActions != null) {
      eventMap['prefixActionCallbacks'] = header!.prefixActions!.map((action) => action.onTap).toList();
    }
    
    if (header?.suffixActions != null) {
      eventMap['suffixActionCallbacks'] = header!.suffixActions!.map((action) => action.onTap).toList();
    }
    
    // ✅ SIMPLE FIX: Return modal directly with children - no wrapper needed!
    // 🔥 Build props map with proper display handling
    Map<String, dynamic> props = {
      'visible': visible,
      if (header != null) 'header': header!.toMap(),
      'detents': detents,
      'selectedDetentIndex': selectedDetentIndex,
      'showDragIndicator': showDragIndicator,
      'cornerRadius': cornerRadius,
      'isDismissible': isDismissible,
      'allowsBackgroundDismiss': allowsBackgroundDismiss,
      'transitionStyle': transitionStyle,
      'capturesStatusBarAppearance': capturesStatusBarAppearance,
      'definesPresentationContext': definesPresentationContext,
      'providesTransitionContext': providesTransitionContext,
      
      ...layout.toMap(),
      ...style.toMap(),
      ...eventMap,
    };
    
    // 🔥 CRITICAL FIX: Always enforce display property based on visibility
    // This ensures style.toMap() cannot override the visibility-based display setting
    props['display'] = visible ? 'flex' : 'none';
    
    print('🎭 DCFModal props being sent to native: visible=$visible, display=${props['display']}');
    
    return DCFElement(
      type: 'Modal',
      props: props,
      children: children, // ✅ Direct children - simple and works!
    );
  }
}

/// Detent constants for convenient usage
class DCFModalDetents {
  static const String small = 'small';
  static const String medium = 'medium'; 
  static const String large = 'large';
  static const String compact = 'compact';
  static const String half = 'half';
  static const String full = 'full';
}

/// Transition style constants for modal presentation
class DCFModalTransitionStyle {
  static const String coverVertical = 'coverVertical';
  static const String flipHorizontal = 'flipHorizontal';
  static const String crossDissolve = 'crossDissolve';
  static const String partialCurl = 'partialCurl';
}
