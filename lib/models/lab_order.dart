enum OrderStatus {
  received,
  inProduction,
  adjustment,
  finished,
  delivered;

  String get label => switch (this) {
    OrderStatus.received => 'Recebido',
    OrderStatus.inProduction => 'Em produção',
    OrderStatus.adjustment => 'Em ajuste',
    OrderStatus.finished => 'Finalizado',
    OrderStatus.delivered => 'Entregue',
  };

  static OrderStatus fromDatabase(Object? value) {
    final index = value is int ? value : int.tryParse('$value');
    if (index == null || index < 0 || index >= values.length) {
      throw FormatException('Status de pedido inválido no banco: $value');
    }
    return values[index];
  }
}

class LabOrder {
  const LabOrder({
    required this.id,
    required this.number,
    required this.patientId,
    required this.patientName,
    required this.dentistId,
    required this.dentistName,
    required this.prosthesisType,
    required this.orderDate,
    required this.expectedDate,
    required this.value,
    required this.status,
    this.deliveryDate,
    this.notes,
  });

  final String id;
  final String number;
  final String patientId;
  final String patientName;
  final String dentistId;
  final String dentistName;
  final String prosthesisType;
  final DateTime orderDate;
  final DateTime expectedDate;
  final DateTime? deliveryDate;
  final double value;
  final OrderStatus status;
  final String? notes;

  factory LabOrder.fromMap(Map<String, Object?> map) => LabOrder(
    id: map['Id']! as String,
    number: map['NumeroPedido']! as String,
    patientId: map['PacienteId']! as String,
    patientName: map['PacienteNome'] as String? ?? 'Paciente removido',
    dentistId: map['DentistaId']! as String,
    dentistName: map['DentistaNome'] as String? ?? 'Dentista removido',
    prosthesisType: map['TipoProtese']! as String,
    orderDate: DateTime.parse(map['DataPedido']! as String),
    expectedDate: DateTime.parse(map['DataPrevista']! as String),
    deliveryDate: map['DataEntrega'] == null
        ? null
        : DateTime.parse(map['DataEntrega']! as String),
    value: (map['Valor']! as num).toDouble(),
    status: OrderStatus.fromDatabase(map['Status']),
    notes: map['Observacoes'] as String?,
  );
}

class LabOrderInput {
  const LabOrderInput({
    required this.number,
    required this.patientId,
    required this.dentistId,
    required this.prosthesisType,
    required this.expectedDate,
    required this.value,
    this.notes,
  });

  final String number;
  final String patientId;
  final String dentistId;
  final String prosthesisType;
  final DateTime expectedDate;
  final double value;
  final String? notes;
}
