/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import 'package:dcflight/dcflight.dart';

/// WebView loading mode
enum DCFWebViewLoadMode {
  url,
  htmlString,
  localFile,
}

/// WebView content type
enum DCFWebViewContentType {
  html,
  pdf,
  markdown,
  text,
}

/// WebView navigation policy
enum DCFWebViewNavigationPolicy {
  allow,
  cancel,
  download,
}

/// WebView properties
class DCFWebViewProps {
  /// The URL to load or HTML string content
  final String source;
  
  /// Loading mode (URL, HTML string, or local file)
  final DCFWebViewLoadMode loadMode;
  
  /// Content type being loaded
  final DCFWebViewContentType contentType;
  
  /// Whether JavaScript is enabled
  final bool javaScriptEnabled;
  
  /// Whether the webview allows inline media playback
  final bool allowsInlineMediaPlayback;
  
  /// Whether media playback requires user action
  final bool mediaPlaybackRequiresUserAction;
  
  /// Whether the webview supports zoom
  final bool allowsZoom;
  
  /// Whether to show scroll indicators
  final bool showsScrollIndicators;
  
  /// Whether to bounce on scroll
  final bool bounces;
  
  /// Whether scrolling is enabled
  final bool scrollEnabled;
  
  /// Whether to automatically adjust content insets
  final bool automaticallyAdjustContentInsets;
  
  /// User agent string
  final String? userAgent;
  
  /// Whether to use adaptive theming
  final bool adaptive;
  
  /// Create webview props
  const DCFWebViewProps({
    required this.source,
    this.loadMode = DCFWebViewLoadMode.url,
    this.contentType = DCFWebViewContentType.html,
    this.javaScriptEnabled = true,
    this.allowsInlineMediaPlayback = true,
    this.mediaPlaybackRequiresUserAction = true,
    this.allowsZoom = true,
    this.showsScrollIndicators = true,
    this.bounces = true,
    this.scrollEnabled = true,
    this.automaticallyAdjustContentInsets = true,
    this.userAgent,
    this.adaptive = true,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'loadMode': loadMode.name,
      'contentType': contentType.name,
      'javaScriptEnabled': javaScriptEnabled,
      'allowsInlineMediaPlayback': allowsInlineMediaPlayback,
      'mediaPlaybackRequiresUserAction': mediaPlaybackRequiresUserAction,
      'allowsZoom': allowsZoom,
      'showsScrollIndicators': showsScrollIndicators,
      'bounces': bounces,
      'scrollEnabled': scrollEnabled,
      'automaticallyAdjustContentInsets': automaticallyAdjustContentInsets,
      if (userAgent != null) 'userAgent': userAgent,
      'adaptive': adaptive,
    };
  }
}

/// WebView component for loading dynamic content
class DCFWebView extends StatelessComponent {
  /// The webview properties
  final DCFWebViewProps webViewProps;
  
  /// The layout properties
  final LayoutProps layout;
  
  /// The style properties
  final StyleSheet styleSheet;
  
  /// Event handlers
  final Map<String, dynamic>? events;
  
  /// Called when page loading starts
  final Function(Map<dynamic, dynamic>)? onLoadStart;
  
  /// Called when page loading finishes
  final Function(Map<dynamic, dynamic>)? onLoadEnd;
  
  /// Called when page loading fails
  final Function(Map<dynamic, dynamic>)? onLoadError;
  
  /// Called when navigation is about to happen
  final Function(Map<dynamic, dynamic>)? onNavigationStateChange;
  
  /// Called when a message is received from JavaScript
  final Function(Map<dynamic, dynamic>)? onMessage;
  
  /// Called when loading progress changes
  final Function(Map<dynamic, dynamic>)? onLoadProgress;
  
  /// Create a webview component
  DCFWebView({
    required this.webViewProps,
    this.layout = const LayoutProps(
      height: 400,
      width: 300,
    ),
    this.styleSheet = const StyleSheet(),
    this.onLoadStart,
    this.onLoadEnd,
    this.onLoadError,
    this.onNavigationStateChange,
    this.onMessage,
    this.onLoadProgress,
    this.events,
    super.key,
  });
  
  @override
  DCFComponentNode render() {
    // Create an events map for callbacks
    Map<String, dynamic> eventMap = events ?? {};
    
    if (onLoadStart != null) {
      eventMap['onLoadStart'] = onLoadStart;
    }
    
    if (onLoadEnd != null) {
      eventMap['onLoadEnd'] = onLoadEnd;
    }
    
    if (onLoadError != null) {
      eventMap['onLoadError'] = onLoadError;
    }
    
    if (onNavigationStateChange != null) {
      eventMap['onNavigationStateChange'] = onNavigationStateChange;
    }
    
    if (onMessage != null) {
      eventMap['onMessage'] = onMessage;
    }
    
    if (onLoadProgress != null) {
      eventMap['onLoadProgress'] = onLoadProgress;
    }
    
    return DCFElement(
      type: 'WebView',
      props: {
        ...webViewProps.toMap(),
        ...layout.toMap(),
        ...styleSheet.toMap(),
        ...eventMap,
      },
      children: [], // WebView is a leaf node - no children allowed just incase you are wondering
    );
  }
}
