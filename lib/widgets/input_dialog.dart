import 'package:asi/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputDialog extends StatelessWidget {
  final String title;
  final Widget? icon;
  final int maxLines;
  final String labelText;
  final String hintText;
  final String confirmText;
  final String cancelText;
  final Function(String)? onConfirm;
  final VoidCallback? onCancel;

  InputDialog({
    required this.title,
    this.icon,
    this.maxLines = 1,
    required this.labelText,
    required this.hintText,
    this.confirmText = "Confirmar",
    this.cancelText = "Cancelar",
    this.onConfirm,
    this.onCancel,
  });

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) icon!,
                    if (icon != null) Container(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: Get.textTheme.headline3,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labelText,
                      style: Get.textTheme.bodyText1,
                    ),
                    Container(height: 5),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: hintText,
                      ),
                      maxLines: maxLines,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    Container(height: 10),
                    Row(
                      children: [
                        Spacer(),
                        TextButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                              MainTheme.grey,
                            ),
                            minimumSize: MaterialStateProperty.all(
                              Size(0, 0),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                          child: Text(cancelText.toUpperCase()),
                          onPressed: onCancel,
                        ),
                        TextButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                              Get.theme.colorScheme.secondary,
                            ),
                            minimumSize: MaterialStateProperty.all(
                              Size(0, 0),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                          child: Text(confirmText.toUpperCase()),
                          onPressed: () {
                            onConfirm?.call(_controller.text);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
