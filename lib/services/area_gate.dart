import 'package:arkan_app/screens/area_listUI.dart';
import 'package:arkan_app/screens/my_areas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class AreaGate extends StatelessWidget {
  const AreaGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Collec_Areas')
          .snapshots(),
      builder: (context, snapshot) {

        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Error
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('في مشكلة حصلت')),
          );
        }

        final docs = snapshot.data!.docs;

        // 🚫 مفيش مناطق
        if (docs.isEmpty) {
          return const MyAreas();
        }

        // ✅ فيه مناطق
        return const AreaList();
      },
    );
  }
}