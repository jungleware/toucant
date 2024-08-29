import 'package:flutter/material.dart';

class Setting {
  final String name;

  final String group;

  final dynamic value;

  final Widget icon;

  final Function onTap;

  Setting({
    required this.name,
    required this.group,
    required this.value,
    required this.icon,
    required this.onTap,
  });
}
