import 'package:dcflight/dcflight.dart';
import 'package:dcflight/framework/renderer/vdom/portal/explicit_portal_api.dart';

/// Simple Portal Test - demonstrates ExplicitPortalAPI usage
class PortalTest extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final activePortalId = useState<String?>(null);
    final counter = useState<int>(0);

    return DCFScrollView(
      layout: LayoutProps(flex: 1, padding: 20.0),
      children: [
        // Title
        DCFText(
          content: '🎯 Portal Test',
          textProps: DCFTextProps(fontSize: 24, fontWeight: DCFFontWeight.bold),
          layout: LayoutProps(marginBottom: 20.0, height: 40.0),
        ),

        // Description
        DCFText(
          content: 'Explicit Portal API Demo - The ONLY way to use portals',
          textProps: DCFTextProps(fontSize: 16, color: Colors.grey[700]),
          layout: LayoutProps(marginBottom: 20.0, height: 30.0),
        ),

        // Portal target area
        DCFView(
          layout: LayoutProps(
            height: 240.0,
            padding: 16.0,
            marginBottom: 20.0,
            borderWidth: 2,
            width: "100%",
          ),
          styleSheet: StyleSheet(
            borderColor: Colors.blue,
            backgroundColor: Colors.blue.withOpacity(0.1),
            borderRadius: 8,
          ),
          children: [
            DCFText(
              content: 'Portal Target Area',
              textProps: DCFTextProps(fontSize: 18, fontWeight: DCFFontWeight.bold),
              layout: LayoutProps(marginBottom: 16.0, height: 30.0),
            ),
            DCFText(
              content: 'Content will appear below via ExplicitPortalAPI',
              textProps: DCFTextProps(fontSize: 14, color: Colors.grey[600]),
              layout: LayoutProps(marginBottom: 16.0, height: 20.0),
            ),
            // Portal target - content renders here
            DCFPortalTarget(targetId: 'test-portal', children: []),
          ],
        ),

        // Add button
        DCFGestureDetector(
          layout: LayoutProps(marginBottom: 16.0, height: 60.0),
          onTap: (_) async {
            final content = [
              DCFView(
                layout: LayoutProps(
                  padding: 16.0,
                  height: 120.0,
                  width: "100%",
                  flexDirection: YogaFlexDirection.row,
                  alignItems: YogaAlign.center,
                  gap: 12.0,
                ),
                styleSheet: StyleSheet(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  borderColor: Colors.green,
                  borderWidth: 2,
                  borderRadius: 8,
                ),
                children: [
                  DCFSpinner(
                    color: Colors.green,
                    style: DCFSpinnerStyle.medium,
                    layout: LayoutProps(width: 24.0, height: 24.0),
                  ),
                  DCFView(
                    styleSheet: StyleSheet(
                      backgroundColor: Colors.white,
                      borderRadius: 8,
                      shadowColor: Colors.amber,
                      shadowRadius: 4.0,
                      shadowOffsetX: 2,
                    ),
                    layout: LayoutProps(flex: 1),
                    children: [
                      DCFText(
                        content: 'Portal Content #${counter.state + 1}',
                        textProps: DCFTextProps(
                          fontSize: 18,
                          fontWeight: DCFFontWeight.bold,
                        ),
                        layout: LayoutProps(marginBottom: 8.0, height: 25.0),
                      ),
                      DCFText(
                        content: 'Added via ExplicitPortalAPI.add()',
                        textProps: DCFTextProps(
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                        layout: LayoutProps(height: 20.0),
                      ),
                      DCFText(
                        content:
                            'Time: ${DateTime.now().toString().substring(11, 19)}',
                        textProps: DCFTextProps(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        layout: LayoutProps(height: 18.0),
                      ),
                    ],
                  ),
                ],
              ),
            ];

            final portalId = await ExplicitPortalAPI.add(
              targetId: 'test-portal',
              content: content,
            );

            activePortalId.setState(portalId);
            counter.setState(counter.state + 1);
          },
          children: [
            DCFView(
              layout: LayoutProps(
                padding: 16.0,
                height: 60.0,
                width: "100%",
                justifyContent: YogaJustifyContent.center,
                alignItems: YogaAlign.center,
              ),
              styleSheet: StyleSheet(
                backgroundColor: Colors.green,
                borderRadius: 8,
              ),
              children: [
                DCFText(
                  content: '➕ Add Portal Content',
                  textProps: DCFTextProps(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: DCFFontWeight.bold,
                  ),
                  layout: LayoutProps(height: 25.0),
                ),
              ],
            ),
          ],
        ),

        // Remove button
        DCFGestureDetector(
          layout: LayoutProps(marginBottom: 16.0, height: 60.0),
          onTap: (_) async {
            if (activePortalId.state != null) {
              await ExplicitPortalAPI.remove(activePortalId.state!);
              activePortalId.setState(null);
            }
          },
          children: [
            DCFView(
              layout: LayoutProps(
                padding: 16.0,
                height: 60.0,
                width: "100%",
                justifyContent: YogaJustifyContent.center,
                alignItems: YogaAlign.center,
              ),
              styleSheet: StyleSheet(
                backgroundColor:
                    activePortalId.state != null ? Colors.red : Colors.grey,
                borderRadius: 8,
              ),
              children: [
                DCFText(
                  content: '🗑️ Remove Portal Content',
                  textProps: DCFTextProps(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: DCFFontWeight.bold,
                  ),
                  layout: LayoutProps(height: 25.0),
                ),
              ],
            ),
          ],
        ),

        // Clear all button
        DCFGestureDetector(
          layout: LayoutProps(marginBottom: 20.0, height: 60.0),
          onTap: (_) async {
            await ExplicitPortalAPI.clearTarget('test-portal');
            activePortalId.setState(null);
          },
          children: [
            DCFView(
              layout: LayoutProps(
                padding: 16.0,
                height: 60.0,
                width: "100%",
                justifyContent: YogaJustifyContent.center,
                alignItems: YogaAlign.center,
              ),
              styleSheet: StyleSheet(
                backgroundColor: Colors.orange,
                borderRadius: 8,
              ),
              children: [
                DCFText(
                  content: '🧹 Clear All Portals',
                  textProps: DCFTextProps(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: DCFFontWeight.bold,
                  ),
                  layout: LayoutProps(height: 25.0),
                ),
              ],
            ),
          ],
        ),

        // Status section
        DCFView(
          layout: LayoutProps(
            padding: 16.0,
            marginBottom: 16.0,
            height: 80.0,
            width: "100%",
          ),
          styleSheet: StyleSheet(
            backgroundColor: Colors.grey[100],
            borderRadius: 8,
            borderWidth: 1,
            borderColor: Colors.grey[300],
          ),
          children: [
            DCFText(
              content:
                  'Status: ${activePortalId.state != null ? "Portal Active" : "No Active Portal"}',
              textProps: DCFTextProps(
                fontSize: 16,
                fontWeight: DCFFontWeight.bold,
                color:
                    activePortalId.state != null
                        ? Colors.green[700]
                        : Colors.grey[600],
              ),
              layout: LayoutProps(height: 25.0, marginBottom: 8.0),
            ),
            DCFText(
              content: 'Portal ID: ${activePortalId.state ?? "None"}',
              textProps: DCFTextProps(fontSize: 12, color: Colors.grey[500]),
              layout: LayoutProps(height: 18.0),
            ),
          ],
        ),
      ],
    );
  }
}
