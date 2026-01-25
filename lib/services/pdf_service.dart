import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../models/workspace_folder.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';  // Add this


final pdfServiceProvider = Provider<PdfService>((ref) => PdfService());

class PdfService {
  // Load font with Unicode support
  Future<pw.Font> _loadFont() async {
    return await PdfGoogleFonts.notoSansRegular();
  }

  Future<pw.Font> _loadBoldFont() async {
    return await PdfGoogleFonts.notoSansBold();
  }

  // Split text into paragraphs for better pagination
  List<String> _splitIntoParagraphs(String text) {
    // Split by newlines and filter out empty paragraphs
    return text
        .split('\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  // Export single note to PDF
  Future<void> exportNoteToPdf(
      BuildContext context,
      Note note,
      String folderName,
      ) async {
    try {
      final pdf = pw.Document();
      final font = await _loadFont();
      final fontBold = await _loadBoldFont();

      // Extract plain text from note content
      final plainText = _extractPlainText(note.content);
      final paragraphs = _splitIntoParagraphs(plainText);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          theme: pw.ThemeData.withFont(
            base: font,
            bold: fontBold,
          ),
          build: (pw.Context context) {
            return [
              // Title
              pw.Text(
                note.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Metadata
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Folder: $folderName',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Created: ${_formatDate(note.createdAt)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Content - Split into paragraphs for better pagination
              ...paragraphs.map((paragraph) => pw.Paragraph(
                text: paragraph,
                style: pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                textAlign: pw.TextAlign.left,
              )),

              // Tags if available
              if (note.tags.isNotEmpty) ...[
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: note.tags.map((tag) {
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        tag,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.blue900,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ];
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            );
          },
        ),
      );

      // Show options dialog
      if (context.mounted) {
        _showExportOptions(context, pdf, note.title);
      }
    } catch (e) {
      print('PDF SAVE ERROR: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating PDF: $e')),
        );
      }
    }
  }

  // Export folder with all notes to PDF
  Future<void> exportFolderToPdf(
      BuildContext context,
      WorkspaceFolder folder,
      List<Note> notes,
      ) async {
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No notes to export in this folder')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final font = await _loadFont();
      final fontBold = await _loadBoldFont();

      // Add cover page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: font,
            bold: fontBold,
          ),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    folder.name,
                    style: pw.TextStyle(
                      fontSize: 36,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    '${notes.length} Notes',
                    style: pw.TextStyle(
                      fontSize: 18,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Exported: ${_formatDate(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Add each note
      for (var note in notes) {
        final plainText = _extractPlainText(note.content);
        final paragraphs = _splitIntoParagraphs(plainText);

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            theme: pw.ThemeData.withFont(
              base: font,
              bold: fontBold,
            ),
            build: (pw.Context context) {
              return [
                pw.Text(
                  note.title,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Created: ${_formatDate(note.createdAt)}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.SizedBox(height: 15),

                // Content as paragraphs
                ...paragraphs.map((paragraph) => pw.Paragraph(
                  text: paragraph,
                  style: pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
                  textAlign: pw.TextAlign.left,
                )),

                if (note.tags.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  pw.Wrap(
                    spacing: 5,
                    children: note.tags.map((tag) {
                      return pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Text(
                          tag,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.blue900,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ];
            },
            footer: (pw.Context context) {
              return pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(top: 10),
                child: pw.Text(
                  'Page ${context.pageNumber}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              );
            },
          ),
        );
      }

      // Show options dialog
      if (context.mounted) {
        _showExportOptions(context, pdf, folder.name);
      }
    } catch (e) {
      print('PDF SAVE ERROR: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating PDF: $e')),
        );
      }
    }
  }

  void _showExportOptions(BuildContext context, pw.Document pdf, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export PDF'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Preview & Print'),
              onTap: () async {
                Navigator.pop(context);
                await _previewPdf(context, pdf);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () async {
                Navigator.pop(context);
                await _sharePdf(context, pdf, fileName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Save to Device'),
              onTap: () async {
                Navigator.pop(context);
                await _savePdf(context, pdf, fileName);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _previewPdf(BuildContext context, pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _sharePdf(BuildContext context, pw.Document pdf, String fileName) async {
    try {
      final bytes = await pdf.save();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Exported from Chatly',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF ready to share!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
    }
  }

// Save PDF to device
// Save PDF to device with proper permissions
// Save PDF to device with proper permissions
  Future<void> _savePdf(BuildContext context, pw.Document pdf, String fileName) async {
    try {
      // Request storage permission first
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();

        // For Android 13+ (API 33+), also request manage external storage
        if (Platform.isAndroid) {
          final manageStatus = await Permission.manageExternalStorage.status;
          if (!manageStatus.isGranted) {
            await Permission.manageExternalStorage.request();
          }
        }
      }

      if (!status.isGranted && !await Permission.manageExternalStorage.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Storage permission denied'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final bytes = await pdf.save();
      Directory? directory;

      if (Platform.isAndroid) {
        // Try multiple paths for Android
        final possiblePaths = [
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Downloads',
          '/sdcard/Download',
          '/sdcard/Downloads',
        ];

        for (var path in possiblePaths) {
          final testDir = Directory(path);
          if (await testDir.exists()) {
            directory = testDir;
            break;
          }
        }

        // Fallback to app-specific directory
        directory ??= await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not find storage directory');
      }

      // Clean filename
      final cleanFileName = fileName
          .replaceAll(RegExp(r'[^\w\s-]'), '_')
          .replaceAll(' ', '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/Chatly_${cleanFileName}_$timestamp.pdf');

      print('Attempting to save PDF to: ${file.path}');
      await file.writeAsBytes(bytes);
      print('PDF saved successfully to: ${file.path}');

      // SUCCESS SNACKBAR
      // SUCCESS SNACKBAR
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✓ PDF Saved Successfully!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Check Downloads folder',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16), // Add this line
            action: SnackBarAction(
              label: 'OPEN',
              textColor: Colors.white,
              onPressed: () async {
                await Printing.sharePdf(
                  bytes: bytes,
                  filename: 'Chatly_${cleanFileName}.pdf',
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('SAVE ERROR: $e');

      // ERROR SNACKBAR
// ERROR SNACKBAR
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '❌ Failed to Save PDF',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.toString().length > 50
                            ? '${e.toString().substring(0, 50)}...'
                            : e.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16), // Add this line
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: () {
                _savePdf(context, pdf, fileName);
              },
            ),
          ),
        );
      }    }
  }
  String _extractPlainText(String jsonContent) {
    try {
      final decoded = jsonDecode(jsonContent);
      if (decoded is List) {
        final buffer = StringBuffer();
        for (var item in decoded) {
          if (item is Map && item.containsKey('insert')) {
            buffer.write(item['insert']);
          }
        }
        return buffer.toString();
      }
      return jsonContent;
    } catch (e) {
      return jsonContent;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}