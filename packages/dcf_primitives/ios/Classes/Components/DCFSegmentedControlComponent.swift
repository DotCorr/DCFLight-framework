/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import dcflight

class DCFSegmentedControlComponent: NSObject, DCFComponent {
    // Use shared instance like other working components (Toggle, Slider, etc.)
    private static let sharedInstance = DCFSegmentedControlComponent()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        print("🚀 DCFSegmentedControlComponent.createView called with props: \(props)")
        
        // Extract segments from props
        var segments: [String] = []
        var iconAssets: [String] = []
        
        if let segmentArray = props["segments"] as? [[String: Any]] {
            // Parse segment objects from Dart
            for segmentData in segmentArray {
                if let title = segmentData["title"] as? String {
                    segments.append(title)
                    if let iconAsset = segmentData["iconAsset"] as? String {
                        iconAssets.append(iconAsset)
                    } else {
                        iconAssets.append("")
                    }
                }
            }
        } else if let segmentArray = props["segments"] as? [String] {
            // Legacy string array support
            segments = segmentArray
        } else if let segmentArray = props["segments"] as? [Any] {
            // Try to extract strings from mixed array
            segments = segmentArray.compactMap { $0 as? String }
        }
        
        print("📊 Parsed segments: \(segments), icons: \(iconAssets)")
        
        // Create segmented control with segments
        let segmentedControl = UISegmentedControl(items: segments.isEmpty ? ["Segment 1"] : segments)
        
        // Set up icons if available
        if !iconAssets.isEmpty {
            updateSegments(segmentedControl, segments: segments, iconAssets: iconAssets)
        }
        
        // Apply adaptive theming like other DCF components
        let isAdaptive = props["adaptive"] as? Bool ?? true
        if isAdaptive {
            if #available(iOS 13.0, *) {
                // Use system colors for adaptive theming
                segmentedControl.backgroundColor = UIColor.systemGray6
                segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
                segmentedControl.tintColor = UIColor.label
            } else {
                // Fallback for older iOS versions
                segmentedControl.backgroundColor = UIColor.lightGray
                segmentedControl.tintColor = UIColor.blue
            }
        }
        
        // Set initial selection
        if let selectedIndex = props["selectedIndex"] as? Int,
           selectedIndex >= 0 && selectedIndex < segmentedControl.numberOfSegments {
            segmentedControl.selectedSegmentIndex = selectedIndex
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
        
        // Configure target-action for value changes - use shared instance like other components
        segmentedControl.addTarget(DCFSegmentedControlComponent.sharedInstance, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        updateView(segmentedControl, withProps: props)
        return segmentedControl
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let segmentedControl = view as? UISegmentedControl else {
            print("❌ DCFSegmentedControlComponent: View is not a UISegmentedControl")
            return false
        }
        
        print("🔄 DCFSegmentedControlComponent updateView called with props: \(props)")
        
        // Update segments if changed
        var segments: [String] = []
        var iconAssets: [String] = []
        
        if let segmentArray = props["segments"] as? [[String: Any]] {
            // Parse segment objects from Dart
            for segmentData in segmentArray {
                if let title = segmentData["title"] as? String {
                    segments.append(title)
                    if let iconAsset = segmentData["iconAsset"] as? String {
                        iconAssets.append(iconAsset)
                    } else {
                        iconAssets.append("")
                    }
                }
            }
            updateSegments(segmentedControl, segments: segments, iconAssets: iconAssets)
        } else if let segmentArray = props["segments"] as? [String] {
            // Legacy string array support
            segments = segmentArray
            updateSegments(segmentedControl, segments: segments, iconAssets: [])
        } else if let segmentArray = props["segments"] as? [Any] {
            // Try to extract strings from mixed array
            segments = segmentArray.compactMap { $0 as? String }
            updateSegments(segmentedControl, segments: segments, iconAssets: [])
        }
        
        // Update selected index
        if let selectedIndex = props["selectedIndex"] as? Int {
            if selectedIndex >= 0 && selectedIndex < segmentedControl.numberOfSegments {
                segmentedControl.selectedSegmentIndex = selectedIndex
                print("✅ Updated selectedIndex to: \(selectedIndex)")
            } else {
                print("⚠️ Invalid selectedIndex: \(selectedIndex), segments count: \(segmentedControl.numberOfSegments)")
            }
        }
        
        // Update enabled state
        if let enabled = props["enabled"] as? Bool {
            segmentedControl.isEnabled = enabled
        }
        
        // Check if adaptive theming is enabled
        let isAdaptive = props["adaptive"] as? Bool ?? true
        
        // Update selected segment tint color (iOS 13+)
        if #available(iOS 13.0, *) {
            if let selectedColor = props["selectedTintColor"] as? String {
                segmentedControl.selectedSegmentTintColor = ColorUtilities.color(fromHexString: selectedColor)
            } else if isAdaptive {
                // Re-apply adaptive color if no explicit color provided
                segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
            }
        }
        
        // Update background color
        if let backgroundColor = props["backgroundColor"] as? String {
            segmentedControl.backgroundColor = ColorUtilities.color(fromHexString: backgroundColor)
        } else if isAdaptive {
            // Re-apply adaptive background if no explicit color provided
            if #available(iOS 13.0, *) {
                segmentedControl.backgroundColor = UIColor.systemGray6
            } else {
                segmentedControl.backgroundColor = UIColor.lightGray
            }
        }
        
        // Update tint color (affects text color of selected segment)
        if let tintColor = props["tintColor"] as? String {
            segmentedControl.tintColor = ColorUtilities.color(fromHexString: tintColor)
        } else if isAdaptive {
            // Re-apply adaptive tint color if no explicit color provided
            if #available(iOS 13.0, *) {
                segmentedControl.tintColor = UIColor.label
            } else {
                segmentedControl.tintColor = UIColor.blue
            }
        }
        
        // Apply common styles
        view.applyStyles(props: props)
        return true
    }
    
    private func updateSegments(_ segmentedControl: UISegmentedControl, segments: [String], iconAssets: [String] = []) {
        // Store current selection
        let currentSelection = segmentedControl.selectedSegmentIndex
        
        // Remove all existing segments
        segmentedControl.removeAllSegments()
        
        // Add new segments
        for (index, segment) in segments.enumerated() {
            // Check if we have an icon for this segment
            if index < iconAssets.count && !iconAssets[index].isEmpty {
                // Load icon image
                if let iconImage = loadIconImage(iconAssets[index]) {
                    segmentedControl.insertSegment(with: iconImage, at: index, animated: false)
                } else {
                    // Fallback to text if icon loading fails
                    segmentedControl.insertSegment(withTitle: segment, at: index, animated: false)
                }
            } else {
                // No icon, use text
                segmentedControl.insertSegment(withTitle: segment, at: index, animated: false)
            }
        }
        
        // Restore selection if still valid
        if currentSelection >= 0 && currentSelection < segments.count {
            segmentedControl.selectedSegmentIndex = currentSelection
        } else if !segments.isEmpty {
            segmentedControl.selectedSegmentIndex = 0
        }
        
        print("✅ Updated segments: \(segments) with icons: \(iconAssets)")
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let selectedTitle = sender.titleForSegment(at: selectedIndex) ?? ""
        
        print("🎯 Segmented control value changed to index: \(selectedIndex), title: '\(selectedTitle)'")
        
        // Create event data that matches what Dart expects
        let eventData: [String: Any] = [
            "selectedIndex": selectedIndex,
            "selectedTitle": selectedTitle
        ]
        
        print("🎯 Event data being sent: \(eventData)")
        
        // Propagate event to Dart
        propagateEvent(on: sender, eventName: "onSelectionChange", data: eventData) { view, data in
            print("🎯 Native-side processing for segmented control selection: \(data)")
        }
    }
    
    // MARK: - Icon Loading
    
    private func loadIconImage(_ asset: String) -> UIImage? {
        print("🔍 DCFSegmentedControl: Loading icon asset: \(asset)")
        
        // Use the Flutter asset lookup pattern from DCFSvgComponent
        let key = sharedFlutterViewController?.lookupKey(forAsset: asset)
        let mainBundle = Bundle.main
        
        // Try to load as UIImage first (for PNG, JPEG, etc.)
        if let assetKey = key,
           let path = mainBundle.path(forResource: assetKey, ofType: nil),
           let image = UIImage(contentsOfFile: path) {
            print("✅ DCFSegmentedControl: Successfully loaded icon from: \(path)")
            return image
        }
        
        // Fallback: try loading directly by asset name
        if let image = UIImage(named: asset) {
            print("✅ DCFSegmentedControl: Successfully loaded icon by name: \(asset)")
            return image
        }
        
        print("❌ DCFSegmentedControl: Failed to load icon asset: \(asset)")
        return nil
    }

    // MARK: - DCFComponent Protocol Methods
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        view.frame = CGRect(
            x: CGFloat(layout.left),
            y: CGFloat(layout.top),
            width: CGFloat(layout.width),
            height: CGFloat(layout.height)
        )
        
        print("📐 DCFSegmentedControlComponent.applyLayout - Applied layout: \(view.frame)")
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        guard let segmentedControl = view as? UISegmentedControl else {
            return CGSize(width: 200, height: 32)
        }
        
        // Get the intrinsic size of the segmented control
        let intrinsicSize = segmentedControl.intrinsicContentSize
        
        // Ensure minimum reasonable size
        let width = max(intrinsicSize.width, 100)
        let height = max(intrinsicSize.height, 32)
        
        return CGSize(width: width, height: height)
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        print("🌳 DCFSegmentedControlComponent view registered with shadow tree: \(nodeId)")
    }
}
