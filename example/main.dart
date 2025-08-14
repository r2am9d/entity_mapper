import 'package:entity_mapper/entity_mapper.dart';

// Domain Entities
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
}

class Address {
  const Address({
    required this.street,
    required this.city,
  });

  final String street;
  final String city;
}

// Data Models
@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({
    required this.id,
    this.name,
    this.age,
    required this.addresses,
  });

  final String id;
  final String? name;
  final int? age;
  final List<AddressModel> addresses;
}

@MapToEntity(Address)
class AddressModel with AddressEntityMappable {
  const AddressModel({
    required this.street,
    required this.city,
  });

  final String street;
  final String city;
}

void main() {
  // Create a model
  const addressModel = AddressModel(street: 'Main St', city: 'Metropolis');
  const userModel = UserModel(
    id: 'u1',
    name: 'Alice',
    age: 30,
    addresses: [addressModel],
  );

  // Model to Entity
  final userEntity = userModel.toEntity();
  print(
    'UserModel → User entity: id=${userEntity.id}, name=${userEntity.name}, age=${userEntity.age}, addresses=${userEntity.addresses.map((a) => a.street).toList()}',
  );

  // Entity to Model
  final userModel2 = UserEntityMapper.toModel(userEntity);
  print(
    'User entity → UserModel: id=${userModel2.id}, name=${userModel2.name}, age=${userModel2.age}, addresses=${userModel2.addresses.map((a) => a.city).toList()}',
  );

  // Nullability example
  const userModelNull = UserModel(id: 'u2', addresses: []);
  final userEntityNull = userModelNull.toEntity();
  print('Null fields: name=${userEntityNull.name}, age=${userEntityNull.age}');
}
