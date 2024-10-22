import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreviewImage extends StatefulWidget {
  final img;
  const PreviewImage({super.key, this.img});

  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Hero(
              tag: 'img',
              child:CachedNetworkImage(
                  alignment: Alignment.center,
                  imageUrl: widget.img,
                  imageBuilder: (context, imageProvider) =>
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            image: DecorationImage(
                              image: imageProvider,
                              //fit: BoxFit.fill,
                              // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn)
                            )
                        ),
                      ),
                  placeholder: (context, url) =>  const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>   const Center(child: Icon(CupertinoIcons.ellipsis_vertical_circle))
              )
              // child: Container(
              //   width: double.infinity,
              //     height: double.infinity,
              //     child: Image.network(widget.img)),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close_rounded), tooltip: 'Close',),
            )
          ],
        ),
      ),
    );
  }
}
