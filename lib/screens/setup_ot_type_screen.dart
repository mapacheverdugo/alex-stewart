import 'package:asi/models/api_error.dart';
import 'package:asi/models/ot.dart';
import 'package:asi/screens/setup_ot_service_screen.dart';
import 'package:asi/services/ot_service.dart';
import 'package:asi/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetupOtTypeScreen extends StatefulWidget {
  final Ot ot;

  SetupOtTypeScreen({Key? key, required this.ot}) : super(key: key);

  @override
  _SetupOtTypeScreenState createState() => _SetupOtTypeScreenState();
}

class _SetupOtTypeScreenState extends State<SetupOtTypeScreen> {
  late Ot _ot;

  @override
  void initState() {
    super.initState();
    _ot = widget.ot;
  }

  _setOtType(Ot ot, OtType type) async {
    try {
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false,
      );
      Ot newOt = await OtService.setOtType(ot, type);
      Get.back();

      setState(() {
        _ot = newOt;
      });

      if (type == OtType.inspeccion) {
        Ot? ot = await Get.to(() => SetupOtServiceScreen(ot: newOt));
        Get.back(result: ot);
      } else {
        Get.back(result: newOt);
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
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Seleccione el tipo de OT".toUpperCase(),
                textAlign: TextAlign.left,
                style: Get.textTheme.headline3,
              ),
              Container(height: 10),
              Text(
                _ot.otNumber ?? "Sin número de OT",
                textAlign: TextAlign.left,
              ),
              Container(height: 20),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            _setOtType(_ot, OtType.inspeccion);
                          },
                          child: Image.asset(
                            "assets/images/inspeccion.png",
                            width: double.infinity,
                          ),
                        ),
                        Container(height: 10),
                        Text(
                          "Inspección".toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Get.textTheme.headline6!.copyWith(
                            color: Get.theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            _setOtType(_ot, OtType.embarque);
                          },
                          child: Image.asset(
                            "assets/images/embarque.png",
                            width: double.infinity,
                          ),
                        ),
                        Container(height: 10),
                        Text(
                          "Embarque".toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Get.textTheme.headline6!.copyWith(
                            color: Get.theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
