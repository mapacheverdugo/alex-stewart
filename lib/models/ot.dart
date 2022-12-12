import 'package:asi/models/activity.dart';
import 'package:asi/models/service_type.dart';
import 'package:asi/services/ot_service.dart';
import 'package:intl/intl.dart';

enum OtType { embarque, inspeccion }

class Ot {
  static const String EMBARQUE_TYPE = "Embarque";
  static const String INSPECCION_TYPE = "Inspección";

  String? id;
  String? otNumber;
  OtType? otType;
  String? placeShip;
  String? instructions;
  String? clientReference;
  num? ton;
  num? balance;
  num? totalInspected;
  DateTime? totalInspectedDate;
  List<Client>? clients;
  List<Product>? products;
  List<Activity>? activities;
  ServiceType? serviceType;

  Ot({
    this.id,
    this.otNumber,
    this.otType,
    this.placeShip,
    this.clientReference,
    this.ton,
    this.balance,
    this.instructions,
    this.totalInspected,
    this.totalInspectedDate,
    this.clients,
    this.products,
    this.activities,
    this.serviceType,
  });

  String get clientsString {
    if (this.clients != null && this.clients!.isNotEmpty) {
      return this.clients!.map((client) => client.name).join(', ');
    }
    return "Sin cliente";
  }

  String get tonString {
    if (this.ton != null) {
      return this.ton!.toStringAsFixed(0) + " Toneladas";
    }
    return "N/A";
  }

  bool get isPinned {
    List<Ot> pinnedOts = OtService.getPinnedOts();
    if (pinnedOts.isNotEmpty) {
      List<Ot> coincidences =
          pinnedOts.where((pinnedOt) => pinnedOt.id == this.id).toList();
      return coincidences.isNotEmpty;
    }

    return false;
  }

  bool get isEmbarque {
    return this.otType == OtType.embarque;
  }

  bool get isInspeccion {
    return this.otType == OtType.inspeccion;
  }

  String? get otTypeString {
    if (this.otType == OtType.embarque) {
      return EMBARQUE_TYPE;
    } else if (this.otType == OtType.inspeccion) {
      return INSPECCION_TYPE;
    }
    return null;
  }

  factory Ot.fromJson(dynamic json) {
    if (json is Map) {
      return Ot(
        id: json["_id"],
        otNumber: json["otNumber"],
        otType: json["otType"] == EMBARQUE_TYPE
            ? OtType.embarque
            : (json["otType"] == INSPECCION_TYPE ? OtType.inspeccion : null),
        instructions: json["instructions"],
        placeShip: json["placeShip"],
        clientReference: json["clientReference"],
        ton: json["ton"],
        balance: json["balance"],
        totalInspected: json["totalInspected"],
        totalInspectedDate: json["totalInspectedDate"] != null
            ? DateFormat('dd/MM/yyyy HH:mm').parse(json["totalInspectedDate"])
            : null,
        clients: Client.fromJsonList(json["clients"]),
        products: Product.fromJsonList(json["products"]),
        activities: Activity.fromJsonList(json["activities"]),
        serviceType: json["serviceType"] != null
            ? ServiceType.fromJson(json["serviceType"])
            : null,
      );
    } else {
      return Ot(
        id: json,
      );
    }
  }

  static List<Ot> fromJsonList(dynamic json) {
    if (json == null) {
      return [];
    }
    List<Ot> list = [];
    for (var item in json) {
      list.add(Ot.fromJson(item));
    }
    return list;
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "otNumber": otNumber,
        "otType": otTypeString,
        "placeShip": placeShip,
        "instructions": instructions,
        "clientReference": clientReference,
        "ton": ton,
        "balance": balance,
        "totalInspected": totalInspected,
        "totalInspectedDate": totalInspectedDate != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(totalInspectedDate!)
            : null,
        "clients": clients?.map((e) => e.toJson()).toList(),
        "products": products?.map((e) => e.toJson()).toList(),
        "activities": activities?.map((e) => e.toJson()).toList(),
        "serviceType": serviceType?.toJson(),
      };
}

class Client {
  String? id;
  String? name;

  Client({this.id, this.name});

  factory Client.fromJson(dynamic json) {
    if (json is Map) {
      return Client(
        id: json["_id"],
        name: json["name"],
      );
    } else {
      return Client(
        id: json,
      );
    }
  }

  static List<Client> fromJsonList(dynamic json) {
    if (json == null) {
      return [];
    }
    List<Client> list = [];
    for (var item in json) {
      list.add(Client.fromJson(item));
    }
    return list;
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}

class Product {
  String? id;
  String? name;

  Product({this.id, this.name});

  factory Product.fromJson(dynamic json) {
    if (json is Map) {
      return Product(
        id: json["_id"],
        name: json["name"],
      );
    } else {
      return Product(
        id: json,
      );
    }
  }

  static List<Product> fromJsonList(dynamic json) {
    if (json == null) {
      return [];
    }
    List<Product> list = [];
    for (var item in json) {
      list.add(Product.fromJson(item));
    }
    return list;
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}
