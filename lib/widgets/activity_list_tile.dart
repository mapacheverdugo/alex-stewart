import 'dart:developer';

import 'package:asi/models/activity.dart';
import 'package:asi/models/task.dart';
import 'package:asi/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mdi/mdi.dart';

class ActivityListTile extends StatefulWidget {
  final Activity activity;
  final VoidCallback onPressed;

  ActivityListTile({Key? key, required this.onPressed, required this.activity})
      : super(key: key);

  @override
  _ActivityListTileState createState() => _ActivityListTileState();
}

class _ActivityListTileState extends State<ActivityListTile> {
  final timeFormat = DateFormat("HH:mm");

  @override
  void initState() {
    super.initState();
  }

  Widget get _taskIcon {
    log(widget.activity.task?.activity ?? "No activity");
    if (widget.activity.task?.activity != null) {
      if (widget.activity.task!.activity!.contains("Inicio")) {
        return SvgPicture.asset(
          "assets/images/complete_progress.svg",
          height: 24,
          width: 24,
          semanticsLabel: 'Inicio de progreso',
          color: Get.theme.colorScheme.secondary.withOpacity(0.2),
        );
      } else if (widget.activity.task!.activity!.contains("Desarrollo")) {
        return SvgPicture.asset(
          "assets/images/half_progress.svg",
          height: 24,
          width: 24,
          semanticsLabel: 'Mitad de progreso',
          color: Get.theme.colorScheme.secondary,
        );
      } else if (widget.activity.task!.activity!.contains("Termino") ||
          widget.activity.task!.activity!.contains("Término")) {
        return SvgPicture.asset(
          "assets/images/complete_progress.svg",
          height: 24,
          width: 24,
          semanticsLabel: 'Término de progreso',
          color: Get.theme.colorScheme.secondary,
        );
      } else if (widget.activity.task?.id == Task.EMERGENCY_TASK_ID) {
        return Icon(
          Icons.error,
          color: MainTheme.emergencyColor,
          size: 24,
        );
      }
    }

    return Icon(
      Icons.assignment,
      color: widget.activity.task?.id == Task.EMERGENCY_TASK_ID
          ? MainTheme.emergencyColor
          : Get.theme.colorScheme.secondary,
      size: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.activity.task?.id == Task.EMERGENCY_TASK_ID
            ? MainTheme.emergencyColor.withOpacity(0.2)
            : MainTheme.listTileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.watch_later,
                            size: 18,
                            color: widget.activity.task?.id ==
                                    Task.EMERGENCY_TASK_ID
                                ? MainTheme.emergencyColor
                                : MainTheme.primaryColor,
                          ),
                          Container(width: 10),
                          Expanded(
                            child: Text(
                              widget.activity.activityDate != null
                                  ? timeFormat
                                      .format(widget.activity.activityDate!)
                                  : "Sin fecha",
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: widget.activity.task?.id ==
                                        Task.EMERGENCY_TASK_ID
                                    ? MainTheme.emergencyColor
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: _taskIcon,
                          ),
                          Container(width: 10),
                          Expanded(
                            child: Text(
                              widget.activity.task?.name ?? "Sin tarea",
                              textAlign: TextAlign.left,
                              style: Get.textTheme.subtitle2!.copyWith(
                                color: widget.activity.task?.id ==
                                        Task.EMERGENCY_TASK_ID
                                    ? MainTheme.emergencyColor
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          Container(width: 10),
                          Icon(
                            widget.activity.isSync
                                ? Mdi.cloudCheck
                                : Mdi.cloudAlert,
                            color: !widget.activity.isSync
                                ? MainTheme.emergencyColor
                                : (widget.activity.task?.id ==
                                        Task.EMERGENCY_TASK_ID
                                    ? Colors.white
                                    : Colors.grey),
                            size: 24,
                          ),
                        ],
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
