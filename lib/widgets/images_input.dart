import 'dart:io';
import 'dart:typed_data';

import 'package:asi/themes/theme.dart';
import 'package:asi/widgets/image_editor_modal.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagesInput extends StatefulWidget {
  final Color color;
  final Function(List<Uint8List>)? onImage;

  ImagesInput({
    Key? key,
    this.color = const Color(MainTheme.PRIMARY_COLOR_VALUE),
    this.onImage,
  }) : super(key: key);

  @override
  _ImagesInputState createState() => _ImagesInputState();
}

class _ImagesInputState extends State<ImagesInput> {
  List<Uint8List> _images = [];
  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            try {
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                Uint8List originalImageBytes =
                    File(image.path).readAsBytesSync();

                Uint8List editedImageBytes = await Get.to(
                  ImageEditorModal(
                    initialImage: originalImageBytes,
                  ),
                );

                setState(() {
                  _images.add(editedImageBytes);
                });

                widget.onImage!(_images);
              } else {
                Get.snackbar(
                  "Error",
                  "No se pudo añadir la imagen",
                  colorText: Colors.white,
                  backgroundColor: Get.theme.primaryColor,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: EdgeInsets.all(20),
                );
              }
            } catch (e) {
              print(e);
              Get.snackbar(
                "Error",
                "No se pudo añadir la imagen",
                colorText: Colors.white,
                backgroundColor: Get.theme.primaryColor,
                snackPosition: SnackPosition.BOTTOM,
                margin: EdgeInsets.all(20),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(8),
              dashPattern: [3, 3],
              color: widget.color,
              strokeWidth: 2,
              child: Container(
                padding: EdgeInsets.all(25),
                width: double.infinity,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: widget.color,
                      ),
                      Container(width: 10),
                      Text(
                        "Añadir imágenes",
                        style: Get.textTheme.bodyText1!.copyWith(
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(height: 15),
        if (_images.length > 0)
          Text(
              "Se subirá${_images.length > 1 ? 'n' : ''} ${_images.length} imágen${_images.length > 1 ? 'es' : ''}"),
        if (_images.length > 0) Container(height: 15),
        if (_images.length > 0)
          Container(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                Uint8List bytesImage = _images[i];
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.memory(
                        bytesImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _images.removeAt(i);
                        });
                      },
                      child: Container(
                        width: 15,
                        height: 15,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 10,
                            color: widget.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, i) => Container(width: 15),
              itemCount: _images.length,
            ),
          ),
      ],
    );
  }
}
