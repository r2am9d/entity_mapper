import 'package:entity_mapper/entity_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import '../index.dart';

part 'entity_model_map_unit_test.entity_mapper.dart';

@MapToEntity(Dummy)
class DummyModel with DummyEntityMappable {
  @override
  String toString() => 'DummyModel';
}

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

  @override
  String toString() => 'UserModel';
}

@MapToEntity(Address)
class AddressModel with AddressEntityMappable {
  const AddressModel({
    required this.street,
    required this.city,
  });

  final String street;
  final String city;

  @override
  String toString() => 'AddressModel';
}

void main() {
  group('Entity ↔ Model Map', () {
    test('UserModel maps to User entity and back', () {
      const addressModel = AddressModel(street: 'Main St', city: 'Metropolis');
      const userModel = UserModel(
        id: 'u1',
        name: 'Alice',
        age: 30,
        addresses: [addressModel],
      );

      // Model to Entity
      final userEntity = userModel.toEntity();
      expect(userEntity, isA<User>());
      expect(userEntity.id, userModel.id);
      expect(userEntity.name, userModel.name);
      expect(userEntity.age, userModel.age);
      expect(userEntity.addresses.length, 1);
      expect(userEntity.addresses.first.street, addressModel.street);

      // Entity to Model
      final userModel2 = UserEntityMapper.toModel(userEntity);
      expect(userModel2, isA<UserModel>());
      expect(userModel2.id, userEntity.id);
      expect(userModel2.name, userEntity.name);
      expect(userModel2.age, userEntity.age);
      expect(userModel2.addresses.length, 1);
      expect(userModel2.addresses.first.city, addressModel.city);
    });

    test('AddressModel maps to Address entity and back', () {
      const addressModel = AddressModel(street: 'Elm St', city: 'Gotham');
      final addressEntity = addressModel.toEntity();
      expect(addressEntity, isA<Address>());
      expect(addressEntity.street, addressModel.street);
      expect(addressEntity.city, addressModel.city);

      final addressModel2 = AddressEntityMapper.toModel(addressEntity);
      expect(addressModel2, isA<AddressModel>());
      expect(addressModel2.street, addressEntity.street);
      expect(addressModel2.city, addressEntity.city);
    });

    test('DummyModel maps to Dummy entity', () {
      final dummyModel = DummyModel();
      final dummyEntity = dummyModel.toEntity();
      expect(dummyEntity, isA<Dummy>());
    });

    test('Handles nullability in UserModel', () {
      const userModel = UserModel(
        id: 'u2',
        addresses: [],
      );
      final userEntity = userModel.toEntity();
      expect(userEntity.name, isNull);
      expect(userEntity.age, isNull);

      final userModel2 = UserEntityMapper.toModel(userEntity);
      expect(userModel2.name, isNull);
      expect(userModel2.age, isNull);
    });
  });
}
