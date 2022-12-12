import 'package:asi/icons/asi_icons.dart';
import 'package:asi/models/ot.dart';
import 'package:asi/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtListTile extends StatefulWidget {
  final Ot ot;
  final VoidCallback onPressed;

  OtListTile({Key? key, required this.ot, required this.onPressed})
      : super(key: key);

  @override
  _OtListTileState createState() => _OtListTileState();
}

class _OtListTileState extends State<OtListTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MainTheme.listTileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    ASiIcons.notes,
                    color: Get.theme.primaryColor,
                    size: 25,
                  ),
                ),
                Container(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ot.otNumber ?? "Sin número de OT",
                        textAlign: TextAlign.left,
                        style: Get.textTheme.subtitle2,
                      ),
                      Text(
                        widget.ot.clientsString,
                        maxLines: 1,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
