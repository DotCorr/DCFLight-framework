/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import UIKit
import dcflight

// 🚀 CHECKBOX COMPONENT - Custom checkbox with checked/unchecked states
class DCFCheckboxComponent: NSObject, DCFComponent {
    private static let sharedInstance = DCFCheckboxComponent()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        let checkbox = DCFCheckboxView()
        
        // Apply adaptive theming
        let isAdaptive = props["adaptive"] as? Bool ?? true
        if isAdaptive {
            if #available(iOS 13.0, *) {
                checkbox.checkedColor = UIColor.systemBlue
                checkbox.uncheckedColor = UIColor.systemGray4
                checkbox.checkmarkColor = UIColor.white
            } else {
                checkbox.checkedColor = UIColor.blue
                checkbox.uncheckedColor = UIColor.lightGray
                checkbox.checkmarkColor = UIColor.white
            }
        }
         // Apply initial color props if provided
        if let activeColor = props["activeColor"] as? String,
           let color = ColorUtilities.color(fromHexString: activeColor) {
            checkbox.checkedColor = color
        }

        if let inactiveColor = props["inactiveColor"] as? String,
           let color = ColorUtilities.color(fromHexString: inactiveColor) {
            checkbox.uncheckedColor = color
        }

        if let checkmarkColor = props["checkmarkColor"] as? String,
           let color = ColorUtilities.color(fromHexString: checkmarkColor) {
            checkbox.checkmarkColor = color
        }

        // Setup event handling
        checkbox.addTarget(DCFCheckboxComponent.sharedInstance, action: #selector(checkboxTapped(_:)), for: .touchUpInside)

        updateView(checkbox, withProps: props)
        checkbox.applyStyles(props: props)
        
        // Force immediate redraw to ensure visibility on first render
        checkbox.setNeedsDisplay()
        checkbox.layoutIfNeeded()
        
        return checkbox
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let checkbox = view as? DCFCheckboxView else { return false }
        
        // Update checked state
        if let checked = props["checked"] as? Bool {
            checkbox.isChecked = checked
        }
        
        // Update enabled state
        if let disabled = props["disabled"] as? Bool {
            checkbox.isEnabled = !disabled
            checkbox.alpha = disabled ? 0.5 : 1.0
        }
        
        // Update colors
        if let checkedColor = props["checkedColor"] as? String {
            checkbox.checkedColor = ColorUtilities.color(fromHexString: checkedColor) ?? checkbox.checkedColor
        }
        
        if let uncheckedColor = props["uncheckedColor"] as? String {
            checkbox.uncheckedColor = ColorUtilities.color(fromHexString: uncheckedColor) ?? checkbox.uncheckedColor
        }
        
        if let checkmarkColor = props["checkmarkColor"] as? String {
            checkbox.checkmarkColor = ColorUtilities.color(fromHexString: checkmarkColor) ?? checkbox.checkmarkColor
        }
        
        // Update size
        if let size = props["size"] as? CGFloat {
            checkbox.checkboxSize = size
        } else {
            // Set default size based on size string
            let sizeString = props["size"] as? String ?? "medium"
            switch sizeString.lowercased() {
            case "small":
                checkbox.checkboxSize = 20.0
            case "large":
                checkbox.checkboxSize = 28.0
            default: // medium
                checkbox.checkboxSize = 24.0
            }
        }
        
        // Update border
        if let borderWidth = props["borderWidth"] as? CGFloat {
            checkbox.borderWidth = borderWidth
        }
        
        // Force redraw to ensure visibility
        checkbox.setNeedsDisplay()
        checkbox.invalidateIntrinsicContentSize()
        
        checkbox.applyStyles(props: props)
        return true
    }
    
    @objc private func checkboxTapped(_ sender: DCFCheckboxView) {
        sender.isChecked.toggle()
        
        propagateEvent(on: sender, eventName: "onValueChange", data: [
            "value": sender.isChecked
        ])
    }
}

// MARK: - Custom Checkbox View

class DCFCheckboxView: UIControl {
    var isChecked: Bool = false {
        didSet {
            setNeedsDisplay()
            updateAccessibility()
        }
    }
    
    var checkedColor: UIColor = UIColor.systemBlue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var uncheckedColor: UIColor = UIColor.systemGray4 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var checkmarkColor: UIColor = UIColor.white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var checkboxSize: CGFloat = 24.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    var borderWidth: CGFloat = 2.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: checkboxSize, height: checkboxSize)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = true
        
        // Add accessibility support
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "Checkbox"
        updateAccessibility()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let checkboxRect = CGRect(
            x: (bounds.width - checkboxSize) / 2,
            y: (bounds.height - checkboxSize) / 2,
            width: checkboxSize,
            height: checkboxSize
        )
        
        // Draw background
        context.setFillColor(isChecked ? checkedColor.cgColor : UIColor.clear.cgColor)
        context.setStrokeColor(isChecked ? checkedColor.cgColor : uncheckedColor.cgColor)
        context.setLineWidth(borderWidth)
        
        let cornerRadius: CGFloat = 4.0
        let path = UIBezierPath(roundedRect: checkboxRect, cornerRadius: cornerRadius)
        
        if isChecked {
            context.addPath(path.cgPath)
            context.fillPath()
        } else {
            context.addPath(path.cgPath)
            context.strokePath()
        }
        
        // Draw checkmark if checked
        if isChecked {
            context.setStrokeColor(checkmarkColor.cgColor)
            context.setLineWidth(2.0)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            
            let checkmarkPath = UIBezierPath()
            let checkmarkSize = checkboxSize * 0.6
            let checkmarkOrigin = CGPoint(
                x: checkboxRect.minX + (checkboxSize - checkmarkSize) / 2,
                y: checkboxRect.minY + (checkboxSize - checkmarkSize) / 2
            )
            
            checkmarkPath.move(to: CGPoint(x: checkmarkOrigin.x + checkmarkSize * 0.2, y: checkmarkOrigin.y + checkmarkSize * 0.5))
            checkmarkPath.addLine(to: CGPoint(x: checkmarkOrigin.x + checkmarkSize * 0.45, y: checkmarkOrigin.y + checkmarkSize * 0.75))
            checkmarkPath.addLine(to: CGPoint(x: checkmarkOrigin.x + checkmarkSize * 0.8, y: checkmarkOrigin.y + checkmarkSize * 0.25))
            
            context.addPath(checkmarkPath.cgPath)
            context.strokePath()
        }
    }
    
    // Update accessibility value when checked state changes
    private func updateAccessibility() {
        accessibilityValue = isChecked ? "Checked" : "Unchecked"
    }
}
