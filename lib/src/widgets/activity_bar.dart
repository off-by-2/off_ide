import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:off_ide/src/bloc/workspace_bloc.dart';
import 'package:off_ide/src/models/models.dart';

/// VS Code-like activity bar widget
///
/// Displays the main navigation items as icon buttons in a vertical column.
/// Clicking an item switches the sidebar content and maintains tab state.
class ActivityBar extends StatelessWidget {
  /// Creates an [ActivityBar]
  const ActivityBar({required this.items, super.key});

  /// List of activity bar items to display
  ///
  /// Each item represents a different workspace context (Explorer, Search, etc.)
  final List<ActivityBarItem> items;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        return Container(
          width: 48,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              // Activity items
              ...items.map(
                (item) => _ActivityBarButton(
                  item: item,
                  isActive: state.activeActivityId == item.id,
                  onTap: () => context.read<WorkspaceBloc>().add(
                    SwitchActivity(item.id),
                  ),
                ),
              ),

              const Spacer(),

              // Settings/gear icon at bottom (optional)
              _ActivityBarButton(
                item: const ActivityBarItem(
                  id: 'settings',
                  icon: Icons.settings,
                  label: 'Settings',
                ),
                isActive: false,
                onTap: () {
                  // Handle settings tap
                  // Could open settings in a tab or show a menu
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

/// Individual button in the activity bar
///
/// Shows an icon with hover effects and active state indication.
class _ActivityBarButton extends StatelessWidget {
  const _ActivityBarButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  /// The activity bar item to display
  final ActivityBarItem item;

  /// Whether this item is currently active
  final bool isActive;

  /// Callback when the button is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: item.tooltip ?? item.label,
      preferBelow: false,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: isActive
                    ? Border(
                        left: BorderSide(color: colorScheme.primary, width: 2),
                      )
                    : null,
                color: isActive
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: item.itemContentBuilder != null
                  ? item.itemContentBuilder!(context, isActive: isActive)
                  : Icon(
                      item.icon,
                      size: 24,
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
