class SignUpBody {
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? password;
  String? confirmPassword;
  String? address;
  String? identificationType;
  String? identificationNumber;
  int? userType;

  SignUpBody(
      {this.fName,
      this.lName,
      this.phone,
      this.email = '',
      this.password,
      this.confirmPassword,
      this.userType});

  SignUpBody.fromJson(Map<String, dynamic> json) {
    fName = json['first_name'];
    lName = json['last_name'];
    phone = json['phone'];
    password = json['password'];
    confirmPassword = json['confirm_password'];
    userType = int.parse(json['user_type'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = fName;
    data['last_name'] = lName;
    data['phone'] = phone;
    data['password'] = password;
    data['confirm_password'] = confirmPassword;
    data['user_type'] = userType;
    return data;
  }
}
