import 'package:flutter/material.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

class VaccineAction extends StatelessWidget {
  const VaccineAction({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.primary = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: primary
            ? const LinearGradient(
                colors: [Color(0xFFF48FB1), Color(0xFFEB72A0)],
              )
            : null,
        color: primary ? null : AuthPalette.blushPink.withValues(alpha: .45),
        border: primary
            ? null
            : Border.all(color: AuthPalette.softCoral.withValues(alpha: .35)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: onTap == null
                    ? AuthPalette.textMuted
                    : primary
                    ? Colors.white
                    : AuthPalette.textDark,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: onTap == null
                        ? AuthPalette.textMuted
                        : primary
                        ? Colors.white
                        : AuthPalette.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class VaccinationHero extends StatelessWidget {
  const VaccinationHero({
    super.key,
    required this.name,
    required this.done,
    required this.total,
    this.next,
  });
  final String name;
  final int done, total;
  final String? next;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFCE3EE), Color(0xFFE8DBF7)],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: .8)),
      boxShadow: [
        BoxShadow(
          color: AuthPalette.lavenderMist.withValues(alpha: .25),
          blurRadius: 25,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.vaccines_outlined,
                color: Color(0xFFE379A0),
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vaccinations',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AuthPalette.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$name’s little steps to protection',
                    style: const TextStyle(
                      color: AuthPalette.textDark,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .8),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                total == 0
                    ? 'No vaccinations added yet'
                    : '$done of $total listed doses received',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AuthPalette.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: total == 0 ? 0 : done / total,
                  color: const Color(0xFFE782A9),
                  backgroundColor: const Color(0xFFECE3F4),
                ),
              ),
              if (next != null) ...[
                const SizedBox(height: 14),
                const Text(
                  'NEXT SUGGESTED / PLANNED',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    color: AuthPalette.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  next!,
                  style: const TextStyle(
                    color: AuthPalette.textDark,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class VaccinationDoseCard extends StatelessWidget {
  const VaccinationDoseCard({
    super.key,
    required this.entry,
    required this.date,
    required this.status,
    required this.onToggle,
    required this.onEdit,
    required this.onReminder,
    required this.menu,
    required this.reminderLabel,
    required this.reminderEnabled,
    this.reminderInfo,
  });
  final Map<String, dynamic> entry;
  final String date, status, reminderLabel;
  final String? reminderInfo;
  final VoidCallback? onToggle, onEdit, onReminder;
  final Widget menu;
  final bool reminderEnabled;
  @override
  Widget build(BuildContext context) {
    final done = entry['done'] == true;
    final excluded = entry['excluded'] == true;
    final accent = done ? const Color(0xFF47876B) : const Color(0xFFB76C8D);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .97),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: done ? AuthPalette.mint : const Color(0xFFEBDDF0),
        ),
        boxShadow: [
          BoxShadow(
            color: AuthPalette.lavenderMist.withValues(alpha: .14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFFE6F5ED)
                      : const Color(0xFFFCEAF1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  done ? Icons.verified_outlined : Icons.vaccines_outlined,
                  color: accent,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry['age'] as String? ?? 'Custom vaccination',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AuthPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              menu,
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                done
                    ? Icons.check_circle_outline
                    : Icons.calendar_today_outlined,
                size: 16,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AuthPalette.textDark,
                  ),
                ),
              ),
              if (reminderEnabled)
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFFB76C8D),
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(fontSize: 12, height: 1.4, color: accent),
          ),
          if (reminderInfo != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                reminderInfo!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AuthPalette.textMuted,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Checkbox(
                value: done,
                onChanged: onToggle == null ? null : (_) => onToggle!(),
                activeColor: const Color(0xFFE782A9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                side: const BorderSide(color: Color(0xFFBF91AB), width: 1.5),
              ),
              Expanded(
                child: Text(
                  done
                      ? 'Received'
                      : excluded
                      ? 'Not included'
                      : 'Mark received today',
                  style: const TextStyle(
                    color: AuthPalette.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: VaccineAction(
                  label: 'Edit details',
                  icon: Icons.edit_outlined,
                  onTap: onEdit,
                ),
              ),
              if (!done && !excluded) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: VaccineAction(
                    label: reminderLabel,
                    icon: Icons.notifications_outlined,
                    onTap: onReminder,
                  ),
                ),
              ],
            ],
          ),
          if ((entry['notes'] as String? ?? '').isNotEmpty ||
              (entry['doctor'] as String? ?? '').isNotEmpty)
            Material(
              type: MaterialType.transparency,
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'Notes & clinic',
                  style: TextStyle(fontSize: 12, color: AuthPalette.textMuted),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      [
                        if ((entry['doctor'] as String? ?? '').isNotEmpty)
                          'Doctor / clinic: ${entry['doctor']}',
                        if ((entry['notes'] as String? ?? '').isNotEmpty)
                          entry['notes'] as String,
                      ].join('\n'),
                      style: const TextStyle(
                        color: AuthPalette.textDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
