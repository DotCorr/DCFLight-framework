
# DCFlight
# 🚧 This CLI is Under Development

## 📌 Key Points
DCFlight in short is a framework that renders actual native UI. It uses the flutter engine (Flutter engine here provides us the runtime and some utilities to initialize DCFlight. More like Hermes in react native). As seen below DCFlight:
``` swift
import dcflight

@main                                                  
@objc class AppDelegate: DCFAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```
It diverges from the flutter abstraction for UI rendering and renders the root view that dcflight depends on to render native UI. No platform views and no absurd abstractions. As a bonus you can still render a flutter Widget by using the ```WidgetToDCFAdaptor``` without impacting performance. 


## 📝 Dart Example

```dart

void main() {
  DCFlight.start(app: DCFGo());
}

import 'package:dcf_go/app/components/footer.dart';
import 'package:dcf_go/app/components/user_card.dart';
import 'package:dcf_go/app/store.dart';
import 'package:dcf_go/app/components/top_bar.dart';
import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

class DCFGo extends StatefulComponent {
  @override
  VDomNode render() {
    final globalCounter = useStore(globalCounterState);
    final counter = useState(0);
    return Fragment(
      children: [
        TopBar(globalCounter: globalCounter, counter: counter),
        DCFScrollView(
          showsScrollIndicator: true,
          style: StyleSheet(backgroundColor: Colors.white),
          layout: LayoutProps(
            paddingHorizontal: 20,
            justifyContent: YogaJustifyContent.spaceBetween,
            flex: 1,
            width: "100%",
            flexDirection: YogaFlexDirection.column,
          ),
          children: [
            UserCard(
              onPress: () {
                print("touchable pressed, maybe state woud change");
                print("counter value: ${counter.value}");
                print("global counter value: ${globalCounter.state}");
                counter.setValue(counter.value + 1);
                globalCounter.setState(globalCounter.state + 1);
              },
            ),
            UserCard(
              onPress: () {
                print("touchable pressed, maybe state woud change");
                print("counter value: ${counter.value}");
                print("global counter value: ${globalCounter.state}");
                counter.setValue(counter.value + 1);
                globalCounter.setState(globalCounter.state + 1);
              },
            ),
            UserCard(
              onPress: () {
                print("touchable pressed, maybe state woud change");
                print("counter value: ${counter.value}");
                print("global counter value: ${globalCounter.state}");
                counter.setValue(counter.value + 1);
                globalCounter.setState(globalCounter.state + 1);
              },
            ),
            UserCard(
              onPress: () {
                print("touchable pressed, maybe state woud change");
                print("counter value: ${counter.value}");
                print("global counter value: ${globalCounter.state}");
                counter.setValue(counter.value + 1);
                globalCounter.setState(globalCounter.state + 1);
              },
            ),
          ],
        ),
        GobalStateCounterComp(),
      ],
    );
  }
}
```


## ☕ Buy Me a Coffee  

> **Your support fuels the grind. Every contribution keeps this journey alive.**  

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://coff.ee/squirelboy360)  

[https://coff.ee/squirelboy360**](https://coff.ee/squirelboy360)

