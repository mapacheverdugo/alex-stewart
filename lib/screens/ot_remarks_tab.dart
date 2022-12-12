import 'dart:developer';

import 'package:asi/models/activity.dart';
import 'package:asi/models/api_error.dart';
import 'package:asi/models/ot.dart';
import 'package:asi/models/task.dart';
import 'package:asi/screens/new_activity_screen.dart';
import 'package:asi/services/activity_service.dart';
import 'package:asi/widgets/activity_list_tile.dart';
import 'package:asi/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OtRemarksTab extends StatefulWidget {
  final Ot ot;
  final ValueNotifier<Ot>? otNotifier;
  final Function(Ot) refreshOt;
  OtRemarksTab(
      {Key? key, required this.ot, required this.refreshOt, this.otNotifier})
      : super(key: key);

  @override
  _OtRemarksTabState createState() => _OtRemarksTabState();
}

class _OtRemarksTabState extends State<OtRemarksTab> {
  late Ot _ot;

  @override
  void initState() {
    _setData(widget.ot);
    widget.otNotifier?.addListener(() {
      log("OT NOTIFIER CHANGED");
      _setData(widget.otNotifier!.value);
    });
    super.initState();
  }

  _setData(Ot ot) {
    if (mounted) {
      setState(() {
        _ot = ot;
      });
    } else {
      _ot = ot;
    }
  }

  final dateFormat = DateFormat("dd/MM/yyyy");

  Map<String, List<Activity>> get _sortedActivities {
    Map<String, List<Activity>> sortedActivities = {};
    if (_ot.activities != null) {
      List<Activity> activities = _ot.activities!;
      activities.sort((b, a) {
        int cmp = a.activityDate!.compareTo(b.activityDate!);
        if (cmp != 0) return cmp;
        return a.createdAt!.compareTo(b.createdAt!);
      });

      for (var activity in activities) {
        String dateKey = activity.activityDate!.toIso8601String().split("T")[0];
        if (sortedActivities[dateKey] == null) {
          sortedActivities[dateKey] = [];
        }
        sortedActivities[dateKey]!.add(activity);
      }
    }
    return sortedActivities;
  }

  bool get _syncPending {
    return _ot.activities != null && _ot.activities!.any((a) => !a.isSync);
  }

  _sync() async {
    try {
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false,
      );
      bool isSync = await ActivityService.syncActivities();
      Get.back();
      if (isSync) {
        setState(() {
          _ot.activities = _ot.activities?.map((e) {
            e.isSync = true;
            return e;
          }).toList();
        });
      } else {
        Get.snackbar(
          "No se sincronizaron las actividades",
          "Comprueba que tengas una conexión a internet",
          margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
          snackStyle: SnackStyle.FLOATING,
        );
      }
    } on ApiError catch (e) {
      Get.back();
      Get.snackbar(
        "Ocurrió un error",
        e.message!,
        margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        snackStyle: SnackStyle.FLOATING,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        e.toString(),
        margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        snackStyle: SnackStyle.FLOATING,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Flexible(
                    child: TextButton(
                      child: Text("Nueva actividad".toUpperCase()),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Get.theme.colorScheme.secondary,
                        ),
                      ),
                      onPressed: () async {
                        Ot? ot = await Get.to(
                          NewActivityScreen(
                            ot: _ot,
                          ),
                        );
                        if (ot != null) {
                          widget.refreshOt(ot);
                        }
                      },
                    ),
                  ),
                  Container(width: 15),
                  Flexible(
                    child: OutlinedButton(
                      child: Text("Breaking News".toUpperCase()),
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                          BorderSide(color: Colors.red, width: 2),
                        ),
                        foregroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      onPressed: () async {
                        Ot? ot = await Get.to(
                          NewActivityScreen(
                            ot: _ot,
                            isEmergency: true,
                          ),
                        );

                        if (ot != null) {
                          widget.refreshOt(ot);
                        }
                      },
                    ),
                  ),
                ],
              ),
              Container(height: 20),
              if (_sortedActivities.keys.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Actividades registradas',
                        style: Get.textTheme.headline6,
                      ),
                    ),
                    if (_syncPending) Container(width: 10),
                    if (_syncPending)
                      TextButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sincronizar".toUpperCase(),
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            Get.theme.colorScheme.secondary,
                          ),
                          side: MaterialStateProperty.all(
                            BorderSide(
                              color: Get.theme.colorScheme.secondary,
                              width: 1,
                            ),
                          ),
                          minimumSize: MaterialStateProperty.all(Size(0, 30)),
                        ),
                        onPressed: () async {
                          _sync();
                        },
                      ),
                  ],
                ),
              Container(height: 15),
              _sortedActivities.keys.isEmpty
                  ? Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no-ots.png',
                            height: 200,
                          ),
                          Container(height: 16),
                          Text(
                            'Aún no hay actividades registradas',
                            style: Get.textTheme.headline3,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: _sortedActivities.keys.length,
                      separatorBuilder: (context, i) => Container(height: 10),
                      itemBuilder: (context, i) {
                        String dateKey = _sortedActivities.keys.toList()[i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(DateTime.parse(dateKey)),
                            ),
                            Container(height: 10),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: _sortedActivities[dateKey]!.length,
                              separatorBuilder: (context, i) =>
                                  Container(height: 10),
                              itemBuilder: (context, i) {
                                Activity activity =
                                    _sortedActivities[dateKey]![i];
                                return ActivityListTile(
                                  activity: activity,
                                  onPressed: () async {
                                    Ot? ot = await Get.to(
                                      () => NewActivityScreen(
                                        ot: _ot,
                                        activity: activity,
                                        isEmergency: activity.task?.id ==
                                            Task.EMERGENCY_TASK_ID,
                                      ),
                                    );

                                    if (ot != null) {
                                      widget.refreshOt(ot);
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
