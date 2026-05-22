
import 'package:arkan_app/screens/MapsPage.dart';
import 'package:arkan_app/services/auth_service.dart';
import 'package:arkan_app/shared/themes/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return SafeArea(
      child: Drawer(
        backgroundColor: backgrround,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    title: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data?.data() == null) {
                          return const Text("مستخدم");
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;

                        return Text(data['name'] ?? 'مستخدم');
                      },
                    ),
                    leading: Icon(Icons.person_2_outlined),
                    onTap: () {},
                  ),
                  Divider(height: 9, thickness: 0.3, color: Colors.blueGrey),
                  ListTile(
                    title: Text(
                      'الخرائط',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: ' Cairo',
                        color: mainTxt,
                      ),
                    ),
                    leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapsPage(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 9, thickness: 0.3, color: Colors.blueGrey),
                  ListTile(
                    title: Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: ' Cairo',
                        color: mainTxt,
                      ),
                    ),

                    leading: Icon(Icons.exit_to_app),
                    onTap: () {
                      Auth().signOut(context);
                    },
                  ),
                  Divider(height: 9, thickness: 0.3, color: Colors.blueGrey),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Developed by',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 121, 116, 116),
                    fontFamily: 'Cairo',
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Geemy Elkardosy @',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 121, 116, 116),
                    fontFamily: 'Cairo',
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ' ${DateTime.now().year} All rights reserved ©',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color.fromARGB(255, 156, 151, 151),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
