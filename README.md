# Off IDE

A high-performance, VS Code-like workspace shell widget for Flutter applications.

[**Live Demo**](https://off-by-2.github.io/off_ide/)


![Off IDE Demo](https://github.com/off-by-2/off_ide/raw/main/off_ide.gif)

## Features

- **VS Code Layout**: Familiar structure with Activity Bar, Sidebar, and Editor Area.
- **Split Editor**: Support for vertical split panes to view multiple tabs side-by-side.
- **Tab Management**: Robust tab system with close actions, dirty state indicators, and drag-and-drop support.
- **Persistence**: Automatic state restoration of open tabs and sidebar state via `HydratedBloc`.
- **Web Ready**: Optimized for web deployments with responsive design and persistence support.
- **High Performance**: Optimized for large widget trees with O(1) state lookups and granular rebuilds.
- **Custom Icons**: Support for dynamic widgets (images, SVGs, etc.) via the `iconWidget` property across sidebar and tabs, preserving icon tree-shaking for web applications.
- **Customizable**: Fully configurable activity bar, sidebar views, and page registry.
- **Theme Aware**: Seamlessly integrates with your application's `ThemeData`, supporting both light and dark modes.

## Getting Started

Add `off_ide` to your `pubspec.yaml`:

```yaml
dependencies:
  off_ide: ^0.1.2
```

## Usage

The main entry point is the `WorkspaceShell` widget, which requires a `WorkspaceConfig`. 

There are two primary ways to define this configuration: **Hardcoded** (for simple, static apps) and **Dynamic** (for robust, backend-driven apps like CRMs).

### 1. Basic Usage (Hardcoded)

For simple applications where the sidebar structure never changes, you can define your `WorkspaceConfig` statically:

```dart
import 'package:flutter/material.dart';
import 'package:off_ide/off_ide.dart';

void main() => runApp(const MyApp());

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
              icon: Icons.folder_outlined,
              label: 'Explorer',
            ),
          ],
          // 2. Define Sidebar Content
          sidebarViews: {
            'files': const SidebarView(
              id: 'files',
              title: 'EXPLORER',
              groups: [
                 MenuGroup(
                   id: 'project',
                   label: 'My Project',
                   items: [
                     MenuItem(
                       id: 'readme',
                       label: 'README.md',
                       pageId: 'markdown_viewer',
                       icon: Icons.description_outlined,
                     ),
                   ],
                 ),
              ],
            ),
          },
          // 3. Register Page Builders
          pageRegistry: {
            'markdown_viewer': (context, args) => const Center(child: Text('README')),
          },
        ),
      ),
    );
  }
}
```

### 2. Advanced Usage: Dynamic Configuration & RBAC (Recommended)

The `WorkspaceConfig` is built to be extremely flexible. For complex applications, it is highly recommended to dynamically generate your sidebar using backend-driven JSON schemas combined with a state manager (like `flutter_bloc`).

This approach easily enables **Role-Based Access Control (RBAC)**. 

#### Implementation Example
By wrapping `WorkspaceShell` in a state listener, the shell will seamlessly update and automatically close restricted tabs when roles change!

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Listen to your Auth/Role State Manager
    return BlocBuilder<RoleCubit, String>(
      builder: (context, currentRole) {
        return MaterialApp(
          home: WorkspaceShell(
            config: WorkspaceConfig(
              
              // 1. Parse your backend JSON and filter by `currentRole`
              activityBarItems: CustomParser.parseActivityBar(jsonSchema, currentRole),
              sidebarViews: CustomParser.parseSidebars(jsonSchema, currentRole),
              
              // 2. Only provide page builders the user has access to
              pageRegistry: CustomParser.getPageRegistry(currentRole),
            ),
          ),
        );
      },
    );
  }
}
```

#### Key Dynamic Features:
1. **Discard Restricted Items:** Overwrite your `CustomParser` to check if a user has permission to see a JSON item. If not, don't instantiate the `MenuItem`.
2. **Auto-Purge Tabs:** Because `WorkspaceShell` is deeply stateful, if the user's role changes, the shell will automatically purge any open tabs that no longer exist in the updated `pageRegistry`. 
3. **Custom Backend Icons:** Make use of the `iconWidget` parameter to parse custom backend icons (SVGs, Image Assets, custom Flutter code) instead of standard `IconData` to ensure Flutter web compilation works smoothly with tree-shaking.

*See the `example/lib/main.dart` source code to view a complete, production-ready implementation of dynamic JSON parsing and an interactive RBAC role toggle.*

## Additional Resources

Check out the `example` directory for a complete, runnable sample application.

## License

MIT
