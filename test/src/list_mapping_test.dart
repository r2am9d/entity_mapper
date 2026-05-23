import 'package:entity_mapper/entity_mapper.dart';
import 'package:test/test.dart';

import '../entities/entities.dart';

part 'list_mapping_test.entity_mapper.dart';

@MapToEntity(UserWithTags)
class UserWithTagsModel with UserWithTagsEntityMappable {
  const UserWithTagsModel({required this.id, required this.tags});

  final String id;
  final List<String> tags;
}

@MapToEntity(Address)
class AddressModel with AddressEntityMappable {
  const AddressModel({required this.street, required this.city});

  final String street;
  final String city;
}

@MapToEntity(UserWithAddresses)
class UserWithAddressesModel with UserWithAddressesEntityMappable {
  const UserWithAddressesModel({required this.id, required this.addresses});

  final String id;
  final List<AddressModel> addresses;
}

@MapToEntity(Zip)
class ZipModel with ZipEntityMappable {
  const ZipModel({required this.code});

  final String code;
}

@MapToEntity(AddressWithZips)
class AddressWithZipsModel with AddressWithZipsEntityMappable {
  const AddressWithZipsModel({
    required this.street,
    required this.city,
    required this.zips,
  });

  final String street;
  final String city;
  final List<ZipModel> zips;
}

void main() {
  group('List<primitive>', () {
    test('passes through unchanged', () {
      const entity = UserWithTags(id: 'u1', tags: ['flutter', 'dart']);
      final model = UserWithTagsEntityMapper.toModel(entity);
      expect(model.tags, equals(['flutter', 'dart']));
    });

    test('empty list is preserved as empty', () {
      const entity = UserWithTags(id: 'u1', tags: []);
      final model = UserWithTagsEntityMapper.toModel(entity);
      expect(model.tags, isEmpty);
    });

    test('round-trip via mixin preserves order and values', () {
      const entity = UserWithTags(id: 'u1', tags: ['a', 'b', 'c']);
      final back = UserWithTagsEntityMapper.toModel(entity).toEntity();
      expect(back.tags, equals(['a', 'b', 'c']));
    });
  });

  group('List<NestedModel>', () {
    test('toModel maps each entity into its model counterpart', () {
      const entity = UserWithAddresses(
        id: 'u1',
        addresses: [
          Address(street: 'A', city: 'X'),
          Address(street: 'B', city: 'Y'),
        ],
      );
      final model = UserWithAddressesEntityMapper.toModel(entity);
      expect(model.addresses, hasLength(2));
      expect(model.addresses[0], isA<AddressModel>());
      expect(model.addresses[0].street, 'A');
      expect(model.addresses[1].city, 'Y');
    });

    test('toEntity maps each model back into an entity', () {
      const model = UserWithAddressesModel(
        id: 'u2',
        addresses: [AddressModel(street: 'C', city: 'Z')],
      );
      final back = model.toEntity();
      expect(back.addresses.single, isA<Address>());
      expect(back.addresses.single.street, 'C');
      expect(back.addresses.single.city, 'Z');
    });

    test('empty list is preserved', () {
      const entity = UserWithAddresses(id: 'u3', addresses: []);
      final model = UserWithAddressesEntityMapper.toModel(entity);
      expect(model.addresses, isEmpty);
    });
  });

  group('Deeply nested List<List<...>> equivalents', () {
    test('Address with a list of Zip nested mappings round-trip', () {
      const entity = AddressWithZips(
        street: 'Main',
        city: 'Metro',
        zips: [
          Zip(code: '111'),
          Zip(code: '222'),
          Zip(code: '333'),
        ],
      );
      final back = AddressWithZipsEntityMapper.toModel(entity).toEntity();
      expect(back.street, 'Main');
      expect(back.city, 'Metro');
      expect(back.zips.map((z) => z.code), equals(['111', '222', '333']));
    });
  });
}
