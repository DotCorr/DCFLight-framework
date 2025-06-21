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
        guard let imageView = view as? UIImageView else { return false }
        
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
        
        // Get SVG asset path
        if let asset = props["asset"] as? String {
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
        }
        
        // Note: Tint color is now applied inside loadSvgFromAsset AFTER the image is loaded
        
        // Apply StyleSheet properties (handles borderRadius, opacity, backgroundColor, etc.)
        imageView.applyStyles(props: props)
        
        return true
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
        if let svgImage = loadSVGFromAssetPath(asset,isRelativePath: isRel,path: path) {
            // Cache the image
            DCFSvgComponent.imageCache[asset] = svgImage
            
            // Set the image
            imageView.image = svgImage.uiImage
            
            // Trigger onLoad event
            propagateEvent(on: imageView, eventName: "onLoad", data: [:])
        } else {
            // If we reach here, the image couldn't be loaded
            propagateEvent(on: imageView, eventName: "onError", data: ["error": "SVG not found: \(asset)"])
    }
        
        // Load SVG using SVGKit
        if let svgImage = loadSVGFromAssetPath(asset,isRelativePath: isRel,path: path) {
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
            // Apply adaptive tint if no explicit tint provided
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
        }
    }
    
    // Load SVG from various possible sources using SVGKit
    private func loadSVGFromAssetPath(_ asset: String, isRelativePath: Bool, path:String) -> SVGKImage? {
        // Method 1: Try loading from direct path if it looks like a file path
        if (asset.hasPrefix("/") || asset.contains(".")) && FileManager.default.fileExists(atPath: asset) && isRelativePath == false {
            return SVGKImage(contentsOfFile: asset)
        } else if asset.hasPrefix("http://") || asset.hasPrefix("https://") {
            if let url = URL(string: asset) {
                return SVGKImage(contentsOf: url)
            }
        } else if (isRelativePath == true) {
            return SVGKImage(contentsOfFile: path)
        }
        return nil
    }
}
