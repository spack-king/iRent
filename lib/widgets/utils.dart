import 'package:flutter/material.dart';

showSpackSnackBar(String content, BuildContext context, Color color, IconData icon){
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
          content: Container(
       // color: color,
        child: Row(
          children: [
            Icon(icon, color: Colors.black,),
            Container(child: Text(' $content', maxLines: 2,)),
          ],
        ),
      ))
  );
}