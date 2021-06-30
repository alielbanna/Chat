import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/services/audio.dart';

class AudioPlayerScreen extends StatelessWidget{
  final String voiceUrl;
  AudioPlayerScreen(this.voiceUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(backgroundColor: Theme.of(context).accentColor,elevation: 0,
      leading: IconButton( icon:Icon(Icons.arrow_back ,color:Colors.white , size:25), onPressed: (){Navigator.pop(context);},)
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Container(
          color: Colors.white24,
          height: 60,
          width: MediaQuery.of(context).size.width*0.9,
        child: AudioPlayerCustom(voiceUrl , true )),
      ),
    );
  }
}