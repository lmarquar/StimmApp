import 'package:flutter/material.dart';

class PointingListTile extends StatelessWidget {
  const PointingListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    this.trailing,
    this.dense,
    this.contentPadding,
    this.enabled = true,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool? dense;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: contentPadding,
      dense: dense,
      enabled: enabled,
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios_outlined,
            color: Theme.of(context).hintColor,
            size: 16.0,
          ),
      onTap: onTap,
    );
  }
}
