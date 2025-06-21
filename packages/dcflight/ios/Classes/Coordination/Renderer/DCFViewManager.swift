/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


import Flutter
import UIKit
import yoga
import Foundation

// Internal class definition for supported layout properties
class SupportedLayoutsProps {
    static let supportedLayoutProps = [
        "width", "height", "minWidth", "maxWidth", "minHeight", "maxHeight",
        "margin", "marginTop", "marginRight", "marginBottom", "marginLeft",
        "marginHorizontal", "marginVertical",
        "padding", "paddingTop", "paddingRight", "paddingBottom", "paddingLeft",
        "paddingHorizontal", "paddingVertical",
        "left", "top", "right", "bottom", "position",
        "translateX", "translateY", 
        "rotateInDegrees", 
        "scale", "scaleX", "scaleY",
        "flexDirection", "justifyContent", "alignItems", "alignSelf", "alignContent",
        "flexWrap", "flex", "flexGrow", "flexShrink", "flexBasis",
        "display", "overflow", "direction", "borderWidth",
        "aspectRatio", "gap", "rowGap", "columnGap"
    ]
}

// For ambiguous init issue:
typealias ViewTypeInfo = (view: UIView, type: String)

/// Registry for storing and managing view references
class ViewRegistry {
    // Singleton instance
    static let shared = ViewRegistry()
    
    // Maps view IDs to views and their types
    public var registry = [String: ViewTypeInfo]()
    
    private init() {}
    
    // Register a view with ID and type
    func registerView(_ view: UIView, id: String, type: String) {
        registry[id] = (view, type)
        
        // Also register with layout manager for direct access
        DCFLayoutManager.shared.registerView(view, withId: id)
    }
    
    // Get view info by ID
    func getViewInfo(id: String) -> ViewTypeInfo? {
        return registry[id]
    }
    
    // Get view by ID
    func getView(id: String) -> UIView? {
        return registry[id]?.view
    }
    
    // Remove a view by ID
    func removeView(id: String) {
        registry.removeValue(forKey: id)
        DCFLayoutManager.shared.unregisterView(withId: id)
    }
    
    // Get all view IDs
    var allViewIds: [String] {
        return Array(registry.keys)
    }
    
    // Clean up views
    func cleanup() {
        registry.removeAll()
    }
}

/// Main view manager that coordinates between all view-related systems
class DCFViewManager {
    // Singleton instance
    static let shared = DCFViewManager()
    
    private init() {}
    
    /// Create a view with automatic layout handling
    func createView(viewId: String, viewType: String, props: [String: Any]) -> Bool {
        print("🔍 DCFViewManager.createView called - viewId: \(viewId), viewType: \(viewType)")
        
        // Get component type
        guard let componentType = DCFComponentRegistry.shared.getComponentType(for: viewType) else {
            
            return false
        }
        
        // Create component instance and view
        let componentInstance = componentType.init()
       
        
        let view = componentInstance.createView(props: props)
        
        
        // Tag the view with its component type for event registration
        objc_setAssociatedObject(
            view,
            UnsafeRawPointer(bitPattern: "componentType".hashValue)!,
            viewType,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        // Register the view
        ViewRegistry.shared.registerView(view, id: viewId, type: viewType)
        
        
        // Create shadow tree node
        YogaShadowTree.shared.createNode(id: viewId, componentType: viewType)
        
        
        // Register with layout manager
        DCFLayoutManager.shared.registerView(view, withNodeId: viewId, componentType: viewType, componentInstance: componentInstance)
       
        
        // Apply layout props if any
        let layoutProps = extractLayoutProps(from: props)
        if !layoutProps.isEmpty {
            DCFLayoutManager.shared.updateNodeWithLayoutProps(
                nodeId: viewId,
                componentType: viewType,
                props: layoutProps
            )
          
        }
        
       
        return true
    }
    
    /// Update a view with automatic layout handling
    func updateView(viewId: String, props: [String: Any]) -> Bool {
        guard let viewInfo = ViewRegistry.shared.getViewInfo(id: viewId) else {
            print("❌ View not found: \(viewId)")
            return false
        }
        
        let view = viewInfo.view
        let viewType = viewInfo.type
        
        // Separate layout props from other props
        let layoutProps = extractLayoutProps(from: props)
        let nonLayoutProps = props.filter { !layoutProps.keys.contains($0.key) }
        
        // Update layout props if any
        if !layoutProps.isEmpty {
            DCFLayoutManager.shared.updateNodeWithLayoutProps(
                nodeId: viewId,
                componentType: viewType,
                props: layoutProps
            )
        }
        
        // Update non-layout props
        if !nonLayoutProps.isEmpty {
            guard let componentType = DCFComponentRegistry.shared.getComponentType(for: viewType) else {
                print("❌ Component type not found for: \(viewType)")
                return false
            }
            
            let componentInstance = componentType.init()
            let success = componentInstance.updateView(view, withProps: nonLayoutProps)
            
            if !success {
                print("❌ Failed to update view \(viewId)")
                return false
            }
        }
        
        print("✅ Updated view \(viewId)")
        return true
    }
    
    /// Delete a view with automatic cleanup
    func deleteView(viewId: String) -> Bool {
        // Remove from registries
        ViewRegistry.shared.removeView(id: viewId)
        DCFLayoutManager.shared.removeNode(nodeId: viewId)
        
        print("✅ Deleted view \(viewId)")
        return true
    }
    
    /// Attach a child view to a parent
    func attachView(childId: String, parentId: String, index: Int) -> Bool {
        guard let childView = ViewRegistry.shared.getView(id: childId),
              let parentView = ViewRegistry.shared.getView(id: parentId) else {
            print("❌ Views not found for attachment: child=\(childId), parent=\(parentId)")
            return false
        }
        
        // Add to view hierarchy
        if index >= 0 && index < parentView.subviews.count {
            parentView.insertSubview(childView, at: index)
        } else {
            parentView.addSubview(childView)
        }
        
        // Update layout tree
        DCFLayoutManager.shared.addChildNode(parentId: parentId, childId: childId, index: index)
        
        print("✅ Attached view \(childId) to \(parentId) at index \(index)")
        return true
    }
    
    /// Extract layout properties from props dictionary
    private func extractLayoutProps(from props: [String: Any]) -> [String: Any] {
        return props.filter { SupportedLayoutsProps.supportedLayoutProps.contains($0.key) }
    }
}

