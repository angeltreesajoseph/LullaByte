import 'dart:convert';
import 'package:flutter/material.dart';
import '../../application/baby_profile_store.dart';

class BabyAvatar extends StatelessWidget {
  const BabyAvatar({super.key, this.size = 64, this.profile});
  final double size;
  final Map<String, dynamic>? profile;
  @override
  Widget build(BuildContext context) {
    final photo = (profile ?? BabyProfileStore.data)['photo_data'] as String?;
    if (photo != null && photo.isNotEmpty) {
      try {
        return ClipOval(
          child: Image.memory(
            base64Decode(photo),
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }
    return Icon(
      Icons.child_friendly_rounded,
      size: size * .5,
      color: Colors.pinkAccent,
    );
  }
}
