import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_task/add_page.dart';
import 'package:crud_task/edit_page.dart';

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final DocumentSnapshot? docid;
  const Home({Key? key, this.docid}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Stream<QuerySnapshot> _itemsStream =
      FirebaseFirestore.instance.collection('items').snapshots();
  CollectionReference items = FirebaseFirestore.instance.collection('items');
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.white,
          leading: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              primary: Colors.green,
            ),
            child: const Text(
              'اضافة',
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddPage(),
                ),
              );
            },
          ),
        ),
        body: StreamBuilder(
          stream: _itemsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("حدث خطأ");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditPage(docid: snapshot.data!.docs[index]),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(3), // Border width
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox.fromSize(
                              size: const Size.fromRadius(48), // Image radius
                              child: Image.network(
                                  snapshot
                                      .data!.docChanges[index].doc['imageUrl'],
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        title: Text(
                          snapshot.data!.docChanges[index].doc['title'],
                        ),
                        subtitle: Text(
                          snapshot.data!.docChanges[index].doc['descrition'],
                        ),
                        trailing: Column(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  widget.docid!.reference.delete();
                                },
                                child: const Text(
                                  'حذف',
                                  style: TextStyle(color: Colors.red),
                                )),
                            GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditPage(
                                          docid: snapshot.data!.docs[index]),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'تعديل',
                                  style: TextStyle(color: Colors.red),
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
