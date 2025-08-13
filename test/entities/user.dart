class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.addresses,
  });

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final List<Address> addresses;
}

class Address {
  const Address({
    required this.street,
    required this.city,
    required this.zipCode,
  });

  final String street;
  final String city;
  final String zipCode;
}
