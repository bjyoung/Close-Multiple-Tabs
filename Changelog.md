# Close Multiple Tabs Changelog

This document tracks all notables changes to the Aseprite Close Multiple Tabs plugin.

---

## 1.0.0 Init

- Add a plugin that adds several options to the tab context menu (right-click on tab to open)
  - Close Others: closes all except the active tab
  - Close to the Left: closes all tabs to the left of the active tab
  - Close to the Right: closes all tabs to the right of the active tab
  - Close Row: close all tabs in the row that the active tab is in
- There are a couple limitations due to the limited available tab API options
  - When any of these options are used, the active tab becomes "modified"
  - The plugin creates a dummy file in order to determine which tabs should be closed, which can look strange sometimes
  - If any of the tabs to be closed are also modified, you cannot cancel out of the save dialog - it will lead to an infinite loop

---
