 import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TVRemote {
  static const UP_ARROW = 19;
  static const DOWN_ARROW = 20;
  static const LEFT_ARROW = 21;
  static const RIGHT_ARROW = 22;

  static const OK = 23;
 }

 class SkyspaceRemoteWrapper extends StatefulWidget {

   final Widget child;

   SkyspaceRemoteWrapper({
     @required this.child
   });

   @override
   State<StatefulWidget> createState() => SkyspaceRemoteWrapperState();

 }

 class SkyspaceRemoteWrapperState extends State<SkyspaceRemoteWrapper> {

   final FocusNode _focusNode = new FocusNode();
   bool _initializedFocusNode = false;

   @override
   void initState(){
     _focusNode.addListener((){
       print("Has focus: ${_focusNode.hasFocus}");
     });

     super.initState();
   }

   @override
   Widget build(BuildContext context) {
     if(!_initializedFocusNode){
       _initializedFocusNode = true;
     }

     return RawKeyboardListener(
       focusNode: _focusNode,
       onKey: (event){
         if(!(event.data is RawKeyEventDataAndroid)) return;
         if(!(event is RawKeyUpEvent)) return;

         var _event = event.data as RawKeyEventDataAndroid;

         switch(_event.keyCode){
           case TVRemote.UP_ARROW:
             print("^");
             break;

           case TVRemote.DOWN_ARROW:
             print("v");
             break;

           case TVRemote.LEFT_ARROW:
             print("<");
             break;

           case TVRemote.RIGHT_ARROW:
             print(">");
             break;

           case TVRemote.OK:
             print("[OK]");
             break;
         }
       },
       child: widget.child,
     );
   }



 }