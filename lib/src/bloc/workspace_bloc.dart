import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:off_ide/src/models/models.dart';
import 'package:uuid/uuid.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

/// Bloc to manage VS Code-like workspace state
///
/// Handles tab management across multiple split panes, activity bar navigation,
/// sidebar state, and split view configuration. Follows BLoC pattern for
/// reactive state management.
class WorkspaceBloc extends HydratedBloc<WorkspaceEvent, WorkspaceState> {
  /// Creates a [WorkspaceBloc] with workspace configuration
  ///
  /// [maxTabs] - Maximum number of tabs that can be open simultaneously
  /// [maxVerticalSplits] - Maximum number of vertical editor splits allowed
  WorkspaceBloc({required this.maxTabs, this.maxVerticalSplits = 2})
    : super(WorkspaceState()) {
    on<OpenTab>(_onOpenTab);
    on<CloseTab>(_onCloseTab);
    on<SwitchTab>(_onSwitchTab);
    on<MarkTabDirty>(_onMarkTabDirty);
    on<SwitchActivity>(_onSwitchActivity);
    on<ToggleSidebarGroup>(_onToggleSidebarGroup);
    on<ResizeSidebar>(_onResizeSidebar);
    on<ReorderTab>(_onReorderTab);
    on<MoveTabToPane>(_onMoveTabToPane);
    on<CloseOthers>(_onCloseOthers);
    on<CloseAll>(_onCloseAll);
    on<SplitView>(_onSplitEditor);
    on<CloseSplit>(_onCloseSplit);
    on<ResizeSplit>(_onResizeSplit);
  }

  @override
  WorkspaceState? fromJson(Map<String, dynamic> json) {
    try {
      return WorkspaceState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(WorkspaceState state) {
    try {
      return state.toJson();
    } catch (_) {
      return null;
    }
  }

  /// The maximum number of tabs allowed to be open simultaneously
  ///
  /// Prevents memory issues by limiting the number of active page widgets.
  final int maxTabs;

  /// Maximum number of vertical splits allowed
  ///
  /// Limits UI complexity and maintains usability.
  final int maxVerticalSplits;

  /// UUID generator for creating unique tab IDs
  final _uuid = const Uuid();

  /// Handles opening a new tab or focusing an existing one
  ///
  /// Checks for existing tabs with the same pageId to prevent duplicates.
  /// Respects the maximum tab limit and split pane configuration.
  Future<void> _onOpenTab(OpenTab event, Emitter<WorkspaceState> emit) async {
    // Check if tab with same pageId already exists
    final existingTab = state.openTabs.cast<TabData?>().firstWhere(
      (tab) => tab?.pageId == event.pageId,
      orElse: () => null,
    );

    if (existingTab != null) {
      // Focus existing tab
      final paneIndex = state.getPaneForTab(existingTab.id) ?? 0;
      emit(
        state.copyWith(activeTabId: existingTab.id, activePaneIndex: paneIndex),
      );
      return;
    }

    // Check tab limit
    if (state.openTabs.length >= maxTabs) {
      emit(
        state.copyWith(error: 'Maximum $maxTabs tabs open. Close a tab first.'),
      );
      return;
    }

    // Create new tab
    final newTab = TabData(
      id: _uuid.v4(),
      pageId: event.pageId,
      title: event.title,
      icon: event.icon,
      pageArgs: event.pageArgs,
    );

    // Add to specified pane (or active pane)
    final targetPane = event.paneIndex.clamp(
      0,
      state.splitConfiguration.splitCount - 1,
    );
    final updatedTabsByPane = Map<int, List<String>>.from(state.tabsByPane);
    updatedTabsByPane[targetPane] = [
      ...(updatedTabsByPane[targetPane] ?? []),
      newTab.id,
    ];

    emit(
      state.copyWith(
        openTabs: [...state.openTabs, newTab],
        activeTabId: newTab.id,
        activePaneIndex: targetPane,
        tabsByPane: updatedTabsByPane,
      ),
    );
  }

  /// Handles closing a specific tab
  ///
  /// Removes the tab from all panes and updates the active tab if necessary.
  Future<void> _onCloseTab(CloseTab event, Emitter<WorkspaceState> emit) async {
    final updatedTabs = state.openTabs
        .where((tab) => tab.id != event.tabId)
        .toList();

    // Remove from all panes
    final updatedTabsByPane = <int, List<String>>{};
    for (final entry in state.tabsByPane.entries) {
      updatedTabsByPane[entry.key] = entry.value
          .where((id) => id != event.tabId)
          .toList();
    }

    // Update active tab if the closed tab was active
    var newActiveId = state.activeTabId;
    var newActivePaneIndex = state.activePaneIndex;

    if (event.tabId == state.activeTabId) {
      // Find the next tab to activate
      final currentPaneTabs = updatedTabsByPane[state.activePaneIndex] ?? [];

      if (currentPaneTabs.isNotEmpty) {
        // Activate the last tab in the current pane
        newActiveId = currentPaneTabs.last;
      } else {
        // Find any tab in any pane
        for (final entry in updatedTabsByPane.entries) {
          if (entry.value.isNotEmpty) {
            newActiveId = entry.value.last;
            newActivePaneIndex = entry.key;
            break;
          }
        }
        if (newActiveId == event.tabId) {
          newActiveId = null;
        }
      }
    }

    emit(
      state.copyWith(
        openTabs: updatedTabs,
        activeTabId: newActiveId,
        activePaneIndex: newActivePaneIndex,
        tabsByPane: updatedTabsByPane,
      ),
    );
  }

  /// Handles switching focus to a specific tab
  ///
  /// Updates the active tab and potentially the active pane.
  Future<void> _onSwitchTab(
    SwitchTab event,
    Emitter<WorkspaceState> emit,
  ) async {
    // Find which pane contains this tab
    final paneIndex = state.getPaneForTab(event.tabId) ?? state.activePaneIndex;
    final targetPaneIndex = event.paneIndex ?? paneIndex;

    emit(
      state.copyWith(
        activeTabId: event.tabId,
        activePaneIndex: targetPaneIndex,
      ),
    );
  }

  /// Handles marking a tab as dirty or clean
  ///
  /// Updates the visual indicator for unsaved changes.
  Future<void> _onMarkTabDirty(
    MarkTabDirty event,
    Emitter<WorkspaceState> emit,
  ) async {
    final updatedTabs = state.openTabs.map((tab) {
      if (tab.id == event.tabId) {
        return tab.copyWith(isDirty: event.isDirty);
      }
      return tab;
    }).toList();

    emit(state.copyWith(openTabs: updatedTabs));
  }

  /// Handles switching the active activity bar item
  ///
  /// Changes the sidebar content without affecting open tabs.
  Future<void> _onSwitchActivity(
    SwitchActivity event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(state.copyWith(activeActivityId: event.activityId));
  }

  /// Handles toggling the expansion state of a sidebar group
  ///
  /// Supports nested groups and sub-groups.
  Future<void> _onToggleSidebarGroup(
    ToggleSidebarGroup event,
    Emitter<WorkspaceState> emit,
  ) async {
    final updatedGroups = Map<String, bool>.from(state.expandedGroups);
    updatedGroups[event.groupId] = !(updatedGroups[event.groupId] ?? false);

    emit(state.copyWith(expandedGroups: updatedGroups));
  }

  /// Handles splitting the editor vertically
  ///
  /// Creates a new pane for side-by-side tab viewing.
  Future<void> _onSplitEditor(
    SplitView event,
    Emitter<WorkspaceState> emit,
  ) async {
    final currentSplitCount = state.splitConfiguration.splitCount;

    // Check split limit
    if (currentSplitCount >= maxVerticalSplits) {
      emit(state.copyWith(error: 'Maximum $maxVerticalSplits splits allowed.'));
      return;
    }

    final newSplitCount = currentSplitCount + 1;
    final newRatios = List.generate(
      newSplitCount,
      (index) => 1.0 / newSplitCount,
    );

    final newSplitConfig = state.splitConfiguration.copyWith(
      splitCount: newSplitCount,
      splitRatios: newRatios,
    );

    // Initialize new pane in tabsByPane
    final updatedTabsByPane = Map<int, List<String>>.from(state.tabsByPane);
    updatedTabsByPane[newSplitCount - 1] = [];

    emit(
      state.copyWith(
        splitConfiguration: newSplitConfig,
        tabsByPane: updatedTabsByPane,
      ),
    );
  }

  /// Handles closing a split pane
  ///
  /// Removes the pane and redistributes its tabs to remaining panes.
  Future<void> _onCloseSplit(
    CloseSplit event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (state.splitConfiguration.splitCount <= 1) {
      return; // Can't close the last pane
    }

    // Move tabs from closing pane to the first pane
    final closingPaneTabs = state.tabsByPane[event.paneIndex] ?? [];
    final updatedTabsByPane = <int, List<String>>{};

    // Redistribute panes
    var newIndex = 0;
    for (final entry in state.tabsByPane.entries) {
      if (entry.key != event.paneIndex) {
        if (newIndex == 0) {
          // Add closing pane's tabs to first remaining pane
          updatedTabsByPane[newIndex] = [...(entry.value), ...closingPaneTabs];
        } else {
          updatedTabsByPane[newIndex] = entry.value;
        }
        newIndex++;
      }
    }

    final newSplitCount = state.splitConfiguration.splitCount - 1;
    final newRatios = List.generate(
      newSplitCount,
      (index) => 1.0 / newSplitCount,
    );

    final newSplitConfig = state.splitConfiguration.copyWith(
      splitCount: newSplitCount,
      splitRatios: newRatios,
      activePane: state.activePaneIndex >= newSplitCount
          ? 0
          : state.activePaneIndex,
    );

    emit(
      state.copyWith(
        splitConfiguration: newSplitConfig,
        tabsByPane: updatedTabsByPane,
        activePaneIndex: state.activePaneIndex >= newSplitCount
            ? 0
            : state.activePaneIndex,
      ),
    );
  }

  /// Handles resizing split panes
  ///
  /// Updates the width ratios for each pane.
  Future<void> _onResizeSplit(
    ResizeSplit event,
    Emitter<WorkspaceState> emit,
  ) async {
    if (event.splitRatios.length != state.splitConfiguration.splitCount) {
      return; // Invalid ratio count
    }

    // Ensure ratios sum to approximately 1.0
    final sum = event.splitRatios.reduce((a, b) => a + b);
    if ((sum - 1.0).abs() > 0.01) {
      return; // Ratios don't sum to 1.0
    }

    final newSplitConfig = state.splitConfiguration.copyWith(
      splitRatios: event.splitRatios,
    );

    emit(state.copyWith(splitConfiguration: newSplitConfig));
  }

  /// Handles resizing the sidebar
  Future<void> _onResizeSidebar(
    ResizeSidebar event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(state.copyWith(sidebarWidth: event.width));
  }

  /// Handles reordering a tab within a pane
  Future<void> _onReorderTab(
    ReorderTab event,
    Emitter<WorkspaceState> emit,
  ) async {
    final currentTabs = List<String>.from(
      state.tabsByPane[event.paneIndex] ?? [],
    );
    if (event.oldIndex < 0 ||
        event.oldIndex >= currentTabs.length ||
        event.newIndex < 0 ||
        event.newIndex > currentTabs.length) {
      return;
    }

    final tabId = currentTabs.removeAt(event.oldIndex);
    final insertIndex = event.newIndex > event.oldIndex
        ? event.newIndex - 1
        : event.newIndex;
    currentTabs.insert(insertIndex, tabId);

    final newTabsByPane = Map<int, List<String>>.from(state.tabsByPane);
    newTabsByPane[event.paneIndex] = currentTabs;

    emit(state.copyWith(tabsByPane: newTabsByPane));
  }

  /// Handles moving a tab to a different pane
  Future<void> _onMoveTabToPane(
    MoveTabToPane event,
    Emitter<WorkspaceState> emit,
  ) async {
    int? sourcePaneIndex;
    for (final entry in state.tabsByPane.entries) {
      if (entry.value.contains(event.tabId)) {
        sourcePaneIndex = entry.key;
        break;
      }
    }

    if (sourcePaneIndex == null || sourcePaneIndex == event.targetPaneIndex) {
      return;
    }

    final newTabsByPane = Map<int, List<String>>.from(state.tabsByPane);

    // Remove from source
    final sourceTabs = List<String>.from(newTabsByPane[sourcePaneIndex]!);
    sourceTabs.remove(event.tabId);
    newTabsByPane[sourcePaneIndex] = sourceTabs;

    // Add to target
    final targetTabs = List<String>.from(
      newTabsByPane[event.targetPaneIndex] ?? [],
    );
    targetTabs.add(event.tabId);
    newTabsByPane[event.targetPaneIndex] = targetTabs;

    emit(
      state.copyWith(
        tabsByPane: newTabsByPane,
        activePaneIndex: event.targetPaneIndex,
        activeTabId: event.tabId,
      ),
    );
  }

  /// Handles closing all other tabs in a pane
  Future<void> _onCloseOthers(
    CloseOthers event,
    Emitter<WorkspaceState> emit,
  ) async {
    final paneTabs = state.tabsByPane[event.paneIndex] ?? [];
    if (!paneTabs.contains(event.tabId)) return;

    final tabsToRemove = paneTabs.where((id) => id != event.tabId).toList();
    if (tabsToRemove.isEmpty) return;

    final newOpenTabs = List<TabData>.from(state.openTabs)
      ..removeWhere((tab) => tabsToRemove.contains(tab.id));

    final newTabsByPane = Map<int, List<String>>.from(state.tabsByPane);
    newTabsByPane[event.paneIndex] = [event.tabId];

    // If active tab was one of the removed ones, switch to the kept tab
    String? newActiveTabId = state.activeTabId;
    if (tabsToRemove.contains(state.activeTabId)) {
      newActiveTabId = event.tabId;
    }

    emit(
      state.copyWith(
        openTabs: newOpenTabs,
        tabsByPane: newTabsByPane,
        activeTabId: newActiveTabId,
      ),
    );
  }

  /// Handles closing all tabs in a pane
  Future<void> _onCloseAll(
    CloseAll event,
    Emitter<WorkspaceState> emit,
  ) async {
    final paneTabs = state.tabsByPane[event.paneIndex] ?? [];
    if (paneTabs.isEmpty) return;

    final newOpenTabs = List<TabData>.from(state.openTabs)
      ..removeWhere((tab) => paneTabs.contains(tab.id));

    final newTabsByPane = Map<int, List<String>>.from(state.tabsByPane);
    newTabsByPane[event.paneIndex] = [];

    // Validating active tab
    String? newActiveTabId = state.activeTabId;
    if (paneTabs.contains(state.activeTabId)) {
      newActiveTabId =
          null; // No active tab if we closed the pane containing it
      // Logic could be improved to find another tab in another pane, but null is safe
    }

    emit(
      state.copyWith(
        openTabs: newOpenTabs,
        tabsByPane: newTabsByPane,
        activeTabId: newActiveTabId,
      ),
    );
  }
}
