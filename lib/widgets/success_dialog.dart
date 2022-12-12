import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageDialog extends StatefulWidget {
  final String text;
  final Widget icon;
  final Duration? autoCloseAfter;

  MessageDialog({
    required this.text,
    required this.icon,
    this.autoCloseAfter,
  });

  @override
  _MessageDialogState createState() => _MessageDialogState();
}

class _MessageDialogState extends State<MessageDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoCloseAfter != null) {
      _timer = Timer(widget.autoCloseAfter!, () {
        Get.back();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.icon,
              Container(height: 10),
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: Get.textTheme.headline3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
