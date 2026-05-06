import 'package:arkan_app/screens/land_listview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:arkan_app/shared/themes/colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  Future<void> markAllAsRead() async {
    if (user == null) return;

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var doc in snapshot.docs) {
          batch.update(doc.reference, {'isRead': true});
        }

        await batch.commit();
      }
    } catch (e) {
      print("Error marking notifications as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("يجب تسجيل الدخول")));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgrround,

        appBar: AppBar(
          backgroundColor: const Color(0xFF1F3F45),
          elevation: 0,
          title: const Text(
            "الإشعارات",
            style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 70, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "لا توجد إشعارات حالياً",
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            var docs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var data = docs[index].data() as Map<String, dynamic>;
                bool isRead = data['isRead'] ?? false;

                String? areaId = data['areaId'];
                String? areaName = data['areaName'];

                String timeText = '';
                if (data['createdAt'] != null) {
                  timeText = timeago.format(
                    (data['createdAt'] as Timestamp).toDate(),
                    locale: 'ar',
                  );
                }

                return Card(
                  elevation: isRead ? 0.5 : 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  color: isRead ? Colors.white : Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: ListTile(
                    onTap: () {
                      final String notifId = docs[index].id;
                      final String? tappedAreaId = areaId;
                      final String? tappedAreaName = areaName;
                      final dynamic rawLandNum = data['landNum'];

                      // ✅ Mark as read
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .collection('notifications')
                          .doc(notifId)
                          .update({'isRead': true});

                      if (tappedAreaId == null || tappedAreaName == null)
                        return;
                      if (rawLandNum == null) return;

                      // ✅ نجيب كل الأراضي في المنطقة دي ونقارن يدوي
                      FirebaseFirestore.instance
                          .collection('Collec_Areas')
                          .doc(tappedAreaId)
                          .collection('Lands')
                          .get()
                          .then((snapshot) {
                            if (!mounted) return;

                            // ✅ نقارن الـ landNum كـ String عشان نتفادى مشكلة النوع
                            final String searchLandNum = rawLandNum
                                .toString()
                                .trim();

                            final bool landExists = snapshot.docs.any((doc) {
                              final docData = doc.data();
                              final String docLandNum =
                                  docData['landNum']?.toString().trim() ?? '';
                              return docLandNum == searchLandNum;
                            });

                            if (!mounted) return;

                            // ❌ القطعة مش موجودة
                            if (!landExists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "هذه القطعة تم حذفها أو غير موجودة حالياً",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontFamily: 'Cairo'),
                                  ),
                                  backgroundColor: Color(0xFF1F3F45),
                                ),
                              );
                              return;
                            }

                            // ✅ القطعة موجودة → نفتح الصفحة
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LandListView(
                                  areaId: tappedAreaId,
                                  areaName: tappedAreaName,
                                  initialSearch: searchLandNum,
                                ),
                              ),
                            );
                          })
                          .catchError((e) {
                            debugPrint("Error checking land: $e");
                          });
                    },

                    leading: CircleAvatar(
                      backgroundColor: isRead
                          ? Colors.grey
                          : const Color(0xFF1F3F45),
                      child: Icon(
                        isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),

                    title: Text(
                      data['title'] ?? '',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: isRead ? Colors.black54 : Colors.blue.shade900,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['body'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
