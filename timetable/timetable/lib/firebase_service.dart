import 'package:cloud_firestore/cloud_firestore.dart';

import 'model_tt.dart';

class FirebasService {
  static Future<bool> uploadData(List<SectionTT> tt, String section) async {
    var sectionDoc = FirebaseFirestore.instance.collection('timetableData');
    try {
      await sectionDoc.add({'section': section}).then((value) async {
        for (var day in tt) {
          await sectionDoc
              .doc(value.id)
              .collection('byday')
              .doc(day.day)
              .set(SectionTT.toJson(day));
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<SectionTT>> getTtData(String section) async {
    List<SectionTT> ttList = [];
    var res = await FirebaseFirestore.instance
        .collection('timetableData')
        .where('section', isEqualTo: section)
        .get();
    var data = res.docs.first;
    var res2 = await FirebaseFirestore.instance
        .collection('timetableData')
        .doc(data.id)
        .collection('byday')
        .orderBy(FieldPath.documentId)
        .get();

    for (var day in res2.docs) {
      ttList.add(SectionTT.fromJson(day.data()));
    }
    return ttList;
  }
}
