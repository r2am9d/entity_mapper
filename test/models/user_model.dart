import 'package:entity_mapper/entity_mapper.dart';
import '../index.dart';

part 'user_model.entity_mapper.dart';

@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({
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
  final List<AddressModel> addresses;
}

@MapToEntity(Address)
class AddressModel with AddressEntityMappable {
  const AddressModel({
    required this.street,
    required this.city,
    required this.zipCode,
  });

  final String street;
  final String city;
  final String zipCode;
}
