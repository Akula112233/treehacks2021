/**
 * Send a http request in the form {"type": "key", "data": ""} to wss://treehacks2021.app.lewisxy.com/workout/user1
 *    Response will be a json {"type: key", "data": [key value itself]}
 * Append the key's value to "rtmp://treehacks2021.app.lewisxy.com:1935/live/" + key
 * Send a http request in the form {"type": "connected", "data": ""} to wss://treehacks2021.app.lewisxy.com/workout/user1
 *    Server immediately starts pushing back data from stream in the form {"type": "push", "data": "[number itself]"
**/
import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  static String id = "camera_screen";
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}