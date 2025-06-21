

import 'package:dcflight/dcflight.dart';

class ComponentShowcase extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final toggleStates = useState<Map<String, bool>>({
      'default': false,
      'material': true,
      'cupertino': false,
    });
    
    final checkboxStates = useState<Map<String, bool>>({
      'small': false,
      'medium': true,
      'large': false,
    });

    void updateToggle(String key, bool value) {
      final newStates = Map<String, bool>.from(toggleStates.state);
      newStates[key] = value;
      toggleStates.setState(newStates);
    }

    void updateCheckbox(String key, bool value) {
      final newStates = Map<String, bool>.from(checkboxStates.state);
      newStates[key] = value;
      checkboxStates.setState(newStates);
    }

    return DCFScrollView(
      layout: LayoutProps(flex: 1, padding: 16),
      children: [
        DCFSlider(value: 0.5,layout: LayoutProps(height: 10, width: "100%",),onValueChange: (data) {
          print("Slider value changed: ${data['value']}");
        },),
        DCFText(
          content: "🎨 Component Showcase",
          textProps: DCFTextProps(
            fontSize: 24,
            fontWeight: DCFFontWeight.bold,
            color: Colors.black,
          ),
          layout: LayoutProps(marginBottom: 20, height: 30),
        ),

        // Toggle Variants
        DCFText(
          content: "Toggle Styles",
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: DCFFontWeight.semibold,
            color: Colors.black87,
          ),
          layout: LayoutProps(marginBottom: 16, height: 25),
        ),

        // Default Toggle
        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.spaceBetween,
            marginBottom: 12,
            padding: 12,
            height: 60,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.white,
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.grey.shade300,
          ),
          children: [
            DCFText(
              content: "Default Toggle",
              textProps: DCFTextProps(
                fontSize: 16,
                color: Colors.black87,
              ),
              layout: LayoutProps(flex: 1),
            ),
            DCFToggle(
              layout: LayoutProps(width: 60, height: 32),
              value: toggleStates.state['default'] ?? false,
              size: DCFToggleSize.medium,
              onValueChange: (data) {
                updateToggle('default', data['value'] as bool);
              },
            ),
          ],
        ),

        // Material Toggle
        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.spaceBetween,
            marginBottom: 12,
            padding: 12,
            height: 60,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.white,
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.grey.shade300,
          ),
          children: [
            DCFText(
              content: "Material Toggle(Nothing like this exists in FCFlight, Just for showcase)",
              textProps: DCFTextProps(
                fontSize: 16,
                color: Colors.black87,
              ),
              layout: LayoutProps(flex: 1),
            ),
            DCFToggle(
              layout: LayoutProps(width: 60, height: 32),
              value: toggleStates.state['material'] ?? false,
              size: DCFToggleSize.medium,
              activeTrackColor: Colors.blue,
              activeThumbColor: Colors.white,
              onValueChange: (data) {
                updateToggle('material', data['value'] as bool);
              },
            ),
          ],
        ),

        // Cupertino Toggle
        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.spaceBetween,
            marginBottom: 20,
            padding: 12,
            height: 60,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.white,
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.grey.shade300,
          ),
          children: [
            DCFText(
              content: "Cupertino Toggle",
              textProps: DCFTextProps(
                fontSize: 16,
                color: Colors.black87,
              ),
              layout: LayoutProps(flex: 1),
            ),
            DCFToggle(
              layout: LayoutProps(width: 60, height: 32),
              value: toggleStates.state['cupertino'] ?? false,
              size: DCFToggleSize.medium,
              activeTrackColor: Colors.green,
              onValueChange: (data) {
                updateToggle('cupertino', data['value'] as bool);
              },
            ),
          ],
        ),

        // Checkbox Variants
        DCFText(
          content: "Checkbox Sizes",
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: DCFFontWeight.semibold,
            color: Colors.black87,
          ),
          layout: LayoutProps(marginBottom: 16, height: 25),
        ),

        // Small Checkbox
        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.spaceBetween,
            marginBottom: 12,
            padding: 12,
            height: 60,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.white,
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.grey.shade300,
          ),
          children: [
            DCFText(
              content: "Small Checkbox",
              textProps: DCFTextProps(
                fontSize: 16,
                color: Colors.black87,
              ),
              layout: LayoutProps(flex: 1),
            ),
            DCFCheckbox(
              layout: LayoutProps(width: 20, height: 20),
              checked: checkboxStates.state['small'] ?? false,
              size: DCFCheckboxSize.small,
              activeColor: Colors.red,
              onValueChange: (data) {
                updateCheckbox('small', data['value'] as bool);
              },
            ),
          ],
        ),

        // Medium Checkbox
        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.spaceBetween,
            marginBottom: 12,
            padding: 12,
            height: 60,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.white,
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.grey.shade300,
          ),
          children: [
            DCFText(
              content: "Medium Checkbox",
              textProps: DCFTextProps(
                fontSize: 16,
                color: Colors.black87,
              ),
              layout: LayoutProps(flex: 1),
            ),
            DCFCheckbox(
              layout: LayoutProps(width: 24, height: 24),
              checked: checkboxStates.state['medium'] ?? false,
              size: DCFCheckboxSize.medium,
              activeColor: Colors.blue,
              onValueChange: (data) {
                updateCheckbox('medium', data['value'] as bool);
              },
            ),
          ],
        ),

        // Large Checkbox
        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.row,
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.spaceBetween,
            marginBottom: 20,
            padding: 12,
            height: 60,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.white,
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.grey.shade300,
          ),
          children: [
            DCFText(
              content: "Large Checkbox",
              textProps: DCFTextProps(
                fontSize: 16,
                color: Colors.black87,
              ),
              layout: LayoutProps(flex: 1),
            ),
            DCFCheckbox(
              layout: LayoutProps(width: 28, height: 28),
              checked: checkboxStates.state['large'] ?? false,
              size: DCFCheckboxSize.large,
              activeColor: Colors.green,
              onValueChange: (data) {
                updateCheckbox('large', data['value'] as bool);
              },
            ),
          ],
        ),

        // Quick Actions
        DCFText(
          content: "Quick Actions",
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: DCFFontWeight.semibold,
            color: Colors.black87,
          ),
          layout: LayoutProps(marginBottom: 16, height: 25),
        ),

        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.row,
            justifyContent: YogaJustifyContent.spaceEvenly,
            marginBottom: 16,
            height: 44,
          ),
          children: [
            DCFButton(
              buttonProps: DCFButtonProps(
                title: "Toggle All",
              ),
              layout: LayoutProps(flex: 1, marginRight: 8),
              styleSheet: StyleSheet(
                backgroundColor: Colors.blue,
                borderRadius: 8,
              ),
              onPress: (v) {
                final allOn = toggleStates.state.values.every((v) => v);
                toggleStates.setState({
                  'default': !allOn,
                  'material': !allOn,
                  'cupertino': !allOn,
                });
              },
            ),
            DCFButton(
              buttonProps: DCFButtonProps(
                title: "Check All",
              ),
              layout: LayoutProps(flex: 1, marginLeft: 8),
              styleSheet: StyleSheet(
                backgroundColor: Colors.green,
                borderRadius: 8,
              ),
              onPress: (v) {
                final allChecked = checkboxStates.state.values.every((v) => v);
                checkboxStates.setState({
                  'small': !allChecked,
                  'medium': !allChecked,
                  'large': !allChecked,
                });
              },
            ),
          ],
        ),

        // Status Summary
        DCFView(
          layout: LayoutProps(
            padding: 16,
            marginBottom: 20,
            minHeight: 100,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.blue.shade50,
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.blue.shade200,
          ),
          children: [
            DCFText(
              content: "Status Summary",
              textProps: DCFTextProps(
                fontSize: 16,
                fontWeight: DCFFontWeight.semibold,
                color: Colors.blue.shade800,
              ),
              layout: LayoutProps(marginBottom: 8, height: 22),
            ),
            DCFText(
              content: "Toggles ON: ${toggleStates.state.values.where((v) => v).length}/3",
              textProps: DCFTextProps(
                fontSize: 14,
                color: Colors.blue.shade700,
              ),
              layout: LayoutProps(marginBottom: 4, height: 18),
            ),
            DCFText(
              content: "Checkboxes Checked: ${checkboxStates.state.values.where((v) => v).length}/3",
              textProps: DCFTextProps(
                fontSize: 14,
                color: Colors.blue.shade700,
              ),
              layout: LayoutProps(height: 18),
            ),
          ],
        ),

        // Component Information
        DCFView(
          layout: LayoutProps(
            padding: 16,
            marginBottom: 20,
            minHeight: 120,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.orange.shade50,
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.orange.shade200,
          ),
          children: [
            DCFText(
              content: "Component Information",
              textProps: DCFTextProps(
                fontSize: 16,
                fontWeight: DCFFontWeight.semibold,
                color: Colors.black87,
              ),
              layout: LayoutProps(marginBottom: 8, height: 22),
            ),
            DCFText(
              content: "This showcase demonstrates the DCFToggle and DCFCheckbox components with different styles and sizes.",
              textProps: DCFTextProps(
                fontSize: 14,
                color: Colors.black87,
              ),
              layout: LayoutProps(marginBottom: 8, height: 18),
            ),
            DCFText(
              content: "All components support real-time value changes and custom styling.",
              textProps: DCFTextProps(
                fontSize: 14,
                color: Colors.black87,
              ),
              layout: LayoutProps(height: 18),
            ),
          ],
        ),

        // Performance Test
        DCFText(
          content: "Performance Test",
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: DCFFontWeight.semibold,
            color: Colors.black87,
          ),
          layout: LayoutProps(marginBottom: 16, height: 25),
        ),

        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.column,
            padding: 16,
            minHeight: 400,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.purple.shade50,
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.purple.shade200,
          ),
          children: [
            DCFText(
              content: "Multiple Components Test (10 checkboxes)",
              textProps: DCFTextProps(
                fontSize: 14,
                fontWeight: DCFFontWeight.semibold,
                color: Colors.purple.shade800,
              ),
              layout: LayoutProps(marginBottom: 12, height: 20),
            ),
            ...List.generate(10, (i) => 
              DCFView(
                layout: LayoutProps(
                  flexDirection: YogaFlexDirection.row,
                  alignItems: YogaAlign.center,
                  justifyContent: YogaJustifyContent.spaceBetween,
                  marginBottom: 8,
                  padding: 8,
                  height: 40,
                ),
                styleSheet: StyleSheet(
                  backgroundColor: Colors.white,
                  borderRadius: 4,
                  borderWidth: 1,
                  borderColor: Colors.purple.shade200,
                ),
                children: [
                  DCFText(
                    content: "Checkbox ${i + 1}",
                    textProps: DCFTextProps(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    layout: LayoutProps(flex: 1, height: 18),
                  ),
                  DCFCheckbox(
                    layout: LayoutProps(width: 20, height: 20),
                    checked: false,
                    size: DCFCheckboxSize.small,
                    activeColor: i % 2 == 0 ? Colors.purple : Colors.orange,
                    onValueChange: (data) {
                      print("Checkbox ${i + 1} changed: ${data['value']}");
                    },
                  ),
                ],
              ),
            ).toList(),
          ],
        ),
      ],
    );
  }
}
