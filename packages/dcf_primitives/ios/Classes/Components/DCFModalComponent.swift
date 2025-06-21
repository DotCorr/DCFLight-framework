/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import UIKit
import dcflight

class DCFModalComponent: NSObject, DCFComponent {
    
    // Track presented modals
    static var presentedModals: [String: DCFModalViewController] = [:]
    
    // FRAMEWORK FIX: Modal presentation queue to handle sequential operations
    static var modalOperationQueue: DispatchQueue = DispatchQueue(label: "DCFModalOperationQueue", qos: .userInitiated)
    static var pendingOperations: [(operation: ModalOperation, viewId: String, completion: (() -> Void)?)] = []
    static var isProcessingOperations = false
    
    enum ModalOperation {
        case present(view: UIView, props: [String: Any])
        case dismiss(view: UIView)
    }
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        print("🚀 DCFModalComponent.createView called with props: \(props.keys.sorted())")
        
        // Create a simple placeholder view
        let view = UIView()
        
        // Set the view as hidden but don't override its geometry
        view.isHidden = true
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = false
        
        let _ = updateView(view, withProps: props)
        return view
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        print("🔄 DCFModalComponent updateView called with props: \(props)")
        print("🔍 DCFModalComponent updateView - view hash: \(view.hash)")
        
        // Get view ID for tracking
        let viewId = String(view.hash)
        
        // Check if modal should be visible (handle both Bool and Int types)
        var isVisible = false
        if let visible = props["visible"] as? Bool {
            isVisible = visible
            print("🔍 DCFModalComponent: Found visible as Bool: \(isVisible)")
        } else if let visible = props["visible"] as? Int {
            isVisible = visible == 1
            print("🔍 DCFModalComponent: Found visible as Int: \(visible) -> \(isVisible)")
        } else if let visible = props["visible"] as? NSNumber {
            isVisible = visible.boolValue
            print("🔍 DCFModalComponent: Found visible as NSNumber: \(visible) -> \(isVisible)")
        } else {
            print("⚠️ DCFModalComponent: No visible property found or wrong type. Props: \(props)")
        }
        
        print("🔍 DCFModalComponent: Final visible value = \(isVisible)")
        
        // ✅ FRAMEWORK FIX: Queue modal operations to prevent conflicts
        if isVisible {
            print("🚀 DCFModalComponent: Queueing modal presentation")
            DCFModalComponent.queueModalOperation(.present(view: view, props: props), viewId: viewId)
        } else {
            // Only programmatically dismiss if we have a modal to dismiss
            if let modalVC = DCFModalComponent.presentedModals[viewId], !modalVC.isBeingDismissed {
                print("🚀 DCFModalComponent: Queueing modal dismissal")
                DCFModalComponent.queueModalOperation(.dismiss(view: view), viewId: viewId)
            } else {
                print("🔄 DCFModalComponent: Modal not presented or already being dismissed, ignoring visible=false")
            }
        }
        
        view.applyStyles(props: props)
        return true
    }
    
    // MARK: - DCFComponent Protocol Methods
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        // Apply the layout calculated by Yoga
        // When display="none", Yoga will calculate zero dimensions
        view.frame = CGRect(
            x: CGFloat(layout.left),
            y: CGFloat(layout.top),
            width: CGFloat(layout.width),
            height: CGFloat(layout.height)
        )
        
        print("📐 DCFModalComponent.applyLayout - Applied Yoga layout: \(view.frame)")
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        // Return a minimal intrinsic size
        // The actual space allocation will be controlled by the display property
        return CGSize(width: 1, height: 1)
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Track node registration for debugging
        print("🌳 DCFModalComponent view registered with shadow tree: \(nodeId)")
    }
    
    func setChildren(_ view: UIView, childViews: [UIView], viewId: String) -> Bool {
        print("🚀 DCFModalComponent.setChildren called with \(childViews.count) children for viewId: \(viewId)")
        print("🚀 DCFModalComponent.setChildren - view hash: \(view.hash)")
        print("🚀 DCFModalComponent.setChildren - children types: \(childViews.map { type(of: $0) })")
        
        // Store children in placeholder but keep them hidden from main UI
        view.subviews.forEach { $0.removeFromSuperview() }
        childViews.forEach { childView in
            view.addSubview(childView)
            // Hide children in placeholder view (they'll be shown when moved to modal)
            childView.isHidden = true
            childView.alpha = 0.0
        }
        
        print("💾 Stored \(childViews.count) children in placeholder view (hidden from main UI)")
        
        // If modal is currently presented, move children to modal content and make them visible
        if let modalVC = DCFModalComponent.presentedModals[viewId] {
            print("✅ Modal is presented, moving children to modal content and making them visible")
            addChildrenToModalContent(modalVC: modalVC, childViews: childViews)
        } else {
            print("📦 Modal not presented, children stored invisibly in placeholder view")
        }
        
        return true
    }
    
    private func addChildrenToModalContent(modalVC: DCFModalViewController, childViews: [UIView]) {
        // Clear existing children from modal content
        modalVC.view.subviews.forEach { subview in
            // Don't remove system views, only our content
            if subview.tag != 999 && subview.tag != 998 { // Preserve title and container
                print("🗑️ Removing existing subview from modal: \(type(of: subview))")
                subview.removeFromSuperview()
            }
        }
        
        // ✅ FIX 2: Force view layout to get accurate bounds before sizing children
        modalVC.view.setNeedsLayout()
        modalVC.view.layoutIfNeeded()
        
        // ✅ GIVE ABSTRACTION LAYER FULL CONTROL: No explicit margins/padding, full width/height
        let modalFrame = modalVC.view.bounds
        let availableWidth = modalFrame.width
        let availableHeight = modalFrame.height
        
        print("📏 Modal FULL sizing - modal bounds: \(modalFrame)")
        print("📏 Modal FULL sizing - available: \(availableWidth)x\(availableHeight)")
        
        // ✅ For sheet presentations, we need to account for the actual content area
        var contentFrame = modalFrame
        if #available(iOS 15.0, *), let sheet = modalVC.sheetPresentationController {
            // Use the modal view's safe area insets for sheet content
            let safeArea = modalVC.view.safeAreaInsets
            contentFrame = CGRect(
                x: safeArea.left,
                y: safeArea.top,
                width: modalFrame.width - safeArea.left - safeArea.right,
                height: modalFrame.height - safeArea.top - safeArea.bottom
            )
            print("📏 Sheet content area adjusted for safe area: \(contentFrame)")
        }
        
        // ✅ AUTO-FILL: Single child fills the entire modal space, let abstraction layer handle layout
        if childViews.count == 1, let childView = childViews.first {
            print("🎯 Single child: giving it FULL modal space for abstraction layer control")
            
            // Remove from any previous parent
            childView.removeFromSuperview()
            
            // ✅ KEY: Disable Auto Layout - use manual frame positioning 
            childView.translatesAutoresizingMaskIntoConstraints = true
            
            // Add to modal view
            modalVC.view.addSubview(childView)
            
            // ✅ MAKE VISIBLE: Child should be visible in modal (opposite of placeholder)
            childView.isHidden = false
            childView.alpha = 1.0
            
            // ✅ FULL FRAME: Give child the entire content area
            childView.frame = contentFrame
            
            print("📐 Child given FULL modal frame: \(childView.frame)")
            
            // ✅ Force layout update to ensure Yoga gets the correct size
            childView.setNeedsLayout()
            childView.layoutIfNeeded()
            
        } else if childViews.count > 1 {
            // Multiple children: stack vertically but use full width
            print("📚 Multiple children: stacking with full width, letting abstraction layer control spacing")
            
            var currentY: CGFloat = contentFrame.minY // Start at content area top
            
            for (index, childView) in childViews.enumerated() {
                print("🔄 Adding child \(index) with full width: \(type(of: childView))")
                
                // Remove from any previous parent
                childView.removeFromSuperview()
                
                // ✅ KEY: Disable Auto Layout
                childView.translatesAutoresizingMaskIntoConstraints = true
                
                // Add to modal view
                modalVC.view.addSubview(childView)
                
                // ✅ MAKE VISIBLE: Child should be visible in modal
                childView.isHidden = false
                childView.alpha = 1.0
                
                // Use child's existing height or default
                var childHeight: CGFloat = childView.frame.height > 0 ? childView.frame.height : 44
                let intrinsicSize = childView.intrinsicContentSize
                if intrinsicSize.height > 0 {
                    childHeight = intrinsicSize.height
                }
                
                // ✅ FULL WIDTH POSITIONING: Let abstraction layer handle internal spacing
                let childFrame = CGRect(
                    x: contentFrame.minX, // Respect content area
                    y: currentY,
                    width: contentFrame.width, // Full content width
                    height: childHeight
                )
                
                childView.frame = childFrame
                print("📐 Child \(index) frame: \(childFrame)")
                
                // Force layout update for this child
                childView.setNeedsLayout()
                childView.layoutIfNeeded()
                
                // No extra spacing - let abstraction layer control it
                currentY += childHeight
            }
        }
        
        print("✅ Modal content positioned with FULL space control given to abstraction layer")
    }
    // MARK: - Modal Operation Queue System (replaces old presentModal method)
    
    @available(iOS 15.0, *)
    private func configureSheetDetents(sheet: UISheetPresentationController, modalVC: UIViewController, props: [String: Any]) {
        var detents: [UISheetPresentationController.Detent] = []
        
        // ✅ FIX 1: Apply corner radius to sheet presentation controller
        var cornerRadius: CGFloat = 16.0 // Default value
        if let radius = props["cornerRadius"] as? CGFloat {
            cornerRadius = radius
            print("🔧 Sheet: Found cornerRadius as CGFloat: \(radius)")
        } else if let radius = props["cornerRadius"] as? Double {
            cornerRadius = CGFloat(radius)
            print("🔧 Sheet: Found cornerRadius as Double: \(radius)")
        } else if let radius = props["cornerRadius"] as? Int {
            cornerRadius = CGFloat(radius)
            print("🔧 Sheet: Found cornerRadius as Int: \(radius)")
        } else if let radius = props["cornerRadius"] as? NSNumber {
            cornerRadius = CGFloat(radius.doubleValue)
            print("🔧 Sheet: Found cornerRadius as NSNumber: \(radius)")
        } else {
            print("🔧 Sheet: No cornerRadius found, using default: \(cornerRadius)")
        }
        
        // Apply corner radius to the sheet
        if #available(iOS 16.0, *) {
            sheet.preferredCornerRadius = cornerRadius
            print("✅ Sheet: Set preferredCornerRadius to: \(cornerRadius)")
        }
        
        // Parse detents from props
        if let detentArray = props["detents"] as? [String] {
            for detentString in detentArray {
                switch detentString.lowercased() {
                case "small", "compact":
                    if #available(iOS 16.0, *) {
                        detents.append(.custom(identifier: .init("small")) { context in
                            return context.maximumDetentValue * 0.3
                        })
                    } else {
                        detents.append(.medium())
                    }
                case "medium", "half":
                    detents.append(.medium())
                case "large", "full":
                    detents.append(.large())
                default:
                    detents.append(.medium())
                }
            }
        } else {
            // Default detents
            detents = [.medium(), .large()]
        }
        
        sheet.detents = detents
        
        // Configure selected detent index
        if #available(iOS 16.0, *) {
            if let selectedDetentIndex = props["selectedDetentIndex"] as? Int,
               selectedDetentIndex < detents.count {
                sheet.selectedDetentIdentifier = detents[selectedDetentIndex].identifier
            }
        }
        
        // Configure other sheet properties
        sheet.prefersGrabberVisible = props["showDragIndicator"] as? Bool ?? true

        if let radius = props["cornerRadius"] as? CGFloat {
            cornerRadius = radius
            print("🔧 DCFModalComponent: Found cornerRadius as CGFloat: \(radius)")
        } else if let radius = props["cornerRadius"] as? Double {
            cornerRadius = CGFloat(radius)
            print("🔧 DCFModalComponent: Found cornerRadius as Double: \(radius)")
        } else if let radius = props["cornerRadius"] as? Int {
            cornerRadius = CGFloat(radius)
            print("🔧 DCFModalComponent: Found cornerRadius as Int: \(radius)")
        } else if let radius = props["cornerRadius"] as? NSNumber {
            cornerRadius = CGFloat(radius.doubleValue)
            print("🔧 DCFModalComponent: Found cornerRadius as NSNumber: \(radius)")
        } else {
            print("🔧 DCFModalComponent: No cornerRadius found, using default: \(cornerRadius)")
        }
        
        sheet.preferredCornerRadius = cornerRadius
        print("✅ DCFModalComponent: Set sheet corner radius to: \(cornerRadius)")
        
        // Configure dismissal behavior - use the modal view controller, not the sheet
        if let isDismissible = props["isDismissible"] as? Bool {
            modalVC.isModalInPresentation = !isDismissible
        }
        
        // Configure background interaction
        if props["allowsBackgroundDismiss"] as? Bool == false {
            modalVC.isModalInPresentation = true
        }
        
        // ✅ CRITICAL FIX: Set delegate to handle drag dismissal properly
        if let dcfModalVC = modalVC as? DCFModalViewController {
            sheet.delegate = dcfModalVC
        }
    }
    
    // NOTE: The old dismissModalWithoutMovingChildren and dismissModal methods have been
    // removed as all modal operations now go through the queue system in processQueuedOperation
    
    // MARK: - Modal Operation Queue System
    
    /// Queue a modal operation to be processed sequentially
    static func queueModalOperation(_ operation: ModalOperation, viewId: String, completion: (() -> Void)? = nil) {
        modalOperationQueue.async {
            pendingOperations.append((operation: operation, viewId: viewId, completion: completion))
            
            if !isProcessingOperations {
                processNextModalOperation()
            }
        }
    }
    
    /// Process the next modal operation in the queue
    static func processNextModalOperation() {
        guard !isProcessingOperations, !pendingOperations.isEmpty else { return }
        
        isProcessingOperations = true
        let nextOperation = pendingOperations.removeFirst()
        
        DispatchQueue.main.async {
            switch nextOperation.operation {
            case .present(let view, let props):
                print("🎭 Processing queued modal presentation for viewId: \(nextOperation.viewId)")
                self.performModalPresentation(from: view, props: props, viewId: nextOperation.viewId) {
                    nextOperation.completion?()
                    self.isProcessingOperations = false
                    // Process next operation after a brief delay to ensure proper sequencing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.processNextModalOperation()
                    }
                }
                
            case .dismiss(let view):
                print("🎭 Processing queued modal dismissal for viewId: \(nextOperation.viewId)")
                self.performModalDismissal(from: view, viewId: nextOperation.viewId) {
                    nextOperation.completion?()
                    self.isProcessingOperations = false
                    // Process next operation after a brief delay to ensure proper sequencing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.processNextModalOperation()
                    }
                }
            }
        }
    }
    
    /// Perform the actual modal presentation (extracted from presentModal)
    static func performModalPresentation(from view: UIView, props: [String: Any], viewId: String, completion: @escaping () -> Void) {
        // Check if modal is already presented
        if DCFModalComponent.presentedModals[viewId] != nil {
            print("ℹ️ DCFModalComponent: Modal already presented for viewId \(viewId)")
            completion()
            return
        }
        
        // Create modal content view controller
        let modalVC = DCFModalViewController()
        modalVC.modalProps = props
        modalVC.sourceView = view
        modalVC.viewId = viewId
        
        // ✅ FIX 1: Load modal view and prepare content BEFORE presenting
        modalVC.loadViewIfNeeded()
        
        // ✅ CRITICAL FIX: Look for children in placeholder view for reopen scenario
        let existingChildren = view.subviews
        print("🔍 Found \(existingChildren.count) children in placeholder view for modal presentation")
        
        if !existingChildren.isEmpty {
            print("🚀 Moving \(existingChildren.count) children from placeholder to modal")
            // Create a copy of the children array before modifying
            let childrenCopy = Array(existingChildren)
            let component = DCFModalComponent()
            component.addChildrenToModalContent(modalVC: modalVC, childViews: childrenCopy)
        } else {
            print("⚠️ No children found in placeholder view - modal will show empty")
            print("🔍 Placeholder view subviews: \(view.subviews)")
            print("🔍 Placeholder view frame: \(view.frame)")
            print("🔍 Placeholder view hidden: \(view.isHidden)")
        }
        
        // Store reference to presented modal BEFORE presentation
        DCFModalComponent.presentedModals[viewId] = modalVC
        
        // Configure modal presentation style
        if #available(iOS 15.0, *) {
            modalVC.modalPresentationStyle = .pageSheet
            
            // Configure sheet presentation controller with detents
            if let sheet = modalVC.sheetPresentationController {
                let component = DCFModalComponent()
                component.configureSheetDetents(sheet: sheet, modalVC: modalVC, props: props)
            }
        } else {
            // Fallback for older iOS versions
            modalVC.modalPresentationStyle = .formSheet
        }
        
        // Configure transition style
        if let transitionStyle = props["transitionStyle"] as? String {
            switch transitionStyle.lowercased() {
            case "coververtical":
                modalVC.modalTransitionStyle = .coverVertical
            case "fliphorizontal":
                modalVC.modalTransitionStyle = .flipHorizontal
            case "crossdissolve":
                modalVC.modalTransitionStyle = .crossDissolve
            case "partialcurl":
                if #available(iOS 3.2, *) {
                    modalVC.modalTransitionStyle = .partialCurl
                }
            default:
                modalVC.modalTransitionStyle = .coverVertical
            }
        }
        
        // Configure status bar appearance capture
        if let capturesStatusBar = props["capturesStatusBarAppearance"] as? Bool {
            modalVC.modalPresentationCapturesStatusBarAppearance = capturesStatusBar
        }
        
        // Configure presentation context
        if let definesPresentationContext = props["definesPresentationContext"] as? Bool {
            modalVC.definesPresentationContext = definesPresentationContext
        }
        
        // Configure transition context
        if let providesTransitionContext = props["providesTransitionContext"] as? Bool {
            modalVC.providesPresentationContextTransitionStyle = providesTransitionContext
        }
        
        // Present the modal
        if let topViewController = getTopViewController() {
            print("🚀 DCFModalComponent: Presenting modal from \(String(describing: topViewController))")
            
            topViewController.present(modalVC, animated: true) {
                print("✅ DCFModalComponent: Modal presentation completed")
                propagateEvent(on: view, eventName: "onShow", data: [:])
                completion()
            }
        } else {
            print("❌ DCFModalComponent: Could not find top view controller")
            // Remove from tracking if presentation failed
            DCFModalComponent.presentedModals.removeValue(forKey: viewId)
            completion()
        }
    }
    
    /// Perform the actual modal dismissal (extracted from dismissModal)
    static func performModalDismissal(from view: UIView, viewId: String, completion: @escaping () -> Void) {
        if let modalVC = DCFModalComponent.presentedModals[viewId] {
            print("🔄 DCFModalComponent: Programmatically dismissing tracked modal")
            
            modalVC.dismiss(animated: true) {
                print("✅ DCFModalComponent: Modal dismissal completed")
                propagateEvent(on: view, eventName: "onDismiss", data: [:])
                completion()
            }
            
            // Remove from tracking
            DCFModalComponent.presentedModals.removeValue(forKey: viewId)
        } else if let topViewController = getTopViewController(),
                  topViewController.presentedViewController != nil {
            print("🔄 DCFModalComponent: Dismissing any presented modal")
            topViewController.dismiss(animated: true) {
                propagateEvent(on: view, eventName: "onDismiss", data: [:])
                completion()
            }
        } else {
            print("ℹ️ DCFModalComponent: No modal to dismiss")
            completion()
        }
    }
    
    /// Get the top view controller (made static for queue operations)
    static func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { 
            print("❌ DCFModalComponent: Could not find window scene")
            return nil 
        }
        
        var topController = window.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
}

// MARK: - Modal View Controller

class DCFModalViewController: UIViewController, UISheetPresentationControllerDelegate {
    var modalProps: [String: Any] = [:]
    weak var sourceView: UIView?
    var viewId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModalContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // ✅ FIX 2: Ensure children are properly sized when modal bounds change
        let contentChildren = view.subviews.filter { $0.tag != 999 && $0.tag != 998 }
        
        if !contentChildren.isEmpty {
            print("📐 Modal bounds changed, updating \(contentChildren.count) children sizes")
            
            // Calculate the available content area
            var contentFrame = view.bounds
            if #available(iOS 15.0, *), let sheet = sheetPresentationController {
                let safeArea = view.safeAreaInsets
                contentFrame = CGRect(
                    x: safeArea.left,
                    y: safeArea.top,
                    width: view.bounds.width - safeArea.left - safeArea.right,
                    height: view.bounds.height - safeArea.top - safeArea.bottom
                )
            }
            
            // Update child frames to match new modal size
            if contentChildren.count == 1, let childView = contentChildren.first {
                // Single child fills entire content area
                childView.frame = contentFrame
                print("📐 Updated single child frame to: \(childView.frame)")
                
                // Force Yoga layout update
                childView.setNeedsLayout()
                childView.layoutIfNeeded()
            } else {
                // Multiple children: recalculate positions
                var currentY: CGFloat = contentFrame.minY
                
                for (index, childView) in contentChildren.enumerated() {
                    let childHeight = childView.frame.height
                    
                    let childFrame = CGRect(
                        x: contentFrame.minX,
                        y: currentY,
                        width: contentFrame.width,
                        height: childHeight
                    )
                    
                    childView.frame = childFrame
                    print("📐 Updated child \(index) frame to: \(childFrame)")
                    
                    // Force Yoga layout update
                    childView.setNeedsLayout()
                    childView.layoutIfNeeded()
                    
                    currentY += childHeight
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // ✅ CRITICAL FIX: Only move children if modal is ACTUALLY being dismissed, not just hiding
        // isBeingDismissed is only true when the modal is truly being removed, not during drag gestures
        if isBeingDismissed {
            print("� Modal is actually being dismissed - this is final")
            // Don't move children here - let presentationControllerDidDismiss handle it
            // This prevents duplicate child movement
        } else {
            print("🔄 Modal viewWillDisappear but NOT being dismissed - probably just drag gesture")
        }
    }
    
    // MARK: - UISheetPresentationControllerDelegate
    
    @available(iOS 13.5, *)
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        // ✅ Allow the user to start dragging to dismiss
        print("🤔 Should dismiss? Allowing user to drag...")
        return true
    }
    
    @available(iOS 13.5, *)
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        // ✅ This is called when the user STARTS the dismiss gesture (dragging down)
        // Do NOT move children here - user might change their mind
        print("🔄 Modal will dismiss - user started dragging (might cancel) - KEEPING CHILDREN IN MODAL")
        
        // ✅ ENSURE children stay visible during drag gesture
        ensureChildrenStayVisible()
    }
    
    @available(iOS 13.5, *)
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // ✅ This is called when the modal is ACTUALLY dismissed (user completed the gesture)
        print("✅ Modal did dismiss - user completed the dismiss gesture - NOW moving children")
        
        // Move children back to placeholder view only when actually dismissed
        if let sourceView = sourceView {
            let modalChildren = view.subviews.filter { $0.tag != 999 && $0.tag != 998 }
            
            if !modalChildren.isEmpty {
                print("💾 Final dismissal: Moving \(modalChildren.count) children back to placeholder")
                
                // Clear existing children from placeholder
                sourceView.subviews.forEach { $0.removeFromSuperview() }
                
                // Move children back to placeholder view and hide them from main UI
                modalChildren.forEach { child in
                    child.removeFromSuperview()
                    sourceView.addSubview(child)
                    // ✅ CRITICAL: Hide children when moved back to placeholder (main UI)
                    child.isHidden = true
                    child.alpha = 0.0
                }
            }
            
            propagateEvent(on: sourceView, eventName: "onDismiss", data: [:])
        }
        
        // Remove from tracking
        if let viewId = viewId {
            DCFModalComponent.presentedModals.removeValue(forKey: viewId)
        }
    }
    
    @available(iOS 13.5, *)
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        // ✅ This is called when user tries to dismiss but it's prevented
        print("⚠️ Modal dismiss attempt was prevented")
    }
    
    // ✅ Helper method to ensure children stay visible during drag gestures
    private func ensureChildrenStayVisible() {
        // Make sure all children are still in the modal view and visible
        let modalChildren = view.subviews.filter { $0.tag != 999 && $0.tag != 998 }
        
        print("🔍 Checking modal children visibility: found \(modalChildren.count) children")
        
        // If no children in modal but we expect them, try to restore from tracking
        if modalChildren.isEmpty, let viewId = viewId, let sourceView = sourceView {
            let placeholderChildren = sourceView.subviews
            
            if !placeholderChildren.isEmpty {
                print("🔧 No children in modal but found \(placeholderChildren.count) in placeholder - restoring to modal")
                
                // Move children back to modal during drag recovery
                placeholderChildren.forEach { child in
                    child.removeFromSuperview()
                    view.addSubview(child)
                }
                
                // Re-apply layout to restored children
                if let modalVC = DCFModalComponent.presentedModals[viewId] as? DCFModalViewController {
                    // Re-trigger the children positioning
                    DispatchQueue.main.async {
                        // Trigger layout update for restored children
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                    }
                }
            }
        } else {
            // Children exist, just ensure they're visible
            for child in modalChildren {
                child.isHidden = false
                child.alpha = 1.0
                
                // Ensure child is still properly positioned
                if child.superview != view {
                    print("🔧 Re-adding child to modal view: \(type(of: child))")
                    child.removeFromSuperview()
                    view.addSubview(child)
                }
            }
        }
        
        print("✅ Ensured modal children are visible and properly positioned")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Debug view hierarchy to find problematic overlays
        DispatchQueue.main.async {
            self.debugViewHierarchy()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // ✅ Only handle final cleanup if actually dismissed
        if isBeingDismissed {
            print("✅ Modal viewDidDisappear - actually dismissed")
        } else {
            print("🔄 Modal viewDidDisappear but not dismissed - probably drag gesture")
            
            // ✅ IMPORTANT: If modal reappears after drag, ensure children are still there
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !self.isBeingDismissed && self.view.window != nil {
                    self.ensureChildrenStayVisible()
                }
            }
        }
    }
    
    private func debugViewHierarchy() {
        print("🔍 DCFModalViewController view hierarchy:")
        debugPrintViewHierarchy(view: self.view, level: 0)
        
        // Look for problematic shadow or overlay views
        findAndFixProblematicViews(in: self.view)
    }
    
    private func debugPrintViewHierarchy(view: UIView, level: Int) {
        let indent = String(repeating: "  ", count: level)
        print("\(indent)- \(type(of: view)) (frame: \(view.frame), userInteractionEnabled: \(view.isUserInteractionEnabled))")
        
        for subview in view.subviews {
            debugPrintViewHierarchy(view: subview, level: level + 1)
        }
    }
    
    private func findAndFixProblematicViews(in view: UIView) {
        // Look for shadow views or transparent overlays that might intercept touches
        for subview in view.subviews {
            let className = String(describing: type(of: subview))
            
            // Check for known problematic view types like _UIRoundedRectShadowView
            if className.contains("Shadow") || className.contains("Rounded") || className.contains("Overlay") || className.contains("_UI") {
                print("🚨 Found potential problematic view: \(className)")
                print("   Frame: \(subview.frame)")
                print("   UserInteractionEnabled: \(subview.isUserInteractionEnabled)")
                print("   Background: \(String(describing: subview.backgroundColor))")
                
                // Try disabling user interaction on problematic views
                if subview.isUserInteractionEnabled {
                    print("   🔧 Disabling user interaction on overlay view: \(className)")
                    subview.isUserInteractionEnabled = false
                }
            }
            
            findAndFixProblematicViews(in: subview)
        }
    }
    
    private func setupModalContent() {
        view.backgroundColor = UIColor.systemBackground
        
        // Configure corner radius for the modal view
        var cornerRadius: CGFloat = 16.0 // Default value
        if let radius = modalProps["cornerRadius"] as? CGFloat {
            cornerRadius = radius
            print("🔧 DCFModalViewController: Found cornerRadius as CGFloat: \(radius)")
        } else if let radius = modalProps["cornerRadius"] as? Double {
            cornerRadius = CGFloat(radius)
            print("🔧 DCFModalViewController: Found cornerRadius as Double: \(radius)")
        } else if let radius = modalProps["cornerRadius"] as? Int {
            cornerRadius = CGFloat(radius)
            print("🔧 DCFModalViewController: Found cornerRadius as Int: \(radius)")
        } else if let radius = modalProps["cornerRadius"] as? NSNumber {
            cornerRadius = CGFloat(radius.doubleValue)
            print("🔧 DCFModalViewController: Found cornerRadius as NSNumber: \(radius)")
        } else {
            print("🔧 DCFModalViewController: No cornerRadius found, using default: \(cornerRadius)")
        }
        
        // ✅ FIX: Apply corner radius to both the view and sheet (if applicable)
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
        print("✅ DCFModalViewController: Set modal view corner radius to: \(cornerRadius)")
        
        // ✅ For sheet presentations on iOS 16+, the preferredCornerRadius should already be set
        // in configureSheetDetents, but let's ensure it's applied here too as a fallback
        if #available(iOS 16.0, *), let sheet = sheetPresentationController {
            sheet.preferredCornerRadius = cornerRadius
            print("✅ DCFModalViewController: Set sheet preferredCornerRadius to: \(cornerRadius)")
        }
        
        // ✅ REMOVED: No automatic title rendering - let abstraction layer handle titles
        // The title prop is still available in modalProps for the abstraction layer to use
        // but we don't force any specific title rendering or safe area constraints
        
        // Propagate onOpen event
        if let sourceView = sourceView {
            propagateEvent(on: sourceView, eventName: "onOpen", data: [:])
        }
    }
}
