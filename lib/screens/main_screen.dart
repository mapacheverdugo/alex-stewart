import 'package:asi/icons/asi_icons.dart';
import 'package:asi/models/ot.dart';
import 'package:asi/models/user.dart';
import 'package:asi/screens/login_screen.dart';
import 'package:asi/screens/ot_screen.dart';
import 'package:asi/screens/setup_ot_service_screen.dart';
import 'package:asi/screens/setup_ot_type_screen.dart';
import 'package:asi/services/ot_service.dart';
import 'package:asi/services/user_service.dart';
import 'package:asi/widgets/action_dialog.dart';
import 'package:asi/widgets/loading_indicator.dart';
import 'package:asi/widgets/ot_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  final User user;

  MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<Ot>> _otsFuture;
  late Future<List<Ot>> _pinnedOtsFuture;
  List<Ot> _ots = [];
  List<Ot> _pinnedOts = [];

  TextEditingController _otTextEditingController = TextEditingController();
  SuggestionsBoxController _otSuggestionsController =
      SuggestionsBoxController();

  @override
  void initState() {
    super.initState();
    _otsFuture = _searchOts();
    _pinnedOtsFuture = _getPinnedOts();
  }

  Future<List<Ot>> _searchOts([String? query]) async {
    List<Ot> ots = await OtService.searchOts(3, query);
    setState(() {
      _ots = ots;
    });
    return ots;
  }

  Future<List<Ot>> _getPinnedOts() async {
    List<Ot> ots = OtService.getPinnedOts();
    setState(() {
      _pinnedOts = ots;
    });
    return ots;
  }

  _navigateToOt(Ot ot) async {
    setState(() {
      _otTextEditingController.text = ot.otNumber!;
    });
    if (ot.otType == null) {
      Ot? newOt = await Get.to(
        () => SetupOtTypeScreen(
          ot: ot,
        ),
      );
      if (newOt != null) {
        await Get.to(
          () => OtScreen(
            ot: newOt,
          ),
        );
      }
    } else if (ot.isInspeccion && ot.serviceType == null) {
      Ot? newOt = await Get.to(
        () => SetupOtServiceScreen(
          ot: ot,
        ),
      );
      if (newOt != null) {
        await Get.to(
          () => OtScreen(
            ot: newOt,
          ),
        );
      }
    } else {
      await Get.to(
        () => OtScreen(
          ot: ot,
        ),
      );
    }

    _pinnedOts = await _getPinnedOts();
    _ots = await _searchOts();

    setState(() {
      _otTextEditingController.text = "";
    });
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola ${widget.user.name ?? ""}',
                          style: Get.textTheme.headline2,
                        ),
                        Text(
                          'Sucursal ${widget.user.office}',
                          style: Get.textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 20),
                  IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () async {
                      Get.dialog(
                        ActionDialog(
                          title: "¿Estás seguro que quieres cerrar sesión?",
                          confirmText: "Cerrar sesión",
                          onConfirm: () async {
                            await UserService.logOut();
                            Get.offAll(LoginScreen());
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
              Container(height: 20),
              Text(
                'Seleccionar OT',
                style: Get.textTheme.bodyText1,
              ),
              Container(height: 5),
              FutureBuilder<List<Ot>>(
                future: _otsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: LoadingIndicator(),
                    );
                  }
                  return Column(
                    children: [
                      TypeAheadField<Ot>(
                        textFieldConfiguration: TextFieldConfiguration(
                          decoration: InputDecoration(
                            hintText: "Selecciona tu OT",
                            prefixIcon: Icon(
                              ASiIcons.search,
                              color: Get.theme.primaryColor,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _otTextEditingController.text.isNotEmpty
                                    ? Icons.close
                                    : Icons.arrow_drop_down,
                                size: 20,
                              ),
                              onPressed: () {
                                if (_otTextEditingController.text.isNotEmpty) {
                                  setState(() {
                                    _otTextEditingController.text = "";
                                  });
                                }
                              },
                            ),
                          ),
                          controller: _otTextEditingController,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        suggestionsCallback: (pattern) async {
                          return _searchOts(pattern);
                        },
                        errorBuilder: (context, error) => Container(
                          height: 60,
                          child: Center(
                            child: Text("$error"),
                          ),
                        ),
                        loadingBuilder: (context) => Container(
                          height: 60,
                          child: Center(
                            child: LoadingIndicator(),
                          ),
                        ),
                        noItemsFoundBuilder: (context) => Container(
                          height: 60,
                          child: Center(
                            child: Text("No se encontraron coincidencias"),
                          ),
                        ),
                        suggestionsBoxController: _otSuggestionsController,
                        getImmediateSuggestions: true,
                        itemBuilder: (context, ot) {
                          int startMiddle = ot.otNumber!.toUpperCase().indexOf(
                              _otTextEditingController.text.toUpperCase());
                          int endMiddle = startMiddle +
                              _otTextEditingController.text.length;

                          return ListTile(
                            tileColor: Colors.white,
                            title: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                                children: startMiddle >= 0
                                    ? [
                                        TextSpan(
                                          text: ot.otNumber!
                                              .substring(0, startMiddle),
                                        ),
                                        TextSpan(
                                          text: ot.otNumber!.substring(
                                              startMiddle, endMiddle),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Get.theme.primaryColor,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ot.otNumber!.substring(
                                              endMiddle, ot.otNumber!.length),
                                        ),
                                      ]
                                    : [
                                        TextSpan(
                                          text: ot.otNumber!,
                                        ),
                                      ],
                              ),
                            ),
                          );
                        },
                        suggestionsBoxVerticalOffset: 10,
                        onSuggestionSelected: (ot) {
                          _navigateToOt(ot);
                        },
                      ),
                      Container(height: 30),
                      Divider(),
                      Container(height: 30),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'OTs guardadas',
                          style: Get.textTheme.headline3,
                        ),
                      ),
                      Container(height: 5),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Acá se muestran las OTs que guardaste',
                        ),
                      ),
                      Container(height: 20),
                      FutureBuilder<List<Ot>>(
                        future: _pinnedOtsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Center(
                              child: LoadingIndicator(),
                            );
                          }
                          if (_pinnedOts.isEmpty) {
                            return Container(
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
                                    'Aún no tienes OTs guardadas',
                                    style: Get.textTheme.headline3,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: _pinnedOts.length,
                              separatorBuilder: (context, i) =>
                                  Container(height: 10),
                              itemBuilder: (context, i) {
                                Ot ot = _ots.firstWhere(
                                    (e) => e.id == _pinnedOts[i].id);
                                return OtListTile(
                                  ot: ot,
                                  onPressed: () {
                                    _navigateToOt(ot);
                                  },
                                );
                              },
                            );
                          }
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
