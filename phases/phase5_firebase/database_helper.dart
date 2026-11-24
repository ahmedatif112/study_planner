import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// LOGIC: All database code lives in this file (not mixed into the widgets)
class DatabaseHelper {
  // LOGIC: The "goals" collection in Cloud Firestore
  // (a getter, so Firebase is only touched after initDatabase has run)
  static CollectionReference<Map<String, dynamic>> get _goalsCollection =>
      FirebaseFirestore.instance.collection('goals');

  // LOGIC: Connect the app to Firebase (called once when the app starts)
  static Future<void> initDatabase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  // LOGIC: Save a goal and return its new id (a text id made by Firestore)
  static Future<String> insertGoal(Map<String, dynamic> goal) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _goalsCollection.add({
      'subject': goal['subject'],
      'hours': goal['hours'],
      // Firestore stores true/false directly, no 1/0 conversion needed
      'done': goal['done'] == true,
      // Server time, used to keep goals in the order they were added
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // LOGIC: Return all saved goals as a list of Maps
  static Future<List<Map<String, dynamic>>> getGoals() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _goalsCollection.orderBy('createdAt').get();

    return snapshot.docs.map((doc) {
      final Map<String, dynamic> data = doc.data();
      return {
        'id': doc.id,
        'subject': data['subject'],
        'hours': (data['hours'] as num).toInt(),
        'done': data['done'] == true,
      };
    }).toList();
  }

  // LOGIC: Change the done value of one goal
  static Future<void> updateGoal(String id, bool done) async {
    await _goalsCollection.doc(id).update({'done': done});
  }

  // LOGIC: Remove one goal
  static Future<void> deleteGoal(String id) async {
    await _goalsCollection.doc(id).delete();
  }
}