/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */



// Main entry point for the DCFlight framework
library dcflight;

export 'package:dcflight/framework/utilities/flutter_framework_interop.dart'
    hide
        PlatformDispatcher,
        Widget,
        View,
        StatefulWidget,
        State,
        BuildContext,
        MethodChannel,
        MethodCall,
        MethodCodec,
        PlatformException,
        AssetBundle,
        AssetBundleImageKey,
        AssetBundleImageProvider,
        ImageConfiguration,
        ImageStreamListener,
        ImageStream,
        ImageStreamCompleter,
        ImageInfo,
        ImageProvider,
        ImageErrorListener,
        ImageCache,
        Text,
        TextStyle,
        TextPainter,
        TextSpan,
        TextHeightBehavior,
        RenderBox,
        RenderObject,
        RenderObjectElement,
        RenderObjectWidget,
        StatefulElement,
        Element,
        ElementVisitor,
        WidgetInspectorService;
// Core Infrastructure
export 'framework/renderer/vdom/index.dart';



// Native Bridge System
export 'framework/renderer/interface/interface.dart';
export 'framework/renderer/interface/interface_impl.dart';

// Core Constants and Properties - explicitly exported for component developers
export 'framework/constants/layout/yoga_enums.dart';
export 'framework/constants/layout/layout_properties.dart';
export 'package:dcflight/framework/constants/layout/absolute_layout.dart';
export 'framework/constants/style/style_properties.dart';
export 'framework/constants/style/color_utils.dart';

// Utilities
export 'framework/utilities/screen_utilities.dart';

// DevTools (debug mode only)
export 'framework/devtools/hot_restart.dart';
export 'package:dcf_primitives/dcf_primitives.dart';
export 'framework/protocol/component_registry.dart';
export 'framework/protocol/plugin_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/component/component_node.dart';

import 'framework/renderer/vdom/vdom_api.dart';
import 'framework/renderer/interface/interface.dart';
import 'framework/utilities/screen_utilities.dart';
import 'framework/protocol/plugin_protocol.dart';
import 'framework/devtools/hot_restart.dart';
import 'package:flutter/material.dart';

/// DCFlight Framework entry points
class DCFlight {
  /// Initialize the DCFlight framework
  static Future<bool> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize platform dispatcher
    final bridge = NativeBridgeFactory.create();
    // PlatformDispatcher.initializeInstance(bridge);
    await bridge.initialize();

    // Initialize screen utilities
    ScreenUtilities.instance.refreshDimensions();

    // Initialize VDOM API with the bridge
    await VDomAPI.instance.init(bridge);


    // Register core plugin
    PluginRegistry.instance.registerPlugin(CorePlugin.instance);

    return true;
  }

  /// Start the application with the given root component
  static Future<void> start({required DCFComponentNode app}) async {
    await _initialize();
    
    // Check for hot restart and cleanup if needed (debug mode only)
    final wasHotRestart = await HotRestartDetector.detectAndCleanup();

    // Get the VDOM API instance
    final vdom = VDomAPI.instance;

    // Create our main app component
    final mainApp = app;

    // Create root with this component
    await vdom.createRoot(mainApp);
    
    if (wasHotRestart) {
      debugPrint('🔥 Hot restart detected - UI rebuilt successfully');
    }

    // Wait for the VDom to be ready
    vdom.isReady.whenComplete(() async {
      debugPrint('VDOM is ready - layout will be calculated automatically');
      // Previously, we had to call `calculateLayout` manually.
      // Now, layout is automatically calculated when layout props change at the native side 🤯.
    });
  }
}
