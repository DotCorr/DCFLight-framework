/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import UIKit
import dcflight
import SVGKit

/// SVG component that renders SVG images from assets
class DCFSvgComponent: NSObject, DCFComponent {
    // Dictionary to cache loaded SVG images
    private static var imageCache = [String: SVGKImage]()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create an image view to display the SVG
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        // Set adaptive background color (SVGs typically transparent)
        let isAdaptive = props["adaptive"] as? Bool ?? true
        if isAdaptive {
            imageView.backgroundColor = UIColor.clear
        } else {
            imageView.backgroundColor = UIColor.clear
        }
        
        // Apply props
        updateView(imageView, withProps: props)
        
        // Apply StyleSheet properties
        imageView.applyStyles(props: props)
        
        return imageView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        print("🔍 DCFSvg updateView called with props: \(props)")
        
        guard let imageView = view as? UIImageView else { 
            print("❌ DCFSvg updateView: view is not UIImageView")
            return false 
        }
        
        print("✅ DCFSvg updateView: imageView cast successful")
        
        do {
            // Apply background color from StyleSheet
            if let backgroundColor = props["backgroundColor"] as? String {
                imageView.backgroundColor = ColorUtilities.color(fromHexString: backgroundColor)
            } else {
                // Re-apply adaptive colors if no explicit color provided
                let isAdaptive = props["adaptive"] as? Bool ?? true
                if isAdaptive {
                    imageView.backgroundColor = UIColor.clear
                }
            }
            
            // Handle asset loading (for initial creation) or prop updates
            if let asset = props["asset"] as? String {
                print("🔍 DCFSvg updateView: Loading asset: \(asset)")
                let key = sharedFlutterViewController?.lookupKey(forAsset: asset)
                let mainBundle = Bundle.main
                let path = mainBundle.path(forResource: key, ofType: nil)
                
                loadSvgFromAsset(
                    asset, 
                    into: imageView, 
                    props: props,  // Pass props to access tintColor
                    isRel: (props["isRelativePath"] as? Bool ?? false),
                    path: path ?? "no path"
                )
                print("🔍 DCFSvg updateView: Asset loading completed")
            } else {
                print("🔍 DCFSvg updateView: No asset property - applying tint color to existing image")
                // No asset provided - this is likely a prop update (like color change)
                // Apply tint color to the existing image
                applyTintColor(to: imageView, props: props)
            }
            
            // Apply StyleSheet properties (handles borderRadius, opacity, backgroundColor, etc.)
            print("🔍 DCFSvg updateView: Applying styles")
            imageView.applyStyles(props: props)
            
            print("✅ DCFSvg updateView: Successfully completed")
            return true
        } catch {
            print("❌ DCFSvg updateView: Exception occurred: \(error)")
            return false
        }
    }
    
    // MARK: - SVG Loading Methods
    
    private func loadSvgFromAsset(_ asset: String, into imageView: UIImageView, props: [String: Any], isRel: Bool, path: String) {
        // Check cache first
        if let cachedImage = DCFSvgComponent.imageCache[asset] {
            // Apply correct rendering mode based on whether tint color is specified
            let hasTintColor = props["tintColor"] as? String != nil
            let isAdaptive = props["adaptive"] as? Bool ?? true
            
            if hasTintColor || isAdaptive {
                // Use template mode for tinting
                imageView.image = cachedImage.uiImage?.withRenderingMode(.alwaysTemplate)
            } else {
                // Use original mode when no tinting
                imageView.image = cachedImage.uiImage?.withRenderingMode(.alwaysOriginal)
            }
            
            // Apply tint color AFTER image is set
            applyTintColor(to: imageView, props: props)
            
            // Trigger onLoad event since we're using the cached image
            propagateEvent(on: imageView, eventName: "onLoad", data: [:])
            return
        }
        
        // Load SVG using SVGKit
        if let svgImage = loadSVGFromAssetPath(asset, isRelativePath: isRel, path: path) {
            // Cache the image
            DCFSvgComponent.imageCache[asset] = svgImage
            
            // Apply correct rendering mode based on whether tint color is specified
            let hasTintColor = props["tintColor"] as? String != nil
            let isAdaptive = props["adaptive"] as? Bool ?? true
            
            if hasTintColor || isAdaptive {
                // Use template mode for tinting
                imageView.image = svgImage.uiImage?.withRenderingMode(.alwaysTemplate)
            } else {
                // Use original mode when no tinting
                imageView.image = svgImage.uiImage?.withRenderingMode(.alwaysOriginal)
            }
            
            // Apply tint color AFTER image is set
            applyTintColor(to: imageView, props: props)
            
            // Trigger onLoad event
            propagateEvent(on: imageView, eventName: "onLoad", data: [:])
        } else {
            // If we reach here, the image couldn't be loaded
            propagateEvent(on: imageView, eventName: "onError", data: ["error": "SVG not found: \(asset)"])
        }
    }
    
    // MARK: - Helper Methods
    
    private func applyTintColor(to imageView: UIImageView, props: [String: Any]) {
        print("🔍 DCFSvg applyTintColor called with props: \(props)")
        
        // Apply tint color if specified
        if let tintColorString = props["tintColor"] as? String,
           let tintColor = ColorUtilities.color(fromHexString: tintColorString) {
            print("🎨 Applying explicit tint color: \(tintColorString)")
            imageView.tintColor = tintColor
            // Force the image to use template rendering mode
            if let image = imageView.image {
                imageView.image = image.withRenderingMode(.alwaysTemplate)
            }
        } else {
            print("🔍 DCFSvg: No valid tintColor found. tintColor value: \(props["tintColor"] ?? "nil")")
            // Only apply adaptive tint if no explicit tintColor was provided at all
            // Check if a tintColor key exists but with nil/empty value vs no key at all
            if props["tintColor"] == nil {
                print("🔍 DCFSvg: tintColor key is nil - applying adaptive")
                // No tintColor specified - apply adaptive tint
                let isAdaptive = props["adaptive"] as? Bool ?? true
                if isAdaptive {
                    if #available(iOS 13.0, *) {
                        imageView.tintColor = UIColor.label
                    } else {
                        imageView.tintColor = UIColor.black
                    }
                    print("🎨 Applying adaptive tint color")
                    // Force the image to use template rendering mode
                    if let image = imageView.image {
                        imageView.image = image.withRenderingMode(.alwaysTemplate)
                    }
                } else {
                    print("🎨 No tint color - using original rendering")
                    // Reset to original rendering mode if no tint specified
                    if let image = imageView.image {
                        imageView.image = image.withRenderingMode(.alwaysOriginal)
                    }
                    // Clear tint color
                    imageView.tintColor = nil
                }
            } else {
                // tintColor key exists but couldn't be parsed - this means
                // an explicit (but invalid) color was provided, keep current state
                print("🎨 Invalid tint color provided, keeping current state")
            }
        }
    }
    
    // Load SVG from various possible sources using SVGKit
    private func loadSVGFromAssetPath(_ asset: String, isRelativePath: Bool, path: String) -> SVGKImage? {
        // Method 1: Try loading from direct path if it looks like a file path
        if (asset.hasPrefix("/") || asset.contains(".")) && FileManager.default.fileExists(atPath: asset) && isRelativePath == false {
            return SVGKImage(contentsOfFile: asset)
        } else if asset.hasPrefix("http://") || asset.hasPrefix("https://") {
            // Method 2: Try loading from URL
            if let url = URL(string: asset) {
                return SVGKImage(contentsOf: url)
            }
        } else if (isRelativePath == true) {
            return SVGKImage(contentsOfFile: path)
        }
        return nil
    }
}
