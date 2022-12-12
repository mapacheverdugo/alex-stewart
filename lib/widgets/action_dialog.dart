import 'package:asi/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActionDialog extends StatelessWidget {
  final String title;
  final Widget? body;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  ActionDialog(
      {required this.title,
      this.body,
      this.confirmText = "Confirmar",
      this.cancelText = "Cancelar",
      this.onConfirm,
      this.onCancel});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Get.textTheme.headline3,
              ),
              Container(height: 20),
              if (body != null) body!,
              if (body != null) Container(height: 20),
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
                  if (onConfirm != null)
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
                      onPressed: onConfirm,
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
