import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LandService {
  static final _db = FirebaseFirestore.instance;

  // 🟢 ADD LAND & DISTRIBUTE NOTIFICATIONS
  static Future<void> addLand({
    required String areaId,
    required String areaName,
    required String address,
    required String level,
    required String landNum,
    required String size,
    required String owner,
    required String paid,
    required String offer,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    // 1. إنشاء مستند الأرض
    DocumentReference landDoc = _db
        .collection('Collec_Areas')
        .doc(areaId)
        .collection('Lands')
        .doc();

    // 2. حفظ بيانات الأرض في الفايرستور
    await landDoc.set({
      'address': address,
      'level': level,
      'landNum': landNum,
      'landSize': double.tryParse(size) ?? 0,
      'landOwner': owner,
      'paid': paid,
      'offer': offer,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3. 🔔 توزيع الإشعارات على كل المستخدمين (التركة اللي طلبتها)
    try {
      // جلب جميع المستخدمين المسجلين في كوليكشن users
      QuerySnapshot usersSnapshot = await _db.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        // تخطي الحساب الحالي الذي يقوم بالإضافة
        if (userDoc.id == user.uid) continue;

        // إضافة الإشعار في الساب-كوليكشن الخاص بكل مستخدم آخر
        // الإشعار سيبقى هنا للأبد حتى لو المستخدم مسجل خروج حالياً
        await _db
            .collection('users')
            .doc(userDoc.id)
            .collection('notifications')
            .add({
          'title': 'قطعة أرض جديدة',
          'body': 'تم إضافة أرض رقم $landNum في منطقة $areaName',
          'createdAt': FieldValue.serverTimestamp(), // مهم جداً للترتيب الزمني
          'isRead': false,
          'areaId': areaId,
          'areaName': areaName,
          'landId': landDoc.id,
          'landNum': landNum,
        });
      }
    } catch (e) {
      // طباعة الخطأ في الـ Console لمعرفة لو الرولز منعت جلب المستخدمين
      print("Error distributing notifications: $e");
    }
  }

  // 🟡 UPDATE LAND
  static Future<void> updateLand({
    required String areaId,
    required String landId,
    required String address,
    required String level,
    required String landNum,
    required String size,
    required String owner,
    required String paid,
    required String offer,
  }) async {
    final user = FirebaseAuth.instance.currentUser; // جلب المستخدم الحالي
    await _db
        .collection('Collec_Areas')
        .doc(areaId)
        .collection('Lands')
        .doc(landId)
        .update({
      'address': address,
      'level': level,
      'landNum': landNum,
      'landSize': double.tryParse(size) ?? 0,
      'landOwner': owner,
      'paid': paid,
      'offer': offer,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔵 GET LAND
  static Future<DocumentSnapshot> getLand({
    required String areaId,
    required String landId,
  }) {
    return _db
        .collection('Collec_Areas')
        .doc(areaId)
        .collection('Lands')
        .doc(landId)
        .get();
  }

  // 🔴 DELETE LAND
  static Future<void> deleteLand({
    required String areaId,
    required String landId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db
        .collection('Collec_Areas')
        .doc(areaId)
        .collection('Lands')
        .doc(landId)
        .delete();
  }
}