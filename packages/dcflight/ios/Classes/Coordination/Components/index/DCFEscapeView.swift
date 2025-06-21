import UIKit
import yoga

/// A simple view that can completely disappear from layout when escaped
public class DCFEscapeView: UIView {
    private var storedSubviews: [UIView] = []
    private var _isEscaped: Bool = false
    
    /// Whether the children are currently escaped from the main UI layout
    public var isEscaped: Bool {
        get { return _isEscaped }
        set {
            if _isEscaped != newValue {
                _isEscaped = newValue
                updateEscapeState()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.clear
    }
    
    /// Updates the escape state
    private func updateEscapeState() {
        if _isEscaped {
            // Store and remove children
            storedSubviews = Array(subviews)
            subviews.forEach { $0.removeFromSuperview() }
            
            // Force Yoga node to zero dimensions
            setYogaToZero()
        } else {
            // Restore children
            storedSubviews.forEach { addSubview($0) }
            storedSubviews.removeAll()
            
            // Restore Yoga node
            restoreYoga()
        }
    }
    
    /// Set Yoga node to zero dimensions - AGGRESSIVE approach for true zero space
    private func setYogaToZero() {
        guard let nodeId = objc_getAssociatedObject(self, UnsafeRawPointer(bitPattern: "nodeId".hashValue)!) as? String else { 
            print("⚠️ DCFEscapeView: No nodeId found, cannot set Yoga to zero - will rely on frame/bounds override")
            return 
        }
        
        // CRITICAL: Use the most aggressive Yoga properties to ensure ZERO space
        let zeroProps: [String: Any] = [
            "display": "none",          // Most important: completely remove from layout tree
            "width": 0.0,               // Force zero width
            "height": 0.0,              // Force zero height
            "minWidth": 0.0,            // Prevent minimum width
            "minHeight": 0.0,           // Prevent minimum height
            "maxWidth": 0.0,            // Prevent maximum width override
            "maxHeight": 0.0,           // Prevent maximum height override
            "marginTop": 0.0,           // Remove any margin
            "marginBottom": 0.0,
            "marginLeft": 0.0,
            "marginRight": 0.0,
            "paddingTop": 0.0,          // Remove any padding
            "paddingBottom": 0.0,
            "paddingLeft": 0.0,
            "paddingRight": 0.0,
            "position": "absolute"      // Remove from normal flow
        ]
        
        YogaShadowTree.shared.updateNodeLayoutProps(nodeId: nodeId, props: zeroProps)
        print("🧹 DCFEscapeView: Applied AGGRESSIVE zero-space Yoga properties for nodeId: \(nodeId)")
    }
    
    /// Restore Yoga node to normal
    private func restoreYoga() {
        guard let nodeId = objc_getAssociatedObject(self, UnsafeRawPointer(bitPattern: "nodeId".hashValue)!) as? String else { 
            print("⚠️ DCFEscapeView: No nodeId found, cannot restore Yoga - will rely on frame/bounds restore")
            return 
        }
        
        // Restore to normal flex layout
        let normalProps: [String: Any] = [
            "display": "flex",
            "position": "relative"
            // Don't set width/height here - let the framework handle sizing
        ]
        
        YogaShadowTree.shared.updateNodeLayoutProps(nodeId: nodeId, props: normalProps)
        print("✅ DCFEscapeView: Restored normal Yoga properties for nodeId: \(nodeId)")
    }
    
    /// Get stored children
    public func getStoredChildren() -> [UIView] {
        return storedSubviews
    }
    
    /// Set stored children
    public func setStoredChildren(_ children: [UIView]) {
        storedSubviews = children
    }
    
    /// Override addSubview to handle escape state
    public override func addSubview(_ view: UIView) {
        if _isEscaped {
            storedSubviews.append(view)
        } else {
            super.addSubview(view)
        }
    }
    
    /// Return zero size when escaped
    public override var intrinsicContentSize: CGSize {
        return _isEscaped ? CGSize.zero : super.intrinsicContentSize
    }
    
    /// Return zero size when escaped
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return _isEscaped ? CGSize.zero : super.sizeThatFits(size)
    }
    
    /// Force zero frame when escaped - AGGRESSIVE override to prevent ANY space allocation
    public override func layoutSubviews() {
        if _isEscaped {
            // CRITICAL: Force absolutely zero space allocation
            frame = CGRect.zero
            bounds = CGRect.zero
            isHidden = true
            alpha = 0.0
            isUserInteractionEnabled = false
            clipsToBounds = true
            
            // Ensure no subviews are visible
            subviews.forEach { $0.isHidden = true }
            return
        }
        
        // Restore normal state when not escaped
        isHidden = false
        alpha = 1.0
        isUserInteractionEnabled = true
        
        super.layoutSubviews()
    }
    
    /// Override setFrame to enforce zero size when escaped
    public override var frame: CGRect {
        get {
            return _isEscaped ? CGRect.zero : super.frame
        }
        set {
            if _isEscaped {
                super.frame = CGRect.zero
            } else {
                super.frame = newValue
            }
        }
    }
    
    /// Override setBounds to enforce zero size when escaped  
    public override var bounds: CGRect {
        get {
            return _isEscaped ? CGRect.zero : super.bounds
        }
        set {
            if _isEscaped {
                super.bounds = CGRect.zero
            } else {
                super.bounds = newValue
            }
        }
    }
}
