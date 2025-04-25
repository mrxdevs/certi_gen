import 'dart:typed_data';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart' as pd;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  pd.PdfPageFormat _selectedPageFormat = pd.PdfPageFormat.a4;
  String _selectedOrientation = 'Portrait';

  final Map<String, pd.PdfPageFormat> _pageFormats = {
    'A4': pd.PdfPageFormat.a4,
    'Letter': pd.PdfPageFormat.letter,
  };

  final List<String> _orientations = ['Portrait', 'Landscape'];

  pd.PdfPageFormat get _effectivePageFormat {
    final base = _selectedPageFormat;
    // if (_selectedOrientation == 'Landscape') {
    return pd.PdfPageFormat(base.height, base.width);
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
    required pd.PdfPageFormat pageFormat,
  }) async {
    final pdf = pw.Document();

    final templateImageData =
        await rootBundle.load('assets/template/certi_temp4.png');
    final templateImageBytes = templateImageData.buffer.asUint8List();
    final templateImageProvider = pw.MemoryImage(templateImageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(templateImageProvider, fit: pw.BoxFit.fitWidth),
              ),
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(32),
                  margin: const pw.EdgeInsets.all(32),
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 60),
                      pw.Text(
                        'Bike Service Report',
                        style: pw.TextStyle(
                          fontSize: 40,
                          fontWeight: pw.FontWeight.bold,
                          color: pd.PdfColor.fromInt(0xFF2E3A59),
                        ),
                      ),
                      pw.SizedBox(height: 32),
                      pw.Text(
                        'This certificate is proudly presented to',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontStyle: pw.FontStyle.italic,
                          color: pd.PdfColor.fromInt(0xFF555555),
                        ),
                      ),
                      pw.SizedBox(height: 18),
                      pw.Text(
                        name,
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: pd.PdfColor.fromInt(0xFF1A237E),
                        ),
                      ),
                      pw.SizedBox(height: 68),
                      pw.Text(
                        'for successfully completing the service and inspection of',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: pd.PdfColor.fromInt(0xFF555555),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        course,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: pd.PdfColor.fromInt(0xFF1565C0),
                        ),
                      ),
                      // pw.SizedBox(height: 28),
                      pw.Divider(
                          height: 0.5,
                          thickness: 0.3,
                          color: pd.PdfColor.fromInt(0xFF757575)),
                      pw.SizedBox(height: 18),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Date:',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                date,
                                style: pw.TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Certificate ID:',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                id,
                                style: pw.TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 50),
                      pw.Text(
                        'Thank you for your dedication and professionalism!',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontStyle: pw.FontStyle.italic,
                          color: pd.PdfColor.fromInt(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

    // if (kIsWeb) {
    //   final blob = web.Blob([web.JSArray<int>.from(bytes)], 'application/pdf');
    //   final url = web.URL.createObjectURL(blob);
    //   final anchor = web.AnchorElement()
    //     ..href = url
    //     ..setAttribute('download', 'certificate.pdf')
    //     ..click();
    //   web.URL.revokeObjectURL(url);
    // } else {
    //   await Printing.layoutPdf(onLayout: (format) async => bytes);
    // }
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
        appBar: AppBar(title: const Text('Testing Certificate Generator')),
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
          DropdownButtonFormField<pd.PdfPageFormat>(
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/supabase_console");
            },
            child: const Text('Supabase Console'),
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
