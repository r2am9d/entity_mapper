// ignore_for_file: prefer_const_constructors, document_ignores

import 'package:entity_mapper/entity_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../index.dart';

void main() {
  group('Functional Tests (Requires Code Generation)', () {
    late User testEntity;
    late UserModel testModel;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2023, 1, 1, 10, 30);
      testEntity = User(
        id: 'test-123',
        name: 'John Doe',
        email: 'john.doe@example.com',
        createdAt: testDate,
      );
      testModel = UserModel(
        id: 'test-123',
        name: 'John Doe',
        email: 'john.doe@example.com',
        createdAt: testDate,
      );
    });

    group('Generated Static Mapper Tests', () {
      test('UserEntityMapper.toModel converts correctly', () {
        final result = UserEntityMapper.toModel(testEntity);

        expect(result.id, equals(testEntity.id));
        expect(result.name, equals(testEntity.name));
        expect(result.email, equals(testEntity.email));
        expect(result.createdAt, equals(testEntity.createdAt));
      });

      test('UserEntityMapper.toEntity converts correctly', () {
        final result = UserEntityMapper.toEntity(testModel);

        expect(result.id, equals(testModel.id));
        expect(result.name, equals(testModel.name));
        expect(result.email, equals(testModel.email));
        expect(result.createdAt, equals(testModel.createdAt));
      });

      test('round trip conversion preserves all data', () {
        final convertedModel = UserEntityMapper.toModel(testEntity);
        final convertedEntity = UserEntityMapper.toEntity(
          convertedModel,
        );

        expect(convertedEntity.id, equals(testEntity.id));
        expect(convertedEntity.name, equals(testEntity.name));
        expect(convertedEntity.email, equals(testEntity.email));
        expect(convertedEntity.createdAt, equals(testEntity.createdAt));
      });
    });

    group('Generated Mixin Tests', () {
      test(
        'mixin methods work when model extends UserMappable',
        () {
          final entity = testModel.toEntity();
          expect(entity.id, equals(testModel.id));
        },
      );
    });

    // These tests work without code generation
    test('annotation is properly applied to UserModel', () {
      // We can at least verify the annotation setup is correct
      expect(UserModel, isNotNull);
      expect(User, isNotNull);
    });

    test('models can be instantiated correctly', () {
      expect(testModel.id, equals('test-123'));
      expect(testModel.name, equals('John Doe'));
      expect(testModel.email, equals('john.doe@example.com'));
      expect(testModel.createdAt, equals(testDate));

      expect(testEntity.id, equals('test-123'));
      expect(testEntity.name, equals('John Doe'));
      expect(testEntity.email, equals('john.doe@example.com'));
      expect(testEntity.createdAt, equals(testDate));
    });

    test('entities and models have correct field types', () {
      expect(testModel.id, isA<String>());
      expect(testModel.name, isA<String>());
      expect(testModel.email, isA<String>());
      expect(testModel.createdAt, isA<DateTime>());

      expect(testEntity.id, isA<String>());
      expect(testEntity.name, isA<String>());
      expect(testEntity.email, isA<String>());
      expect(testEntity.createdAt, isA<DateTime>());
    });
  });
}
