class Dentist {
  const Dentist({
    required this.id,
    required this.name,
    required this.cro,
    required this.phone,
    required this.email,
    required this.address,
    this.notes,
  });

  final String id;
  final String name;
  final String cro;
  final String phone;
  final String email;
  final String address;
  final String? notes;

  factory Dentist.fromMap(Map<String, Object?> map) => Dentist(
    id: map['Id']! as String,
    name: map['Nome']! as String,
    cro: map['CRO']! as String,
    phone: map['Telefone']! as String,
    email: map['Email']! as String,
    address: map['Endereco']! as String,
    notes: map['Observacoes'] as String?,
  );
}

class DentistInput {
  const DentistInput({
    required this.name,
    required this.cro,
    required this.phone,
    required this.email,
    required this.address,
    this.notes,
  });

  final String name;
  final String cro;
  final String phone;
  final String email;
  final String address;
  final String? notes;
}
