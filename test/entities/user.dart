class User {
  const User({
    required this.id,
    this.name,
    this.age,
    required this.addresses,
  });

  final String id;
  final String? name;
  final int? age;
  final List<Address> addresses;

  @override
  String toString() => 'User';
}

class Address {
  const Address({
    required this.street,
    required this.city,
  });

  final String street;
  final String city;

  @override
  String toString() => 'Address';
}
