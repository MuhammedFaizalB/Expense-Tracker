import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'web_download_web.dart';

class PdfPreviewPage extends StatelessWidget {
  final Uint8List bytes;
  final String fileName;
  final String title;
  const PdfPreviewPage({
    super.key,
    required this.bytes,
    required this.fileName,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (_) async => bytes,
        pdfFileName: fileName,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}

Future<void> openPdfPreview(
  BuildContext context, {
  required Uint8List bytes,
  required String fileName,
  required String title,
}) async {
  if (kIsWeb) {
    await downloadPdfBytes(bytes, fileName);
    return;
  }
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          PdfPreviewPage(bytes: bytes, fileName: fileName, title: title),
    ),
  );
}

Future<T> runWithBlockingLoader<T>(
  BuildContext context,
  Future<T> Function() task,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    ),
  );
  try {
    return await task();
  } finally {
    navigator.pop();
  }
}
