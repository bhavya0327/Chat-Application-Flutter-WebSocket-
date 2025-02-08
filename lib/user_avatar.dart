import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;
  final String initials;
  final double radius;

  UserAvatar({required this.avatarUrl, required this.initials, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      backgroundImage: avatarUrl.isNotEmpty ? AssetImage(avatarUrl) : null,
      child: avatarUrl.isEmpty
          ? Text(
              initials,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }
}
