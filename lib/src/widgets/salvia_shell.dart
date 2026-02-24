import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:off_ide/src/bloc/workspace_bloc.dart';
import 'package:off_ide/src/models/workspace_config_model.dart';
import 'package:off_ide/src/widgets/activity_bar.dart';
import 'package:off_ide/src/widgets/resizable_container.dart';
import 'package:off_ide/src/widgets/sidebar.dart';
import 'package:off_ide/src/widgets/split_editor.dart';

/// Main workspace shell widget providing a VS Code-like interface
///
/// This is the primary widget that creates a complete workspace environment
/// similar to Visual Studio Code, featuring:
///
/// - **Activity Bar**: Leftmost vertical bar with main activity icons
/// - **Sidebar**: Context-sensitive panel showing hierarchical content
/// - **Split Editor**: Main content area supporting vertical splits
/// - **Persistent State**: Maintains open tabs and layout across activity switches
///
/// ## Layout Structure
/// ```text
/// ┌─────────────┬──────────────┬─────────────────────────┐
/// │ Activity    │   Sidebar    │     Split Editor        │
/// │ Bar         │             │                         │
/// │ (48px)      │  (Variable)  │     (Remainder)         │
/// │             │             │                         │
/// │ • Explorer  │ - Main Item  │ ┌─────────┬─────────────┐ │
/// │ • Search    │   - Child    │ │ Tab Bar │   Tab Bar   │ │
/// │ • Git       │   - Child    │ ├─────────┼─────────────┤ │
/// │ • Debug     │ - Main Item  │ │         │             │ │
/// │ • Extensions│              │ │ Content │   Content   │ │
/// │             │              │ │         │             │ │
/// └─────────────┴──────────────┴─────────────────────────┘
/// ```
///
/// ## Usage Example
/// ```dart
/// WorkspaceShell(
///   config: WorkspaceConfig(
///     activityBarItems: [
///       ActivityBarItem(
///         id: 'explorer',
///         icon: Icons.folder_outlined,
///         label: 'Explorer',
///         sidebarView: SidebarView(/* ... */),
///       ),
///       // ... more items
///     ],
///   ),
/// )
/// ```
class WorkspaceShell extends StatelessWidget {
  /// Creates a [WorkspaceShell]
  const WorkspaceShell({required this.config, super.key});

  /// Configuration defining the workspace structure and content
  ///
  /// Contains activity bar items, sidebar views, theming, and behavior settings.
  final WorkspaceConfig config;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WorkspaceBloc(maxTabs: config.maxTabs)
            ..add(SwitchActivity(config.activityBarItems.first.id)),
      child: _WorkspaceLayout(config: config),
    );
  }
}

/// Internal layout widget that handles the actual UI structure
///
/// Separated for cleaner code organization and to ensure BLoC context
/// is properly available to all child widgets.
class _WorkspaceLayout extends StatefulWidget {
  const _WorkspaceLayout({required this.config});

  final WorkspaceConfig config;

  @override
  State<_WorkspaceLayout> createState() => _WorkspaceLayoutState();
}

class _WorkspaceLayoutState extends State<_WorkspaceLayout> {
  @override
  void didUpdateWidget(_WorkspaceLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if configuration changed
    if (widget.config != oldWidget.config) {
      final bloc = context.read<WorkspaceBloc>();
      final activeActivity = bloc.state.activeActivityId;

      // If the currently active activity is no longer in the config (e.g., due to role change),
      // switch to the first available activity to avoid a broken UI state.
      final activityExists = widget.config.activityBarItems.any(
        (item) => item.id == activeActivity,
      );

      if (!activityExists && widget.config.activityBarItems.isNotEmpty) {
        bloc.add(SwitchActivity(widget.config.activityBarItems.first.id));
      }

      // Check open tabs and close any that are no longer accessible
      final openTabs = bloc.state.openTabs;
      for (final tab in openTabs) {
        if (!widget.config.pageRegistry.containsKey(tab.pageId)) {
          bloc.add(CloseTab(tab.id));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<WorkspaceBloc, WorkspaceState>(
        builder: (context, state) {
          return Row(
            children: [
              // Activity Bar - Using proper ActivityBar widget
              ActivityBar(items: widget.config.activityBarItems),

              // Resizable Container for Sidebar + Content
              Expanded(
                child: ResizableContainer(
                  sidebarWidth:
                      state.sidebarWidth ?? widget.config.sidebarWidth,
                  onResize: (width) =>
                      context.read<WorkspaceBloc>().add(ResizeSidebar(width)),
                  sidebar: WorkspaceSidebar(config: widget.config),
                  content: const SplitEditor(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
