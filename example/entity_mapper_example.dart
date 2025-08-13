// ignore_for_file: unused_import, undefined_class, undefined_identifier
import 'package:entity_mapper/entity_mapper.dart';

// Domain Entity (Pure)
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
}

// Data Model (w/ Data manipulation methods)
part 'user_model.entity_mapper.dart';

@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
}

// Usage example
void main() {
  // Create entity
  final user = User(
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    createdAt: DateTime.now(),
  );

  // Convert entity to model
  final userModel = UserEntityMapper.toModel(user);

  // Convert model to entity
  final userEntity1 = userModel.toEntity();
  final userEntity2 = UserEntityMapper.toEntity(userModel);

  print('Entity mapping example ready!');
  print('Entity: ${user.name}');
}
