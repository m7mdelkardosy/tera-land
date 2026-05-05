import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AreaService {
  final CollectionReference areas =
      FirebaseFirestore.instance.collection('Collec_Areas');

  Future<void> addArea({
    required String name,
    required BuildContext context,
  }) async {
    try {
      await areas.add({
        'name': name,
        'createdAt': Timestamp.now(),
      });

      _showSnackBar(context, 'تمت إضافة المنطقة ✅');
    } catch (e) {
      _showSnackBar(context, 'حصل خطأ أثناء الإضافة');
    }
  }

  Future<void> submitArea({
    required TextEditingController controller,
    required BuildContext context,
  }) async {
    final name = controller.text.trim();

    if (name.isEmpty) {
      _showSnackBar(context, 'من فضلك اكتب اسم المنطقة');
      return;
    }

    await addArea(name: name, context: context);

    controller.clear();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}