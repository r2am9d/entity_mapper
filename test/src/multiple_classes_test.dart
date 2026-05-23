import 'package:entity_mapper/entity_mapper.dart';
import 'package:test/test.dart';

import '../entities/entities.dart';

part 'multiple_classes_test.entity_mapper.dart';

@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({
    required this.id,
    required this.name,
    required this.age,
  });

  final String id;
  final String name;
  final int age;
}

@MapToEntity(Address)
class AddressModel with AddressEntityMappable {
  const AddressModel({required this.street, required this.city});

  final String street;
  final String city;
}

@MapToEntity(Zip)
class ZipModel with ZipEntityMappable {
  const ZipModel({required this.code});

  final String code;
}

@MapToEntity(Dummy)
class DummyModel with DummyEntityMappable {
  const DummyModel();
}

void main() {
  group('Multiple @MapToEntity classes in one file', () {
    test('each class gets its own working mapper', () {
      const userModel = UserModel(id: 'u1', name: 'Alice', age: 30);
      const addressModel = AddressModel(street: 'Main', city: 'Metro');
      const zipModel = ZipModel(code: '111');
      const dummyModel = DummyModel();

      // Every mixin's toEntity() resolves correctly.
      expect(userModel.toEntity(), isA<User>());
      expect(addressModel.toEntity(), isA<Address>());
      expect(zipModel.toEntity(), isA<Zip>());
      expect(dummyModel.toEntity(), isA<Dummy>());

      // Every static toModel resolves correctly.
      expect(
        UserEntityMapper.toModel(userModel.toEntity()),
        isA<UserModel>(),
      );
      expect(
        AddressEntityMapper.toModel(addressModel.toEntity()),
        isA<AddressModel>(),
      );
      expect(
        ZipEntityMapper.toModel(zipModel.toEntity()),
        isA<ZipModel>(),
      );
    });

    test('round-trips preserve every class independently', () {
      const userModel = UserModel(id: 'u1', name: 'Alice', age: 30);
      const addressModel = AddressModel(street: 'Main', city: 'Metro');

      final restoredUser = UserEntityMapper.toModel(userModel.toEntity());
      final restoredAddress = AddressEntityMapper.toModel(
        addressModel.toEntity(),
      );

      expect(restoredUser.id, 'u1');
      expect(restoredUser.name, 'Alice');
      expect(restoredUser.age, 30);
      expect(restoredAddress.street, 'Main');
      expect(restoredAddress.city, 'Metro');
    });
  });
}
