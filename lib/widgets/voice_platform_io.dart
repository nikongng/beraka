import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';





class SpeechResult {

  final String recognizedWords;

  final bool finalResult;



  SpeechResult(
      this.recognizedWords,
      this.finalResult,
      );

}









class SpeechRecognizerImpl {


  final stt.SpeechToText _speech =
      stt.SpeechToText();



  bool _isListening = false;



  bool get isListening =>
      _isListening;









  Future<bool> initialize({

    void Function(String status)? onStatus,

    void Function(String error)? onError,

  }) async {


    try {



      debugPrint(
          "🎤 Initialisation Speech..."
      );




      // Permission uniquement Android

      if(!kIsWeb && Platform.isAndroid){


        final permission =
        await Permission.microphone.request();



        if(!permission.isGranted){


          debugPrint(
              "❌ Micro refusé"
          );


          onError?.call(
              "Autorisation microphone refusée"
          );


          return false;


        }


      }






      final available =
      await _speech.initialize(



        debugLogging: true,



        onStatus:(status){



          debugPrint(
              "🎤 STATUS : $status"
          );



          _isListening =
              status == "listening";



          onStatus?.call(status);



        },




        onError:(error){



          debugPrint(
              "❌ Speech error : ${error.errorMsg}"
          );



          _isListening=false;



          onError?.call(

              error.errorMsg ??

                  "Erreur microphone"

          );


        },



      );





      debugPrint(
          "🎤 Disponible : $available"
      );



      return available;



    }

    catch(e){


      debugPrint(
          "❌ Exception Speech : $e"
      );


      onError?.call(
          e.toString()
      );


      return false;


    }



  }









  Future<void> listen({


    required void Function(
        SpeechResult result
        )
    onResult,


    required Duration listenFor,


    required Duration pauseFor,


    bool partialResults = true,


  }) async {




    if(!_speech.isAvailable){


      debugPrint(
          "❌ Speech non disponible"
      );


      return;


    }







    await _speech.listen(



      localeId:
      "fr_FR",



      listenFor:
      listenFor,



      pauseFor:
      pauseFor,



      partialResults:
      partialResults,



      listenMode:
      stt.ListenMode.confirmation,



      onResult:(result){



        debugPrint(
            "📝 Reconnu : ${result.recognizedWords}"
        );



        onResult(

          SpeechResult(

            result.recognizedWords,

            result.finalResult,

          ),

        );



      },


    );



    _isListening=true;



  }









  Future<void> stop() async {



    await _speech.stop();



    _isListening=false;



    debugPrint(
        "🎤 Stop écoute"
    );


  }



}













class TextToSpeechImpl {


  final FlutterTts _tts =
      FlutterTts();



  bool _available=false;



  bool get isAvailable =>
      _available;









  Future<void> init() async {


    try {



      debugPrint(
          "🔊 Initialisation TTS"
      );



      await _tts.setLanguage(
          "fr-FR"
      );



      await _tts.setSpeechRate(
          0.45
      );



      await _tts.setPitch(
          1.0
      );



      await _tts.awaitSpeakCompletion(
          true
      );



      _available=true;



      debugPrint(
          "🔊 TTS OK"
      );



    }

    catch(e){



      debugPrint(
          "❌ TTS erreur : $e"
      );



      _available=false;



    }


  }









  Future<void> speak(
      String text
      ) async {



    if(!_available ||
        text.trim().isEmpty){


      return;


    }





    try {



      await _tts.stop();



      await _tts.speak(
          text
      );



    }

    catch(e){


      debugPrint(
          "❌ TTS speak erreur : $e"
      );


    }



  }









  Future<void> stop() async {


    if(!_available){

      return;

    }



    await _tts.stop();


  }



}