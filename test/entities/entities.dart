// Pure-Dart domain entities used across the test suite.
//
// These classes are deliberately free of any framework or codegen dependency
// (no @MapToEntity, no dart_mappable annotations) — they represent what a
// real "domain layer" entity looks like under Clean Architecture rules.
// Test files declare their own model classes (annotated with @MapToEntity)
// that target these entities.

// ─────────────────────────────────────────────────────────────────────────
// Basic entities
// ─────────────────────────────────────────────────────────────────────────

/// Empty class — a model targeting Dummy should generate trivial mappers.
class Dummy {
  const Dummy();
}

class Address {
  const Address({required this.street, required this.city});

  final String street;
  final String city;
}

class Zip {
  const Zip({required this.code});

  final String code;
}

class User {
  const User({required this.id, required this.name, required this.age});

  final String id;
  final String name;
  final int age;
}

/// Multi-primitive entity exercising String, int, double, bool, DateTime.
class Profile {
  const Profile({
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

// ─────────────────────────────────────────────────────────────────────────
// Nested entities (non-list)
// ─────────────────────────────────────────────────────────────────────────

class UserWithAddress {
  const UserWithAddress({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final Address address;
}

class UserMaybeAddress {
  const UserMaybeAddress({required this.id, required this.name, this.address});

  final String id;
  final String name;
  final Address? address;
}

// ─────────────────────────────────────────────────────────────────────────
// List entities (primitives, nested, deeply nested, nullable)
// ─────────────────────────────────────────────────────────────────────────

class UserWithTags {
  const UserWithTags({required this.id, required this.tags});

  final String id;
  final List<String> tags;
}

class UserWithAddresses {
  const UserWithAddresses({required this.id, required this.addresses});

  final String id;
  final List<Address> addresses;
}

class AddressWithZips {
  const AddressWithZips({
    required this.street,
    required this.city,
    required this.zips,
  });

  final String street;
  final String city;
  final List<Zip> zips;
}

class UserMaybeAddresses {
  const UserMaybeAddresses({required this.id, this.addresses});

  final String id;
  final List<Address>? addresses;
}

// ─────────────────────────────────────────────────────────────────────────
// All-nullable / required-nullable / defaults
// ─────────────────────────────────────────────────────────────────────────

/// Every field optional and nullable. Lets a model construct with all-null.
class NullablePerson {
  const NullablePerson({this.id, this.name, this.age, this.address});

  final String? id;
  final String? name;
  final int? age;
  final Address? address;
}

/// `required` keyword on every parameter, but field types are nullable.
/// Used to verify that `required` and nullable are independent dimensions.
class RequiredNullable {
  const RequiredNullable({
    required this.id,
    required this.name,
    required this.age,
  });

  final String? id;
  final String? name;
  final int? age;
}

/// Entity with default values for optional parameters.
class WithDefaults {
  const WithDefaults({
    this.id = 'default-id',
    this.name = 'default-name',
    this.count = 0,
  });

  final String id;
  final String name;
  final int count;
}

// ─────────────────────────────────────────────────────────────────────────
// "Partial" entities: deliberately missing fields that some test models declare.
// Used to exercise the "model has fields the entity doesn't" code path —
// the generator must fail at codegen for non-nullable required, pass `null`
// for nullable required, and let optional fields use their defaults.
// ─────────────────────────────────────────────────────────────────────────

/// Entity has only id/name. Models targeting this may declare extra fields.
class PartialUser {
  const PartialUser({required this.id, required this.name});

  final String id;
  final String name;
}
