import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

class _MemoryPhoto {
  _MemoryPhoto({
    required this.title,
    required this.dateLabel,
    required this.accentColor,
    this.file,
    this.isFavorite = false,
    this.isThisMonth = false,
  });

  final String title;
  final String dateLabel;
  final Color accentColor;
  final File? file;
  bool isFavorite;
  bool isThisMonth;
}

/// Gallery screen (SRS Section 10.12).
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Login, Register, Baby Registration, Dashboard, Cry
/// Analyzer, Baby Profile, Vaccination, and Milestones — the gradient
/// backdrop, palette, and rounded 28px card language come directly from
/// `features/authentication/presentation/widgets/` (read-only reuse; those
/// files are not modified).
///
/// Photo capture/selection is real (via `image_picker`), but every picked
/// photo lives only in local widget state for this session — there is no
/// backend, Firebase, or cloud storage integration. Pre-seeded memories use
/// realistic sample data with pastel placeholders instead of bundled
/// images. Add Video is UI-only and surfaces a friendly "coming soon" toast.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;

  static const _tabletBreakpoint = 700.0;

  static const _accentCycle = <Color>[
    AuthPalette.blushPink,
    AuthPalette.powderBlue,
    AuthPalette.mint,
    AuthPalette.lavenderMist,
    AuthPalette.softCoral,
  ];

  static const _filters = <String>['All', 'Favorites', 'This Week', 'This Month', 'Videos'];

  int _selectedFilter = 0;

  late final List<_MemoryPhoto> _photos = [
    _MemoryPhoto(
      title: "Lily's first laugh",
      dateLabel: '1 Aug 2026',
      accentColor: AuthPalette.blushPink,
      isFavorite: true,
      isThisMonth: true,
    ),
    _MemoryPhoto(
      title: 'Nap time snuggles',
      dateLabel: '30 Jul 2026',
      accentColor: AuthPalette.softCoral,
      isThisMonth: true,
    ),
    _MemoryPhoto(
      title: 'Bath time giggles',
      dateLabel: '20 Jul 2026',
      accentColor: AuthPalette.lavenderMist,
    ),
    _MemoryPhoto(
      title: 'Tummy time',
      dateLabel: '15 Jun 2026',
      accentColor: AuthPalette.mint,
    ),
    _MemoryPhoto(
      title: 'Meeting Grandma',
      dateLabel: '2 May 2026',
      accentColor: AuthPalette.powderBlue,
      isFavorite: true,
    ),
    _MemoryPhoto(
      title: 'First smile',
      dateLabel: '18 Apr 2026',
      accentColor: AuthPalette.blushPink,
      isFavorite: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );
    _heroFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );
    _heroScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.1, 0.8, curve: Curves.easeOutBack)),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AuthPalette.textDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text(
            message,
            style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
  }

  Future<void> _handleAddPhotoTap() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _PhotoSourceSheet(),
    );
    if (source == null || !mounted) return;
    await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _photos.insert(
          0,
          _MemoryPhoto(
            title: 'New memory',
            dateLabel: 'Today',
            accentColor: _accentCycle[_photos.length % _accentCycle.length],
            file: File(picked.path),
            isThisMonth: true,
          ),
        );
      });
      _showToast('Photo added to the gallery 🌙');
    } catch (_) {
      if (!mounted) return;
      _showToast("Couldn't access the camera or photo library.");
    }
  }

  void _toggleFavorite(_MemoryPhoto photo) {
    setState(() => photo.isFavorite = !photo.isFavorite);
  }

  void _deletePhoto(_MemoryPhoto photo) {
    setState(() => _photos.remove(photo));
  }

  void _openPreview(_MemoryPhoto photo) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (context) => _PhotoPreviewDialog(
        photo: photo,
        onToggleFavorite: () => _toggleFavorite(photo),
        onDelete: () {
          _deletePhoto(photo);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = MediaQuery.sizeOf(context).width >= _tabletBreakpoint ? 3 : 2;
    final totalCount = _photos.length;
    final favoriteCount = _photos.where((p) => p.isFavorite).length;
    final thisMonthCount = _photos.where((p) => p.isThisMonth).length;

    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _GalleryFloatingDecor()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              AuthBackButton(onPressed: () => context.go(RoutePaths.dashboard)),
                              const Spacer(),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Memories',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: AuthPalette.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Lily's precious moments",
                                  style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (_photos.isNotEmpty)
                            FadeTransition(
                              opacity: _heroFade,
                              child: ScaleTransition(
                                scale: _heroScale,
                                child: _MemoryHeroCard(
                                  photo: _photos.first,
                                  onToggleFavorite: () => _toggleFavorite(_photos.first),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          _GalleryActionsRow(
                            onAddPhoto: _handleAddPhotoTap,
                            onAddVideo: () => _showToast('Video memories are coming soon 🌙'),
                            onCamera: () => _pickImage(ImageSource.camera),
                            onGallery: () => _pickImage(ImageSource.gallery),
                          ),
                          const SizedBox(height: 20),
                          _FilterChipsRow(
                            filters: _filters,
                            selectedIndex: _selectedFilter,
                            onSelected: (index) => setState(() => _selectedFilter = index),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Your Memories'),
                          const SizedBox(height: 10),
                          if (_photos.isEmpty)
                            _EmptyGalleryState(onAddFirstPhoto: _handleAddPhotoTap)
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _photos.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) {
                                final photo = _photos[index];
                                return _GalleryThumbnail(
                                  photo: photo,
                                  onTap: () => _openPreview(photo),
                                );
                              },
                            ),
                          const SizedBox(height: 22),
                          _MemoryStatsCard(
                            totalCount: totalCount,
                            favoriteCount: favoriteCount,
                            thisMonthCount: thisMonthCount,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gallery-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used by
/// Dashboard, Cry Analyzer, Baby Profile, Vaccination, and Milestones, so
/// no shared or sibling screen file needs to change.
class _GalleryFloatingDecor extends StatefulWidget {
  const _GalleryFloatingDecor();

  @override
  State<_GalleryFloatingDecor> createState() => _GalleryFloatingDecorState();
}

class _GalleryFloatingDecorState extends State<_GalleryFloatingDecor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <_DecorSpec>[
    _DecorSpec(icon: Icons.star_rounded, top: 0.03, left: 0.09, size: 12, color: AuthPalette.softCoral, phase: 0.0),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.05, left: 0.85, size: 20, color: AuthPalette.powderBlue, phase: 0.4),
    _DecorSpec(icon: Icons.star_rounded, top: 0.20, left: 0.91, size: 10, color: AuthPalette.mint, phase: 0.25),
    _DecorSpec(icon: Icons.star_rounded, top: 0.29, left: 0.05, size: 11, color: AuthPalette.lavenderMist, phase: 0.6),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.54, left: 0.07, size: 16, color: AuthPalette.blushPink, phase: 0.15),
    _DecorSpec(icon: Icons.star_rounded, top: 0.71, left: 0.91, size: 12, color: AuthPalette.softCoral, phase: 0.5),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final spec in _specs)
                Positioned(
                  top: constraints.maxHeight * spec.top,
                  left: constraints.maxWidth * spec.left,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final t = (math.sin((_controller.value + spec.phase) * math.pi * 2) + 1) / 2;
                      return Opacity(opacity: 0.07 + (t * 0.09), child: child);
                    },
                    child: Icon(spec.icon, size: spec.size, color: spec.color),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DecorSpec {
  const _DecorSpec({
    required this.icon,
    required this.top,
    required this.left,
    required this.size,
    required this.color,
    required this.phase,
  });

  final IconData icon;
  final double top;
  final double left;
  final double size;
  final Color color;
  final double phase;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.quicksand(fontSize: 17, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
      ),
    );
  }
}

class _MemoryHeroCard extends StatelessWidget {
  const _MemoryHeroCard({required this.photo, required this.onToggleFavorite});

  final _MemoryPhoto photo;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AuthPalette.softCoral.withValues(alpha: 0.16),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: AuthPalette.lavenderMist.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 11,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _PhotoSurface(photo: photo, iconSize: 48),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _FavoriteBadge(isFavorite: photo.isFavorite, onTap: onToggleFavorite),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.title,
                        style: GoogleFonts.quicksand(fontSize: 17, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        photo.dateLabel,
                        style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted),
                      ),
                    ],
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

/// Renders a picked photo's real file, or a soft pastel placeholder for
/// pre-seeded sample memories (no bundled sample images ship with the app).
class _PhotoSurface extends StatelessWidget {
  const _PhotoSurface({required this.photo, required this.iconSize});

  final _MemoryPhoto photo;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final file = photo.file;
    if (file != null) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            photo.accentColor.withValues(alpha: 0.55),
            photo.accentColor.withValues(alpha: 0.25),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.child_friendly_rounded, size: iconSize, color: Colors.white.withValues(alpha: 0.9)),
      ),
    );
  }
}

class _FavoriteBadge extends StatelessWidget {
  const _FavoriteBadge({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: Material(
        color: Colors.white.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18,
              color: AuthPalette.softCoral,
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryActionsRow extends StatelessWidget {
  const _GalleryActionsRow({
    required this.onAddPhoto,
    required this.onAddVideo,
    required this.onCamera,
    required this.onGallery,
  });

  final VoidCallback onAddPhoto;
  final VoidCallback onAddVideo;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _GalleryActionChip(icon: Icons.add_photo_alternate_rounded, label: 'Add Photo', color: AuthPalette.softCoral, onTap: onAddPhoto),
          _GalleryActionChip(icon: Icons.videocam_outlined, label: 'Add Video', color: AuthPalette.lavenderMist, onTap: onAddVideo),
          _GalleryActionChip(icon: Icons.photo_camera_outlined, label: 'Camera', color: AuthPalette.powderBlue, onTap: onCamera),
          _GalleryActionChip(icon: Icons.photo_library_outlined, label: 'Gallery', color: AuthPalette.mint, onTap: onGallery),
        ],
      ),
    );
  }
}

class _GalleryActionChip extends StatelessWidget {
  const _GalleryActionChip({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: color.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: AuthPalette.textDark),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({required this.filters, required this.selectedIndex, required this.onSelected});

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return _FilterChip(
            label: filters[index],
            selected: selected,
            onTap: () => onSelected(index),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? AuthPalette.softCoral : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? Colors.transparent : AuthPalette.lavenderMist.withValues(alpha: 0.6),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AuthPalette.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryThumbnail extends StatelessWidget {
  const _GalleryThumbnail({required this.photo, required this.onTap});

  final _MemoryPhoto photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${photo.title}, ${photo.dateLabel}',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AuthPalette.softCoral.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AuthPalette.lavenderMist.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _PhotoSurface(photo: photo, iconSize: 30),
                  if (photo.isFavorite)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.favorite_rounded, size: 16, color: Colors.white),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
                        ),
                      ),
                      child: Text(
                        photo.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen preview dialog with favorite toggle and delete action.
class _PhotoPreviewDialog extends StatefulWidget {
  const _PhotoPreviewDialog({
    required this.photo,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final _MemoryPhoto photo;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  @override
  State<_PhotoPreviewDialog> createState() => _PhotoPreviewDialogState();
}

class _PhotoPreviewDialogState extends State<_PhotoPreviewDialog> {
  void _handleToggleFavorite() {
    widget.onToggleFavorite();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _DarkCircleButton(
                    icon: Icons.close_rounded,
                    label: 'Close',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  _DarkCircleButton(
                    icon: photo.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    label: photo.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    iconColor: AuthPalette.softCoral,
                    onTap: _handleToggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: _PhotoSurface(photo: photo, iconSize: 72),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                photo.title,
                style: GoogleFonts.quicksand(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                photo.dateLabel,
                style: GoogleFonts.nunito(fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 18),
              AuthOutlineButton(
                label: 'Delete Memory',
                icon: Icons.delete_outline_rounded,
                accent: AuthPalette.error,
                isLoading: false,
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkCircleButton extends StatelessWidget {
  const _DarkCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}

class _MemoryStatsCard extends StatelessWidget {
  const _MemoryStatsCard({
    required this.totalCount,
    required this.favoriteCount,
    required this.thisMonthCount,
  });

  final int totalCount;
  final int favoriteCount;
  final int thisMonthCount;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Row(
        children: [
          Expanded(child: _StatBlock(icon: Icons.photo_library_rounded, label: 'Total Photos', value: '$totalCount')),
          _statDivider(),
          Expanded(child: _StatBlock(icon: Icons.favorite_rounded, label: 'Favorites', value: '$favoriteCount')),
          _statDivider(),
          Expanded(child: _StatBlock(icon: Icons.calendar_month_rounded, label: 'This Month', value: '$thisMonthCount')),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AuthPalette.lavenderMist.withValues(alpha: 0.5),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AuthPalette.softCoral),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 10.5, color: AuthPalette.textMuted),
        ),
      ],
    );
  }
}

class _EmptyGalleryState extends StatelessWidget {
  const _EmptyGalleryState({required this.onAddFirstPhoto});

  final VoidCallback onAddFirstPhoto;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        children: [
          SizedBox(
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AuthPalette.blushPink.withValues(alpha: 0.4),
                  ),
                ),
                const Icon(Icons.photo_album_rounded, color: AuthPalette.softCoral, size: 38),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start your baby memory book',
            style: GoogleFonts.quicksand(fontSize: 16.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            'Every smile, giggle, and tiny milestone deserves a page of its own.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            label: 'Add First Photo',
            isLoading: false,
            onPressed: onAddFirstPhoto,
          ),
        ],
      ),
    );
  }
}

/// Pastel bottom sheet offering Camera / Gallery as the photo source.
class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        decoration: BoxDecoration(
          color: AuthPalette.warmCream,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AuthPalette.softCoral.withValues(alpha: 0.18),
              blurRadius: 36,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AuthPalette.lavenderMist.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              'Add a photo',
              style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
            ),
            const SizedBox(height: 16),
            _SourceOptionTile(
              icon: Icons.photo_camera_outlined,
              label: 'Take a photo',
              color: AuthPalette.powderBlue,
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(height: 10),
            _SourceOptionTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from gallery',
              color: AuthPalette.mint,
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOptionTile extends StatelessWidget {
  const _SourceOptionTile({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AuthPalette.textDark, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
