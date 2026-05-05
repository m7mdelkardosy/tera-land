import 'dart:io';
import 'package:arkan_app/shared/themes/app_bar.dart';
import 'package:arkan_app/shared/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arkan_app/services/pdf_viewer_page.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  bool isUploading = false;
  double uploadProgress = 0;
  Future<void> pickAndUploadPDFs() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => isUploading = true);

      try {
        for (var file in result.files) {
          if (file.path != null) {
            File pdfFile = File(file.path!);
            await uploadPDF(pdfFile, file.name);
          }
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("تم رفع الملفات بنجاح")));
      } finally {
        setState(() => isUploading = false);
         uploadProgress = 0;
      }
    }
  }

  Future<void> uploadPDF(File file, String fileName) async {
    final storageRef = FirebaseStorage.instance.ref().child('maps/$fileName');

    UploadTask uploadTask = storageRef.putFile(file);

    // 🔥 متابعة الرفع لحظة بلحظة
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = (snapshot.bytesTransferred / snapshot.totalBytes);

      setState(() {
        uploadProgress = progress;
      });
    });

    // استنى لما يخلص
    await uploadTask;

    String downloadUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance.collection('maps').add({
      'name': fileName,
      'url': downloadUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMap(String docId, String fileName) async {
    try {
      await FirebaseFirestore.instance.collection('maps').doc(docId).delete();

      await FirebaseStorage.instance.ref().child('maps/$fileName').delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("تم حذف الخريطة")));
    } catch (e) {
      print("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // 🔥 رجّعنا RTL زي الأول
      child: Scaffold(
        backgroundColor: backgrround,
        // appBar: AppBar(
        //   title: const Text("الخرائط"),
        //   centerTitle: true,
        // ),
        appBar: CustomAppBar(
          titleBar: Text(
            "الخرائط",
            style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
          ),
        ),

        body: Column(
          children: [
            if (isUploading)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: uploadProgress, // 👈 النسبة
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      color: const Color(0xFF1F3F45),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${(uploadProgress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('maps')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("لم تتم إضافة أي خريطة"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var doc = docs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      String docId = doc.id;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                          ),
                          title: Text(data['name'] ?? ''),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFViewerPage(
                                  url: data['url'],
                                  name: data['name'],
                                ),
                              ),
                            );
                          },

                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("حذف الخريطة"),
                                content: const Text("هل أنت متأكد من الحذف؟"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("إلغاء"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      deleteMap(docId, data['name']);
                                    },
                                    child: const Text(
                                      "حذف",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    elevation: 6, // 👈 الشادو
                    shadowColor: Colors.black.withOpacity(0.3),

                    backgroundColor: const Color(0xFF1F3F45),
                    foregroundColor: Colors.white,

                    // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), // 👈 الحواف
                    ),
                  ),
                  onPressed: isUploading ? null : pickAndUploadPDFs,
                  icon: const Icon(
                    Icons.upload_file,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 25,
                  ),
                  label: Text(
                    isUploading ? "جاري الرفع..." : "إضافة ",
                    style: TextStyle(
                      fontFamily: 'Din',
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
