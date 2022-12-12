import 'package:asi/icons/asi_icons.dart';
import 'package:asi/models/api_error.dart';
import 'package:asi/screens/password_recovery_change_screen.dart';
import 'package:asi/services/user_service.dart';
import 'package:asi/themes/theme.dart';
import 'package:asi/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PasswordRecoveryEmailScreen extends StatefulWidget {
  PasswordRecoveryEmailScreen({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryEmailScreenState createState() =>
      _PasswordRecoveryEmailScreenState();
}

class _PasswordRecoveryEmailScreenState
    extends State<PasswordRecoveryEmailScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  _sendEmail() async {
    try {
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false,
      );
      await UserService.passwordRecoverySendEmail(_emailController.text);
      Get.back();
      Get.to(() => PasswordRecoveryChangeScreen());
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
                        'Ingresa el correo registrado',
                        style: Get.textTheme.subtitle2,
                      ),
                      Container(height: 45),
                      Text(
                        'Correo electrónico',
                        style: Get.textTheme.bodyText1,
                      ),
                      Container(height: 5),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Ingresa tu correo electrónico",
                          prefixIcon: Icon(
                            ASiIcons.mail,
                            color: Get.theme.primaryColor,
                            size: 20,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                      ),
                      Container(height: 45),
                      TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _sendEmail();
                          }
                        },
                        child: Text("Continuar".toUpperCase()),
                      ),
                      Container(height: 15),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            MainTheme.primaryColor,
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: Text("Volver al inicio de sesión"),
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
