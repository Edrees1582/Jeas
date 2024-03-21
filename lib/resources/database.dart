import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference requestCollection =
      FirebaseFirestore.instance.collection('requests');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  void requestService(
    String location,
    String title,
    String description,
    String serviceType,
    String serviceCategory,
  ) async {
    String requestId = const Uuid().v4();
    await requestCollection.doc(requestId).set({
      'uid': requestId,
      'requesterUID': uid,
      'location': location,
      'title': title,
      'description': description,
      'serviceType': serviceType,
      'serviceCategory': serviceCategory,
      'workerUID': null,
      'status': 'Pending',
    });
    await userCollection.doc(uid).update({
      "requests": FieldValue.arrayUnion([requestId]),
    });
  }
  void deleteRequestService(
    String requestId,
  ) async {
    await requestCollection.doc(requestId).delete();

    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    List<dynamic> newArray = List.from(documentSnapshot['requests']);
    newArray.remove(requestId);

    await userCollection.doc(uid).update({
      "requests": newArray,
    });
  }
}
