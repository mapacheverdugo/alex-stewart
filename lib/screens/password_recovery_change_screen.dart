import 'package:asi/models/api_error.dart';
import 'package:asi/screens/login_screen.dart';
import 'package:asi/services/user_service.dart';
import 'package:asi/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PasswordRecoveryChangeScreen extends StatefulWidget {
  PasswordRecoveryChangeScreen({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryChangeScreenState createState() =>
      _PasswordRecoveryChangeScreenState();
}

class _PasswordRecoveryChangeScreenState
    extends State<PasswordRecoveryChangeScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _codeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  _sendCode() async {
    try {
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false,
      );
      await UserService.passwordRecoveryChangePassword(
          _codeController.text, _passwordController.text);
      Get.back();
      Get.offAll(() => LoginScreen());
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
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(height: 30),
                      Text(
                        'Recupera tu contraseña',
                        style: Get.textTheme.headline2,
                      ),
                      Container(height: 10),
                      Text(
                        'Hemos enviado un código al correo electrónico registrado. Copia y pega el código acá, e ingresa tu nueva contraseña',
                        style: Get.textTheme.subtitle2,
                      ),
                      Container(height: 45),
                      Text(
                        'Código de verificación',
                        style: Get.textTheme.bodyText1,
                      ),
                      Container(height: 5),
                      TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          hintText: "Ingresa el código",
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                      ),
                      Container(height: 10),
                      Text(
                        'Nueva contraseña',
                        style: Get.textTheme.bodyText1,
                      ),
                      Container(height: 5),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Ingresa tu contraseña",
                        ),
                      ),
                      Container(height: 10),
                      Text(
                        'Confirma tu contraseña',
                        style: Get.textTheme.bodyText1,
                      ),
                      Container(height: 5),
                      TextFormField(
                        controller: _passwordConfirmationController,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Ingresa tu contraseña",
                        ),
                      ),
                      Container(height: 45),
                      TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _sendCode();
                          }
                        },
                        child: Text("Continuar".toUpperCase()),
                      ),
                      Container(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
