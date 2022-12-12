import 'package:asi/models/api_error.dart';
import 'package:asi/models/ot.dart';
import 'package:asi/services/ot_service.dart';
import 'package:asi/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OtVolumeTab extends StatefulWidget {
  final Ot ot;
  final ValueNotifier<Ot>? otNotifier;

  OtVolumeTab({Key? key, required this.ot, this.otNotifier}) : super(key: key);

  @override
  _OtVolumeTabState createState() => _OtVolumeTabState();
}

class _OtVolumeTabState extends State<OtVolumeTab> {
  final dateFormat = DateFormat("dd/MM/yyyy");
  final timeFormat = DateFormat("HH:mm");
  final dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm");

  TextEditingController _tonTextController = TextEditingController();
  TextEditingController _totalInspectedTextController = TextEditingController();
  TextEditingController _dateTextController = TextEditingController();
  TextEditingController _timeTextController = TextEditingController();
  TextEditingController _balanceTextController = TextEditingController();

  FocusNode _dateFocusNode = FocusNode();
  FocusNode _timeFocusNode = FocusNode();

  late Ot _ot;

  @override
  void initState() {
    super.initState();
    _setData(widget.ot);

    widget.otNotifier?.addListener(() {
      _setData(widget.otNotifier!.value);
    });

    _dateFocusNode.addListener(() {
      if (!_dateFocusNode.hasFocus) {
        try {
          DateTime? date = _dateTextController.text != ""
              ? dateFormat.parse(_dateTextController.text)
              : null;
          setState(() {
            _dateTextController.text =
                date != null ? dateFormat.format(date) : "";
          });
        } catch (e) {
          setState(() {
            _dateTextController.text = "";
          });
        }
      }
    });

    _timeFocusNode.addListener(() {
      if (!_timeFocusNode.hasFocus) {
        try {
          DateTime? date = _timeTextController.text != ""
              ? timeFormat.parse(_timeTextController.text)
              : null;
          setState(() {
            _timeTextController.text =
                date != null ? timeFormat.format(date) : "";
          });
        } catch (e) {
          setState(() {
            _timeTextController.text = "";
          });
        }
      }
    });
  }

  bool get _isValid {
    double? ton = double.tryParse(
        _tonTextController.text.replaceAll(".", "").replaceAll(",", "."));
    double? totalInspected = double.tryParse(_totalInspectedTextController.text
        .replaceAll(".", "")
        .replaceAll(",", "."));
    double? balance = double.tryParse(
        _balanceTextController.text.replaceAll(".", "").replaceAll(",", "."));

    return totalInspected != null &&
        ton != null &&
        balance != null &&
        totalInspected <= ton &&
        _dateTextController.text.isNotEmpty &&
        _timeTextController.text.isNotEmpty;
  }

  _setData(Ot ot) {
    if (ot.otType != null && ot.isEmbarque) {
      _tonTextController = TextEditingController(
        text: toCurrencyString(
          ot.ton.toString(),
          leadingSymbol: "",
          mantissaLength: 0,
          thousandSeparator: ThousandSeparator.Period,
        ),
      );
      _totalInspectedTextController = TextEditingController(
        text: toCurrencyString(
          ot.totalInspected.toString(),
          leadingSymbol: "",
          mantissaLength: 0,
          thousandSeparator: ThousandSeparator.Period,
        ),
      );
      _balanceTextController = TextEditingController(
        text: toCurrencyString(
          ot.balance.toString(),
          leadingSymbol: "",
          mantissaLength: 0,
          thousandSeparator: ThousandSeparator.Period,
        ),
      );
    } else if (ot.otType != null && ot.isInspeccion) {
      _tonTextController = TextEditingController(
        text: toCurrencyString(
          ot.ton.toString(),
          leadingSymbol: "",
          mantissaLength: 0,
          thousandSeparator: ThousandSeparator.Period,
        ),
      );
      _balanceTextController = TextEditingController(
        text: toCurrencyString(
          ot.balance.toString(),
          leadingSymbol: "",
          mantissaLength: 0,
          thousandSeparator: ThousandSeparator.Period,
        ),
      );
    }

    _dateTextController.text = widget.ot.totalInspectedDate != null
        ? dateFormat.format(widget.ot.totalInspectedDate!)
        : dateFormat.format(DateTime.now());
    _timeTextController.text = widget.ot.totalInspectedDate != null
        ? timeFormat.format(widget.ot.totalInspectedDate!)
        : dateFormat.format(DateTime.now());

    _dateTextController.text = dateFormat.format(DateTime.now());
    _timeTextController.text = timeFormat.format(DateTime.now());

    if (mounted) {
      setState(() {
        _ot = ot;
      });
    } else {
      _ot = ot;
    }
  }

  _updateOt() async {
    double? totalInspected = double.tryParse(_totalInspectedTextController.text
        .replaceAll(".", "")
        .replaceAll(",", "."));
    double? balance = double.tryParse(
        _balanceTextController.text.replaceAll(".", "").replaceAll(",", "."));

    if (totalInspected != null &&
        balance != null &&
        _dateTextController.text.isNotEmpty &&
        _timeTextController.text.isNotEmpty) {
      DateTime date = dateTimeFormat
          .parse("${_dateTextController.text} ${_timeTextController.text}");

      try {
        Get.dialog(
          LoadingDialog(),
          barrierDismissible: false,
        );
        Ot ot = await OtService.updateTon(_ot, totalInspected, balance, date);
        Get.back();
        Get.snackbar(
          "¡Actualizado!",
          "Tonelaje actualizado correctamente",
          margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
          snackStyle: SnackStyle.FLOATING,
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
  }

  Widget get _inspeccionVolumen {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tonelaje Nominado',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        Stack(
          children: [
            TextFormField(
              controller: _tonTextController,
              readOnly: true,
              inputFormatters: [
                MoneyInputFormatter(
                  leadingSymbol: "",
                  mantissaLength: 0,
                  thousandSeparator: ThousandSeparator.Period,
                ),
              ],
              decoration: InputDecoration(
                filled: true,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Toneladas",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(height: 20),
        Text(
          'Tonelaje Inspeccionado',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        Stack(
          children: [
            TextFormField(
              controller: _totalInspectedTextController,
              inputFormatters: [
                MoneyInputFormatter(
                  leadingSymbol: "",
                  mantissaLength: 0,
                  thousandSeparator: ThousandSeparator.Period,
                ),
              ],
              onChanged: (val) {
                num? ton = _ot.ton;
                num? inspected = num.tryParse(_totalInspectedTextController.text
                    .replaceAll(".", "")
                    .replaceAll(",", "."));

                if (inspected == null) {
                  inspected = 0;
                }

                if (ton != null) {
                  num balance = ton - inspected;
                  setState(() {
                    _balanceTextController.text = toCurrencyString(
                      balance.toString(),
                      leadingSymbol: "",
                      mantissaLength: 0,
                      thousandSeparator: ThousandSeparator.Period,
                    );
                  });
                }
              },
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Toneladas",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(height: 20),
        Text(
          'Fecha de Inspección',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        Theme(
          data: Get.theme.copyWith(
            textButtonTheme: ThemeData.light().textButtonTheme,
            textTheme: Get.textTheme.copyWith(
              button: ThemeData.light().textTheme.button,
              headline4: ThemeData.light().textTheme.headline4,
            ),
          ),
          child: Builder(
            builder: (BuildContext context) => TextFormField(
              controller: _dateTextController,
              focusNode: _dateFocusNode,
              decoration: InputDecoration(
                hintText: "Selecciona una fecha",
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: Get.theme.primaryColor,
                  ),
                  onPressed: () async {
                    DateTime? oldDate;
                    try {
                      oldDate = _dateTextController.text != ""
                          ? dateFormat.parse(_dateTextController.text)
                          : null;
                    } catch (e) {
                      setState(() {
                        _dateTextController.text = "";
                      });
                    }

                    if (oldDate != null &&
                        oldDate.isAfter(
                            DateTime.now().subtract(Duration(days: 365))) &&
                        oldDate.isBefore(
                            DateTime.now().add(Duration(days: 365)))) {
                      DateTime? newDate = await showDatePicker(
                        context: context,
                        locale: Locale('es', 'ES'),
                        firstDate: _ot.totalInspectedDate ?? DateTime.now(),
                        initialDate: oldDate,
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (newDate != null) {
                        setState(() {
                          _dateTextController.text = dateFormat.format(newDate);
                        });
                      }
                    }
                  },
                ),
              ),
              keyboardType: TextInputType.datetime,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Este campo es obligatorio";
                }
                bool isValidDate = true;
                try {
                  DateTime date = dateFormat.parse(value);
                  if (!date
                      .isAfter(DateTime.now().subtract(Duration(days: 365)))) {
                    return "La fecha no puede ser menor a 365 días a partir de hoy";
                  }
                  if (!date.isBefore(DateTime.now().add(Duration(days: 365)))) {
                    return "La fecha no puede ser mayor a 365 días a partir de hoy";
                  }
                } catch (e) {
                  isValidDate = false;
                }
                if (!isValidDate) {
                  return "Debe ingresar una fecha válida";
                }
              },
              inputFormatters: [
                MaskedInputFormatter('##/##/####'),
              ],
            ),
          ),
        ),
        Container(height: 20),
        Text(
          'Hora de Inspección',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        Theme(
          data: Get.theme.copyWith(
            textButtonTheme: ThemeData.light().textButtonTheme,
            textTheme: Get.textTheme.copyWith(
              button: ThemeData.light().textTheme.button,
              headline4: ThemeData.light().textTheme.headline4,
            ),
          ),
          child: Builder(
            builder: (BuildContext context) => TextFormField(
              controller: _timeTextController,
              focusNode: _timeFocusNode,
              decoration: InputDecoration(
                hintText: "Selecciona una hora",
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.watch_later,
                    color: Get.theme.primaryColor,
                  ),
                  onPressed: () async {
                    DateTime oldDate = DateTime.now();
                    try {
                      oldDate = timeFormat.parse(_timeTextController.text);
                    } catch (e) {
                      setState(() {
                        _timeTextController.text = "";
                      });
                    }

                    TimeOfDay? newTime = await showTimePicker(
                      context: context,
                      cancelText: 'Cancelar'.toUpperCase(),
                      confirmText: 'Aceptar'.toUpperCase(),
                      initialTime: TimeOfDay.fromDateTime(oldDate),
                    );

                    if (newTime != null) {
                      DateTime now = new DateTime.now();
                      DateTime newDate = DateTime(now.year, now.month, now.day,
                          newTime.hour, newTime.minute);
                      setState(() {
                        _timeTextController.text = timeFormat.format(newDate);
                      });
                    }
                  },
                ),
              ),
              inputFormatters: [
                MaskedInputFormatter('##:##'),
              ],
            ),
          ),
        ),
        Container(height: 20),
        Text(
          'Tonelaje por Inspeccionar',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        Stack(
          children: [
            TextFormField(
              controller: _balanceTextController,
              readOnly: true,
              inputFormatters: [
                MoneyInputFormatter(
                  leadingSymbol: "",
                  mantissaLength: 0,
                  thousandSeparator: ThousandSeparator.Period,
                ),
              ],
              decoration: InputDecoration(
                filled: true,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Toneladas",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(height: 20),
        OutlinedButton(
          child: Text("Guardar cambios".toUpperCase()),
          onPressed: _isValid
              ? () {
                  _updateOt();
                }
              : null,
        ),
      ],
    );
  }

  Widget get _embarqueVolumen {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tonelaje Nominado',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _tonTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Tonelaje Inspeccionado',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _totalInspectedTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Balance',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _balanceTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        OutlinedButton(
          child: Text("Guardar cambios".toUpperCase()),
          onPressed: _isValid
              ? () {
                  _updateOt();
                }
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(30),
          child: _inspeccionVolumen,
        ),
      ),
    );
  }
}
