import 'package:entity_mapper/entity_mapper.dart';
import 'package:test/test.dart';

import '../entities/entities.dart';

part 'nullability_test.entity_mapper.dart';

@MapToEntity(Address)
class AddressModel with AddressEntityMappable {
  const AddressModel({required this.street, required this.city});

  final String street;
  final String city;
}

/// Every field optional + nullable.
@MapToEntity(NullablePerson)
class NullablePersonModel with NullablePersonEntityMappable {
  const NullablePersonModel({this.id, this.name, this.age, this.address});

  final String? id;
  final String? name;
  final int? age;
  final AddressModel? address;
}

/// `required` on parameters but field types are nullable.
@MapToEntity(UserMaybeAddress)
class UserMaybeAddressModel with UserMaybeAddressEntityMappable {
  const UserMaybeAddressModel({
    required this.id,
    required this.name,
    this.address,
  });

  final String id;
  final String name;
  final AddressModel? address;
}

@MapToEntity(UserMaybeAddresses)
class UserMaybeAddressesModel with UserMaybeAddressesEntityMappable {
  const UserMaybeAddressesModel({required this.id, this.addresses});

  final String id;
  final List<AddressModel>? addresses;
}

void main() {
  group('Nullable primitive fields', () {
    test('null values stay null through entity → model', () {
      const entity = NullablePerson();
      final model = NullablePersonEntityMapper.toModel(entity);
      expect(model.id, isNull);
      expect(model.name, isNull);
      expect(model.age, isNull);
      expect(model.address, isNull);
    });

    test('non-null values flow through unchanged', () {
      const entity = NullablePerson(id: 'x', name: 'y', age: 30);
      final model = NullablePersonEntityMapper.toModel(entity);
      expect(model.id, 'x');
      expect(model.name, 'y');
      expect(model.age, 30);
    });

    test('mixed null + non-null are preserved independently', () {
      const entity = NullablePerson(id: 'x', age: 40);
      final model = NullablePersonEntityMapper.toModel(entity);
      expect(model.id, 'x');
      expect(model.name, isNull);
      expect(model.age, 40);
    });
  });

  group('Nullable nested model (FooModel?)', () {
    test('null nested model survives entity → model', () {
      const entity = UserMaybeAddress(id: 'u1', name: 'a');
      final model = UserMaybeAddressEntityMapper.toModel(entity);
      expect(model.address, isNull);
    });

    test('non-null nested model is mapped', () {
      const entity = UserMaybeAddress(
        id: 'u1',
        name: 'a',
        address: Address(street: 'X', city: 'Y'),
      );
      final model = UserMaybeAddressEntityMapper.toModel(entity);
      expect(model.address, isNotNull);
      expect(model.address!.street, 'X');
      expect(model.address!.city, 'Y');
    });

    test('null survives model → entity', () {
      const model = UserMaybeAddressModel(id: 'u1', name: 'a');
      final back = model.toEntity();
      expect(back.address, isNull);
    });

    test('non-null survives model → entity', () {
      const model = UserMaybeAddressModel(
        id: 'u1',
        name: 'a',
        address: AddressModel(street: 'X', city: 'Y'),
      );
      final back = model.toEntity();
      expect(back.address, isNotNull);
      expect(back.address!.street, 'X');
    });
  });

  group('Nullable list (List<FooModel>?)', () {
    test('null list survives entity → model (regression: 0.5.0 fix)', () {
      const entity = UserMaybeAddresses(id: 'u1');
      final model = UserMaybeAddressesEntityMapper.toModel(entity);
      expect(model.addresses, isNull);
    });

    test('populated list maps each element', () {
      const entity = UserMaybeAddresses(
        id: 'u1',
        addresses: [Address(street: 'A', city: 'B')],
      );
      final model = UserMaybeAddressesEntityMapper.toModel(entity);
      expect(model.addresses, isNotNull);
      expect(model.addresses, hasLength(1));
      expect(model.addresses!.first.street, 'A');
    });

    test('null survives model → entity', () {
      const model = UserMaybeAddressesModel(id: 'u1');
      final back = model.toEntity();
      expect(back.addresses, isNull);
    });

    test('round-trip null and non-null both stable', () {
      const populated = UserMaybeAddresses(
        id: 'u1',
        addresses: [Address(street: 'A', city: 'B')],
      );
      final restored = UserMaybeAddressesEntityMapper.toModel(
        populated,
      ).toEntity();
      expect(restored.addresses, isNotNull);
      expect(restored.addresses!.first.street, 'A');
    });
  });
}
