# Off IDE

A high-performance, VS Code-like workspace shell widget for Flutter applications.

<video src="https://github.com/off-by-2/off_ide/raw/main/off_ide.mp4" autoplay loop muted playsinline width="100%"></video>

## Features

- **VS Code Layout**: Familiar structure with Activity Bar, Sidebar, and Editor Area.
- **Split Editor**: Support for vertical split panes to view multiple tabs side-by-side.
- **Tab Management**: Robust tab system with close actions, dirty state indicators, and drag-and-drop (coming soon).
- **High Performance**: Optimized for large widget trees with O(1) state lookups and granular rebuilds.
- **Customizable**: Fully configurable activity bar, sidebar views, and page registry.
- **Theme Aware**: Seamlessly integrates with your application's `ThemeData`, supporting both light and dark modes.

## Getting Started

Add `off_ide` to your `pubspec.yaml`:

```yaml
dependencies:
  off_ide: ^0.1.0
```

## Usage

The main entry point is the `WorkspaceShell` widget, which requires a `WorkspaceConfig`.

```dart
import 'package:flutter/material.dart';
import 'package:off_ide/off_ide.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WorkspaceShell(
        config: WorkspaceConfig(
          // 1. Define Activity Bar Items
          activityBarItems: [
            const ActivityBarItem(
              id: 'files',
              icon: Icons.folder,
              label: 'Explorer',
            ),
            const ActivityBarItem(
              id: 'settings',
              icon: Icons.settings,
              label: 'Settings',
            ),
          ],

          // 2. Define Sidebar Content
          sidebarViews: {
            'files': const SidebarView(
              id: 'files',
              title: 'Explorer',
              groups: [
                 MenuGroup(
                   id: 'project',
                   label: 'My Project',
                   items: [
                     MenuItem(
                       id: 'readme',
                       label: 'README.md',
                       pageId: 'markdown_viewer',
                       pageArgs: {'file': 'README.md'},
                     ),
                   ],
                 ),
              ],
            ),
          },

          // 3. Register Page Builders
          pageRegistry: {
            'markdown_viewer': (context, args) {
              return Center(child: Text('Viewing ${args?['file']}'));
            },
          },
        ),
      ),
    );
  }
}
```

## Key Concepts

### WorkspaceConfig
The central configuration object defining the entire workspace structure. It connects activities to sidebars and menu items to pages.

### Activity Bar
The narrow vertical strip on the far left. Items here switch the *context* of the sidebar (e.g., from File Explorer to Search).

### Sidebar
The collapsible panel next to the activity bar. It typically displays hierarchical navigation (MenuGroups and MenuItems) relevant to the active activity.

### Split Editor
The main content area. It can display a single view or be split vertically to show multiple tabs at once.

## Additional Resources

Check out the `example` directory for a complete, runnable sample application.

## License

MIT
