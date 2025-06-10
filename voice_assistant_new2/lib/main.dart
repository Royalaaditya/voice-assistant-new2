import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Assistant New2',
      theme: ThemeData.dark(),
      home: const AssistantPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _clonePlayer = AudioPlayer();
  static const _channel = MethodChannel('assistant.new2/channel');

  bool _isListening = false;
  bool _useClone = false;
  String _recognized = '';
  String _reply = '';

  Future<void> _listen() async {
    await Permission.microphone.request();
    if (!_isListening) {
      bool ready = await _speech.initialize(
        onStatus: print,
        onError: print,
      );
      if (ready) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: "en_US",
          onResult: (val) {
            setState(() => _recognized = val.recognizedWords);
            if (['stop', 'ruk ja', 'bas'].contains(val.recognizedWords.toLowerCase().trim())) {
              _stopAll();
            }
          },
        );
      }
    }
  }

  Future<void> _stopAll() async {
    if (_isListening) await _speech.stop();
    await _tts.stop();
    await _clonePlayer.stop();
    await _channel.invokeMethod('stopActions');
    setState(() => _isListening = false);
  }

  Future<void> _send() async {
    if (_recognized.isEmpty) return;
    await _channel.invokeMethod('sendQuery', {'text': _recognized});
    String reply = await _channel.invokeMethod('readReply');
    setState(() => _reply = reply);
    if (_useClone) {
      await _channel.invokeMethod('speakClone', {'text': reply});
    } else {
      await _tts.speak(reply);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Assistant New2')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(onPressed: _listen, child: const Icon(Icons.mic)),
          const SizedBox(width: 20),
          FloatingActionButton(onPressed: _send, child: const Icon(Icons.send)),
          const SizedBox(width: 20),
          FloatingActionButton(backgroundColor: Colors.red,onPressed: _stopAll, child: const Icon(Icons.stop)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Use Cloned Voice'),
              value: _useClone,
              onChanged: (v)=>setState(()=>_useClone=v),
            ),
            const Divider(),
            Text('Heard: $_recognized'),
            const Divider(),
            Text('Reply: $_reply'),
          ],
        ),
      ),
    );
  }
}
