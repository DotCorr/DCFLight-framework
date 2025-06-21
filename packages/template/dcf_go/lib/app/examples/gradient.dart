

import 'package:dcflight/dcflight.dart';
import 'package:dcflight/framework/constants/style/gradient.dart';

class GradientTest extends StatefulComponent {
  @override
  DCFComponentNode render() {
    return DCFView(
      layout: LayoutProps(flex: 1),
      children: [
        DCFView(
          styleSheet: StyleSheet(
            backgroundGradient: DCFGradient.linear(
              colors: [Colors.red, Colors.blue],
              startX: 0.0,
              startY: 0.0,
              endX: 1.0,
              endY: 1.0,
            ),
          ),
          layout: LayoutProps(flex: 1),
        ),
        DCFView(
          styleSheet: StyleSheet(
            borderRadius: 100,
            borderWidth: 5,
            backgroundGradient: DCFGradient.radial(
              colors: [Colors.green, Colors.red],
              centerX: 0.5,
              centerY: 0.5,
              radius: 0.5,
            ),
          ),
          layout: LayoutProps(
            height: 200,
            width: 200,
            position: YogaPositionType.absolute,
                 absoluteLayout: AbsoluteLayout.centered(),
            alignSelf: YogaAlign.center
          ),
        ),
      ],
    );
  }
}
