import 'dart:developer';
import 'dart:typed_data';

import 'package:asi/models/activity.dart';
import 'package:asi/models/api_error.dart';
import 'package:asi/models/ot.dart';
import 'package:asi/models/task.dart';
import 'package:asi/models/user.dart';
import 'package:asi/services/activity_service.dart';
import 'package:asi/services/task_service.dart';
import 'package:asi/services/user_service.dart';
import 'package:asi/themes/theme.dart';
import 'package:asi/widgets/action_dialog.dart';
import 'package:asi/widgets/default_network_image.dart';
import 'package:asi/widgets/images_input.dart';
import 'package:asi/widgets/loading_dialog.dart';
import 'package:asi/widgets/loading_indicator.dart';
import 'package:asi/widgets/success_dialog.dart';
import 'package:asi/widgets/type_selector_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewActivityScreen extends StatefulWidget {
  final bool isEmergency;
  final Ot ot;
  final Activity? activity;

  NewActivityScreen({
    Key? key,
    this.isEmergency = false,
    this.activity,
    required this.ot,
  }) : super(key: key);

  @override
  _NewActivityScreenState createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen> {
  final dateFormat = DateFormat("dd/MM/yyyy");
  final timeFormat = DateFormat("HH:mm");
  final dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm");

  List<String> _embarqueTaskCategories = [
    'Inicio Embarque',
    'Desarrollo Embarque',
    'Termino Embarque'
  ];
  List<String> _inspeccionTaskCategories = [
    'Inicio Inspección',
    'Desarrollo Inspección',
    'Termino Inspección'
  ];

  String? _taskCategory;
  Task? _selectedTask;
  late Future<List<Task>> _tasksFuture;
  List<Task> _tasks = [];
  late Activity _activity;
  List<Uint8List> _images = [];
  bool _editable = true;
  bool _alreadySaved = false;

  TextEditingController _taskTextController = TextEditingController();
  TextEditingController _dateTextController = TextEditingController();
  TextEditingController _timeTextController = TextEditingController();
  TextEditingController _tonTextController = TextEditingController();
  TextEditingController _userTextController = TextEditingController();
  TextEditingController _descripionTextController = TextEditingController();
  FocusNode _dateFocusNode = FocusNode();
  FocusNode _timeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _activity = widget.activity ?? Activity(isSync: false);
    if (widget.activity != null) {
      _alreadySaved = true;
      if (widget.isEmergency) {
        _editable = false;
      }

      User? user = UserService.getLocalUser();
      if (user?.id != null && user!.id != widget.activity!.createdBy?.id) {
        _editable = false;
      }
      _taskTextController.text = widget.activity?.task?.name ?? "";
      _dateTextController.text = widget.activity!.activityDate != null
          ? dateFormat.format(widget.activity!.activityDate!)
          : "";
      _timeTextController.text = widget.activity!.activityDate != null
          ? timeFormat.format(widget.activity!.activityDate!)
          : "";

      if (widget.activity?.ton != null) {
        _tonTextController.text = toCurrencyString(
          widget.activity!.ton.toString(),
          leadingSymbol: "",
          mantissaLength: 0,
          thousandSeparator: ThousandSeparator.Period,
        );
      }
      if (!widget.activity!.isSync) {
        User? user = UserService.getLocalUser();
        if (user != null) {
          _userTextController.text = user.name ?? "";
        }
      } else {
        _userTextController.text = widget.activity!.createdBy?.name ??
            (widget.activity!.createdBy?.id ?? "");
      }
      _descripionTextController.text = widget.activity!.description ?? "";
    } else {
      _dateTextController.text = dateFormat.format(DateTime.now());
      _timeTextController.text = timeFormat.format(DateTime.now());

      User? user = UserService.getLocalUser();
      if (user != null) {
        _userTextController.text = user.name ?? "";
      }

      if (widget.isEmergency) {
        _selectedTask = Task(
          id: Task.EMERGENCY_TASK_ID,
          tonIsRequired: false,
          name: "Breaking News",
        );
      }
    }
    _tasksFuture = _getTasks();

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

  Future<List<Task>> _getTasks() async {
    List<Task> tasks = await TaskService.getTasks();
    setState(() {
      _tasks = tasks;
    });
    return tasks;
  }

  List<Task> get _tasksByCategory {
    return _tasks
        .where((task) =>
            task.activity?.toLowerCase() == _taskCategory?.toLowerCase())
        .toList();
  }

  Future<Ot?> _saveActivity() async {
    _activity.activityDate = dateTimeFormat
        .parse("${_dateTextController.text} ${_timeTextController.text}");

    if (!_alreadySaved) {
      _activity.task = _selectedTask;

      if (_selectedTask!.tonIsRequired!) {
        _activity.ton = double.tryParse(
            _tonTextController.text.replaceAll(".", "").replaceAll(",", "."));
      }
    } else {
      if (_tonTextController.text.isNotEmpty) {
        _activity.ton = double.tryParse(
            _tonTextController.text.replaceAll(".", "").replaceAll(",", "."));
      }
    }
    _activity.description = _descripionTextController.text;

    try {
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false,
      );
      Ot ot;
      if (_alreadySaved) {
        ot = await ActivityService.editActivity(_activity, widget.ot);
      } else {
        ot =
            await ActivityService.createActivity(_activity, widget.ot, _images);
      }

      Get.back();
      return ot;
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
      return null;
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
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _alreadySaved
                            ? 'Este es el detalle de tu ${widget.isEmergency ? "breaking news" : "tarea"}'
                            : 'Ingresa la descripción de tu ${widget.isEmergency ? "breaking news" : "tarea"}',
                        style: Get.textTheme.headline3,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(width: 30),
                  ],
                ),
              ),
              Container(height: 20),
              if (!widget.isEmergency && !_alreadySaved)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 130,
                  child: Row(
                    children: [
                      Expanded(
                        child: TypeSelectorCard(
                          text: widget.ot.isEmbarque
                              ? _embarqueTaskCategories[0]
                              : _inspeccionTaskCategories[0],
                          icon: SvgPicture.asset(
                            "assets/images/complete_progress.svg",
                            semanticsLabel: 'Inicio de progreso',
                            color: Get.theme.colorScheme.secondary
                                .withOpacity(0.2),
                          ),
                          selected: widget.ot.isEmbarque
                              ? _taskCategory == _embarqueTaskCategories[0]
                              : _taskCategory == _inspeccionTaskCategories[0],
                          onTap: () {
                            if ((widget.ot.isEmbarque &&
                                    _taskCategory ==
                                        _embarqueTaskCategories[0]) ||
                                (!widget.ot.isEmbarque &&
                                    _taskCategory ==
                                        _inspeccionTaskCategories[0])) {
                              setState(() {
                                _selectedTask = null;
                                _taskCategory = null;
                              });
                            } else {
                              setState(() {
                                _selectedTask = null;
                                _taskCategory = widget.ot.isEmbarque
                                    ? _embarqueTaskCategories[0]
                                    : _inspeccionTaskCategories[0];
                              });
                            }
                          },
                        ),
                      ),
                      Container(width: 10),
                      Expanded(
                        child: TypeSelectorCard(
                          text: widget.ot.isEmbarque
                              ? _embarqueTaskCategories[1]
                              : _inspeccionTaskCategories[1],
                          icon: SvgPicture.asset(
                            "assets/images/half_progress.svg",
                            semanticsLabel: 'Mitad de progreso',
                            color: Get.theme.colorScheme.secondary,
                          ),
                          selected: widget.ot.isEmbarque
                              ? _taskCategory == _embarqueTaskCategories[1]
                              : _taskCategory == _inspeccionTaskCategories[1],
                          onTap: () {
                            if ((widget.ot.isEmbarque &&
                                    _taskCategory ==
                                        _embarqueTaskCategories[1]) ||
                                (!widget.ot.isEmbarque &&
                                    _taskCategory ==
                                        _inspeccionTaskCategories[1])) {
                              setState(() {
                                _selectedTask = null;
                                _taskCategory = null;
                              });
                            } else {
                              setState(() {
                                _selectedTask = null;
                                _taskCategory = widget.ot.isEmbarque
                                    ? _embarqueTaskCategories[1]
                                    : _inspeccionTaskCategories[1];
                              });
                            }
                          },
                        ),
                      ),
                      Container(width: 10),
                      Expanded(
                        child: TypeSelectorCard(
                          text: widget.ot.isEmbarque
                              ? _embarqueTaskCategories[2]
                              : _inspeccionTaskCategories[2],
                          icon: SvgPicture.asset(
                            "assets/images/complete_progress.svg",
                            semanticsLabel: 'Término de progreso',
                            color: Get.theme.colorScheme.secondary,
                          ),
                          selected: widget.ot.isEmbarque
                              ? _taskCategory == _embarqueTaskCategories[2]
                              : _taskCategory == _inspeccionTaskCategories[2],
                          onTap: () {
                            if ((widget.ot.isEmbarque &&
                                    _taskCategory ==
                                        _embarqueTaskCategories[2]) ||
                                (!widget.ot.isEmbarque &&
                                    _taskCategory ==
                                        _inspeccionTaskCategories[2])) {
                              setState(() {
                                _selectedTask = null;
                                _taskCategory = null;
                              });
                            } else {
                              setState(() {
                                _selectedTask = null;
                                _taskCategory = widget.ot.isEmbarque
                                    ? _embarqueTaskCategories[2]
                                    : _inspeccionTaskCategories[2];
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              if (!widget.isEmergency && !_alreadySaved) Container(height: 20),
              if (_taskCategory != null && !_alreadySaved)
                FutureBuilder(
                  future: _tasksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error.toString()}",
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return Center(
                        child: LoadingIndicator(),
                      );
                    } else {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selecciona detalle de la tarea',
                              style: Get.textTheme.bodyText1,
                            ),
                            Container(height: 5),
                            FormField<Task>(
                              builder: (FormFieldState<Task?> state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                    hintText: "Selecciona la tarea realizada",
                                  ),
                                  isEmpty: _selectedTask == null,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: widget.isEmergency
                                            ? MainTheme.emergencyColor
                                            : Get.theme.primaryColor,
                                      ),
                                      value: _selectedTask?.id,
                                      isDense: true,
                                      onChanged: (String? taskId) {
                                        if (taskId != null) {
                                          setState(() {
                                            _selectedTask = _tasksByCategory
                                                .firstWhere((task) =>
                                                    task.id == taskId);
                                          });
                                        }
                                      },
                                      items: _tasksByCategory.map((Task task) {
                                        return DropdownMenuItem<String>(
                                          value: task.id,
                                          child:
                                              Text(task.name ?? "Sin nombre"),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(height: 15),
                          ],
                        ),
                      );
                    }
                  },
                ),
              if (_alreadySaved)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tarea',
                        style: Get.textTheme.bodyText1,
                      ),
                      Container(height: 5),
                      TextField(
                        controller: _taskTextController,
                        decoration: InputDecoration(
                          filled: _alreadySaved,
                        ),
                        enabled: !_alreadySaved,
                        readOnly: _alreadySaved,
                      ),
                      Container(height: 15),
                    ],
                  ),
                ),
              if (_selectedTask != null || _alreadySaved)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de actividad (DD/MM/AAAA)',
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
                                  color: widget.isEmergency
                                      ? MainTheme.emergencyColor
                                      : Get.theme.primaryColor,
                                ),
                                onPressed: _editable
                                    ? () async {
                                        DateTime? oldDate;
                                        try {
                                          oldDate =
                                              _dateTextController.text != ""
                                                  ? dateFormat.parse(
                                                      _dateTextController.text)
                                                  : null;
                                        } catch (e) {
                                          setState(() {
                                            _dateTextController.text = "";
                                          });
                                        }

                                        if (oldDate != null &&
                                            oldDate.isAfter(DateTime.now()
                                                .subtract(
                                                    Duration(days: 365))) &&
                                            oldDate.isBefore(DateTime.now()
                                                .add(Duration(days: 365)))) {
                                          DateTime? newDate =
                                              await showDatePicker(
                                            context: context,
                                            locale: Locale('es', 'ES'),
                                            firstDate: DateTime.now()
                                                .subtract(Duration(days: 365)),
                                            initialDate: oldDate,
                                            lastDate: DateTime.now()
                                                .add(Duration(days: 365)),
                                          );
                                          if (newDate != null) {
                                            setState(() {
                                              _dateTextController.text =
                                                  dateFormat.format(newDate);
                                            });
                                          }
                                        }
                                      }
                                    : null,
                              ),
                              filled: !_editable,
                            ),
                            keyboardType: TextInputType.datetime,
                            readOnly: !_editable,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Este campo es obligatorio";
                              }
                              bool isValidDate = true;
                              try {
                                DateTime date = dateFormat.parse(value);
                                if (!date.isAfter(DateTime.now()
                                    .subtract(Duration(days: 365)))) {
                                  return "La fecha no puede ser menor a 365 días a partir de hoy";
                                }
                                if (!date.isBefore(
                                    DateTime.now().add(Duration(days: 365)))) {
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
                      Container(height: 15),
                      Text(
                        'Hora de actividad (HH:MM de 24 hrs)',
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
                                  color: widget.isEmergency
                                      ? MainTheme.emergencyColor
                                      : Get.theme.primaryColor,
                                ),
                                onPressed: _editable
                                    ? () async {
                                        DateTime oldDate = DateTime.now();
                                        try {
                                          oldDate = timeFormat
                                              .parse(_timeTextController.text);
                                        } catch (e) {
                                          setState(() {
                                            _timeTextController.text = "";
                                          });
                                        }

                                        TimeOfDay? newTime =
                                            await showTimePicker(
                                          context: context,
                                          cancelText: 'Cancelar'.toUpperCase(),
                                          confirmText: 'Aceptar'.toUpperCase(),
                                          initialTime:
                                              TimeOfDay.fromDateTime(oldDate),
                                        );

                                        if (newTime != null) {
                                          DateTime now = new DateTime.now();
                                          DateTime newDate = DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                              newTime.hour,
                                              newTime.minute);
                                          setState(() {
                                            _timeTextController.text =
                                                timeFormat.format(newDate);
                                          });
                                        }
                                      }
                                    : null,
                              ),
                              filled: !_editable,
                            ),
                            inputFormatters: [
                              MaskedInputFormatter('##:##'),
                            ],
                            readOnly: !_editable,
                          ),
                        ),
                      ),
                      Container(height: 15),
                      if ((_selectedTask != null &&
                              _selectedTask!.tonIsRequired == true) ||
                          widget.activity?.ton != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'En toneladas',
                              style: Get.textTheme.bodyText1,
                            ),
                            Container(height: 5),
                            Stack(
                              children: [
                                TextFormField(
                                  controller: _tonTextController,
                                  inputFormatters: [
                                    MoneyInputFormatter(
                                      leadingSymbol: "",
                                      mantissaLength: 0,
                                      thousandSeparator:
                                          ThousandSeparator.Period,
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    filled: !_editable,
                                  ),
                                  readOnly: !_editable,
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
                            Container(height: 15),
                          ],
                        ),
                      Text(
                        'Creado por',
                        style: Get.textTheme.bodyText1,
                      ),
                      Container(height: 5),
                      TextField(
                        controller: _userTextController,
                        enabled: !_alreadySaved,
                        decoration: InputDecoration(
                          hintText: "Usuario",
                          filled: true,
                          suffixIcon: Icon(
                            Icons.person_rounded,
                            color: widget.isEmergency
                                ? MainTheme.emergencyColor
                                : Get.theme.primaryColor,
                          ),
                        ),
                        textCapitalization: TextCapitalization.none,
                        readOnly: true,
                      ),
                      Container(height: 15),
                      Text(
                        'Observaciones',
                        style: Get.textTheme.bodyText1,
                      ),
                      Container(height: 5),
                      TextField(
                        controller: _descripionTextController,
                        decoration: InputDecoration(
                          hintText: "Ingresa la observación...",
                          filled: !_editable,
                        ),
                        readOnly: !_editable,
                        maxLines: 5,
                      ),
                      Container(height: 15),
                      if (!_alreadySaved)
                        Text(
                          'Subir imágenes',
                          style: Get.textTheme.bodyText1,
                        ),
                      if (!_alreadySaved) Container(height: 5),
                      if (!_alreadySaved)
                        ImagesInput(
                          color: widget.isEmergency
                              ? MainTheme.emergencyColor
                              : Get.theme.primaryColor,
                          onImage: (images) {
                            setState(() {
                              _images = images;
                            });
                          },
                        ),
                      if (_alreadySaved &&
                          _activity.images != null &&
                          _activity.images!.isNotEmpty)
                        Container(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              log(_activity.images.toString());
                              String imageUrl = _activity.images![i];
                              return Container(
                                height: 80,
                                width: 80,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DefaultNetworkImage(
                                  url: imageUrl,
                                ),
                              );
                            },
                            separatorBuilder: (context, i) =>
                                Container(width: 15),
                            itemCount: _activity.images?.length ?? 0,
                          ),
                        ),
                      if (_editable) Container(height: 30),
                      if (_editable)
                        OutlinedButton(
                          child: Text(widget.isEmergency
                              ? "Guardar y dar aviso".toUpperCase()
                              : "Guardar cambios".toUpperCase()),
                          style: widget.isEmergency
                              ? ButtonStyle(
                                  side: MaterialStateProperty.all(
                                    BorderSide(
                                      color: widget.isEmergency
                                          ? MainTheme.emergencyColor
                                          : Get.theme.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  foregroundColor: MaterialStateProperty.all(
                                      MainTheme.emergencyColor),
                                )
                              : ButtonStyle(),
                          onPressed: () async {
                            bool requireTon = (_selectedTask != null &&
                                    _selectedTask!.tonIsRequired == true) ||
                                widget.activity?.ton != null;
                            if (requireTon && _tonTextController.text.isEmpty) {
                              Get.snackbar(
                                "Faltan datos",
                                "Debe ingresar las toneladas",
                                margin: EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 20),
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Get.theme.primaryColor,
                                colorText: Colors.white,
                                snackStyle: SnackStyle.FLOATING,
                              );
                            } else {
                              if (widget.isEmergency) {
                                Get.dialog(
                                  ActionDialog(
                                    title: "¿Estás seguro de dar aviso?",
                                    confirmText: "Enviar",
                                    onConfirm: () async {
                                      Ot? ot = await _saveActivity();
                                      if (ot != null) {
                                        Get.back();
                                        bool hasInternetConnection =
                                            await ActivityService
                                                .checkInternetConnection();
                                        await Get.dialog(
                                          MessageDialog(
                                            text: hasInternetConnection
                                                ? "Aviso enviado con éxito"
                                                : "No tienes internet, se enviara el aviso cuando se sincronicen las actividades",
                                            icon: Icon(
                                              hasInternetConnection
                                                  ? Icons.check_circle
                                                  : Icons.info,
                                              color: hasInternetConnection
                                                  ? Colors.green
                                                  : Get.theme.primaryColor,
                                              size: 48,
                                            ),
                                            autoCloseAfter:
                                                Duration(seconds: 3),
                                          ),
                                        );
                                        Get.back(result: ot);
                                      }
                                    },
                                    onCancel: () {
                                      Get.back();
                                    },
                                  ),
                                );
                              } else {
                                Ot? ot = await _saveActivity();
                                if (ot != null) {
                                  Get.back(result: ot);
                                }
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ),
              Container(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
