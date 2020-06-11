import 'package:cloud_firestore/cloud_firestore.dart';

class Bug {
  final String name;
  final int price;
  final String month;
  final String time;
  final DocumentReference reference;

  Bug.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['price'] != null),
        name = map['name'],
        price = map['price'],
        month = map['month'],
        time = map['time'];

  Bug.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$price>";
}

class Fish {
  final String name;
  final int price;
  final String month;
  final String time;
  final int shadow;
  final String location;
  final DocumentReference reference;

  Fish.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['price'] != null),
        name = map['name'],
        price = map['price'],
        month = map['month'],
        time = map['time'],
        shadow = map['shadow'],
        location = map['location'];

  Fish.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$price>";
}