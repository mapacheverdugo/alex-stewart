import 'package:asi/screens/image_view_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DefaultNetworkImage extends StatelessWidget {
  final String? url;
  final BorderRadiusGeometry? borderRadius;

  DefaultNetworkImage({
    this.url,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: url ?? "",
        imageBuilder: (context, imageProvider) => GestureDetector(
          onTap: () async {
            Get.to(
              () => ImageViewScreen(imagen: imageProvider),
            );
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: this.borderRadius ?? BorderRadius.circular(10),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        placeholder: (context, url) => Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: this.borderRadius ?? BorderRadius.circular(10),
            color: Colors.grey[300],
          ),
          child: Center(
            child: Icon(Icons.photo),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: this.borderRadius ?? BorderRadius.circular(10),
            color: Colors.grey[300],
          ),
          child: Center(
            child: Icon(Icons.photo),
          ),
        ),
      ),
    );
  }
}
