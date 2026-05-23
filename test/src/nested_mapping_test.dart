import 'package:entity_mapper/entity_mapper.dart';
import 'package:test/test.dart';

import '../entities/entities.dart';

part 'nested_mapping_test.entity_mapper.dart';

@MapToEntity(Address)
class AddressModel with AddressEntityMappable {
  const AddressModel({required this.street, required this.city});

  final String street;
  final String city;
}

@MapToEntity(UserWithAddress)
class UserWithAddressModel with UserWithAddressEntityMappable {
  const UserWithAddressModel({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final AddressModel address;
}

void main() {
  group('Non-list nested model', () {
    const entity = UserWithAddress(
      id: 'u1',
      name: 'Alice',
      address: Address(street: 'Main', city: 'Metropolis'),
    );

    test('toModel converts a nested entity into a nested model', () {
      final model = UserWithAddressEntityMapper.toModel(entity);
      expect(model.address, isA<AddressModel>());
      expect(model.address.street, 'Main');
      expect(model.address.city, 'Metropolis');
    });

    test('toEntity converts a nested model back to a nested entity', () {
      const model = UserWithAddressModel(
        id: 'u2',
        name: 'Bob',
        address: AddressModel(street: 'Oak', city: 'Gotham'),
      );
      final back = model.toEntity();
      expect(back.address, isA<Address>());
      expect(back.address.street, 'Oak');
      expect(back.address.city, 'Gotham');
    });

    test('round-trip preserves nested values', () {
      final back = UserWithAddressEntityMapper.toModel(entity).toEntity();
      expect(back.address.street, entity.address.street);
      expect(back.address.city, entity.address.city);
    });
  });
}
