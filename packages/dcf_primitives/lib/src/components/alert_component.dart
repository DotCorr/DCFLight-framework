/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';

/// Alert text field configuration with full parity to DCFTextInput
class DCFAlertTextField {
  // Basic text properties
  final String? placeholder;
  final String? text;
  final String? defaultValue;
  final Color? placeholderTextColor;
  
  // Security and type
  final bool secureTextEntry;
  
  // Keyboard configuration
  final DCFKeyboardType keyboardType;
  final DCFAutoCapitalizationType autoCapitalization;
  final DCFReturnKeyType returnKeyType;
  final DCFTextContentType textContentType;
  
  // Behavior configuration
  final bool autoCorrect;
  final bool autoFocus;
  final bool clearButtonMode;
  final bool clearTextOnFocus;
  final bool enablesReturnKeyAutomatically;
  final bool editable;
  final bool selectTextOnFocus;
  final bool spellCheck;
  
  // Text limits and display
  final int? maxLength;
  final int? numberOfLines;
  final bool multiline;
  
  // Styling
  final String? textAlign;
  final Color? textColor;
  final Color? selectionColor;
  final double? fontSize;
  final String? fontWeight;
  final String? fontFamily;

  const DCFAlertTextField({
    // Basic text properties
    this.placeholder,
    this.text,
    this.defaultValue,
    this.placeholderTextColor,
    
    // Security and type
    this.secureTextEntry = false,
    
    // Keyboard configuration
    this.keyboardType = DCFKeyboardType.defaultType,
    this.autoCapitalization = DCFAutoCapitalizationType.sentences,
    this.returnKeyType = DCFReturnKeyType.defaultReturn,
    this.textContentType = DCFTextContentType.none,
    
    // Behavior configuration
    this.autoCorrect = true,
    this.autoFocus = false,
    this.clearButtonMode = false,
    this.clearTextOnFocus = false,
    this.enablesReturnKeyAutomatically = false,
    this.editable = true,
    this.selectTextOnFocus = false,
    this.spellCheck = true,
    
    // Text limits and display
    this.maxLength,
    this.numberOfLines = 1,
    this.multiline = false,
    
    // Styling
    this.textAlign,
    this.textColor,
    this.selectionColor,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  });

  // Convenience constructor for secure text (password) fields
  const DCFAlertTextField.secure({
    this.placeholder,
    this.text,
    this.defaultValue,
    this.placeholderTextColor,
    this.keyboardType = DCFKeyboardType.defaultType,
    this.autoCapitalization = DCFAutoCapitalizationType.none,
    this.returnKeyType = DCFReturnKeyType.defaultReturn,
    this.textContentType = DCFTextContentType.password,
    this.autoCorrect = false,
    this.autoFocus = false,
    this.clearButtonMode = false,
    this.clearTextOnFocus = false,
    this.enablesReturnKeyAutomatically = false,
    this.editable = true,
    this.selectTextOnFocus = false,
    this.spellCheck = false,
    this.maxLength,
    this.numberOfLines = 1,
    this.multiline = false,
    this.textAlign,
    this.textColor,
    this.selectionColor,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  }) : secureTextEntry = true;

  Map<String, dynamic> toMap() {
    return {
      // Basic text properties
      'placeholder': placeholder,
      'text': text,
      'defaultValue': defaultValue,
      if (placeholderTextColor != null) 
        'placeholderTextColor': '#${placeholderTextColor!.toARGB32().toRadixString(16).padLeft(8, '0')}',
      
      // Security and type
      'secureTextEntry': secureTextEntry,
      
      // Keyboard configuration  
      'keyboardType': keyboardType.name,
      'autoCapitalization': autoCapitalization.name,
      'returnKeyType': returnKeyType.name,
      'textContentType': textContentType.name,
      
      // Behavior configuration
      'autoCorrect': autoCorrect,
      'autoFocus': autoFocus,
      'clearButtonMode': clearButtonMode,
      'clearTextOnFocus': clearTextOnFocus,
      'enablesReturnKeyAutomatically': enablesReturnKeyAutomatically,
      'editable': editable,
      'selectTextOnFocus': selectTextOnFocus,
      'spellCheck': spellCheck,
      
      // Text limits and display
      'maxLength': maxLength,
      'numberOfLines': numberOfLines,
      'multiline': multiline,
      
      // Styling
      'textAlign': textAlign,
      if (textColor != null) 
        'textColor': '#${textColor!.toARGB32().toRadixString(16).padLeft(8, '0')}',
      if (selectionColor != null) 
        'selectionColor': '#${selectionColor!.toARGB32().toRadixString(16).padLeft(8, '0')}',
      'fontSize': fontSize,
      'fontWeight': fontWeight,
      'fontFamily': fontFamily,
    };
  }
  
  // Convenience constructor for email input
  const DCFAlertTextField.email({
    this.placeholder = 'Email',
    this.text,
    this.defaultValue,
    this.placeholderTextColor,
    this.returnKeyType = DCFReturnKeyType.next,
    this.autoFocus = false,
    this.clearButtonMode = true,
    this.clearTextOnFocus = false,
    this.enablesReturnKeyAutomatically = true,
    this.editable = true,
    this.selectTextOnFocus = false,
    this.spellCheck = false,
    this.maxLength,
    this.numberOfLines = 1,
    this.multiline = false,
    this.textAlign,
    this.textColor,
    this.selectionColor,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  }) : secureTextEntry = false,
       keyboardType = DCFKeyboardType.emailAddress,
       autoCapitalization = DCFAutoCapitalizationType.none,
       textContentType = DCFTextContentType.emailAddress,
       autoCorrect = false;
       
  // Convenience constructor for phone number input
  const DCFAlertTextField.phone({
    this.placeholder = 'Phone Number',
    this.text,
    this.defaultValue,
    this.placeholderTextColor,
    this.returnKeyType = DCFReturnKeyType.done,
    this.autoFocus = false,
    this.clearButtonMode = true,
    this.clearTextOnFocus = false,
    this.enablesReturnKeyAutomatically = true,
    this.editable = true,
    this.selectTextOnFocus = false,
    this.spellCheck = false,
    this.maxLength,
    this.numberOfLines = 1,
    this.multiline = false,
    this.textAlign,
    this.textColor,
    this.selectionColor,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  }) : secureTextEntry = false,
       keyboardType = DCFKeyboardType.phonePad,
       autoCapitalization = DCFAutoCapitalizationType.none,
       textContentType = DCFTextContentType.telephoneNumber,
       autoCorrect = false;
}

/// Alert action configuration
class DCFAlertAction {
  final String title;
  final DCFAlertActionStyle style;
  final String handler;
  final bool enabled;

  const DCFAlertAction({
    required this.title,
    this.style = DCFAlertActionStyle.defaultStyle,
    required this.handler,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'style': style.value,
      'handler': handler,
      'enabled': enabled,
    };
  }
}

/// Alert action styles
enum DCFAlertActionStyle {
  defaultStyle('default'),
  cancel('cancel'),
  destructive('destructive');

  const DCFAlertActionStyle(this.value);
  final String value;
}

/// Alert styles
enum DCFAlertStyle {
  alert('alert'),
  actionSheet('actionSheet');

  const DCFAlertStyle(this.value);
  final String value;
}

/// 🚀 DCF Alert Component
/// 
/// An alert/dialog component that provides native platform behavior.
/// Supports different alert types, actions, text fields, and custom styling.
class DCFAlert extends StatelessComponent {
  /// Whether the alert is visible
  final bool visible;
  
  /// Title of the alert
  final String? title;
  
  /// Message content of the alert
  final String? message;
  
  /// Style of the alert
  final DCFAlertStyle style;
  
  /// List of text field configurations
  final List<DCFAlertTextField>? textFields;
  
  /// List of action configurations
  final List<DCFAlertAction>? actions;
  
  /// Whether the alert can be dismissed by tapping outside or back button
  final bool dismissible;
  
  /// Called when alert is shown
  final Function(Map<dynamic, dynamic>)? onShow;
  
  /// Called when alert is dismissed
  final Function(Map<dynamic, dynamic>)? onDismiss;
  
  /// Called when an action is pressed (includes textFieldValues if present)
  final Function(Map<dynamic, dynamic>)? onActionPress;
  
  /// Called when text field content changes
  final Function(Map<dynamic, dynamic>)? onTextFieldChange;
  
  /// Whether to use adaptive theming
  final bool adaptive;
  

   DCFAlert({
    super.key,
    required this.visible,
    this.title,
    this.message,
    this.textFields,
    this.style = DCFAlertStyle.alert,
    this.actions,
    this.dismissible = true,
    this.onShow,
    this.onDismiss,
    this.onActionPress,
    this.onTextFieldChange,
    this.adaptive = true,
  });

  @override
  DCFComponentNode render() {
    // Create an events map for callbacks
    Map<String, dynamic> eventMap = {};
    
    if (onShow != null) {
      eventMap['onShow'] = onShow;
    }
    
    if (onDismiss != null) {
      eventMap['onDismiss'] = onDismiss;
    }
    
    if (onActionPress != null) {
      eventMap['onActionPress'] = onActionPress;
    }
    
    if (onTextFieldChange != null) {
      eventMap['onTextFieldChange'] = onTextFieldChange;
    }

    // Build props map
    Map<String, dynamic> props = {
      'visible': visible,
      'style': style.value,
      'dismissible': dismissible,
      'adaptive': adaptive,
    };
    
    // Add event handlers
    props.addAll(eventMap);

    // Always include alert content as a structured object (like actions)
    Map<String, dynamic> alertContent = {
      'title': title,
      'message': message,
    };
    props['alertContent'] = alertContent;

    // Add textFields if present
    if (textFields != null && textFields!.isNotEmpty) {
      props['textFields'] = textFields!.map((textField) => textField.toMap()).toList();
    }

    // Add actions if present (always send as array like we do now)
    if (actions != null && actions!.isNotEmpty) {
      props['actions'] = actions!.map((action) => action.toMap()).toList();
    }
    
    return DCFElement(
      type: 'Alert',
      props: props,
      children: const [], // Alerts don't support children anymore - use textFields instead
    );
  }

  /// Helper method to create a simple alert with OK button
  static DCFAlert simple({
    required String title,
    required String message,
    Function(Map<dynamic, dynamic>)? onDismiss,
    bool adaptive = true,
  }) {
    return DCFAlert(
      visible: true,
      title: title,
      message: message,
      adaptive: adaptive,
      actions: [
        DCFAlertAction(
          title: 'OK',
          style: DCFAlertActionStyle.defaultStyle,
          handler: 'dismiss',
        )
      ],
      onDismiss: onDismiss,
    );
  }

  /// Helper method to create a text input alert
  static DCFAlert textInput({
    required String title,
    String? message,
    required String placeholder,
    String? initialText,
    bool isSecure = false,
    DCFKeyboardType keyboardType = DCFKeyboardType.defaultType,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    Function(String text)? onConfirm,
    Function()? onCancel,
    Function(String text)? onTextChange,
    bool adaptive = true,
  }) {
    return DCFAlert(
      visible: true,
      title: title,
      message: message,
      adaptive: adaptive,
      textFields: [
        DCFAlertTextField(
          placeholder: placeholder,
          text: initialText,
          secureTextEntry: isSecure,
          keyboardType: keyboardType,
        ),
      ],
      actions: [
        DCFAlertAction(
          title: cancelText,
          style: DCFAlertActionStyle.cancel,
          handler: 'cancel',
        ),
        DCFAlertAction(
          title: confirmText,
          style: DCFAlertActionStyle.defaultStyle,
          handler: 'confirm',
        ),
      ],
      onActionPress: (data) {
        if (data['handler'] == 'confirm' && onConfirm != null) {
          List<String> textValues = List<String>.from(data['textFieldValues'] ?? []);
          if (textValues.isNotEmpty) {
            onConfirm(textValues[0]);
          }
        } else if (data['handler'] == 'cancel' && onCancel != null) {
          onCancel();
        }
      },
      onTextFieldChange: onTextChange != null ? (data) {
        if (data['fieldIndex'] == 0) {
          onTextChange(data['text'] ?? '');
        }
      } : null,
    );
  }

  /// Helper method to create a login alert with username and password fields
  static DCFAlert login({
    String title = 'Login',
    String? message,
    String usernamePlaceholder = 'Username',
    String passwordPlaceholder = 'Password',
    String? initialUsername,
    DCFKeyboardType usernameKeyboardType = DCFKeyboardType.emailAddress,
    String loginText = 'Login',
    String cancelText = 'Cancel',
    Function(String username, String password)? onLogin,
    Function()? onCancel,
    Function(String username, String password)? onTextChange,
    bool adaptive = true,
  }) {
    return DCFAlert(
      visible: true,
      title: title,
      message: message,
      adaptive: adaptive,
      textFields: [
        DCFAlertTextField(
          placeholder: usernamePlaceholder,
          text: initialUsername,
          keyboardType: usernameKeyboardType,
          autoCapitalization: DCFAutoCapitalizationType.none,
        ),
        DCFAlertTextField.secure(
          placeholder: passwordPlaceholder,
        ),
      ],
      actions: [
        DCFAlertAction(
          title: cancelText,
          style: DCFAlertActionStyle.cancel,
          handler: 'cancel',
        ),
        DCFAlertAction(
          title: loginText,
          style: DCFAlertActionStyle.defaultStyle,
          handler: 'login',
        ),
      ],
      onActionPress: (data) {
        if (data['handler'] == 'login' && onLogin != null) {
          List<String> textValues = List<String>.from(data['textFieldValues'] ?? []);
          if (textValues.length >= 2) {
            onLogin(textValues[0], textValues[1]);
          }
        } else if (data['handler'] == 'cancel' && onCancel != null) {
          onCancel();
        }
      },
      onTextFieldChange: onTextChange != null ? (data) {
        // Track current field values
        List<String> currentValues = ['', ''];  // username, password
        if (data['fieldIndex'] == 0) {
          currentValues[0] = data['text'] ?? '';
        } else if (data['fieldIndex'] == 1) {
          currentValues[1] = data['text'] ?? '';
        }
        onTextChange(currentValues[0], currentValues[1]);
      } : null,
    );
  }

  /// Helper method to create a confirmation alert with Yes/No buttons
  static DCFAlert confirmation({
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    Function(Map<dynamic, dynamic>)? onConfirm,
    Function(Map<dynamic, dynamic>)? onCancel,
    bool adaptive = true,
  }) {
    return DCFAlert(
      visible: true,
      title: title,
      message: message,
      adaptive: adaptive,
      actions: [
        DCFAlertAction(
          title: cancelText,
          style: DCFAlertActionStyle.cancel,
          handler: 'cancel',
        ),
        DCFAlertAction(
          title: confirmText,
          style: DCFAlertActionStyle.defaultStyle,
          handler: 'confirm',
        )
      ],
      onActionPress: (data) {
        if (data['handler'] == 'confirm' && onConfirm != null) {
          onConfirm(data);
        } else if (data['handler'] == 'cancel' && onCancel != null) {
          onCancel(data);
        }
      },
    );
  }

  /// Helper method to create a destructive action alert
  static DCFAlert destructive({
    required String title,
    required String message,
    String destructiveText = 'Delete',
    String cancelText = 'Cancel',
    Function(Map<dynamic, dynamic>)? onDestructive,
    Function(Map<dynamic, dynamic>)? onCancel,
    bool adaptive = true,
  }) {
    return DCFAlert(
      visible: true,
      title: title,
      message: message,
      adaptive: adaptive,
      actions: [
        DCFAlertAction(
          title: cancelText,
          style: DCFAlertActionStyle.cancel,
          handler: 'cancel',
        ),
        DCFAlertAction(
          title: destructiveText,
          style: DCFAlertActionStyle.destructive,
          handler: 'destructive',
        )
      ],
      onActionPress: (data) {
        if (data['handler'] == 'destructive' && onDestructive != null) {
          onDestructive(data);
        } else if (data['handler'] == 'cancel' && onCancel != null) {
          onCancel(data);
        }
      },
    );
  }
}