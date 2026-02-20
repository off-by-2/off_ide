import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:off_ide/off_ide.dart';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  runApp(const ExampleApp());
}

/// Main example application widget
class ExampleApp extends StatelessWidget {
  /// Creates the example app
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Off IDE Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.dark,
      home: const WorkspacePage(),
    );
  }
}

/// Page demonstrating the workspace layout
class WorkspacePage extends StatelessWidget {
  /// Creates the workspace page
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkspaceShell(
      config: WorkspaceConfig(
        activityBarItems: [
          const ActivityBarItem(
            id: 'explorer',
            icon: Icons.folder_copy_outlined,
            label: 'Explorer',
            tooltip: 'File Explorer (Ctrl+Shift+E)',
          ),
          const ActivityBarItem(
            id: 'search',
            icon: Icons.search,
            label: 'Search',
            tooltip: 'Search (Ctrl+Shift+F)',
          ),
          const ActivityBarItem(
            id: 'git',
            icon: Icons.source_outlined,
            label: 'Source Control',
          ),
          const ActivityBarItem(
            id: 'extensions',
            icon: Icons.extension_outlined,
            label: 'Extensions',
          ),
        ],
        sidebarViews: {
          'explorer': const SidebarView(
            id: 'explorer',
            title: 'Explorer',
            groups: [
              MenuGroup(
                id: 'open_editors',
                label: 'Open Editors',
                isExpanded: true,
                items: [], // Populated dynamically in a real app
              ),
              MenuGroup(
                id: 'project',
                label: 'Project',
                isExpanded: true,
                items: [
                  MenuItem(
                    id: 'main_dart',
                    label: 'main.dart',
                    pageId: 'editor',
                    icon: Icons.code,
                    pageArgs: {'fileName': 'main.dart', 'language': 'dart'},
                  ),
                  MenuItem(
                    id: 'pubspec_yaml',
                    label: 'pubspec.yaml',
                    pageId: 'editor',
                    icon: Icons.settings,
                    pageArgs: {'fileName': 'pubspec.yaml', 'language': 'yaml'},
                  ),
                  MenuItem(
                    id: 'readme',
                    label: 'README.md',
                    pageId: 'preview',
                    icon: Icons.info_outline,
                    pageArgs: {'fileName': 'README.md'},
                  ),
                ],
                subGroups: [
                  MenuSubGroup(
                    id: 'src',
                    label: 'src',
                    items: [
                      MenuItem(
                        id: 'utils_dart',
                        label: 'utils.dart',
                        pageId: 'editor',
                        icon: Icons.code,
                        pageArgs: {
                          'fileName': 'utils.dart',
                          'language': 'dart',
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
            actions: [
              SidebarAction(
                id: 'new_file',
                icon: Icons.note_add_outlined,
                tooltip: 'New File',
                onTap: _onNewFile,
              ),
              SidebarAction(
                id: 'refresh',
                icon: Icons.refresh,
                tooltip: 'Refresh',
                onTap: _onRefresh,
              ),
            ],
          ),
          'search': const SidebarView(
            id: 'search',
            title: 'Search',
            searchable: true,
            groups: [],
            // In a real app, you might use childBuilder for the search UI
          ),
        },
        pageRegistry: {
          'editor': (context, args) =>
              EditorPage(fileName: args?['fileName'] as String? ?? 'Untitled'),
          'preview': (context, args) =>
              PreviewPage(fileName: args?['fileName'] as String? ?? 'Untitled'),
        },
      ),
    );
  }

  static void _onNewFile() {
    debugPrint('New file action');
  }

  static void _onRefresh() {
    debugPrint('Refresh action');
  }
}

/// Dummy editor page
class EditorPage extends StatelessWidget {
  /// Creates the editor page
  const EditorPage({required this.fileName, super.key});

  /// Name of the file being edited
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.code, size: 64, color: Colors.blueGrey),
          const SizedBox(height: 16),
          Text(
            'Editing $fileName',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

/// Dummy preview page
class PreviewPage extends StatelessWidget {
  /// Creates the preview page
  const PreviewPage({required this.fileName, super.key});

  /// Name of the file being previewed
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.preview, size: 64, color: Colors.teal),
          const SizedBox(height: 16),
          Text(
            'Previewing $fileName',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text('Markdown content rendered here...'),
        ],
      ),
    );
  }
}
