// domain/entities/user.dart
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

// data/models/user_model.dart
import 'package:entity_mapper/entity_mapper.dart';

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

void main() {
  // Create domain entity
  final user = User(
    id: '1337',
    name: 'John Doe',
    email: 'john.doe@example.com',
    createdAt: DateTime.now(),
  );
  
  // Convert entity to model (static method)
  final userModel = UserEntityMapper.toModel(user);
  
  // Convert model to entity (instance method)
  final userEntity = userModel.toEntity();
  
  // Convert model to entity (static method alternative)
  final userEntity2 = UserEntityMapper.toEntity(userModel);
}
