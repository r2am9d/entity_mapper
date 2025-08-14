import 'package:entity_mapper/entity_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import '../index.dart';

part 'map_to_entity_unit_test.entity_mapper.dart';

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
  group('MapToEntity Annotation', () {
    test('can be instantiated with a valid type', () {
      const annotation = MapToEntity(Dummy);
      expect(annotation, isA<MapToEntity>());
    });

    test('entityType property returns correct type', () {
      const annotation = MapToEntity(Dummy);
      expect(annotation.entityType, Dummy);
    });

    test('can be used as a class annotation for DummyModel', () {
      final model = DummyModel();
      final annotations = model.toString();
      expect(annotations, contains('DummyModel'));
    });

    test('can be used as a class annotation for UserModel', () {
      const model = UserModel(id: '1', addresses: []);
      final annotations = model.toString();
      expect(annotations, contains('UserModel'));
    });

    test('can be used as a class annotation for AddressModel', () {
      const model = AddressModel(street: 'Main St', city: 'Metropolis');
      final annotations = model.toString();
      expect(annotations, contains('AddressModel'));
    });
  });
}
