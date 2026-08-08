import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/authentication/presentation/widgets/auth_palette.dart';
import 'route_paths.dart';

/// Persistent shell scaffold for the four main sections (Home, Trackers,
/// Memories, Profile), built on `go_router`'s `StatefulShellRoute` so each
/// tab keeps its own navigation state while the bottom bar stays constant.
///
/// The AI assistant (Luma) is deliberately NOT one of the four
/// [StatefulShellBranch]es — it's an elevated button overlaid on the bar
/// that navigates to the standalone [RoutePaths.aiAssistant] route outside
/// the shell, so it (like every other deep/detail screen) renders without
/// the bottom bar.
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Explicit pastel background — without this, the area behind and
      // around the bottom bar's rounded corners falls through to the
      // app's theme default (near-black in dark mode) instead of
      // matching every individual screen's own warmCream background.
      backgroundColor: AuthPalette.warmCream,
      body: navigationShell,
      bottomNavigationBar: _AppBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTabSelected: _onTabSelected,
        onLumaTap: () => context.go(RoutePaths.aiAssistant),
      ),
    );
  }
}

class _AppBottomBar extends StatelessWidget {
  const _AppBottomBar({required this.currentIndex, required this.onTabSelected, required this.onLumaTap});

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onLumaTap;

  static const _barHeight = 72.0;
  static const _lumaDiameter = 68.0;
  static const _cornerRadius = 32.0;
  // How far above the bar's top edge Luma's circle extends — kept small so
  // most of the circle overlaps into the bar and it reads as attached
  // rather than floating above it.
  static const _lumaProtrusion = 22.0;

  static const _items = <_BarItemSpec>[
    _BarItemSpec(icon: Icons.home_rounded, label: 'Home'),
    _BarItemSpec(icon: Icons.checklist_rounded, label: 'Trackers'),
    _BarItemSpec(icon: Icons.photo_library_rounded, label: 'Memories'),
    _BarItemSpec(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // The device's bottom safe-area inset (gesture bar / home indicator)
    // is added as extra height + padding on the *outside* of the fixed
    // _barHeight, rather than eating into it via a nested SafeArea. That
    // nested-SafeArea approach squeezed the icon row into less than its
    // needed height on devices with a tall inset, which is what produced
    // the sharp/clipped-looking edge next to the rounded corners.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final totalHeight = _barHeight + bottomInset;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: totalHeight,
          padding: EdgeInsets.only(bottom: bottomInset),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(_cornerRadius)),
            boxShadow: [
              BoxShadow(
                color: AuthPalette.softCoral.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _BarItem(
                  spec: _items[0],
                  selected: currentIndex == 0,
                  onTap: () => onTabSelected(0),
                ),
              ),
              Expanded(
                child: _BarItem(
                  spec: _items[1],
                  selected: currentIndex == 1,
                  onTap: () => onTabSelected(1),
                ),
              ),
              const SizedBox(width: _lumaDiameter),
              Expanded(
                child: _BarItem(
                  spec: _items[2],
                  selected: currentIndex == 2,
                  onTap: () => onTabSelected(2),
                ),
              ),
              Expanded(
                child: _BarItem(
                  spec: _items[3],
                  selected: currentIndex == 3,
                  onTap: () => onTabSelected(3),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -_lumaProtrusion,
          child: _LumaButton(onTap: onLumaTap),
        ),
      ],
    );
  }
}

class _BarItemSpec {
  const _BarItemSpec({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _BarItem extends StatelessWidget {
  const _BarItem({required this.spec, required this.selected, required this.onTap});

  final _BarItemSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AuthPalette.softCoral : AuthPalette.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: spec.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: selected ? AuthPalette.softCoral.withValues(alpha: 0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(spec.icon, color: color, size: 22),
              ),
              const SizedBox(height: 3),
              Text(
                spec.label,
                style: GoogleFonts.nunito(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Elevated, lavender, center AI-assistant button. Deliberately calm —
/// only a small tap-triggered scale, no bounce/pulse/breathing loop.
class _LumaButton extends StatefulWidget {
  const _LumaButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_LumaButton> createState() => _LumaButtonState();
}

class _LumaButtonState extends State<_LumaButton> {
  static const _lavender = Color(0xFFB9A7FF);
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Luma, AI assistant',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _lavender,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: _lavender.withValues(alpha: 0.55),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 3),
              Text(
                'Luma',
                style: GoogleFonts.nunito(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: _lavender,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
