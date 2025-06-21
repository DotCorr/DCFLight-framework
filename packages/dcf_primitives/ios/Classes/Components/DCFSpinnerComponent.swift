/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import UIKit
import dcflight

// 🚀 SPINNER/ACTIVITY INDICATOR COMPONENT - Native spinner with adaptive theming
class DCFSpinnerComponent: NSObject, DCFComponent {
    private static let sharedInstance = DCFSpinnerComponent()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        print("🚀 DCFSpinnerComponent.createView called with props: \(props.keys.sorted())")
        
        let spinner: UIActivityIndicatorView
        
        // Choose style based on props
        let style = props["style"] as? String ?? "medium"
        
        if #available(iOS 13.0, *) {
            switch style.lowercased() {
            case "large":
                spinner = UIActivityIndicatorView(style: .large)
            case "small":
                spinner = UIActivityIndicatorView(style: .medium)
            default: // medium
                spinner = UIActivityIndicatorView(style: .medium)
            }
        } else {
            switch style.lowercased() {
            case "large":
                spinner = UIActivityIndicatorView(style: .whiteLarge)
            case "small":
                spinner = UIActivityIndicatorView(style: .white)
            default: // medium
                spinner = UIActivityIndicatorView(style: .gray)
            }
        }
        
        // Apply adaptive theming like DCFViewComponent
        let isAdaptive = props["adaptive"] as? Bool ?? true
        if isAdaptive {
            if #available(iOS 13.0, *) {
                spinner.color = UIColor.label
            } else {
                spinner.color = UIColor.gray
            }
        }
        
        updateView(spinner, withProps: props)
        spinner.applyStyles(props: props)
        
        print("✅ DCFSpinnerComponent.createView completed successfully")
        return spinner
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let spinner = view as? UIActivityIndicatorView else { return false }
        
        // Update animating state
        if let animating = props["animating"] as? Bool {
            if animating {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        } else {
            // Default to animating
            spinner.startAnimating()
        }
        
        // Update color
        if let color = props["color"] as? String,
           let spinnerColor = ColorUtilities.color(fromHexString: color) {
            spinner.color = spinnerColor
        }
        
        // Update hidden when stopped
        if let hidesWhenStopped = props["hidesWhenStopped"] as? Bool {
            spinner.hidesWhenStopped = hidesWhenStopped
        } else {
            spinner.hidesWhenStopped = true // Default behavior
        }
        
        spinner.applyStyles(props: props)
        return true
    }
}
