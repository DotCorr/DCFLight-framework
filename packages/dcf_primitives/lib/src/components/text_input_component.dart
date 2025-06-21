/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';

/// DCFTextInput - Cross-platform text input component
/// Provides native text input functionality with comprehensive type safety
class DCFTextInput extends StatelessComponent {
  final LayoutProps? layout;
  final StyleSheet? styleSheet;
  final String? value;
  final String? defaultValue;
  final String? placeholder;
  final Color? placeholderTextColor;
  final DCFTextInputType inputType;
  final DCFKeyboardType keyboardType;
  final DCFAutoCapitalizationType autoCapitalization;
  final DCFReturnKeyType returnKeyType;
  final DCFTextContentType textContentType;
  final bool autoCorrect;
  final bool autoFocus;
  final bool blurOnSubmit;
  final bool caretHidden;
  final bool clearButtonMode;
  final bool clearTextOnFocus;
  final bool contextMenuHidden;
  final bool editable;
  final bool enablesReturnKeyAutomatically;
  final int? maxLength;
  final int? numberOfLines;
  final bool multiline;
  final bool secureTextEntry;
  final bool selectTextOnFocus;
  final Color? selectionColor;
  final bool spellCheck;
  final String? textAlign;
  final Color? textColor;
  final double? fontSize;
  final String? fontWeight;
  final String? fontFamily;
  final void Function(String)? onChangeText;
  final Function(Map<dynamic, dynamic>)? onFocus;
  final Function(Map<dynamic, dynamic>)? onBlur;
  final Function(Map<dynamic, dynamic>)? onSubmitEditing;
  final Function(Map<dynamic, dynamic>)? onKeyPress;
  final Function(Map<dynamic, dynamic>)? onSelectionChange;
  final Function(Map<dynamic, dynamic>)? onEndEditing;
  final bool adaptive;
  
  DCFTextInput({
    super.key,
    this.styleSheet,
    this.layout = const LayoutProps( height: 50,width: 200),
    this.value,
    this.defaultValue,
    this.placeholder,
    this.placeholderTextColor,
    this.inputType = DCFTextInputType.text,
    this.keyboardType = DCFKeyboardType.defaultType,
    this.autoCapitalization = DCFAutoCapitalizationType.sentences,
    this.returnKeyType = DCFReturnKeyType.defaultReturn,
    this.textContentType = DCFTextContentType.none,
    this.autoCorrect = true,
    this.autoFocus = false,
    this.blurOnSubmit = true,
    this.caretHidden = false,
    this.clearButtonMode = false,
    this.clearTextOnFocus = false,
    this.contextMenuHidden = false,
    this.editable = true,
    this.enablesReturnKeyAutomatically = false,
    this.maxLength,
    this.numberOfLines = 1,
    this.multiline = false,
    this.secureTextEntry = false,
    this.selectTextOnFocus = false,
    this.selectionColor,
    this.spellCheck = true,
    this.textAlign,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.onChangeText,
    this.onFocus,
    this.onBlur,
    this.onSubmitEditing,
    this.onKeyPress,
    this.onSelectionChange,
    this.onEndEditing,
    this.adaptive = true,
  });

  @override
  DCFComponentNode render() {
    final events = <String, dynamic>{};
    
    // Add specific event handlers
    if (onChangeText != null) events['onChangeText'] = onChangeText;
    if (onFocus != null) events['onFocus'] = onFocus;
    if (onBlur != null) events['onBlur'] = onBlur;
    if (onSubmitEditing != null) events['onSubmitEditing'] = onSubmitEditing;
    if (onKeyPress != null) events['onKeyPress'] = onKeyPress;
    if (onSelectionChange != null) events['onSelectionChange'] = onSelectionChange;
    if (onEndEditing != null) events['onEndEditing'] = onEndEditing;

    return DCFElement(
      type: 'TextInput',
      key: key,
      props: {
        'value': value,
        'defaultValue': defaultValue,
        'placeholder': placeholder,
        if (placeholderTextColor != null) 'placeholderTextColor': '#${placeholderTextColor!.value.toRadixString(16).padLeft(8, '0')}',
        'inputType': inputType.name,
        'keyboardType': keyboardType.name,
        'autoCapitalization': autoCapitalization.name,
        'returnKeyType': returnKeyType.name,
        'textContentType': textContentType.name,
        'autoCorrect': autoCorrect,
        'autoFocus': autoFocus,
        'blurOnSubmit': blurOnSubmit,
        'caretHidden': caretHidden,
        'clearButtonMode': clearButtonMode,
        'clearTextOnFocus': clearTextOnFocus,
        'contextMenuHidden': contextMenuHidden,
        'editable': editable,
        'enablesReturnKeyAutomatically': enablesReturnKeyAutomatically,
        'maxLength': maxLength,
        'numberOfLines': numberOfLines,
        'multiline': multiline,
        'secureTextEntry': secureTextEntry,
        'selectTextOnFocus': selectTextOnFocus,
        if (selectionColor != null) 'selectionColor': '#${selectionColor!.value.toRadixString(16).padLeft(8, '0')}',
        'spellCheck': spellCheck,
        'textAlign': textAlign,
        if (textColor != null) 'textColor': '#${textColor!.value.toRadixString(16).padLeft(8, '0')}',
        'fontSize': fontSize,
        'fontWeight': fontWeight,
        'fontFamily': fontFamily,
        'adaptive': adaptive,
        ...layout?.toMap() ?? {},
        ...styleSheet?.toMap() ?? {},
        ...events,
      },
      children: [],
    );
  }
}

/// Text input types
enum DCFTextInputType {
  text,
  email,
  password,
  number,
  phone,
  url,
  search,
  multiline,
}

/// Keyboard types
enum DCFKeyboardType {
  defaultType,
  asciiCapable,
  numbersAndPunctuation,
  numberPad,
  phonePad,
  namePhonePad,
  emailAddress,
  decimalPad,
  twitter,
  webSearch,
  asciiCapableNumberPad,
}

/// Auto-capitalization types
enum DCFAutoCapitalizationType {
  none,
  words,
  sentences,
  allCharacters,
}

/// Return key types
enum DCFReturnKeyType {
  defaultReturn,
  go,
  google,
  join,
  next,
  route,
  search,
  send,
  yahoo,
  done,
  emergencyCall,
  continue_,
}

/// Text content types for autofill
enum DCFTextContentType {
  none,
  addressCity,
  addressCityAndState,
  addressState,
  countryName,
  creditCardNumber,
  emailAddress,
  familyName,
  fullStreetAddress,
  givenName,
  jobTitle,
  location,
  middleName,
  name,
  namePrefix,
  nameSuffix,
  nickname,
  organizationName,
  postalCode,
  streetAddressLine1,
  streetAddressLine2,
  sublocality,
  telephoneNumber,
  url,
  username,
  password,
  newPassword,
  oneTimeCode,
}
