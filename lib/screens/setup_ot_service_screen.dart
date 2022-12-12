import 'package:asi/models/api_error.dart';
import 'package:asi/models/ot.dart';
import 'package:asi/models/service_type.dart';
import 'package:asi/services/ot_service.dart';
import 'package:asi/services/service_type_service.dart';
import 'package:asi/widgets/input_dialog.dart';
import 'package:asi/widgets/loading_dialog.dart';
import 'package:asi/widgets/loading_indicator.dart';
import 'package:asi/widgets/type_selector_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetupOtServiceScreen extends StatefulWidget {
  final Ot ot;

  SetupOtServiceScreen({Key? key, required this.ot}) : super(key: key);

  @override
  _SetupOtServiceScreenState createState() => _SetupOtServiceScreenState();
}

class _SetupOtServiceScreenState extends State<SetupOtServiceScreen> {
  late Future<List<ServiceType>> _serviceTypesFuture;
  List<ServiceType> _serviceTypes = [];
  late Ot _ot;

  @override
  void initState() {
    super.initState();
    _ot = widget.ot;
    _serviceTypesFuture = _getServiceTypes();
  }

  Future<List<ServiceType>> _getServiceTypes() async {
    List<ServiceType> serviceTypes = await ServiceTypeService.getServiceTypes();
    serviceTypes.add(
      ServiceType(
        id: 'otro',
        name: 'Añadir nuevo Servicio',
      ),
    );
    setState(() {
      _serviceTypes = serviceTypes;
    });
    return serviceTypes;
  }

  _createServiceType(String name) async {
    try {
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false,
      );
      ServiceType serviceType =
          await ServiceTypeService.createServiceTypes(name);
      await _getServiceTypes();
      Get.back();
      Get.back();
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

  _setOtType(Ot ot, String selectedServiceTypeId) async {
    try {
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false,
      );
      Ot newOt = await OtService.setOtService(ot, selectedServiceTypeId);
      Get.back();

      setState(() {
        _ot = newOt;
      });

      Get.back(result: newOt);
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
        "Ocurrió un error inesperado",
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
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Seleccione tipo de servicio".toUpperCase(),
                textAlign: TextAlign.left,
                style: Get.textTheme.headline3,
              ),
              Container(height: 10),
              Text(
                _ot.otNumber ?? "Sin número de OT",
                textAlign: TextAlign.left,
              ),
              Container(height: 20),
              FutureBuilder(
                future: _serviceTypesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  }
                  if (!snapshot.hasData) {
                    return LoadingIndicator();
                  }
                  if (_serviceTypes.isEmpty) {
                    return Center(
                      child: Text("No hay servicios disponibles"),
                    );
                  }
                  return GridView.count(
                    primary: false,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 110 / 144,
                    children: List.generate(
                      _serviceTypes.length,
                      (index) {
                        ServiceType serviceType = _serviceTypes[index];
                        return TypeSelectorCard(
                          text: serviceType.name ?? "Sin nombre",
                          icon: serviceType.id == "otro"
                              ? Icon(
                                  Icons.add,
                                  color: Get.theme.colorScheme.secondary,
                                )
                              : Icon(
                                  Icons.assignment,
                                  color: Get.theme.colorScheme.secondary,
                                ),
                          onTap: () {
                            if (serviceType.id == "otro") {
                              Get.dialog(
                                InputDialog(
                                    title: "Nuevo servicio",
                                    icon: Icon(
                                      Icons.add_circle,
                                    ),
                                    labelText: "Añadir nuevo servicio",
                                    hintText: "Nuevo servicio",
                                    onCancel: () {
                                      Get.back();
                                    },
                                    onConfirm: (value) async {
                                      _createServiceType(value);
                                    }),
                              );
                            } else {
                              _setOtType(_ot, serviceType.id!);
                            }
                          },
                        );
                      },
                    ),
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
