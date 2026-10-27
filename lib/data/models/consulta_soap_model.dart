import 'paciente_model.dart';

class VitaisConsulta {
  final int? sistolica;
  final int? diastolica;
  final int? fc; // frequência cardíaca bpm
  final double? peso; // kg
  final int? glicemia; // mg/dL

  const VitaisConsulta({
    this.sistolica,
    this.diastolica,
    this.fc,
    this.peso,
    this.glicemia,
  });

  Map<String, dynamic> toJson() => {
    'sistolica': sistolica,
    'diastolica': diastolica,
    'fc': fc,
    'peso': peso,
    'glicemia': glicemia,
  };

  factory VitaisConsulta.fromJson(Map<String, dynamic> json) => VitaisConsulta(
    sistolica: json['sistolica'],
    diastolica: json['diastolica'],
    fc: json['fc'],
    peso: (json['peso'] as num?)?.toDouble(),
    glicemia: json['glicemia'],
  );
}

class ConsultaSOAP {
  final String id;
  final String pacienteId;
  final String profissionalId;
  final DateTime data;
  final String tipo; // 'presencial' | 'teleconsulta' | 'retorno'
  final String subjetivo; // Queixa principal, histórico da moléstia
  final String objetivo; // Exame físico, dados vitais
  final VitaisConsulta? vitais;
  final String avaliacao; // Raciocínio clínico
  final List<Diagnostico> hipoteses;
  final String plano; // Conduta terapêutica, metas
  final int? retornoEmDias;

  const ConsultaSOAP({
    required this.id,
    required this.pacienteId,
    required this.profissionalId,
    required this.data,
    required this.tipo,
    required this.subjetivo,
    required this.objetivo,
    this.vitais,
    required this.avaliacao,
    this.hipoteses = const [],
    required this.plano,
    this.retornoEmDias,
  });
}
