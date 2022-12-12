import 'package:asi/icons/asi_icons.dart';
import 'package:asi/models/api_error.dart';
import 'package:asi/models/user.dart';
import 'package:asi/screens/main_screen.dart';
import 'package:asi/screens/password_recovery_email_screen.dart';
import 'package:asi/services/user_service.dart';
import 'package:asi/themes/theme.dart';
import 'package:asi/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    if (!bool.fromEnvironment('dart.vm.product')) {
      _emailController.text = "inspectortest@blanco-brand.com";
      _passwordController.text = "";
    }
  }

  _login() async {
    try {
      Get.dialog(
        LoadingDialog(),
        barrierDismissible: false,
      );
      User user = await UserService.login(
          _emailController.text, _passwordController.text);
      Get.back();
      Get.offAll(() => MainScreen(user: user));
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Stack(
          children: [
            Container(
              height: Get.mediaQuery.size.height * 0.3 + 40,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Image.asset(
                    "assets/images/login_bg.png",
                    fit: BoxFit.cover,
                  ),
                  SafeArea(
                    child: Container(
                      height: Get.mediaQuery.size.height * 0.25 - 40,
                      child: Image.asset(
                        "assets/images/isotipo.png",
                        height: Get.mediaQuery.size.height * 0.15,
                        width: Get.mediaQuery.size.height * 0.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.only(top: Get.mediaQuery.size.height * 0.25),
              child: SafeArea(
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
                                'Bienvenido Inspector ASi Statement of Fact',
                                style: Get.textTheme.headline2,
                                textAlign: TextAlign.center,
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
                              Container(height: 15),
                              Text(
                                'Contraseña',
                                style: Get.textTheme.bodyText1,
                              ),
                              Container(height: 5),
                              TextField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: InputDecoration(
                                  hintText: "Ingresa tu contraseña",
                                  prefixIcon: Icon(
                                    ASiIcons.lock,
                                    color: Get.theme.primaryColor,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Get.theme.primaryColor,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Container(height: 45),
                              TextButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _login();
                                  }
                                },
                                child: Text("Iniciar sesión".toUpperCase()),
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
                                  Get.to(PasswordRecoveryEmailScreen());
                                },
                                child: Text("¿Olvidaste tu contraseña?"),
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
            ),
          ],
        ),
      ),
    );
  }
}
