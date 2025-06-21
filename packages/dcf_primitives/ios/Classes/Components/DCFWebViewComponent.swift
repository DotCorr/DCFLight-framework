/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation
import UIKit
import WebKit
import dcflight

class DCFWebViewComponent: NSObject, DCFComponent {
    // Use shared instance pattern like other components
    private static let sharedInstance = DCFWebViewComponent()
    
    private var currentURL: String?
    private weak var sourceView: UIView?  // Track the source view for events
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Ensure we're on the main thread for UI operations
        guard Thread.isMainThread else {
            print("DCFWebView: Creating view on background thread, dispatching to main")
            return DispatchQueue.main.sync {
                return createView(props: props)
            }
        }
        
        let configuration = WKWebViewConfiguration()
        
        // Configure JavaScript
        let javaScriptEnabled = props["javaScriptEnabled"] as? Bool ?? true
        configuration.preferences.javaScriptEnabled = javaScriptEnabled
        
        // Configure media playback
        let allowsInlineMediaPlayback = props["allowsInlineMediaPlayback"] as? Bool ?? true
        configuration.allowsInlineMediaPlayback = allowsInlineMediaPlayback
        
        let mediaPlaybackRequiresUserAction = props["mediaPlaybackRequiresUserAction"] as? Bool ?? true
        configuration.mediaTypesRequiringUserActionForPlayback = mediaPlaybackRequiresUserAction ? .all : []
        
        // Create the web view
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        print("DCFWebView: Successfully created WKWebView")
        
        // Store source view for event propagation
        sourceView = webView
        
        // Set navigation delegate to shared instance
        webView.navigationDelegate = DCFWebViewComponent.sharedInstance
        webView.uiDelegate = DCFWebViewComponent.sharedInstance
        
        // Ensure the webview is visible and properly sized
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = true  // Make opaque to ensure content visibility
        webView.backgroundColor = UIColor.white  // Always white background
        
        // Configure scroll behavior
        let allowsZoom = props["allowsZoom"] as? Bool ?? true
        webView.scrollView.isScrollEnabled = props["scrollEnabled"] as? Bool ?? true
        webView.scrollView.showsHorizontalScrollIndicator = props["showsScrollIndicators"] as? Bool ?? true
        webView.scrollView.showsVerticalScrollIndicator = props["showsScrollIndicators"] as? Bool ?? true
        webView.scrollView.bounces = props["bounces"] as? Bool ?? true
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = 
                (props["automaticallyAdjustContentInsets"] as? Bool ?? true) ? .automatic : .never
        }
        
        // Set user agent if provided
        if let userAgent = props["userAgent"] as? String {
            webView.customUserAgent = userAgent
        }
        
        // Handle adaptive theming - always use white for better visibility 
        webView.backgroundColor = UIColor.white
        webView.scrollView.backgroundColor = UIColor.white
        
        print("DCFWebView: WebView configured, about to load content")
        
        // Load content on main thread
        DispatchQueue.main.async {
            DCFWebViewComponent.sharedInstance.loadContent(webView: webView, props: props)
        }
        
        return webView  // Return webview directly
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // View should be the webview directly now
        guard let webView = view as? WKWebView else { 
            print("DCFWebView: updateView - View is not a WKWebView")
            return false 
        }
        
        let source = props["source"] as? String ?? ""
        
        // Only reload if source changed
        if DCFWebViewComponent.sharedInstance.currentURL != source {
            print("DCFWebView: updateView - Source changed from \(DCFWebViewComponent.sharedInstance.currentURL ?? "nil") to \(source)")
            DispatchQueue.main.async {
                DCFWebViewComponent.sharedInstance.loadContent(webView: webView, props: props)
            }
        }
        
        // Update other properties that can be changed without reload
        webView.scrollView.isScrollEnabled = props["scrollEnabled"] as? Bool ?? true
        webView.scrollView.showsHorizontalScrollIndicator = props["showsScrollIndicators"] as? Bool ?? true
        webView.scrollView.showsVerticalScrollIndicator = props["showsScrollIndicators"] as? Bool ?? true
        webView.scrollView.bounces = props["bounces"] as? Bool ?? true
        
        // Handle adaptive theming updates
        let isAdaptive = props["adaptive"] as? Bool ?? true
        if isAdaptive {
            if #available(iOS 13.0, *) {
                webView.backgroundColor = UIColor.systemBackground
                webView.scrollView.backgroundColor = UIColor.systemBackground
            } else {
                webView.backgroundColor = UIColor.white
                webView.scrollView.backgroundColor = UIColor.white
            }
        }
        
        view.applyStyles(props: props)
        return true
    }
    
    // MARK: - DCFComponent Protocol Methods
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        view.frame = CGRect(
            x: CGFloat(layout.left),
            y: CGFloat(layout.top),
            width: CGFloat(layout.width),
            height: CGFloat(layout.height)
        )
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Track node registration for debugging
    }
    
    private func loadContent(webView: WKWebView, props: [String: Any]) {
        // Ensure we're on the main thread for all web view operations
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.loadContent(webView: webView, props: props)
            }
            return
        }
        
        let source = props["source"] as? String ?? ""
        let loadMode = props["loadMode"] as? String ?? "url"
        let contentType = props["contentType"] as? String ?? "html"
        
        print("DCFWebView: Loading content - source: \(source), loadMode: \(loadMode)")
        print("DCFWebView: WebView frame: \(webView.frame)")
        print("DCFWebView: WebView bounds: \(webView.bounds)")
        print("DCFWebView: WebView superview: \(webView.superview?.description ?? "nil")")
        
        currentURL = source
        
        // Ensure webView is properly configured for content loading
        webView.isHidden = false
        webView.alpha = 1.0
        
        switch loadMode {
        case "url":
            if source.isEmpty {
                print("DCFWebView: Empty source URL provided")
                return
            }
            
            guard let url = URL(string: source) else {
                print("DCFWebView: Invalid URL: \(source)")
                return
            }
            
            var request = URLRequest(url: url)
            
            // Add debugging headers and proper configuration
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.timeoutInterval = 30.0
            
            print("DCFWebView: Loading URL request: \(url)")
            print("DCFWebView: Request headers: \(request.allHTTPHeaderFields ?? [:])")
            print("DCFWebView: Request timeout: \(request.timeoutInterval)")
            
            // Load the request
            webView.load(request)
            
        case "htmlString":
            print("DCFWebView: Loading HTML string of length: \(source.count)")
            webView.loadHTMLString(source, baseURL: nil)
            
        case "localFile":
            // Load file from app bundle using Flutter asset resolution
            if let key = sharedFlutterViewController?.lookupKey(forAsset: source),
               let path = Bundle.main.path(forResource: key, ofType: nil),
               let fileURL = URL(string: "file://" + path) {
                
                if #available(iOS 9.0, *) {
                    webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
                } else {
                    // Fallback for older iOS versions
                    if let data = try? Data(contentsOf: fileURL) {
                        let mimeType = mimeTypeForContentType(contentType)
                        webView.load(data, mimeType: mimeType, characterEncodingName: "UTF-8", baseURL: fileURL.deletingLastPathComponent())
                    }
                }
            } else {
                // Fallback: try direct file path if asset resolution fails
                if let fileURL = URL(string: source.hasPrefix("file://") ? source : "file://" + source) {
                    if #available(iOS 9.0, *) {
                        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
                    } else {
                        // Fallback for older iOS versions
                        if let data = try? Data(contentsOf: fileURL) {
                            let mimeType = mimeTypeForContentType(contentType)
                            webView.load(data, mimeType: mimeType, characterEncodingName: "UTF-8", baseURL: fileURL.deletingLastPathComponent())
                        }
                    }
                }
            }
            
        default:
            break
        }
    }
    
    private func mimeTypeForContentType(_ contentType: String) -> String {
        switch contentType {
        case "html":
            return "text/html"
        case "pdf":
            return "application/pdf"
        case "markdown":
            return "text/markdown"
        case "text":
            return "text/plain"
        default:
            return "text/html"
        }
    }
}

// MARK: - WKNavigationDelegate
extension DCFWebViewComponent: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("DCFWebView: didStartProvisionalNavigation - URL: \(webView.url?.absoluteString ?? "nil")")
        print("DCFWebView: WebView frame during load start: \(webView.frame)")
        print("DCFWebView: WebView isHidden: \(webView.isHidden), alpha: \(webView.alpha)")
        
        guard let sourceView = DCFWebViewComponent.sharedInstance.sourceView else { return }
        propagateEvent(on: sourceView, eventName: "onLoadStart", data: [
            "url": webView.url?.absoluteString ?? "",
            "title": webView.title ?? ""
        ])
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("DCFWebView: didFinish navigation - URL: \(webView.url?.absoluteString ?? "nil")")
        print("DCFWebView: Page title: \(webView.title ?? "nil")")
        print("DCFWebView: WebView frame after load: \(webView.frame)")
        print("DCFWebView: WebView isHidden: \(webView.isHidden), alpha: \(webView.alpha)")
        
        // Force a layout pass to ensure content is visible
        DispatchQueue.main.async {
            webView.setNeedsLayout()
            webView.layoutIfNeeded()
            print("DCFWebView: Forced layout update after content load")
        }
        
        guard let sourceView = DCFWebViewComponent.sharedInstance.sourceView else { return }
        propagateEvent(on: sourceView, eventName: "onLoadEnd", data: [
            "url": webView.url?.absoluteString ?? "",
            "title": webView.title ?? ""
        ])
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("DCFWebView: Navigation failed - Error: \(error.localizedDescription)")
        print("DCFWebView: Error code: \((error as NSError).code)")
        print("DCFWebView: Error domain: \((error as NSError).domain)")
        print("DCFWebView: Error userInfo: \((error as NSError).userInfo)")
        
        guard let sourceView = DCFWebViewComponent.sharedInstance.sourceView else { return }
        propagateEvent(on: sourceView, eventName: "onLoadError", data: [
            "error": error.localizedDescription,
            "code": (error as NSError).code,
            "url": webView.url?.absoluteString ?? ""
        ])
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("DCFWebView: Provisional navigation failed - Error: \(error.localizedDescription)")
        print("DCFWebView: Error code: \((error as NSError).code)")
        print("DCFWebView: Error domain: \((error as NSError).domain)")
        print("DCFWebView: Error userInfo: \((error as NSError).userInfo)")
        
        guard let sourceView = DCFWebViewComponent.sharedInstance.sourceView else { return }
        propagateEvent(on: sourceView, eventName: "onLoadError", data: [
            "error": error.localizedDescription,
            "code": (error as NSError).code,
            "url": webView.url?.absoluteString ?? ""
        ])
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString ?? ""
        
        guard let sourceView = DCFWebViewComponent.sharedInstance.sourceView else { 
            decisionHandler(.allow)
            return 
        }
        
        propagateEvent(on: sourceView, eventName: "onNavigationStateChange", data: [
            "url": url,
            "title": webView.title ?? "",
            "canGoBack": webView.canGoBack,
            "canGoForward": webView.canGoForward,
            "loading": webView.isLoading
        ])
        
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate
extension DCFWebViewComponent: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        
        if let viewController = findViewController(from: webView) {
            viewController.present(alert, animated: true, completion: nil)
        } else {
            completionHandler()
        }
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        
        if let viewController = findViewController(from: webView) {
            viewController.present(alert, animated: true, completion: nil)
        } else {
            completionHandler(false)
        }
    }
    
    private func findViewController(from view: UIView) -> UIViewController? {
        var responder: UIResponder? = view
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
}
