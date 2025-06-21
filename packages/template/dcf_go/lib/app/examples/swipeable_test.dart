/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import 'package:dcflight/dcflight.dart';
import 'package:dcf_primitives/dcf_primitives.dart';

class SwipeableTest extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final swipePosition = useState<Map<String, double>>({'x': 0, 'y': 0});
    final swipeHistory = useState<List<String>>([]);

    void addSwipeEvent(String event) {
      final newHistory = List<String>.from(swipeHistory.state);
      newHistory.insert(0, event);
      if (newHistory.length > 10) {
        newHistory.removeLast();
      }
      swipeHistory.setState(newHistory);
    }

    return DCFScrollView(
      layout: LayoutProps(flex: 1, padding: 16),
      children: [
        DCFText(
          content: "🎯 Swipeable View Test",
          textProps: DCFTextProps(
            fontSize: 24,
            fontWeight: "bold",
            color: Colors.black,
          ),
          layout: LayoutProps(marginBottom: 20, height: 30),
        ),

        DCFText(
          content: "Interactive Swipe Area",
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: "600",
            color: Colors.black87,
          ),
          layout: LayoutProps(marginBottom: 12, height: 25),
        ),

        // Main Swipeable View
        DCFSwipeableView(
          layout: LayoutProps(
            height: 200,
            marginBottom: 20,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.blue.shade100,
            borderRadius: 12,
            borderWidth: 2,
            borderColor: Colors.blue.shade300,
          ),
          horizontalSwipeEnabled: true,
          verticalSwipeEnabled: true,
          swipeThreshold: 30.0,
          elasticEnabled: true,
          onSwipeStart: (data) {
            addSwipeEvent("Swipe Started at (${data['x']}, ${data['y']})");
          },
          onSwipeMove: (data) {
            swipePosition.setState({
              'x': data['x'] as double,
              'y': data['y'] as double,
            });
          },
          onSwipeEnd: (data) {
            addSwipeEvent("Swipe Ended at (${data['x']}, ${data['y']})");
          },
          onSwipeRight: (data) {
            addSwipeEvent("Swiped RIGHT! 👉");
          },
          onSwipeLeft: (data) {
            addSwipeEvent("Swiped LEFT! 👈");
          },
          onSwipeUp: (data) {
            addSwipeEvent("Swiped UP! 👆");
          },
          onSwipeDown: (data) {
            addSwipeEvent("Swiped DOWN! 👇");
          },
          children: [
            DCFView(
              layout: LayoutProps(
                flex: 1,
                justifyContent: YogaJustifyContent.center,
                alignItems: YogaAlign.center,
                padding: 20,
              ),
              children: [
                DCFText(
                  content: "🎮 Swipe me in any direction!",
                  textProps: DCFTextProps(
                    fontSize: 18,
                    fontWeight: "600",
                    color: Colors.blue.shade800,
                    textAlign: "center",
                  ),
                  layout: LayoutProps(marginBottom: 12, height: 25),
                ),
                DCFText(
                  content: "Position: (${swipePosition.state['x']?.toStringAsFixed(1)}, ${swipePosition.state['y']?.toStringAsFixed(1)})",
                  textProps: DCFTextProps(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                  ),
                  layout: LayoutProps(height: 20),
                ),
              ],
            ),
          ],
        ),

        // Swipe History
        DCFText(
          content: "Swipe Events History",
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: "600",
            color: Colors.black87,
          ),
          layout: LayoutProps(marginBottom: 12, height: 25),
        ),

        DCFView(
          layout: LayoutProps(
            padding: 16,
            marginBottom: 20,
            minHeight: 100,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.grey.shade100,
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.grey.shade300,
          ),
          children: [
            if (swipeHistory.state.isEmpty)
              DCFText(
                content: "No swipe events yet. Try swiping the area above!",
                textProps: DCFTextProps(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  textAlign: "center",
                ),
                layout: LayoutProps(height: 20),
              )
            else
              ...swipeHistory.state.map((event) => 
                DCFView(
                  layout: LayoutProps(
                    padding: 8,
                    marginBottom: 4,
                    height: 32,
                  ),
                  styleSheet: StyleSheet(
                    backgroundColor: Colors.white,
                    borderRadius: 4,
                    borderWidth: 1,
                    borderColor: Colors.grey.shade200,
                  ),
                  children: [
                    DCFText(
                      content: event,
                      textProps: DCFTextProps(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      layout: LayoutProps(height: 16),
                    ),
                  ],
                ),
              ).toList(),
          ],
        ),

        // Horizontal Only Swipe
        DCFText(
          content: "Horizontal Only Swipe",
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: "600",
            color: Colors.black87,
          ),
          layout: LayoutProps(marginBottom: 12, height: 25),
        ),

        DCFSwipeableView(
          layout: LayoutProps(
            height: 120,
            marginBottom: 20,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.green.shade100,
            borderRadius: 8,
            borderWidth: 2,
            borderColor: Colors.green.shade300,
          ),
          horizontalSwipeEnabled: true,
          verticalSwipeEnabled: false,
          onSwipeRight: (data) {
            addSwipeEvent("Horizontal: RIGHT swipe! ➡️");
          },
          onSwipeLeft: (data) {
            addSwipeEvent("Horizontal: LEFT swipe! ⬅️");
          },
          children: [
            DCFView(
              layout: LayoutProps(
                flex: 1,
                justifyContent: YogaJustifyContent.center,
                alignItems: YogaAlign.center,
              ),
              children: [
                DCFText(
                  content: "↔️ Horizontal swipes only",
                  textProps: DCFTextProps(
                    fontSize: 16,
                    fontWeight: "600",
                    color: Colors.green.shade800,
                  ),
                  layout: LayoutProps(height: 22),
                ),
              ],
            ),
          ],
        ),

        // Vertical Only Swipe
        DCFText(
          content: "Vertical Only Swipe",
          textProps: DCFTextProps(
            fontSize: 18,
            fontWeight: "600",
            color: Colors.black87,
          ),
          layout: LayoutProps(marginBottom: 12, height: 25),
        ),

        DCFSwipeableView(
          layout: LayoutProps(
            height: 120,
            marginBottom: 20,
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.purple.shade100,
            borderRadius: 8,
            borderWidth: 2,
            borderColor: Colors.purple.shade300,
          ),
          horizontalSwipeEnabled: false,
          verticalSwipeEnabled: true,
          onSwipeUp: (data) {
            addSwipeEvent("Vertical: UP swipe! ⬆️");
          },
          onSwipeDown: (data) {
            addSwipeEvent("Vertical: DOWN swipe! ⬇️");
          },
          children: [
            DCFView(
              layout: LayoutProps(
                flex: 1,
                justifyContent: YogaJustifyContent.center,
                alignItems: YogaAlign.center,
              ),
              children: [
                DCFText(
                  content: "↕️ Vertical swipes only",
                  textProps: DCFTextProps(
                    fontSize: 16,
                    fontWeight: "600",
                    color: Colors.purple.shade800,
                  ),
                  layout: LayoutProps(height: 22),
                ),
              ],
            ),
          ],
        ),

        // Clear History Button
        DCFButton(
          buttonProps: DCFButtonProps(
            title: "Clear Swipe History",
          ),
          layout: LayoutProps(height: 44),
          styleSheet: StyleSheet(
            backgroundColor: Colors.red,
            borderRadius: 8,
          ),
          onPress: (v) {
            swipeHistory.setState([]);
            swipePosition.setState({'x': 0, 'y': 0});
          },
        ),
      ],
    );
  }
}
