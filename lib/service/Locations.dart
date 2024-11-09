import 'package:cloud_firestore/cloud_firestore.dart';

class Locations {
  final String local_name;
  final int local_id;

  Locations({required this.local_name, required this.local_id});

  factory Locations.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Locations(
      local_name: data['local_name'] ?? 'No local_name',
      local_id: data['local_id'] ?? 0,
    );
  }
}

Future<List<Locations>> fetchLocations() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Locations').get();
  return snapshot.docs.map((doc) => Locations.fromFirestore(doc)).toList();
}
