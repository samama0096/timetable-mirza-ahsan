import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timetable/model_tt.dart';
import 'package:timetable/timetable_view.dart';

import 'firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Table')),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('timetableData')
            .orderBy('section')
            .get(),
        builder: (context, snap) {
          if (snap.hasData) {
            if (snap.data!.docs.isNotEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ListView.builder(
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ViewTimeTable(
                                        section: snap.data!.docs[i]
                                            ['section'])));
                          },
                          trailing: const Icon(
                            Icons.arrow_circle_right_rounded,
                            size: 40,
                          ),
                          shape: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blueGrey, width: 2)),
                          title:
                              Text('Section: ${snap.data!.docs[i]['section']}'),
                        ),
                      );
                    }),
              );
            }
          }
          return const Center(
            child: Text('Loading...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var e = await rootBundle.loadString('assets/tt-json.json');
          Map jsondata = jsonDecode(e);
          var keys = jsondata.keys;
          for (var section in keys) {
            List<SectionTT> tt = [];
            var sectionData = jsondata[section] as List<dynamic>;
            tt = sectionData
                .map((e) => SectionTT.fromJson(e as Map<String, dynamic>))
                .toList();

            var res = await FirebasService.uploadData(tt, section);
            print(res);
          }
        },
        child: const Icon(Icons.upload),
      ),
    );
  }
}
