class ProfileUpdateRequestModel {
  final String? firstName;
  final String? secondName;
  final String? lastName;
  final String? secondLastName;
  final String? phone;
  final String? photoUrl;

  const ProfileUpdateRequestModel({
    this.firstName,
    this.secondName,
    this.lastName,
    this.secondLastName,
    this.phone,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        if (firstName != null) 'first_name': firstName,
        if (secondName != null) 'second_name': secondName,
        if (lastName != null) 'last_name': lastName,
        if (secondLastName != null) 'second_last_name': secondLastName,
        if (phone != null) 'phone': phone,
        if (photoUrl != null) 'photo_url': photoUrl,
      };
}
