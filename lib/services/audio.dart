
import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

Future<String> getAppFolderPath()async{
  Directory tempDir = await getExternalStorageDirectory();
  String tempPath = tempDir.path;
  if(!(await Directory("$tempPath/Media").exists())){
    createNewMediaFolder(tempPath);
  }
  print("$tempPath/Media");
  return "$tempPath/Media";
}

createNewMediaFolder(tempPath)async{
  Directory('$tempPath/Media').create()
    .then((Directory directory) {
  });
}
String pathRecord;
Future<String> startRecording()async{
  getAppFolderPath().then((path)async {
    bool result = await Record.hasPermission();
    print(result);
      pathRecord = '$path/${DateTime.now().toString()}.m4a';
      await Record.start(
  path: pathRecord
  );
  });
  return pathRecord;
}

Future<String> stopRecording()async{
   await Record.stop();
   return pathRecord;
}

Future<bool> isRecording()async{
  bool state = await Record.isRecording();
  return state;
}


class AudioPlayerCustom extends StatefulWidget {
  final bool isMe;
  final String url;
  AudioPlayerCustom(this.url ,this.isMe);
  @override
  _AudioPlayerCustomState createState() => _AudioPlayerCustomState();
}

class _AudioPlayerCustomState extends State<AudioPlayerCustom> {
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = Duration();
  Duration possition = Duration();
  bool playing = false;
  @override
  Widget build(BuildContext context) {
    return  Directionality(
      textDirection: TextDirection.rtl,
          child: Container(
        width: MediaQuery.of(context).size.width*0.4,
            padding: EdgeInsets.all(5),
                child:Column(
                  children:[
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 10 ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          duration.inSeconds.toInt() < 10  ?
                          "0${duration.inSeconds.toInt()} / 0${possition.inSeconds.toInt()}":
                          duration.inSeconds.toInt() > 10 && duration.inSeconds.toInt() < 10 ?
                          "${duration.inSeconds.toInt()} / 0${possition.inSeconds.toInt()}":
                          "${duration.inSeconds.toInt()} / ${possition.inSeconds.toInt()}",
                          style:
                              TextStyle(fontSize: 14, color: widget.isMe? Colors.white :Colors.black54)),
                      slider(),
                      InkWell(
                        onTap: () async {
                          playing
                              ? await audioPlayer
                                  .pause()
                                  .then((value) => setState(() {
                                        playing = false;
                                      }))
                              : await audioPlayer
                                  .play(
                                      widget.url,
                                      isLocal: false)
                                  .then((value) => setState(() {
                                        playing = true;
                                      }));

                          audioPlayer.onDurationChanged.listen((Duration dd) {
                            setState(() {
                              duration = dd;
                            });
                          });
                          audioPlayer.onAudioPositionChanged
                              .listen((Duration dd) {
                            setState(() {
                              possition = dd;
                            });
                            if (possition.inSeconds.toInt() ==
                                duration.inSeconds.toInt()) {
                              setState(() {
                                playing = false;
                                audioPlayer.pause();
                                audioPlayer.seek(Duration(seconds: 0));
                              });
                            }
                          });
                        },
                        child: Icon(
                          playing == false ? Icons.play_arrow : Icons.pause,
                          size: 30,
                          color: widget.isMe? Colors.white : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
      ),
    );
  }

  Widget slider() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Flexible(
              child: Slider.adaptive(
            activeColor: widget.isMe? Colors.white : Colors.black54,
            inactiveColor: widget.isMe? Colors.white : Colors.black54,
            min: 0.0,
            value: possition.inSeconds.toDouble(),
            max: duration.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                audioPlayer.seek(Duration(seconds: value.toInt()));
              });
            }),
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
