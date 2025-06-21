import 'package:dcflight/dcflight.dart';

class ModalTest extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final modalVisible = useState<bool>(false);
    final modalVisible2 = useState<bool>(false);

    final actionSheetVisible = useState<bool>(false);
    final alertVisible = useState<bool>(false);
    final textInputAlertVisible = useState<bool>(false);
    final loginAlertVisible = useState<bool>(false);
    final toggleValue = useState<bool>(false);
    final checkboxValue = useState<bool>(false);

    return DCFScrollView(
      layout: LayoutProps(flex: 1, padding: 16.0),
      children: [
        DCFText(
          content: "🚀 DCF Primitives Test",
          textProps: DCFTextProps(fontSize: 24, fontWeight: "bold"),
          layout: LayoutProps(marginBottom: 20.0, height: 30.0),
        ),

        // Modal Tests
        DCFText(
          content: "Native Modal Components",
          textProps: DCFTextProps(fontSize: 18, fontWeight: "600"),
          layout: LayoutProps(marginBottom: 16.0, height: 25.0),
        ),

        DCFButton(
          buttonProps: DCFButtonProps(title: "Show Native Modal"),
          layout: LayoutProps(marginBottom: 12.0, height: 44.0),
          styleSheet: StyleSheet(backgroundColor: Colors.blue, borderRadius: 8),
          onPress: (v) {
            print('🔥 Show Native Modal button pressed');
            modalVisible.setState(true);
          },
        ),

        DCFButton(
          buttonProps: DCFButtonProps(title: "Show Action Sheet"),
          layout: LayoutProps(marginBottom: 20, height: 44),
          styleSheet: StyleSheet(
            backgroundColor: Colors.purple,
            borderColor: Colors.purple,
            borderWidth: 1,
            borderRadius: 8,
          ),
          onPress: (v) {
            actionSheetVisible.setState(true);
          },
        ),

        // Toggle/Switch Tests
        DCFText(
          content: "Toggle & Checkbox",
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: "600",
            color: Colors.black87,
          ),
          layout: LayoutProps(marginBottom: 16, height: 25),
        ),

        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            height: 44,
            marginBottom: 12,
          ),
          children: [
            DCFToggle(
              layout: LayoutProps(width: 60, height: 32),
              value: toggleValue.state,
              onValueChange: (data) {
                toggleValue.setState(data['value'] as bool);
                print("Toggle changed: ${data['value']}");
              },
              activeTrackColor: Colors.green,
              size: DCFToggleSize.medium,
            ),
            DCFText(
              content: "Toggle: ${toggleValue.state ? 'ON' : 'OFF'}",
              textProps: DCFTextProps(fontSize: 16, color: Colors.black87),
              layout: LayoutProps(marginLeft: 12, flex: 1, height: 20),
            ),
          ],
        ),

        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            height: 44,
            marginBottom: 20,
          ),
          children: [
            DCFCheckbox(
              layout: LayoutProps(width: 24, height: 24),
              checked: checkboxValue.state,
              onValueChange: (data) {
                checkboxValue.setState(data['value'] as bool);
                print("Checkbox changed: ${data['value']}");
              },
              activeColor: Colors.blue,
              size: DCFCheckboxSize.medium,
            ),
            DCFText(
              content:
                  "Checkbox: ${checkboxValue.state ? 'Checked' : 'Unchecked'}",
              textProps: DCFTextProps(fontSize: 16, color: Colors.black87),
              layout: LayoutProps(marginLeft: 12, flex: 1),
            ),
          ],
        ),

        // Alert Tests
        DCFText(
          content: "Alert Components",
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: "600",
            color: Colors.black87,
          ),
          layout: LayoutProps(marginBottom: 16, height: 25),
        ),

        DCFSpinner(
          animating: true,
          color: Colors.amber,
          style: DCFSpinnerStyle.medium,
          layout: LayoutProps(height: 60, width: 60),
          styleSheet: StyleSheet(backgroundColor: Colors.blue),
        ),

        DCFButton(
          buttonProps: DCFButtonProps(title: "Simple Alert"),
          layout: LayoutProps(marginBottom: 12, height: 44),
          styleSheet: StyleSheet(
            backgroundColor: Colors.orange,
            borderRadius: 8,
          ),
          onPress: (v) {
            alertVisible.setState(true);
          },
        ),

        DCFButton(
          buttonProps: DCFButtonProps(title: "Action Sheet"),
          layout: LayoutProps(marginBottom: 12, height: 44),
          styleSheet: StyleSheet(
            backgroundColor: Colors.purple,
            borderRadius: 8,
          ),
          onPress: (v) {
            actionSheetVisible.setState(true);
          },
        ),

        DCFButton(
          buttonProps: DCFButtonProps(title: "Text Input Alert"),
          layout: LayoutProps(marginBottom: 12, height: 44),
          styleSheet: StyleSheet(
            backgroundColor: Colors.green,
            borderRadius: 8,
          ),
          onPress: (v) {
            textInputAlertVisible.setState(true);
          },
        ),

        DCFButton(
          buttonProps: DCFButtonProps(title: "Login Alert"),
          layout: LayoutProps(marginBottom: 20, height: 44),
          styleSheet: StyleSheet(backgroundColor: Colors.teal, borderRadius: 8),
          onPress: (v) {
            loginAlertVisible.setState(true);
          },
        ),

        // Native DCFModal - true native modal presentation
        DCFModal(
          visible: modalVisible.state,
          title: "Native Modal",
          detents: [
            DCFModalDetents.small,
            DCFModalDetents.medium,
            DCFModalDetents.large,
          ],
          showDragIndicator: true,
          onDismiss: (data) {
            print('🔥 Native Modal onDismiss called');
            modalVisible.setState(false);
            print("Native modal dismissed: $data");
          },
          children: [
            DCFView(
              styleSheet: StyleSheet(backgroundColor: Colors.red.shade100),
              layout: LayoutProps(
                padding: 20,
                flex: 1,
                flexDirection: YogaFlexDirection.column,
              ),
              children: [
                DCFText(
                  content: "🚀 This is a true native modal!",
                  textProps: DCFTextProps(
                    fontSize: 18,
                    fontWeight: "bold",
                    color: Colors.black87,
                  ),
                  layout: LayoutProps(marginBottom: 16, height: 25),
                ),
                DCFText(
                  content:
                      "✅ Native iOS/Android modal presentation\n✅ Hardware-accelerated animations\n✅ System-level modal behavior\n✅ True modal stacking",
                  textProps: DCFTextProps(
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                  layout: LayoutProps(marginBottom: 20, height: 80),
                ),
                DCFButton(
                  buttonProps: DCFButtonProps(title: "Close Native Modal"),
                  layout: LayoutProps(height: 44),
                  styleSheet: StyleSheet(
                    backgroundColor: Colors.blue,
                    borderRadius: 8,
                  ),
                  onPress: (v) {
                    modalVisible.setState(false);
                  },
                ),

                DCFButton(
                  buttonProps: DCFButtonProps(title: "Open Native Modal 2"),
                  layout: LayoutProps(height: 44),
                  styleSheet: StyleSheet(
                    backgroundColor: Colors.blue,
                    borderRadius: 8,
                  ),
                  onPress: (v) {
                    modalVisible2.setState(true);
                  },
                ),
              ],
            ),
          ],
        ),

        DCFModal(
          visible: modalVisible2.state,
          title: "Native Modal 2",
          detents: [
            DCFModalDetents.small,
            DCFModalDetents.medium,
            DCFModalDetents.large,
          ],
          showDragIndicator: true,
          onDismiss: (data) {
            print('🔥 Native Modal onDismiss called');
            modalVisible2.setState(false);
            print("Native modal dismissed: $data");
          },
          children: [
            DCFView(
              styleSheet: StyleSheet(backgroundColor: Colors.yellow.shade100),
              layout: LayoutProps(
                padding: 20,
                flex: 1,
                flexDirection: YogaFlexDirection.column,
              ),
              children: [
                DCFText(
                  content: "🚀 This is a true native modal! 2",
                  textProps: DCFTextProps(
                    fontSize: 18,
                    fontWeight: "bold",
                    color: Colors.black87,
                  ),
                  layout: LayoutProps(marginBottom: 16, height: 25),
                ),
                DCFText(
                  content:
                      "✅ Native iOS/Android modal presentation\n✅ Hardware-accelerated animations\n✅ System-level modal behavior\n✅ True modal stacking",
                  textProps: DCFTextProps(
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                  layout: LayoutProps(marginBottom: 20, height: 80),
                ),
                DCFButton(
                  buttonProps: DCFButtonProps(title: "Close Native Modal"),
                  layout: LayoutProps(height: 44),
                  styleSheet: StyleSheet(
                    backgroundColor: Colors.blue,
                    borderRadius: 8,
                  ),
                  onPress: (v) {
                    modalVisible2.setState(false);
                  },
                ),
              ],
            ),
          ],
        ),

        // Alert Component
        DCFAlert(
          visible: alertVisible.state,
          title: "Test Alert",
          message: "This is a test alert message with custom actions!",
          style: DCFAlertStyle.alert,
          actions: [
            DCFAlertAction(
              title: 'Cancel',
              style: DCFAlertActionStyle.cancel,
              handler: 'cancel',
            ),
            DCFAlertAction(
              title: 'OK',
              style: DCFAlertActionStyle.defaultStyle,
              handler: 'confirm',
            ),
          ],
          dismissible: true,
          onShow: (data) {
            print("Alert shown: $data");
          },
          onActionPress: (data) {
            print("Alert action pressed: ${data['handler']}");
            if (data['handler'] == 'cancel') {
              alertVisible.setState(false);
              print("Alert cancelled");
            } else if (data['handler'] == 'confirm') {
              alertVisible.setState(false);
              print("Alert confirmed");
            }
          },
          onDismiss: (data) {
            alertVisible.setState(false);
            print("Alert dismissed: $data");
          },
        ),

        // Text Input Alert
        DCFAlert(
          visible: textInputAlertVisible.state,
          title: "Enter Your Name",
          message: "Please enter your full name:",
          style: DCFAlertStyle.alert,
          textFields: [
            DCFAlertTextField(
              placeholder: "Full Name",
              keyboardType: DCFKeyboardType.defaultType,
            ),
          ],
          actions: [
            DCFAlertAction(
              title: 'Cancel',
              style: DCFAlertActionStyle.cancel,
              handler: 'cancel',
            ),
            DCFAlertAction(
              title: 'Save',
              style: DCFAlertActionStyle.defaultStyle,
              handler: 'confirm',
            ),
          ],
          onActionPress: (data) {
            print("Text input action: ${data['handler']}");
            if (data['handler'] == 'confirm') {
              List<String> textValues = List<String>.from(
                data['textFieldValues'] ?? [],
              );
              if (textValues.isNotEmpty) {
                print("Name entered: ${textValues[0]}");
              }
            }
            textInputAlertVisible.setState(false);
          },
          onShow: (data) {
            print("Text input alert shown: $data");
          },
          onDismiss: (data) {
            textInputAlertVisible.setState(false);
            print("Text input alert dismissed: $data");
          },
          onTextFieldChange: (data) {
            print(
              "Text field changed - Index: ${data['fieldIndex']}, Text: '${data['text']}'",
            );
          },
        ),

        // Login Alert
        DCFAlert(
          visible: loginAlertVisible.state,
          title: "Login Required",
          message: "Please enter your credentials:",
          style: DCFAlertStyle.alert,

          textFields: [
            DCFAlertTextField(
              placeholder: "Email",
              keyboardType: DCFKeyboardType.emailAddress,
              autoCapitalization: DCFAutoCapitalizationType.none,
              textContentType: DCFTextContentType.username,
            ),
            DCFAlertTextField.secure(
              placeholder: "Password",
              textContentType: DCFTextContentType.password,
            ),
          ],
          actions: [
            DCFAlertAction(
              title: 'Cancel',
              style: DCFAlertActionStyle.cancel,
              handler: 'cancel',
            ),
            DCFAlertAction(
              title: 'Sign In',
              style: DCFAlertActionStyle.defaultStyle,
              handler: 'login',
            ),
          ],
          onActionPress: (data) {
            print("Login action: ${data['handler']}");
            if (data['handler'] == 'login') {
              List<String> textValues = List<String>.from(
                data['textFieldValues'] ?? [],
              );
              if (textValues.length >= 2) {
                print(
                  "Login attempt - Username: ${textValues[0]}, Password: [hidden]",
                );
              }
            }
            loginAlertVisible.setState(false);
          },
          onShow: (data) {
            print("Login alert shown: $data");
          },
          onDismiss: (data) {
            loginAlertVisible.setState(false);
            print("Login alert dismissed: $data");
          },
          onTextFieldChange: (data) {
            print(
              "Login field changed - Index: ${data['fieldIndex']}, Text: '${data['text']}'",
            );
          },
        ),

        // Action Sheet Alert Component
        DCFAlert(
          visible: actionSheetVisible.state,
          title: "Choose Action",
          message:
              "What would you like to do? Select an action from the list below:",
          style: DCFAlertStyle.actionSheet,
          actions: [
            DCFAlertAction(
              title: 'Edit',
              style: DCFAlertActionStyle.defaultStyle,
              handler: 'edit',
            ),
            DCFAlertAction(
              title: 'Share',
              style: DCFAlertActionStyle.defaultStyle,
              handler: 'share',
            ),
            DCFAlertAction(
              title: 'Delete',
              style: DCFAlertActionStyle.destructive,
              handler: 'delete',
            ),
            DCFAlertAction(
              title: 'Cancel',
              style: DCFAlertActionStyle.cancel,
              handler: 'cancel',
            ),
          ],
          dismissible: true,
          onShow: (data) {
            print("Action sheet shown: $data");
          },
          onActionPress: (data) {
            print("Action sheet action pressed: ${data['handler']}");
            actionSheetVisible.setState(false);

            switch (data['handler']) {
              case 'edit':
                print("Edit action selected");
                break;
              case 'share':
                print("Share action selected");
                break;
              case 'delete':
                print("Delete action selected");
                break;
              case 'cancel':
                print("Action sheet cancelled");
                break;
            }
          },
          onDismiss: (data) {
            actionSheetVisible.setState(false);
            print("Action sheet dismissed: $data");
          },
        ),
      ],
    );
  }
}
