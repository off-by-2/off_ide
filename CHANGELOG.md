# Changelog

## 0.1.3

- Added `iconWidget` property to `ActivityBarItem`, `SidebarView`, `MenuItem`, `MenuGroup`, and `MenuSubGroup` to support generic custom widgets (images, SVGs) overriding `icon` data.
- Fixed an issue requiring the `--no-tree-shake-icons` build flag for web by avoiding dynamic `IconData` parsing in models.
- Upgraded `WorkspaceShell` to dynamically react to `WorkspaceConfig` updates, automatically dropping inaccessible tabs and redirecting restricted views when roles or setups change.

## 0.1.2

- Added GitHub Actions for automatic deployment to GitHub Pages.
- Updated example application with generic terminology (Project Management / Team Workspace).
- Optimized Web support with standard persistence handling and fixed icon tree-shaking for web builds.
- Added live demo link to README.


## 0.1.1

- Initial release.
- VS Code-like workspace shell with Activity Bar, Sidebar, and Split Editor.
- Tab management with drag-and-drop reordering and cross-pane moves.
- Tab context menus (Close, Close Others, Close All).
- Resizable sidebar with drag handle.
- Actionable sidebar groups and subgroups.
- State persistence via `HydratedBloc`.
- Sidebar-to-editor drag-and-drop.
- Click-to-focus split panes with visual feedback.
- Theme-aware design supporting light and dark modes.

