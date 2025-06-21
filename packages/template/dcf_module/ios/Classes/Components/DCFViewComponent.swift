/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import UIKit
import dcflight

class DCFViewComponent: NSObject, DCFComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a basic UIView
        let view = UIView()
        
        // Print all props for debugging
        print("📋 DCFViewComponent createView props: \(props.keys.sorted().joined(separator: ", "))")
        
        // Check for gradient first
        if let gradientData = props["backgroundGradient"] as? [String: Any] {
            print("🌈 DCFViewComponent found gradient in createView: \(gradientData)")
        }
        
        // Apply adaptive default styling - let OS handle light/dark mode
        let isAdaptive = props["adaptive"] as? Bool ?? true
        if isAdaptive {
            // Use system colors that automatically adapt to light/dark mode
            if #available(iOS 13.0, *) {
                view.backgroundColor = UIColor.systemBackground
            } else {
                view.backgroundColor = UIColor.white
            }
        } else {
            view.backgroundColor = UIColor.clear
        }
        
        // Apply StyleSheet properties before other props to ensure correct order
        view.applyStyles(props: props)
        
        // Apply any other props that were passed
        updateView(view, withProps: props)
        
        return view
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let view = view as? UIView else { return false }
        
        // If a background gradient is specified, ensure it's applied
        if let gradientData = props["backgroundGradient"] as? [String: Any] {
            print("🌈 DCFViewComponent explicitly applying gradient: \(gradientData)")
            view.applyStyles(props: ["backgroundGradient": gradientData])
        }
        
        // Apply StyleSheet properties (handles backgroundColor, borderRadius, opacity, etc.)
        view.applyStyles(props: props)
        
        return true
    }
}
