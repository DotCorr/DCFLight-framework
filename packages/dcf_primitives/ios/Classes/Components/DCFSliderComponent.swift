/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import UIKit
import dcflight

// 🚀 SLIDER COMPONENT - Native UISlider with adaptive theming
class DCFSliderComponent: NSObject, DCFComponent {
    private static let sharedInstance = DCFSliderComponent()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        print("🚀 DCFSliderComponent.createView called with props: \(props.keys.sorted())")
        
        let slider = UISlider()
        
        // Apply adaptive theming like DCFViewComponent
        let isAdaptive = props["adaptive"] as? Bool ?? true
        if isAdaptive {
            if #available(iOS 13.0, *) {
                slider.minimumTrackTintColor = UIColor.systemBlue
                slider.maximumTrackTintColor = UIColor.systemGray4
                slider.thumbTintColor = UIColor.systemBlue
            } else {
                slider.minimumTrackTintColor = UIColor.blue
                slider.maximumTrackTintColor = UIColor.lightGray
                slider.thumbTintColor = UIColor.blue
            }
        }
        
        // Setup event handling
        slider.addTarget(DCFSliderComponent.sharedInstance, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(DCFSliderComponent.sharedInstance, action: #selector(sliderTouchBegan(_:)), for: .touchDown)
        slider.addTarget(DCFSliderComponent.sharedInstance, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        updateView(slider, withProps: props)
        slider.applyStyles(props: props)
        
        print("✅ DCFSliderComponent.createView completed successfully")
        return slider
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let slider = view as? UISlider else { return false }
        
        // Update value
        if let value = props["value"] as? Float {
            slider.value = value
        } else if let value = props["value"] as? Double {
            slider.value = Float(value)
        }
        
        // Update range
        if let minValue = props["minimumValue"] as? Float {
            slider.minimumValue = minValue
        } else if let minValue = props["minimumValue"] as? Double {
            slider.minimumValue = Float(minValue)
        }
        
        if let maxValue = props["maximumValue"] as? Float {
            slider.maximumValue = maxValue
        } else if let maxValue = props["maximumValue"] as? Double {
            slider.maximumValue = Float(maxValue)
        }
        
        // Update step
        if let step = props["step"] as? Float {
            // Note: UISlider doesn't have built-in step support, but we can handle it in the event
        }
        
        // Update disabled state
        if let disabled = props["disabled"] as? Bool {
            slider.isEnabled = !disabled
            slider.alpha = disabled ? 0.5 : 1.0
        }
        
        // Update colors
        if let minTrackColor = props["minimumTrackTintColor"] as? String,
           let color = ColorUtilities.color(fromHexString: minTrackColor) {
            slider.minimumTrackTintColor = color
        }
        
        if let maxTrackColor = props["maximumTrackTintColor"] as? String,
           let color = ColorUtilities.color(fromHexString: maxTrackColor) {
            slider.maximumTrackTintColor = color
        }
        
        if let thumbColor = props["thumbTintColor"] as? String,
           let color = ColorUtilities.color(fromHexString: thumbColor) {
            slider.thumbTintColor = color
        }
        
        slider.applyStyles(props: props)
        return true
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        propagateEvent(on: sender, eventName: "onValueChange", data: [
            "value": sender.value
        ])
    }
    
    @objc private func sliderTouchBegan(_ sender: UISlider) {
        propagateEvent(on: sender, eventName: "onSlidingStart", data: [
            "value": sender.value
        ])
    }
    
    @objc private func sliderTouchEnded(_ sender: UISlider) {
        propagateEvent(on: sender, eventName: "onSlidingComplete", data: [
            "value": sender.value
        ])
    }
}
