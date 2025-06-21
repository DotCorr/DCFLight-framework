
// Test for store usage validation system

import 'package:dcf_go/app/examples/gradient.dart';
import 'package:dcflight/dcflight.dart';

/// Test app that demonstrates validation warnings
class ValidationTestApp extends StatefulComponent {
  @override
  DCFComponentNode render() {
    return DCFScrollView(
      layout: LayoutProps(flex: 1),
      // ADD EVENT HANDLERS SO EVENTS GET REGISTERED
         onContentSizeChange: (v) {
        print("Content size changed: $v");
      },
      onScroll: (v) {
        print("Scrolled to: $v");
      },
      children: [
        GradientTest(),
        DCFView(
          layout: LayoutProps(
            alignItems: YogaAlign.center,
            justifyContent: YogaJustifyContent.center,
            width: 220,
            position: YogaPositionType.absolute,
            height: 220,
            flexDirection: YogaFlexDirection.column,
            rotateInDegrees: 0,
            scale: 1,
            absoluteLayout: AbsoluteLayout.centeredHorizontally(bottom: 1),
          ),
        ),
      ],
    );
  }
}
