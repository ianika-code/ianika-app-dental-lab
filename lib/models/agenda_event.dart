enum AgendaEventType {
  delivery('Entrega'),
  returnVisit('Retorno'),
  reminder('Lembrete');

  const AgendaEventType(this.label);

  final String label;

  static AgendaEventType fromDatabase(Object? value) {
    final index = value is int ? value : int.tryParse('$value');
    if (index == null || index < 0 || index >= values.length) {
      throw FormatException('Tipo de evento inválido no banco: $value');
    }
    return values[index];
  }
}

class AgendaEvent {
  const AgendaEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.dateTime,
    required this.completed,
    this.description,
    this.orderId,
    this.orderNumber,
    this.dentistId,
    this.dentistName,
  });

  final String id;
  final AgendaEventType type;
  final String title;
  final String? description;
  final DateTime dateTime;
  final String? orderId;
  final String? orderNumber;
  final String? dentistId;
  final String? dentistName;
  final bool completed;

  factory AgendaEvent.fromMap(Map<String, Object?> map) => AgendaEvent(
        id: map['Id']! as String,
        type: AgendaEventType.fromDatabase(map['Tipo']),
        title: map['Titulo']! as String,
        description: map['Descricao'] as String?,
        dateTime: DateTime.parse(map['DataHora']! as String),
        orderId: map['PedidoId'] as String?,
        orderNumber: map['PedidoNumero'] as String?,
        dentistId: map['DentistaId'] as String?,
        dentistName: map['DentistaNome'] as String?,
        completed: (map['Concluido']! as num).toInt() != 0,
      );
}

class AgendaEventInput {
  const AgendaEventInput({
    required this.type,
    required this.title,
    required this.dateTime,
    this.description,
    this.orderId,
    this.dentistId,
  });

  final AgendaEventType type;
  final String title;
  final String? description;
  final DateTime dateTime;
  final String? orderId;
  final String? dentistId;
}
