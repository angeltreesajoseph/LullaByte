import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import '../../application/care_pdf.dart';
import '../../domain/care_overview.dart';

class CarePdfPreview extends StatefulWidget {
  const CarePdfPreview({super.key, required this.report});
  final CareOverview report;
  @override
  State<CarePdfPreview> createState() => _CarePdfPreviewState();
}

class _CarePdfPreviewState extends State<CarePdfPreview> {
  late Future<Uint8List> _bytes;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _bytes = CarePdf.build(widget.report);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final uri = await FilePicker.saveFile(
        fileName: CarePdf.filename(widget.report),
        bytes: await _bytes,
        mimeType: 'application/pdf',
        dialogTitle: 'Save baby care summary',
      );
      if (uri != null && mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF saved to your chosen location.')),
        );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save PDF. Please retry.')),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Care summary PDF'),
      actions: [
        IconButton(
          tooltip: 'Save PDF',
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_alt_rounded),
        ),
      ],
    ),
    body: FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not create PDF. No file was exported.'),
                TextButton(
                  onPressed: () =>
                      setState(() => _bytes = CarePdf.build(widget.report)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        return PdfPreview(
          build: (_) => snapshot.data!,
          pdfFileName: CarePdf.filename(widget.report),
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          onError: (_, __) => const Center(
            child: Text(
              'Preview unavailable. You can still try Save or Share.',
            ),
          ),
          onPrintError: (_, __) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open printing. Please retry.'),
            ),
          ),
        );
      },
    ),
  );
}
