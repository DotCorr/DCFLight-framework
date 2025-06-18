/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'package:dcf_go/app/examples/gradient.dart';
import 'package:dcf_go/app/examples/really_long_list.dart';
import 'package:dcf_go/app/examples/validation_test.dart';
import 'package:dcf_go/app/examples/list_state_perf.dart';
import 'package:dcf_go/app/examples/modal_test.dart';
import 'package:dcf_go/app/examples/swipeable_test.dart';
import 'package:dcf_go/app/examples/component_showcase.dart';
import 'package:dcf_go/app/examples/portal_test.dart';
import 'package:dcflight/dcflight.dart';

final pagestate = Store<int>(0);

// Test comment for hydration
class App extends StatefulComponent {
  @override
  DCFComponentNode render() {
    final pagestateLocal = useStore(pagestate);

    // Removed DCFPortalProvider wrapper to test modal rendering
    return DCFSafeAreaView(
      layout: LayoutProps(flex: 1, padding: 8),
      children: [
        DCFDropdown(
          layout: LayoutProps(height: 40, marginBottom: 8),
          onValueChange: (v) {
            pagestateLocal.setState(int.parse(v['value']));
            print("Selected value: $v, Item: $v");
          },
          onClose: (v) {
            print("closed");
          },
          onOpen: (v) {
            print("open");
          },
          dropdownProps: DCFDropdownProps(
            items: [
              DCFDropdownMenuItem(title: "Validation Test", value: "0"),
              DCFDropdownMenuItem(title: "List State Perf", value: "1"),
              DCFDropdownMenuItem(title: "Gradient Test", value: "2"),
              DCFDropdownMenuItem(title: "Really Long List", value: "3"),
              DCFDropdownMenuItem(title: "Modal & Alert Test", value: "4"),
              DCFDropdownMenuItem(title: "Swipeable Test", value: "5"),
              DCFDropdownMenuItem(title: "Component Showcase", value: "6"),
              DCFDropdownMenuItem(title: "Portal Test", value: "7"),
             
            ],
            selectedValue: pagestateLocal.state.toString(),
          ),
        ),
        DCFView(
          layout: LayoutProps(flex: 1, flexDirection: YogaFlexDirection.column),
          children: [
            pagestateLocal.state == 0
                ? ValidationTestApp()
                : pagestateLocal.state == 1
                ? ListStatePerf()
                : pagestateLocal.state == 2
                ? GradientTest()
                : pagestateLocal.state == 3
                ? ReallyLongList()
                : pagestateLocal.state == 4
                ? ModalTest()
                : pagestateLocal.state == 5
                ? SwipeableTest()
                : pagestateLocal.state == 6
                ? ComponentShowcase()
                : pagestateLocal.state == 7
                ? PortalTest()
                : DCFView(),
          ],
        ),

        DCFScrollView(
          styleSheet: StyleSheet(
            backgroundColor: Colors.grey[200]!,
            borderRadius: 8,
          ),
          horizontal: true,
          showsScrollIndicator: true,
          layout: LayoutProps(
            height: 70,
            padding: 10,
            paddingHorizontal: 8,
            flexWrap: YogaWrap.nowrap,
          ),
          children: [
            DCFView(
              layout: LayoutProps(
                flexDirection: YogaFlexDirection.row,
                justifyContent: YogaJustifyContent.spaceAround,
                alignItems: YogaAlign.center,
                gap: 8,
                height: 50,
                flexWrap: YogaWrap.nowrap,
                width: "100%",
              ),
              children: [
                DCFGestureDetector(
                  onTap: (v) {
                    pagestateLocal.setState(0);
                  },
                  layout: LayoutProps(
                    height: 50,
                    width: 50,
                    marginHorizontal: 4,
                  ),
                  children: [
                    DCFView(
                      layout: LayoutProps(
                        flex: 1,
                        justifyContent: YogaJustifyContent.center,
                        alignItems: YogaAlign.center,
                      ),
                      children: [
                        DCFIcon(
                          iconProps: DCFIconProps(
                            name: DCFIcons.house,
                            color:
                                pagestateLocal.state == 0
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                DCFGestureDetector(
                  onTap: (v) {
                    pagestateLocal.setState(1);
                  },
                  layout: LayoutProps(
                    height: 50,
                    width: 50,
                    marginHorizontal: 4,
                  ),
                  children: [
                    DCFView(
                      layout: LayoutProps(
                        flex: 1,
                        justifyContent: YogaJustifyContent.center,
                        alignItems: YogaAlign.center,
                      ),
                      children: [
                        DCFIcon(
                          iconProps: DCFIconProps(
                            name: DCFIcons.list,
                            color:
                                pagestateLocal.state == 1
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                DCFGestureDetector(
                  onTap: (v) {
                    pagestateLocal.setState(2);
                  },
                  layout: LayoutProps(
                    height: 50,
                    width: 50,
                    marginHorizontal: 4,
                  ),
                  children: [
                    DCFView(
                      layout: LayoutProps(
                        flex: 1,
                        justifyContent: YogaJustifyContent.center,
                        alignItems: YogaAlign.center,
                      ),
                      children: [
                        DCFIcon(
                          iconProps: DCFIconProps(
                            name: DCFIcons.palette,
                            color:
                                pagestateLocal.state == 2
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                DCFGestureDetector(
                  onTap: (v) {
                    pagestateLocal.setState(3);
                  },
                  layout: LayoutProps(
                    height: 50,
                    width: 50,
                    marginHorizontal: 4,
                  ),
                  children: [
                    DCFView(
                      layout: LayoutProps(
                        flex: 1,
                        justifyContent: YogaJustifyContent.center,
                        alignItems: YogaAlign.center,
                      ),
                      children: [
                        DCFIcon(
                          iconProps: DCFIconProps(
                            name: DCFIcons.recycle,
                            color:
                                pagestateLocal.state == 3
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                DCFGestureDetector(
                  onTap: (v) {
                    pagestateLocal.setState(4);
                  },
                  layout: LayoutProps(
                    height: 50,
                    width: 50,
                    marginHorizontal: 4,
                  ),
                  children: [
                    DCFView(
                      layout: LayoutProps(
                        flex: 1,
                        justifyContent: YogaJustifyContent.center,
                        alignItems: YogaAlign.center,
                      ),
                      children: [
                        DCFIcon(
                          iconProps: DCFIconProps(
                            name: DCFIcons.layoutGrid,
                            color:
                                pagestateLocal.state == 4
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                DCFGestureDetector(
                  onTap: (v) {
                    pagestateLocal.setState(5);
                  },
                  layout: LayoutProps(
                    height: 50,
                    width: 50,
                    marginHorizontal: 4,
                  ),
                  children: [
                    DCFView(
                      layout: LayoutProps(
                        flex: 1,
                        justifyContent: YogaJustifyContent.center,
                        alignItems: YogaAlign.center,
                      ),
                      children: [
                        DCFIcon(
                          iconProps: DCFIconProps(
                            name: DCFIcons.hand,
                            color:
                                pagestateLocal.state == 5
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                DCFGestureDetector(
                  onTap: (v) {
                    pagestateLocal.setState(6);
                  },
                  layout: LayoutProps(
                    height: 50,
                    width: 50,
                    marginHorizontal: 4,
                  ),
                  children: [
                    DCFView(
                      layout: LayoutProps(
                        flex: 1,
                        justifyContent: YogaJustifyContent.center,
                        alignItems: YogaAlign.center,
                      ),
                      children: [
                        DCFIcon(
                          iconProps: DCFIconProps(
                            name: DCFIcons.grid3x3,
                            color:
                                pagestateLocal.state == 6
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                DCFGestureDetector(
                  onTap: (v) {
                    pagestateLocal.setState(7);
                  },
                  layout: LayoutProps(
                    height: 50,
                    width: 50,
                    marginHorizontal: 4,
                  ),
                  children: [
                    DCFView(
                      layout: LayoutProps(
                        flex: 1,
                        justifyContent: YogaJustifyContent.center,
                        alignItems: YogaAlign.center,
                      ),
                      children: [
                        DCFIcon(
                          iconProps: DCFIconProps(
                            name: DCFIcons.shuffle,
                            color:
                                pagestateLocal.state == 7
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ], // Close DCFView children (inside DCFScrollView)
            ), // Close DCFView (inside DCFScrollView)
          ], // Close DCFScrollView children
        ), // Close DCFScrollView
      ], // Close DCFSafeAreaView children
    ); // Close DCFSafeAreaView (return statement)
  }
}
