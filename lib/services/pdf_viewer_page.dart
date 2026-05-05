import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PDFViewerPage extends StatefulWidget {
  final String url;
  final String name;

  const PDFViewerPage({super.key, required this.url, required this.name});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  File? localFile;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _downloadAndCachePdf();
  }

  Future<void> _downloadAndCachePdf() async {
    try {
      // 1. تحديد مهلة زمنية (Timeout) للتحميل من الكاش
      // لو غيب أكتر من 7 ثواني، هيعتبره فشل ويدخل على الـ catch
      var file = await DefaultCacheManager()
          .getSingleFile(widget.url)
          .timeout(const Duration(seconds: 7));

      if (!mounted) return;

      setState(() {
        localFile = file;
        isLoading = false;
      });
    } catch (e) {
      print("Cache error or timeout: $e");

      if (!mounted) return;

      // 2. الحل البديل: لو الكاش فشل، افتح من الشبكة مباشرة
      setState(() {
        localFile = null; // نأكد إنه مفيش ملف محلي
        isLoading = false; // نقفل شاشة الـ Loading ونعرض الـ Network Viewer
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name, style: const TextStyle(fontSize: 15)),
          centerTitle: true,
          backgroundColor: const Color(0xff546C74), // لون متناسق مع الـ Loading
          foregroundColor: Colors.white,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xff546C74)),
            SizedBox(height: 15),
            Text("جاري فتح الخريطة..."),
          ],
        ),
      );
    }

    // لو التحميل المحلي (Cache) نجح
    if (localFile != null) {
      return SfPdfViewer.file(localFile!);
    }

    // لو الكاش فشل، بنفتح من الروابط مباشرة (Network) كخيار احتياطي
    return SfPdfViewer.network(
      widget.url,
      enableDoubleTapZooming: true,
      enableTextSelection: true,
      maxZoomLevel: 5,
      onDocumentLoadFailed: (details) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("عذراً، تعذر فتح الملف: ${details.description}"),
          ),
        );
      },
    );
  }
}
