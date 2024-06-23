import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_zsign_ffi/flutter_zsign_ffi.dart' as flutter_zsign_ffi;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int sumResult;
  late Future<String> sumAsyncResult;

  @override
  void initState() {
    super.initState();
    String ipaPath = "";
    String p12Path = "";
    String p12Password = "";
    String mpPath = "";
    String dylibFilePath = "";
    String dylibPrefixPath = "";
    String removeDylibPath = "";
    String appName = "";
    String appVersion = "";
    String appBundleId = "";
    String appIconPath = "";
    String outputPath = "";
    bool deletePlugIns = false;
    bool deleteWatchPlugIns = false;
    bool deleteDeviceSupport = false;
    bool deleteSchemeURL = false;
    bool enableFileAccess = false;
    bool sign = false;
    int zipLevel = 3;
    bool zipIpa = false;
    bool showLog = true;
    sumAsyncResult = flutter_zsign_ffi.sign(
      ipaPath,
      p12Path,
      p12Password,
      mpPath,
      dylibFilePath,
      dylibPrefixPath,
      removeDylibPath,
      appName,
      appVersion,
      appBundleId,
      appIconPath,
      outputPath,
      deletePlugIns,
      deleteWatchPlugIns,
      deleteDeviceSupport,
      deleteSchemeURL,
      enableFileAccess,
      sign,
      zipLevel,
      zipIpa,
      showLog,
    );
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'sum(1, 2) = $sumResult',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                FutureBuilder<String>(
                  future: sumAsyncResult,
                  builder: (BuildContext context, AsyncSnapshot<String> value) {
                    final displayValue =
                        (value.hasData) ? value.data : 'loading';
                    return Text(
                      'await sumAsync(3, 4) = $displayValue',
                      style: textStyle,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
