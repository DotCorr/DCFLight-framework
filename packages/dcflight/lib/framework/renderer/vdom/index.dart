/*
 * Copyright (c) Dotcorr Studio. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


/// This file serves as a central export point for the VDOM system,
/// allowing easy swapping between implementations.
library;

// Re-export the new VDOM API
export 'vdom_api.dart';

// Re-export the component classes from the new implementation
export 'component/component.dart';

// Re-export hooks
export 'component/state_hook.dart';
export 'component/fragment.dart';
// Re-export element and node classes
export 'component/component_node.dart';
export 'component/dcf_element.dart';

// Re-export error boundary
export 'component/error_boundary.dart';

// Re-export store
export 'component/store.dart';

// Re-export portal system
export 'portal/enhanced_portal_manager.dart';
export 'portal/dcf_portal.dart';
