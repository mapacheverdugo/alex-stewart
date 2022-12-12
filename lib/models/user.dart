class User {
  String? id;
  String? email;
  String? name;
  String? office;
  String? token;

  User({this.id, this.email, this.name, this.office, this.token});

  factory User.fromJson(dynamic json) {
    if (json is Map) {
      return User(
        id: json["id"] == null ? json["_id"] : json["id"],
        email: json["email"],
        name: json["name"],
        office: json["office"],
        token: json["token"],
      );
    } else {
      return User(
        id: json,
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "name": name,
        "office": office,
        "token": token,
      };
}
