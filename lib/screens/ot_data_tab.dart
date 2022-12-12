import 'package:asi/models/ot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';

class OtDataTab extends StatefulWidget {
  final Ot ot;
  final ValueNotifier<Ot>? otNotifier;
  OtDataTab({Key? key, required this.ot, this.otNotifier}) : super(key: key);

  @override
  _OtDataTabState createState() => _OtDataTabState();
}

class _OtDataTabState extends State<OtDataTab> {
  TextEditingController _serviceTypeTextController = TextEditingController();
  TextEditingController _clientsTextController = TextEditingController();
  TextEditingController _clientReferenceTextController =
      TextEditingController();
  TextEditingController _placeShipTextController = TextEditingController();
  TextEditingController _productTextController = TextEditingController();
  TextEditingController _tonTextController = TextEditingController();
  late Ot _ot;

  @override
  void initState() {
    super.initState();
    _setData(widget.ot);
    widget.otNotifier?.addListener(() {
      _setData(widget.otNotifier!.value);
    });
  }

  _setData(Ot ot) {
    if (ot.otType != null && ot.isEmbarque) {
      _clientsTextController = TextEditingController(text: ot.clientsString);
      _clientReferenceTextController =
          TextEditingController(text: ot.clientReference);
      _placeShipTextController = TextEditingController(text: ot.placeShip);
      _productTextController =
          TextEditingController(text: ot.products![0].name);
      _tonTextController = TextEditingController(
        text: toCurrencyString(
          ot.ton.toString(),
          leadingSymbol: "",
          mantissaLength: 0,
          thousandSeparator: ThousandSeparator.Period,
        ),
      );
    } else if (ot.otType != null && ot.isInspeccion) {
      _serviceTypeTextController =
          TextEditingController(text: ot.serviceType?.name);
      _clientsTextController = TextEditingController(text: ot.clientsString);
      _clientReferenceTextController =
          TextEditingController(text: ot.clientReference);
      _placeShipTextController = TextEditingController(text: ot.placeShip);
      _productTextController =
          TextEditingController(text: ot.products![0].name);
      _tonTextController = TextEditingController(
        text: toCurrencyString(
          ot.ton.toString(),
          leadingSymbol: "",
          mantissaLength: 0,
          thousandSeparator: ThousandSeparator.Period,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _ot = ot;
      });
    } else {
      _ot = ot;
    }
  }

  Widget get _inspeccionData {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tipo de servicio',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _serviceTypeTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Clientes',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _clientsTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Ref. Cliente',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _clientReferenceTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Lugar/Nave',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _placeShipTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Material',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _productTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Cantidad Nominación',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        Stack(
          children: [
            TextField(
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
      ],
    );
  }

  Widget get _embarqueData {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Clientes',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _clientsTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Ref. Cliente',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _clientReferenceTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Lugar/Nave',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _placeShipTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Material',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        TextField(
          controller: _productTextController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
          ),
        ),
        Container(height: 20),
        Text(
          'Cantidad Nominación',
          style: Get.textTheme.bodyText1,
        ),
        Container(height: 5),
        Stack(
          children: [
            TextField(
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(30),
          child: _ot.isEmbarque ? _embarqueData : _inspeccionData,
        ),
      ),
    );
  }
}
