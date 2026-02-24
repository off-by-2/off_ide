import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Data model representing a single open tab
class TabData extends Equatable {
  /// Creates a [TabData] instance
  const TabData({
    required this.id,
    required this.pageId,
    required this.title,
    this.icon,
    this.iconWidget,
    this.isDirty = false,
    this.pageArgs,
  });

  /// Creates a [TabData] instance from a JSON map
  factory TabData.fromJson(Map<String, dynamic> json) {
    return TabData(
      id: json['id'] as String,
      pageId: json['pageId'] as String,
      title: json['title'] as String,
      isDirty: json['isDirty'] as bool? ?? false,
      pageArgs: json['pageArgs'] as Map<String, dynamic>?,
    );
  }

  /// Unique identifier for this specific tab instance
  final String id;

  /// Identifier of the page type (e.g., 'editor', 'settings')
  final String pageId;

  /// Display title for the tab
  final String title;

  /// Optional icon displayed in the tab
  final IconData? icon;

  /// Optional widget displayed in the tab, overrides [icon] if provided.
  /// This allows using images, SVGs, or custom widgets as icons.
  final Widget? iconWidget;

  /// Whether the tab has unsaved changes
  final bool isDirty;

  /// Optional arguments passed to the page builder
  final Map<String, dynamic>? pageArgs;

  /// Creates a copy with modified values
  TabData copyWith({
    String? id,
    String? pageId,
    String? title,
    IconData? icon,
    Widget? iconWidget,
    bool? isDirty,
    Map<String, dynamic>? pageArgs,
  }) {
    return TabData(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      iconWidget: iconWidget ?? this.iconWidget,
      isDirty: isDirty ?? this.isDirty,
      pageArgs: pageArgs ?? this.pageArgs,
    );
  }

  /// Converts the [TabData] instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageId': pageId,
      'title': title,
      if (icon != null) 'iconCodePoint': icon!.codePoint,
      if (icon != null) 'iconFontFamily': icon!.fontFamily,
      if (icon != null) 'iconFontPackage': icon!.fontPackage,
      'isDirty': isDirty,
      'pageArgs': pageArgs,
    };
  }

  @override
  List<Object?> get props => [id, pageId, title, icon, isDirty, pageArgs];
}
