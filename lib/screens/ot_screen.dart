import 'package:asi/models/api_error.dart';
import 'package:asi/models/ot.dart';
import 'package:asi/screens/ot_data_tab.dart';
import 'package:asi/screens/ot_remarks_tab.dart';
import 'package:asi/screens/ot_volume_tab.dart';
import 'package:asi/screens/setup_ot_service_screen.dart';
import 'package:asi/screens/setup_ot_type_screen.dart';
import 'package:asi/services/ot_service.dart';
import 'package:asi/widgets/action_dialog.dart';
import 'package:asi/widgets/input_dialog.dart';
import 'package:asi/widgets/loading_dialog.dart';
import 'package:asi/widgets/success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtScreen extends StatefulWidget {
  final Ot ot;

  OtScreen({Key? key, required this.ot}) : super(key: key);

  @override
  _OtScreenState createState() => _OtScreenState();
}

class _OtScreenState extends State<OtScreen> {
  final List<String> _tabs = <String>[
    "Data".toUpperCase(),
    "Remarks".toUpperCase(),
    "Volumen".toUpperCase(),
  ];

  bool _isPinned = false;
  late Ot _ot;
  late ValueNotifier<Ot> _otNotifier;

  @override
  void initState() {
    super.initState();
    _ot = widget.ot;
    _otNotifier = ValueNotifier(widget.ot);
    _isPinned = _ot.isPinned;
  }

  var scrollController = ScrollController();

  List<Widget> get _tabPages => <Widget>[
        OtDataTab(ot: _ot, otNotifier: _otNotifier),
        OtRemarksTab(ot: _ot, otNotifier: _otNotifier, refreshOt: _refreshOt),
        OtVolumeTab(ot: _ot, otNotifier: _otNotifier),
      ];

  _togglePinOt(Ot ot) async {
    try {
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false,
      );
      bool nowIsPinned = OtService.togglePinOt(ot);
      Get.back();
      Get.snackbar(
        nowIsPinned
            ? "La OT se guardó en la lista"
            : "La OT se removió de la lista",
        nowIsPinned
            ? "Ahora la encontrarás más facil en la pantalla principal"
            : "Ya no la verás en la pantalla principal",
        margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        snackStyle: SnackStyle.FLOATING,
      );
      setState(() {
        _isPinned = nowIsPinned;
      });
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Ocurrió un error inesperado",
        e.toString(),
        margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        snackStyle: SnackStyle.FLOATING,
      );
    }
  }

  _refreshOt(Ot ot) async {
    print("OT ${ot.toString()} ${ot.activities}");
    setState(() {
      _ot = ot;
      _otNotifier.value = ot;
    });
  }

  _sendReport(String comment) async {
    try {
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false,
      );
      await OtService.sendReport(widget.ot, comment);
      Get.back();
      await Get.dialog(
        MessageDialog(
          text: "Reporte enviado con éxito",
          icon: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          autoCloseAfter: Duration(seconds: 3),
        ),
      );
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
      body: NestedScrollView(
        controller: scrollController,
        physics: ScrollPhysics(
          parent: PageScrollPhysics(),
        ),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: false,
              pinned: false,
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _ot.otTypeString ?? "Sin tipo de OT",
                                textAlign: TextAlign.left,
                                style: Get.textTheme.headline6!.copyWith(
                                  color: Get.theme.primaryColor,
                                ),
                              ),
                              Container(height: 5),
                              Text(
                                _ot.otNumber ?? "Sin número de OT",
                                textAlign: TextAlign.left,
                                style: Get.textTheme.headline3,
                              ),
                              Container(height: 5),
                              Text(
                                _ot.placeShip != null
                                    ? "Sucursal ${_ot.placeShip}"
                                    : "Sin sucursal",
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        Container(width: 20),
                        if (widget.ot.instructions != null &&
                            widget.ot.instructions!.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Get.dialog(
                                    ActionDialog(
                                      title: "Instrucciones",
                                      cancelText: "Cerrar",
                                      onCancel: () => Get.back(),
                                      body: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: 300,
                                        ),
                                        child: SingleChildScrollView(
                                          child: Text(
                                            widget.ot.instructions!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.info,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_ot.activities == null ||
                            _ot.activities!.isEmpty ||
                            _ot.otTypeString == Ot.INSPECCION_TYPE)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Get.dialog(
                                    ActionDialog(
                                      title:
                                          "¿Estás seguro de hacer cambios en el tipo de OT?",
                                      confirmText: "Continuar",
                                      onConfirm: () async {
                                        Get.back();
                                        Ot? ot;
                                        if (_ot.otTypeString ==
                                                Ot.INSPECCION_TYPE &&
                                            _ot.activities != null &&
                                            _ot.activities!.isNotEmpty) {
                                          ot = await Get.to(
                                            () => SetupOtServiceScreen(ot: _ot),
                                          );
                                        } else {
                                          ot = await Get.to(
                                            () => SetupOtTypeScreen(ot: _ot),
                                          );
                                        }

                                        if (ot != null) {
                                          setState(() {
                                            _ot = ot!;
                                            _otNotifier.value = ot;
                                          });
                                          _otNotifier.notifyListeners();
                                        }
                                      },
                                      onCancel: () {
                                        Get.back();
                                      },
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.edit,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _togglePinOt(_ot);
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  _isPinned ? Icons.star : Icons.star_border,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 10),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        TextButton(
                          child: Text("Enviar reporte".toUpperCase()),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                              Size(0, 36),
                            ),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                                Get.theme.colorScheme.secondary),
                          ),
                          onPressed: () {
                            Get.dialog(
                              InputDialog(
                                labelText:
                                    "Comentario para incluir en correo a cliente",
                                hintText: "Escribe un comentario",
                                maxLines: 4,
                                title: "¿Estás seguro de enviar un reporte?",
                                confirmText: "Enviar",
                                onConfirm: (val) {
                                  Get.back();
                                  _sendReport(val);
                                },
                                onCancel: () {
                                  Get.back();
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: SafeArea(
          child: DefaultTabController(
            length: _tabs.length,
            child: Column(
              children: <Widget>[
                Container(
                  child: TabBar(
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: TabBarView(
                      children: _tabPages,
                    ),
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
