import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'flutter_zsign_ffi_bindings_generated.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

extension Utf8Pointer on String {
  ffi.Pointer<ffi.Char> toNativeUtf8Pointer() {
    return toNativeUtf8().cast<ffi.Char>();
  }
}

extension DartString on ffi.Pointer<ffi.Char> {
  String toDartString() {
    return cast<Utf8>().toDartString();
  }
}

Future<String> sign(
    String ipaPath,
    String p12Path,
    String p12Password,
    String mpPath,
    String? dylibFilePath,
    String? dylibPrefixPath,
    String? removeDylibPath,
    String? appName,
    String? appVersion,
    String? appBundleId,
    String? appIconPath,
    String outputPath,
    bool deletePlugIns,
    bool deleteWatchPlugIns,
    bool deleteDeviceSupport,
    bool deleteSchemeURL,
    bool enableFileAccess,
    bool sign,
    int zipLevel,
    bool zipIpa,
    bool showLog) async {
  final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
  final int requestId = _nextSumRequestId++;
  final _SignRequest request = _SignRequest(
      requestId,
      ipaPath,
      p12Path,
      p12Password,
      mpPath,
      dylibFilePath ?? "",
      dylibPrefixPath ?? "@executable_path/",
      removeDylibPath ?? "",
      appName ?? "",
      appVersion ?? "",
      appBundleId ?? "",
      appIconPath ?? "",
      outputPath,
      deletePlugIns,
      deleteWatchPlugIns,
      deleteDeviceSupport,
      deleteSchemeURL,
      enableFileAccess,
      sign,
      zipLevel,
      zipIpa,
      showLog);
  final Completer<String> completer = Completer<String>();
  _SignRequests[requestId] = completer;
  helperIsolateSendPort.send(request);
  return completer.future;
}

const String _libName = 'flutter_zsign_ffi';

/// The dynamic library in which the symbols for [Hello2Bindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final FlutterZsignFfiBindings _bindings = FlutterZsignFfiBindings(_dylib);

/// A request to compute `sum`.
///
/// Typically sent from one isolate to another.
class _SignRequest {
  final int id;
  final String ipaPath;
  final String p12Path;
  final String p12Password;
  final String mpPath;
  final String dylibFilePath;
  final String dylibPrefixPath;
  final String removeDylibPath;
  final String appName;
  final String appVersion;
  final String appBundleId;
  final String appIconPath;
  final String outputPath;
  final bool deletePlugIns;
  final bool deleteWatchPlugIns;
  final bool deleteDeviceSupport;
  final bool deleteSchemeURL;
  final bool enableFileAccess;
  final bool sign;
  final int zipLevel;
  final bool zipIpa;
  final bool showLog;

  const _SignRequest(
    this.id,
    this.ipaPath,
    this.p12Path,
    this.p12Password,
    this.mpPath,
    this.dylibFilePath,
    this.dylibPrefixPath,
    this.removeDylibPath,
    this.appName,
    this.appVersion,
    this.appBundleId,
    this.appIconPath,
    this.outputPath,
    this.deletePlugIns,
    this.deleteWatchPlugIns,
    this.deleteDeviceSupport,
    this.deleteSchemeURL,
    this.enableFileAccess,
    this.sign,
    this.zipLevel,
    this.zipIpa,
    this.showLog,
  );
}

/// A response with the result of `sum`.
///
/// Typically sent from one isolate to another.
class _SignResponse {
  final int id;
  final String result;

  const _SignResponse(this.id, this.result);
}

/// Counter to identify [_SignRequest]s and [_SignResponse]s.
int _nextSumRequestId = 0;

/// Mapping from [_SignRequest] `id`s to the completers corresponding to the correct future of the pending request.
final Map<int, Completer<String>> _SignRequests = <int, Completer<String>>{};

/// The SendPort belonging to the helper isolate.
Future<SendPort> _helperIsolateSendPort = () async {
  // The helper isolate is going to send us back a SendPort, which we want to
  // wait for.
  final Completer<SendPort> completer = Completer<SendPort>();

  // Receive port on the main isolate to receive messages from the helper.
  // We receive two types of messages:
  // 1. A port to send messages on.
  // 2. Responses to requests we sent.
  final ReceivePort receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        // The helper isolate sent us the port on which we can sent it requests.
        completer.complete(data);
        return;
      }
      if (data is _SignResponse) {
        // The helper isolate sent us a response to a request we sent.
        final Completer<String> completer = _SignRequests[data.id]!;
        _SignRequests.remove(data.id);
        completer.complete(data.result);
        return;
      }
      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
    });

  // Start the helper isolate.
  await Isolate.spawn((SendPort sendPort) async {
    final ReceivePort helperReceivePort = ReceivePort()
      ..listen((dynamic data) {
        // On the helper isolate listen to requests and respond to them.
        if (data is _SignRequest) {
          var ipaPath = data.ipaPath.toNativeUtf8Pointer();
          var p12Path = data.p12Path.toNativeUtf8Pointer();
          var p12Password = data.p12Password.toNativeUtf8Pointer();
          var mpPath = data.mpPath.toNativeUtf8Pointer();
          var dylibFilePath = data.dylibFilePath.toNativeUtf8Pointer();
          var dylibPrefixPath = data.dylibPrefixPath.toNativeUtf8Pointer();
          var removeDylibPath = data.removeDylibPath.toNativeUtf8Pointer();
          var appName = data.appName.toNativeUtf8Pointer();
          var appVersion = data.appVersion.toNativeUtf8Pointer();
          var appBundleId = data.appBundleId.toNativeUtf8Pointer();
          var appIconPath = data.appIconPath.toNativeUtf8Pointer();
          var outputPath = data.outputPath.toNativeUtf8Pointer();
          int deletePlugIns = data.deletePlugIns ? 1 : 0;
          int deleteWatchPlugIns = data.deleteWatchPlugIns ? 1 : 0;
          int deleteDeviceSupport = data.deleteDeviceSupport ? 1 : 0;
          int deleteSchemeURL = data.deleteSchemeURL ? 1 : 0;
          int enableFileAccess = data.enableFileAccess ? 1 : 0;
          int sign = data.sign ? 1 : 0;
          int zipLevel = data.zipLevel;
          int zipIpa = data.zipIpa ? 1 : 0;
          int showLog = data.showLog ? 1 : 0;
          try {
            final ffi.Pointer<ffi.Char> result = _bindings.sign_ipa(
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
                showLog);
            String resultString = result.toDartString();
            if (resultString != null) {
              throw Exception(resultString);
            }
            malloc.free(result);
            final _SignResponse response = _SignResponse(data.id, resultString);
            sendPort.send(response);
          } finally {
            malloc.free(ipaPath);
            malloc.free(p12Path);
            malloc.free(p12Password);
            malloc.free(mpPath);
            malloc.free(dylibFilePath);
            malloc.free(dylibPrefixPath);
            malloc.free(removeDylibPath);
            malloc.free(appName);
            malloc.free(appVersion);
            malloc.free(appBundleId);
            malloc.free(appIconPath);
            malloc.free(outputPath);
          }
          return;
        }
        throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
      });

    // Send the port to the main isolate on which we can receive requests.
    sendPort.send(helperReceivePort.sendPort);
  }, receivePort.sendPort);

  // Wait until the helper isolate has sent us back the SendPort on which we
  // can start sending requests.
  return completer.future;
}();
