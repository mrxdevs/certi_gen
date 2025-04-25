import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

export 'dart:io' show Platform;

class CertificateGeneratorPage extends StatefulWidget {
  const CertificateGeneratorPage({Key? key}) : super(key: key);

  @override
  State<CertificateGeneratorPage> createState() =>
      _CertificateGeneratorPageState();
}

class _CertificateGeneratorPageState extends State<CertificateGeneratorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _dateController = TextEditingController();
  final _idController = TextEditingController();

  bool showCertificate = false;

  PdfPageFormat _selectedPageFormat = PdfPageFormat.a4;
  String _selectedOrientation = 'Portrait';

  final Map<String, PdfPageFormat> _pageFormats = {
    'A4': PdfPageFormat.a4,
    'Letter': PdfPageFormat.letter,
  };

  final List<String> _orientations = ['Portrait', 'Landscape'];

  PdfPageFormat get _effectivePageFormat {
    final base = _selectedPageFormat;
    // if (_selectedOrientation == 'Landscape') {
    return PdfPageFormat(base.height, base.width);
    // }
    // return base;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _dateController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<Uint8List> _buildPdf({
    required String name,
    required String course,
    required String date,
    required String id,
    required PdfPageFormat pageFormat,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) => pw.Center(
          child: pw.Container(
            width: pageFormat.width,
            height: pageFormat.height,
            // width: MediaQuery.of(context).size.width > 700 ? 350 : 300,
            padding: const pw.EdgeInsets.all(24),
            margin: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromInt(0xFFCCCCCC)),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('Service Report',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 24),
                pw.Text('This is to certify that',
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 8),
                pw.Text(name,
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(
                    'has completed all inspections and repairs of raptee T30',
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 8),
                pw.Text(course, style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 16),
                pw.Text('Date: $date', style: pw.TextStyle(fontSize: 14)),
                pw.Text('ID: $id', style: pw.TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
    return pdf.save();
  }

  Future<void> _downloadPdf({
    required String name,
    required String course,
    required String date,
    required String id,
  }) async {
    final bytes = await _buildPdf(
      name: name,
      course: course,
      date: date,
      id: id,
      pageFormat: _effectivePageFormat,
    );

    if (kIsWeb) {
      // Web download using dart:html
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'certificate.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Native platforms
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    }
  }

  Widget _certificatePreview({
    required String name,
    required String course,
    required String date,
    required String id,
    bool showBack = false,
  }) {
    return PdfPreview(
      build: (format) => _buildPdf(
        name: name.isEmpty ? 'Name' : name,
        course: course.isEmpty ? 'Course' : course,
        date: date.isEmpty ? 'Date' : date,
        id: id.isEmpty ? 'ID' : id,
        pageFormat: _effectivePageFormat,
      ),
      allowPrinting: false,
      allowSharing: false,
      canChangePageFormat: false,
      pdfFileName: 'certificate.pdf',
      initialPageFormat: _effectivePageFormat,
      actions: showBack
          ? [
              PdfPreviewAction(
                icon: const Icon(Icons.arrow_back),
                onPressed: (context, build, pageFormat) {
                  setState(() {
                    showCertificate = false;
                  });
                },
              ),
            ]
          : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    if (showCertificate) {
      return Scaffold(
        appBar: AppBar(title: const Text('Certificate Generator')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _certificatePreview(
            name: _nameController.text,
            course: _courseController.text,
            date: _dateController.text,
            id: _idController.text,
            showBack: true,
          ),
        ),
      );
    }

    final form = Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          DropdownButtonFormField<PdfPageFormat>(
            value: _selectedPageFormat,
            decoration: const InputDecoration(labelText: 'Page Size'),
            items: _pageFormats.entries
                .map((e) => DropdownMenuItem(
                      value: e.value,
                      child: Text(e.key),
                    ))
                .toList(),
            onChanged: (format) {
              if (format != null) {
                setState(() {
                  _selectedPageFormat = format;
                });
              }
            },
          ),
          DropdownButtonFormField<String>(
            value: _selectedOrientation,
            decoration: const InputDecoration(labelText: 'Orientation'),
            items: _orientations
                .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o),
                    ))
                .toList(),
            onChanged: (orientation) {
              if (orientation != null) {
                setState(() {
                  _selectedOrientation = orientation;
                });
              }
            },
          ),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter name' : null,
            onChanged: (_) => setState(() {}),
          ),
          TextFormField(
            controller: _courseController,
            decoration: const InputDecoration(labelText: 'Course'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter course' : null,
            onChanged: (_) => setState(() {}),
          ),
          TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(labelText: 'Date'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter date' : null,
            onChanged: (_) => setState(() {}),
          ),
          TextFormField(
            controller: _idController,
            decoration: const InputDecoration(labelText: 'ID'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter ID' : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                setState(() {
                  showCertificate = true;
                });
              }
            },
            child: const Text('Generate'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _downloadPdf(
                  name: _nameController.text,
                  course: _courseController.text,
                  date: _dateController.text,
                  id: _idController.text,
                );
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Report Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isWide
            ? Row(
                children: [
                  Expanded(
                    child: form,
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  Expanded(
                    flex: 2,
                    child: _certificatePreview(
                      name: _nameController.text,
                      course: _courseController.text,
                      date: _dateController.text,
                      id: _idController.text,
                    ),
                  ),
                ],
              )
            : form,
      ),
    );
  }
}
