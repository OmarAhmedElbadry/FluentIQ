import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:fluentiq/features/questions/domain/audio_recorder.dart';

/// [QuestionAudioRecorder] backed by `package:record`. This is the only
/// file in the app that imports that package — swapping recorders later
/// means editing only this file and the DI registration.
class RecordPackageAudioRecorder implements QuestionAudioRecorder {
  final AudioRecorder _recorder = AudioRecorder();

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<void> start() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/answer_${DateTime.now().microsecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
  }

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<void> cancel() => _recorder.cancel();
}
