import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

// import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const CallingPageView(),
    );
  }
}

class CallingPageView extends StatefulWidget {
  const CallingPageView({Key? key}) : super(key: key);

  @override
  _CallingPageViewState createState() => _CallingPageViewState();
}

class _CallingPageViewState extends State<CallingPageView> {
  List phoneNos = [
    '121',
    '9868154070',
    '9810114070',
    '9650825901',
    '01123814070'
  ];
  List numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];

  TextEditingController numberdialedcontroller = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call Recording App"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            numberdialedcontroller.text = "";
          });
          Alert(
              context: context,
              title: "Make Call",
              content: StatefulBuilder(
                builder: (context, fun) => Column(
                  children: [
                    TextFormField(
                      controller: numberdialedcontroller,
                      readOnly: true,
                      decoration: const InputDecoration(
                        counterStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      childAspectRatio: 1.4,
                      crossAxisCount: 3,
                      children: numbers
                          .map((e) => InkWell(
                                onTap: () {
                                  setState(() {
                                    numberdialedcontroller.text =
                                        numberdialedcontroller.text +
                                            e.toString();
                                  });
                                },
                                child: GridTile(
                                    child: Text(
                                  e.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                )),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              buttons: [
                DialogButton(
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        if (numberdialedcontroller.text.isNotEmpty) {
                          numberdialedcontroller.text =
                              numberdialedcontroller.text.substring(
                                  0, numberdialedcontroller.text.length - 1);
                        }
                      });
                    }),
                DialogButton(
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                    onPressed: () {})
              ]).show();
        },
        child: const Icon(Icons.phone),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: phoneNos
                  .map((e) => Card(
                        color: Colors.blue[50],
                        elevation: 10,
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              e.toString(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.record_voice_over),
                                  label: const Text("Recording")),
                              TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.history),
                                  label: const Text("History")),
                            ],
                          ),
                          trailing: IconButton(
                              onPressed: () async {
                                bool result = await Record().hasPermission();

                                if (result) {
                                  final directory =
                                      await getExternalStorageDirectories();
                                  // print("test reco" + directory.toString());

                                  FlutterPhoneDirectCaller.callNumber(e)
                                      .then((value) async {
                                    // var recorder = FlutterAudioRecorder(
                                    //     directory.first.path.toString() +
                                    //         '/' +
                                    //         e.toString() +
                                    //         '_' +
                                    //         DateTime.now().toLocal().toString() +
                                    //         '.m4a');
                                    // await recorder.initialized;
                                    // await recorder.start();
                                    // var recording =
                                    //     await recorder.current(channel: 0);

                                    await Record()
                                        .start(
                                          path:
                                              directory!.first.path.toString() +
                                                  '/' +
                                                  e.toString() +
                                                  '_' +
                                                  DateTime.now()
                                                      .toLocal()
                                                      .toString() +
                                                  '.m4a', // required
                                          encoder:
                                              AudioEncoder.AAC, // by default
                                          bitRate: 128000, // by default
                                          samplingRate: 44100, // by default
                                        )
                                        .then((value) => Fluttertoast.showToast(
                                            msg: "Call Recording Start...",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.grey,
                                            textColor: Colors.white,
                                            fontSize: 16.0));

                                    Timer(const Duration(seconds: 10),
                                        () async {
                                      await Record().stop().then((value) =>
                                          Fluttertoast.showToast(
                                              msg: "Call Recording End...",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.grey,
                                              textColor: Colors.white,
                                              fontSize: 16.0));
                                    });
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.call,
                                color: Colors.green,
                              )),
                        ),
                      ))
                  .toList(),
            )),
      ),
    );
  }
}
