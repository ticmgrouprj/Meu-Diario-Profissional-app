class RegistroPressao {
  final String id;
  final String pacienteId;
  final String data; // YYYY-MM-DD
  final String hora; // HH:mm
  final String? periodo;
  final int sistolica;
  final int diastolica;

  const RegistroPressao({
    required this.id,
    required this.pacienteId,
    required this.data,
    required this.hora,
    this.periodo,
    required this.sistolica,
    required this.diastolica,
  });

  String get formatada => '$sistolica/$diastolica mmHg';

  DateTime get dateTime {
    try {
      final d = data.split('-');
      final h = hora.split(':');
      return DateTime(
        int.parse(d[0]),
        int.parse(d[1]),
        int.parse(d[2]),
        int.parse(h[0]),
        int.parse(h[1]),
      );
    } catch (_) {
      return DateTime.now();
    }
  }
}

class RegistroGlicemia {
  final String id;
  final String pacienteId;
  final String data; // YYYY-MM-DD
  final String hora; // HH:mm
  final String? periodo; // Jejum, Pós-prandial, etc.
  final int valor; // mg/dL

  const RegistroGlicemia({
    required this.id,
    required this.pacienteId,
    required this.data,
    required this.hora,
    this.periodo,
    required this.valor,
  });

  String get formatada => '$valor mg/dL';

  DateTime get dateTime {
    try {
      final d = data.split('-');
      final h = hora.split(':');
      return DateTime(
        int.parse(d[0]),
        int.parse(d[1]),
        int.parse(d[2]),
        int.parse(h[0]),
        int.parse(h[1]),
      );
    } catch (_) {
      return DateTime.now();
    }
  }
}

class RegistroPeso {
  final String id;
  final String pacienteId;
  final String data; // YYYY-MM-DD
  final double peso; // kg

  const RegistroPeso({
    required this.id,
    required this.pacienteId,
    required this.data,
    required this.peso,
  });

  String get formatada => '${peso.toStringAsFixed(1)} kg';

  DateTime get dateTime {
    try {
      final d = data.split('-');
      return DateTime(int.parse(d[0]), int.parse(d[1]), int.parse(d[2]));
    } catch (_) {
      return DateTime.now();
    }
  }
}

class HorarioMedicamento {
  final String id;
  final String hora; // "08:00", "20:00"
  final String? periodo;

  const HorarioMedicamento({
    required this.id,
    required this.hora,
    this.periodo,
  });
}

class MedicamentoPaciente {
  final String id;
  final String pacienteId;
  final String nome;
  final String? dosagem;
  final String? frequencia;
  final String? instrucoes;
  final List<HorarioMedicamento> horarios;
  final bool ativo;
  final double? adesaoPercentual; // 0..1

  const MedicamentoPaciente({
    required this.id,
    required this.pacienteId,
    required this.nome,
    this.dosagem,
    this.frequencia,
    this.instrucoes,
    this.horarios = const [],
    this.ativo = true,
    this.adesaoPercentual,
  });
}

class RegistroTomada {
  final String id;
  final String medicamentoId;
  final String medicamentoNome;
  final String? horarioId;
  final String data;
  final String? horaPrevista;
  final String horaTomada;
  final String status; // 'tomado' | 'atrasado' | 'esquecido'

  const RegistroTomada({
    required this.id,
    required this.medicamentoId,
    required this.medicamentoNome,
    this.horarioId,
    required this.data,
    this.horaPrevista,
    required this.horaTomada,
    required this.status,
  });
}
