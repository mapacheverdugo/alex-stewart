import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TypeSelectorCard extends StatefulWidget {
  final Widget icon;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  TypeSelectorCard(
      {Key? key,
      this.selected = false,
      required this.onTap,
      required this.icon,
      required this.text})
      : super(key: key);

  @override
  _TypeSelectorCardState createState() => _TypeSelectorCardState();
}

class _TypeSelectorCardState extends State<TypeSelectorCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: 250,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.selected
              ? Get.theme.colorScheme.secondary
              : Get.theme.colorScheme.secondary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                height: 35,
                width: 35,
                child: widget.icon,
              ),
            ),
            Container(height: 10),
            Text(widget.text.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Get.textTheme.bodyText1!.copyWith(
                  fontSize: 12,
                  color: widget.selected
                      ? Colors.white
                      : Get.theme.colorScheme.secondary,
                )),
          ],
        ),
      ),
    );
  }
}
