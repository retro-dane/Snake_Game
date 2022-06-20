import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighScoreTile extends StatelessWidget {
  final String documentId;
  const HighScoreTile({
    Key? key,
    required this.documentId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference highScores = FirebaseFirestore.instance.collection(
        "highscores");
    return FutureBuilder<DocumentSnapshot>(
      future: highScores.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Row(
            children: [
              Text("${data['name']} : "),
              Text(data['score'].toString()),
            ],
          );
        }else {
          return const CircularProgressIndicator(color: Colors.red,);
        }
      },
    );
  }
}
