import 'package:entity_mapper/entity_mapper.dart';
import 'package:test/test.dart';

import '../entities/entities.dart';

part 'basic_mapping_test.entity_mapper.dart';

@MapToEntity(Dummy)
class DummyModel with DummyEntityMappable {
  const DummyModel();
}

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

@MapToEntity(Profile)
class ProfileModel with ProfileEntityMappable {
  const ProfileModel({
    required this.id,
    required this.email,
    required this.isVerified,
    required this.score,
    required this.joinedAt,
  });

  final String id;
  final String email;
  final bool isVerified;
  final double score;
  final DateTime joinedAt;
}

void main() {
  group('Empty class', () {
    test('Dummy ↔ DummyModel constructs without arguments', () {
      const model = DummyModel();
      final entity = model.toEntity();
      expect(entity, isA<Dummy>());

      final back = DummyEntityMapper.toModel(entity);
      expect(back, isA<DummyModel>());
    });
  });

  group('Single class with three primitive fields', () {
    const user = User(id: 'u1', name: 'Alice', age: 30);

    test('toModel preserves every field', () {
      final model = UserEntityMapper.toModel(user);
      expect(model.id, 'u1');
      expect(model.name, 'Alice');
      expect(model.age, 30);
    });

    test('toEntity preserves every field', () {
      const model = UserModel(id: 'u2', name: 'Bob', age: 25);
      final entity = UserEntityMapper.toEntity(model);
      expect(entity.id, 'u2');
      expect(entity.name, 'Bob');
      expect(entity.age, 25);
    });

    test('round-trip via mixin preserves values', () {
      final roundTripped = UserEntityMapper.toModel(user).toEntity();
      expect(roundTripped.id, user.id);
      expect(roundTripped.name, user.name);
      expect(roundTripped.age, user.age);
    });
  });

  group('Multiple primitive types in one entity', () {
    test('String, int, double, bool, DateTime all survive a round-trip', () {
      final profile = Profile(
        id: 'p1',
        email: 'alice@example.com',
        isVerified: true,
        score: 4.75,
        joinedAt: DateTime.utc(2026, 5, 10, 12, 30),
      );
      final restored = ProfileEntityMapper.toModel(profile).toEntity();
      expect(restored.id, profile.id);
      expect(restored.email, profile.email);
      expect(restored.isVerified, profile.isVerified);
      expect(restored.score, profile.score);
      expect(restored.joinedAt, profile.joinedAt);
    });

    test('false booleans and zero numerics are preserved (not defaulted)', () {
      final profile = Profile(
        id: 'p2',
        email: '',
        isVerified: false,
        score: 0,
        joinedAt: DateTime.utc(2026, 1, 2),
      );
      final restored = ProfileEntityMapper.toModel(profile).toEntity();
      expect(restored.isVerified, isFalse);
      expect(restored.score, 0.0);
      expect(restored.email, '');
    });
  });
}
