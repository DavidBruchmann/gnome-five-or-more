# Implementation Plan

- [x] 1. Create combo mode indicator manager component
  - Implement ComboModeIndicatorManager class to centralize all visual indicator logic
  - Add methods for updating header bar indicator, menu state, and notifications
  - Integrate with existing GSettings system for state persistence
  - _Requirements: 1.4, 2.2, 4.1, 4.2_

- [x] 2. Implement header bar combo mode indicator
  - [x] 2.1 Add combo mode icon to header bar layout
    - Create and position combo mode indicator icon in header bar
    - Use appropriate GTK icon or custom symbol for combo mode representation
    - Implement visibility toggle based on combo mode state
    - _Requirements: 2.1, 2.3, 2.4_

  - [x] 2.2 Add tooltip and accessibility support for header indicator
    - Implement descriptive tooltip explaining combo mode status
    - Add ARIA labels and screen reader support for the indicator
    - Ensure keyboard navigation compatibility
    - _Requirements: 2.5, 5.1, 5.2_

- [ ] 3. Enhance menu system with state indicators
  - [ ] 3.1 Convert combo mode menu item to stateful action
    - Modify existing toggle-combo-mode action to support state display
    - Update menu item definition to show checkmark when combo mode is active
    - Ensure menu state updates immediately when mode changes
    - _Requirements: 1.1, 1.3, 1.4, 1.5_

  - [ ] 3.2 Implement menu state synchronization
    - Add logic to sync menu indicator with actual combo mode state
    - Handle state restoration when application starts
    - Ensure consistency between settings, game constants, and menu display
    - _Requirements: 4.1, 4.2, 4.3_

- [ ] 4. Enhance mode transition notifications
  - [ ] 4.1 Improve notification content and styling
    - Update notification messages with clearer mode descriptions
    - Add distinctive icons or symbols to differentiate mode notifications
    - Extend notification duration for better readability
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ] 4.2 Add accessibility announcements for mode changes
    - Implement screen reader announcements when combo mode toggles
    - Ensure notifications are accessible to assistive technologies
    - Add keyboard navigation support for notification interactions
    - _Requirements: 3.5, 5.3, 5.4_

- [ ] 5. Integrate indicator system with existing toggle functionality
  - [ ] 5.1 Update existing toggle_combo_mode method
    - Modify current toggle implementation to use new indicator manager
    - Ensure all visual indicators update when mode changes
    - Maintain backward compatibility with existing functionality
    - _Requirements: 1.4, 2.2, 3.4, 4.4_

  - [ ] 5.2 Add state persistence and restoration
    - Implement indicator state restoration on application startup
    - Ensure visual indicators reflect saved settings correctly
    - Handle edge cases where settings and display state might be inconsistent
    - _Requirements: 4.1, 4.2, 4.5_

- [ ] 6. Update UI definition file for enhanced menu
  - Modify five-or-more.ui to support stateful combo mode menu item
  - Add proper role and state attributes for menu accessibility
  - Ensure UI changes maintain existing layout and functionality
  - _Requirements: 1.1, 1.2, 6.1, 6.2_

- [ ] 7. Implement error handling and graceful degradation
  - [ ] 7.1 Add indicator consistency validation
    - Implement checks to ensure visual indicators match actual game state
    - Add recovery mechanisms for inconsistent state scenarios
    - Provide fallback behavior when indicator resources are unavailable
    - _Requirements: 7.1, 7.2, 7.3_

  - [ ]* 7.2 Add comprehensive error logging
    - Implement detailed logging for indicator state changes and errors
    - Add diagnostic information for troubleshooting indicator issues
    - Create validation tools for verifying indicator functionality
    - _Requirements: 7.4, 7.5_

- [ ] 8. Create comprehensive test suite for visual indicators
  - [ ]* 8.1 Write unit tests for indicator manager
    - Test ComboModeIndicatorManager state management functionality
    - Verify correct indicator updates for various mode change scenarios
    - Test error handling and recovery mechanisms
    - _Requirements: 1.4, 2.2, 4.2_

  - [ ]* 8.2 Create integration tests for complete toggle flow
    - Test full user interaction flow from menu click to visual feedback
    - Verify indicator persistence across application restarts
    - Test accessibility features and screen reader integration
    - _Requirements: 3.1, 4.1, 5.1_

  - [ ]* 8.3 Add visual regression tests
    - Create tests to ensure indicators don't break existing UI layout
    - Verify proper positioning and styling of header bar indicator
    - Test menu state display consistency across different themes
    - _Requirements: 6.3, 6.4, 6.5_