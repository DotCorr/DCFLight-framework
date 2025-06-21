
import 'package:dcf_go/app/app.dart';
import 'package:dcflight/dcflight.dart';
import 'package:dcflight/framework/constants/style/gradient.dart';

class ListStatePerf extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final textInputState = useState("Initial Text Value");

    return DCFScrollView(
      layout: LayoutProps(flex: 1),
      showsScrollIndicator: true,
      onContentSizeChange: (v) {
        print("Content size changed:$v");
      },
      onScroll: (v) {
        print("Scrolled to: $v");
      },
      children: [
        // Text Input with pink text color
        DCFTextInput(
          layout: LayoutProps(
            marginBottom: 15,
            height: 50,
            width: double.infinity,
            padding: 10,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.amber,
            borderWidth: 2,
            borderColor: Colors.teal,
            borderRadius: 10,
          ),
          autoCorrect: false,
          selectionColor: Colors.purple,
          keyboardType: DCFKeyboardType.defaultType,
          textColor: Colors.pink,
          value: textInputState.state,
          onChangeText: (v) {
            textInputState.setState(v);
          },
          returnKeyType: DCFReturnKeyType.done,
          onSubmitEditing: (v) {
            // Hide keyboard
            print("Keyboard done pressed, hiding keyboard");
          },
          placeholder: "Type something...",
        ),

        // A Text component using the state
        DCFText(
          content: "Current Text: ${textInputState.state}",
          layout: LayoutProps(marginBottom: 15),
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: "bold",
            color: Colors.blue,
          ),
        ),

        // An Image with border radius and state-based opacity
        DCFImage(
          imageProps: DCFImageProps(
            source: "https://picsum.photos/200/300",
            resizeMode: DCFImageResizeMode.cover,
          ),
          layout: LayoutProps(
            height: 200,
            width: double.infinity,
            marginBottom: 15,
          ),
          styleSheet: StyleSheet(
            borderRadius: 15,
            borderWidth: 2,
            borderColor: Colors.purple,
            // Opacity based on text length
            opacity: textInputState.state.isEmpty ? 0.3 : 1.0,
          ),
        ),

        // A button with state-based color
        DCFButton(
          layout: LayoutProps(
            marginBottom: 15,
            height: 50,
            width: double.infinity,
          ),
          styleSheet: StyleSheet(
            borderRadius: 8,
            backgroundColor:
                textInputState.state.length > 10 ? Colors.green : Colors.orange,
          ),
          buttonProps: DCFButtonProps(
            title: "Text Length: ${textInputState.state.length}",
          ),
          onPress: (v) {
            textInputState.setState(textInputState.state.toUpperCase());
          },
        ),

        // A view with gradient based on text length
        DCFView(
          layout: LayoutProps(
            height: 100,
            width: double.infinity,
            marginBottom: 15,
            justifyContent: YogaJustifyContent.center,
            alignItems: YogaAlign.center,
          ),
          styleSheet: StyleSheet(
            borderRadius: 10,
            backgroundGradient:
                textInputState.state.length > 5
                    ? DCFGradient.linear(
                      colors: [Colors.purple, Colors.blue],
                      startX: 0.0,
                      startY: 0.0,
                      endX: 1.0,
                      endY: 1.0,
                    )
                    : DCFGradient.linear(
                      colors: [Colors.red, Colors.orange],
                      startX: 0.0,
                      startY: 0.0,
                      endX: 1.0,
                      endY: 1.0,
                    ),
          ),
          children: [
            DCFText(
              content: textInputState.state,
              textProps: DCFTextProps(
                fontSize: 20,
                fontWeight: "bold",
                color: Colors.white,
              ),
            ),
          ],
        ),

        // Three text components with different styling to test multiple rerenders
        DCFView(
          layout: LayoutProps(
            flexDirection: YogaFlexDirection.row,
            justifyContent: YogaJustifyContent.spaceBetween,
            marginBottom: 15,
          ),
          children: [
            DCFText(
              content: textInputState.state,
              layout: LayoutProps(flex: 1, marginRight: 5),
              textProps: DCFTextProps(
                fontSize: 14,
                fontWeight: "normal",
                color: Colors.red,
              ),
            ),
            DCFText(
              content: textInputState.state,
              layout: LayoutProps(flex: 1, marginHorizontal: 5),
              textProps: DCFTextProps(
                fontSize: 14,
                fontWeight: "bold",
                color: Colors.green,
              ),
            ),
            DCFText(
              content: textInputState.state,
              layout: LayoutProps(flex: 1, marginLeft: 5),
              textProps: DCFTextProps(
                fontSize: 14,
                fontWeight: "normal",
                color: Colors.blue,
              ),
            ),
          ],
        ),

        // Original FlatList
        DCFFlatList( 
          layout: LayoutProps(
            height: 150,
            width: double.infinity,
            flexDirection: YogaFlexDirection.row,
          ),
          initialNumToRender: 4,
          showsHorizontalScrollIndicator: true,
          orientation: DCFListOrientation.horizontal,
          data: List<int>.generate(4, (i) => i + 1),
          renderItem: (v, i) {
            return DCFTextInput(
              layout: LayoutProps(
                height: 50,
                width: 120,
                margin: 5,
                padding: 10,
              ),
              styleSheet: StyleSheet(
                backgroundColor: Colors.amber,
                borderWidth: 2,
                borderColor: Colors.teal,
                borderRadius: 10,
              ),
              autoCorrect: false,
              selectionColor: Colors.purple,
              keyboardType: DCFKeyboardType.webSearch,
              textColor: Colors.pink,
              value: textInputState.state,
              onChangeText: (v) {
                textInputState.setState(v);
              },
              placeholder: "Item $i",
            );
          },
        ),

        // Back Button
        DCFButton(
          layout: LayoutProps(marginTop: 15),
          buttonProps: DCFButtonProps(title: "Back"),
          onPress: (v) {
            pagestate.setState(0);
          },
        ),
      ],
    );
  }
}
