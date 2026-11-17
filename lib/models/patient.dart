class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.cpf,
    required this.phone,
    required this.birthDate,
    required this.dentistId,
    required this.dentistName,
    this.notes,
  });

  final String id;
  final String name;
  final String cpf;
  final String phone;
  final DateTime birthDate;
  final String dentistId;
  final String dentistName;
  final String? notes;

  factory Patient.fromMap(Map<String, Object?> map) => Patient(
    id: map['Id']! as String,
    name: map['Nome']! as String,
    cpf: map['CPF']! as String,
    phone: map['Telefone']! as String,
    birthDate: DateTime.parse(map['DataNascimento']! as String),
    dentistId: map['DentistaResponsavelId']! as String,
    dentistName: map['DentistaNome']! as String,
    notes: map['Observacoes'] as String?,
  );
}

class PatientInput {
  const PatientInput({
    required this.name,
    required this.cpf,
    required this.phone,
    required this.birthDate,
    required this.dentistId,
    this.notes,
  });

  final String name;
  final String cpf;
  final String phone;
  final DateTime birthDate;
  final String dentistId;
  final String? notes;
}
