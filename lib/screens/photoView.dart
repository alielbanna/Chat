import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/services/permission.dart';
import 'package:flutter_chat_ui_starter/services/save.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewCustom extends StatefulWidget {
  final bool canDownoladed;
  final imageList;
  final clickerIndex;
  
  PhotoViewCustom(this.clickerIndex,this.imageList ,  this.canDownoladed );
  

  @override
  _PhotoViewCustomState createState() => _PhotoViewCustomState();
}

class _PhotoViewCustomState extends State<PhotoViewCustom> {
  @override
  Widget build(BuildContext context) {
    PageController controller =
        PageController(initialPage: widget.clickerIndex);
    return Scaffold(
        backgroundColor: Theme.of(context).accentColor,
        appBar: AppBar(
          title: Text(""), backgroundColor: Colors.black,
          //Theme.of(context).accentColor,
          leading: IconButton(
            color: Colors.white,
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            widget.canDownoladed ? IconButton(
              color: Colors.white,
              icon: Icon(Icons.file_download),
              onPressed: () {
                permissionStorage(context).then((value) {
                if(value == "PermissionStatus.allow"){
                saveNetworkImage(widget.imageList[controller.page.toInt()]) ;
                }});
              },
            ) : Container(),
          ],
        ),
        body: PhotoViewGallery.builder(
          reverse: false,
          pageController: controller,
          itemCount: widget.imageList.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(
                widget.imageList[index],
              ),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          scrollPhysics: BouncingScrollPhysics(),
          loadingChild: Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }
}
