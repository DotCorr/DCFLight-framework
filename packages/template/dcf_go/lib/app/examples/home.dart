import 'package:dcflight/dcflight.dart';

class Home extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final selectedIndexWeb = useState<int>(2);
    return DCFScrollView(
      layout: LayoutProps(
        flex: 1,
        gap: 10,
        alignContent: YogaAlign.spaceBetween,
        justifyContent: YogaJustifyContent.spaceBetween,
      ),

      children: [
        DCFSegmentedControl(
          segmentedControlProps: DCFSegmentedControlProps(
            selectedIndex: selectedIndexWeb.state,
            segments: [
              DCFSegmentItem(title: "Android"),
              DCFSegmentItem(title: "IOS"),
              DCFSegmentItem(title: "DCFlight"),
            ],
          ),
          onSelectionChange: (v) {
            selectedIndexWeb.setState(v["selectedIndex"]);
          },
        ),
        DCFWebView(
          webViewProps: DCFWebViewProps(
            source:
                selectedIndexWeb.state == 0
                    ? "https://developer.android.com/compose"
                    : selectedIndexWeb.state == 1
                    ? "https://developer.apple.com/tutorials/swiftui/"
                    : "https://www.dotcorr.com",
            loadMode: DCFWebViewLoadMode.url,
          ),
          layout: LayoutProps(height: 500, width: "100%"),
        ),

        DCFView(
          layout: LayoutProps(flex: 1),
          children: [
            DCFText(
              content: "Welcome To DCFlight",
              textProps: DCFTextProps(
                fontSize: 25,
                color: Colors.black,
                fontWeight: DCFFontWeight.bold,
              ),
            ),
            DCFText(
              content: "Build native apps with Dart",
              textProps: DCFTextProps(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
