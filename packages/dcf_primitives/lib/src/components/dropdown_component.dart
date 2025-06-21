/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';

/// Dropdown properties
class DCFDropdownProps {
  /// Whether the dropdown is visible
  final bool visible;
  
  /// List of dropdown items
  final List<DCFDropdownMenuItem> items;
  
  /// Currently selected value
  final String? selectedValue;
  
  /// Placeholder text
  final String? placeholder;
  
  /// Color of placeholder text
  final Color? placeholderTextColor;
  
  /// Position of the dropdown
  final DCFDropdownPosition dropdownPosition;
  
  /// Maximum height of dropdown
  final double? maxHeight;
  
  /// Height of each item
  final double? itemHeight;
  
  /// Background color of dropdown
  final Color? backgroundColor;
  
  /// Border color of dropdown
  final Color? borderColor;
  
  /// Border width
  final double? borderWidth;
  
  /// Border radius
  final double? borderRadius;
  
  /// Whether dropdown is searchable
  final bool searchable;
  
  /// Search placeholder text
  final String? searchPlaceholder;
  
  /// Whether multiple selection is enabled
  final bool multiSelect;
  
  /// Currently selected values (for multi-select)
  final List<String>? selectedValues;
  
  /// Whether dropdown is disabled
  final bool disabled;
  
  /// Whether to use adaptive theming
  final bool adaptive;
  
  /// Create dropdown props
  const DCFDropdownProps({
    this.visible = false,
    this.items = const [],
    this.selectedValue,
    this.placeholder,
    this.placeholderTextColor,
    this.dropdownPosition = DCFDropdownPosition.auto,
    this.maxHeight,
    this.itemHeight,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.searchable = false,
    this.searchPlaceholder,
    this.multiSelect = false,
    this.selectedValues,
    this.disabled = false,
    this.adaptive = true,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'visible': visible,
      'items': items.map((item) => {
        'value': item.value,
        'label': item.title,  // Use title as label for native
        'disabled': item.disabled,
      }).toList(),
      'selectedValue': selectedValue,
      'placeholder': placeholder,
      if (placeholderTextColor != null) 'placeholderTextColor': '#${placeholderTextColor!.value.toRadixString(16).padLeft(8, '0')}',
      'dropdownPosition': dropdownPosition.name,
      'maxHeight': maxHeight,
      'itemHeight': itemHeight,
      if (backgroundColor != null) 'backgroundColor': '#${backgroundColor!.value.toRadixString(16).padLeft(8, '0')}',
      if (borderColor != null) 'borderColor': '#${borderColor!.value.toRadixString(16).padLeft(8, '0')}',
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'searchable': searchable,
      'searchPlaceholder': searchPlaceholder,
      'multiSelect': multiSelect,
      'selectedValues': selectedValues,
      'disabled': disabled,
      'adaptive': adaptive,
    };
  }
}

/// DCFDropdown - Cross-platform dropdown menu component
/// Provides native dropdown functionality with type-safe positioning and items
class DCFDropdown extends StatelessComponent {
  /// The dropdown properties
  final DCFDropdownProps dropdownProps;
  
  /// The layout properties
  final LayoutProps layout;
  
  /// The style properties
  final StyleSheet styleSheet;
  
  /// Event handlers
  final Map<String, dynamic>? events;
  
  /// Value change event handler - receives Map<dynamic, dynamic> with selected value and item data
  final Function(Map<dynamic, dynamic>)? onValueChange;
  
  /// Multi-value change event handler - receives Map<dynamic, dynamic> with selected values and items data
  final Function(Map<dynamic, dynamic>)? onMultiValueChange;
  
  /// Open event handler - receives Map<dynamic, dynamic> with dropdown state
  final Function(Map<dynamic, dynamic>)? onOpen;
  
  /// Close event handler - receives Map<dynamic, dynamic> with dropdown state
  final Function(Map<dynamic, dynamic>)? onClose;

  DCFDropdown({
    super.key,
    required this.dropdownProps,
    this.layout = const LayoutProps(),
    this.styleSheet = const StyleSheet(),
    this.onValueChange,
    this.onMultiValueChange,
    this.onOpen,
    this.onClose,
    this.events,
  });

  @override
  DCFComponentNode render() {
    // Create an events map for callbacks
    Map<String, dynamic> eventMap = events ?? {};
    
    if (onValueChange != null) {
      eventMap['onValueChange'] = onValueChange;
    }
    
    if (onMultiValueChange != null) {
      eventMap['onMultiValueChange'] = onMultiValueChange;
    }
    
    if (onOpen != null) {
      eventMap['onOpen'] = onOpen;
    }
    
    if (onClose != null) {
      eventMap['onClose'] = onClose;
    }
    
    return DCFElement(
      type: 'Dropdown',
      key: key,
      props: {
        ...dropdownProps.toMap(),
        ...layout.toMap(),
        ...styleSheet.toMap(),
        ...eventMap,
      },
      children: [],
    );
  }
}

/// Dropdown menu item configuration
class DCFDropdownMenuItem {
  final String value;
  final String title;
  final String? subtitle;
  final String? icon;
  final bool disabled;
  final void Function(String value)? onSelected;

  const DCFDropdownMenuItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
    this.disabled = false,
    this.onSelected,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'title': title,
      'subtitle': subtitle,
      'icon': icon,
      'disabled': disabled,
    };
  }
}

/// Dropdown menu positions
enum DCFDropdownPosition {
  auto,
  top,
  bottom,
  left,
  right,
}
