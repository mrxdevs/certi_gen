import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart' as pd;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

class PdfPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> jsonData;
  const PdfPreviewScreen({required this.jsonData, super.key});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  @override
  initState() {
    super.initState();
    print('PDF Preview Screen initialized');
    print("jsonData: ${widget.jsonData}");
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

  @override
  Widget build(BuildContext context) {
    print('Building PDF preview...');
    print("jsonData: ${widget.jsonData}");
    return PdfPreview(
      build: (format) => _buildPdf(
        name: widget.jsonData['name'].toString() ?? '',
        course: widget.jsonData['email'].toString() ?? '',
        date: widget.jsonData['created_at'].toString() ?? '',
        id: widget.jsonData['user_id'].toString() ?? '',
        pageFormat: format,
      ),
      allowPrinting: false,
      allowSharing: false,
      canChangePageFormat: false,
      pdfFileName: 'certificate.pdf',
      // initialPageFormat: format,
    );
    ;
  }
}
