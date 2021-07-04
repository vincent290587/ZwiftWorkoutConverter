import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';

import 'WorkoutConverter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // do not display the debug banner
      //theme: ThemeData.light(),
      //darkTheme: ThemeData.dark(),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: 'Zwift Converter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;
  final TextEditingController controller = TextEditingController();
  String _convertedContent = "Converted workout";
  bool upgrade_ramps = false;

  void _refreshText() {
    WorkoutConverter converter = WorkoutConverter();
    converter.parseWorkout(upgrade_ramps, controller.text);
    _convertedContent = converter.convertToZwift();
  }

  void _printLatestValue() {
    //print('Second text field: ${controller.text}');

    setState(() {
      _refreshText();
    });
  }

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    controller.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    controller.dispose();
    super.dispose();
  }

  Future<void> _onConvertPressed() async {

    _refreshText();

    Uint8List _bytes = Uint8List.fromList(_convertedContent.codeUnits);

    FilePickerCross myFile  = FilePickerCross(_bytes,
        path: '',
        type: FileTypeCross.custom,
        fileExtension: 'zwo');

    // for sharing to other apps you can also specify optional `text` and `subject`
    await myFile.exportToStorage();

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          Text(
            'Upgrade ramps',
            textAlign: TextAlign.center,
          ),
          Switch(
            value: upgrade_ramps,
            activeColor: Colors.white,
            activeTrackColor: Colors.black54,
            inactiveTrackColor: Colors.black54,
            onChanged: (bool newValue) {
              setState(() {
                upgrade_ramps = newValue;
                _refreshText();
              });
            },
          )
        ],
      ),
      body: Row(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: [
          Flexible(
            flex: 1,
            child: Container(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              //mainAxisAlignment: MainAxisAlignment.center,
              // width: 600.0,
              // height: 800.0,
              child: TextField(
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  minLines: null,
                  maxLines: null,  // If this is null, there is no limit to the number of lines, and the text container will start with enough vertical space for one line and automatically grow to accommodate additional lines as they are entered.
                  expands: true,
                  controller: controller,
                  // onChanged: (text) {
                  //   setState(() {
                  //     _convertedContent = text;
                  //   });
                  // },
                ),
            ),
          ),
          VerticalDivider(),
          Flexible(
            flex: 2,
            child: Container(
              // width: 600.0,
              // height: 800.0,
              child: Text(
                _convertedContent,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onConvertPressed,
        tooltip: 'Increment',
        child: Icon(Icons.save_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
