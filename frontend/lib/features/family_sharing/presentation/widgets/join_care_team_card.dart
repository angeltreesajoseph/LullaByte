import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

/// Entry for caregivers who do not have a baby profile of their own.
class JoinCareTeamCard extends StatelessWidget {
  const JoinCareTeamCard({super.key});
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: AuthPalette.lavenderMist),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(
        Icons.group_add_outlined,
        color: AuthPalette.softCoral,
      ),
      title: const Text(
        'Join a baby’s care team',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: const Text('Have an invitation? No baby profile needed.'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push('${RoutePaths.familySharing}?join=true'),
    ),
  );
}
