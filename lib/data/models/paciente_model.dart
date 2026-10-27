enum Sexo { m, f, o }

enum StatusRisco { critico, atencao, estavel }

class Diagnostico {
  final String codigoCid;
  final String descricao;

  const Diagnostico({
    required this.codigoCid,
    required this.descricao,
  });

  Map<String, dynamic> toJson() => {
    'codigoCid': codigoCid,
    'descricao': descricao,
  };

  factory Diagnostico.fromJson(Map<String, dynamic> json) => Diagnostico(
    codigoCid: json['codigoCid'] ?? '',
    descricao: json['descricao'] ?? '',
  );
}

class MetasClinicas {
  final double paSistolicaMax;
  final double paDiastolicaMax;
  final double glicemiaJejumMin;
  final double glicemiaJejumMax;
  final double glicemiaPosPrandialMax;
  final double? pesoMeta;

  const MetasClinicas({
    this.paSistolicaMax = 130,
    this.paDiastolicaMax = 80,
    this.glicemiaJejumMin = 70,
    this.glicemiaJejumMax = 100,
    this.glicemiaPosPrandialMax = 140,
    this.pesoMeta,
  });

  Map<String, dynamic> toJson() => {
    'paSistolicaMax': paSistolicaMax,
    'paDiastolicaMax': paDiastolicaMax,
    'glicemiaJejumMin': glicemiaJejumMin,
    'glicemiaJejumMax': glicemiaJejumMax,
    'glicemiaPosPrandialMax': glicemiaPosPrandialMax,
    'pesoMeta': pesoMeta,
  };

  factory MetasClinicas.fromJson(Map<String, dynamic> json) => MetasClinicas(
    paSistolicaMax: (json['paSistolicaMax'] as num?)?.toDouble() ?? 130,
    paDiastolicaMax: (json['paDiastolicaMax'] as num?)?.toDouble() ?? 80,
    glicemiaJejumMin: (json['glicemiaJejumMin'] as num?)?.toDouble() ?? 70,
    glicemiaJejumMax: (json['glicemiaJejumMax'] as num?)?.toDouble() ?? 100,
    glicemiaPosPrandialMax: (json['glicemiaPosPrandialMax'] as num?)?.toDouble() ?? 140,
    pesoMeta: (json['pesoMeta'] as num?)?.toDouble(),
  );

  MetasClinicas copyWith({
    double? paSistolicaMax,
    double? paDiastolicaMax,
    double? glicemiaJejumMin,
    double? glicemiaJejumMax,
    double? glicemiaPosPrandialMax,
    double? pesoMeta,
  }) => MetasClinicas(
    paSistolicaMax: paSistolicaMax ?? this.paSistolicaMax,
    paDiastolicaMax: paDiastolicaMax ?? this.paDiastolicaMax,
    glicemiaJejumMin: glicemiaJejumMin ?? this.glicemiaJejumMin,
    glicemiaJejumMax: glicemiaJejumMax ?? this.glicemiaJejumMax,
    glicemiaPosPrandialMax: glicemiaPosPrandialMax ?? this.glicemiaPosPrandialMax,
    pesoMeta: pesoMeta ?? this.pesoMeta,
  );
}

class Paciente {
  final String id;
  final String nome;
  final Sexo sexo;
  final String dataNascimento; // YYYY-MM-DD
  final String? telefone;
  final String? email;
  final double? altura; // metros (ex: 1.75)
  final List<String> alergias;
  final List<Diagnostico> diagnosticos;
  final MetasClinicas metas;
  final DateTime vinculadoEm;
  final DateTime? proximoRetorno;

  const Paciente({
    required this.id,
    required this.nome,
    required this.sexo,
    required this.dataNascimento,
    this.telefone,
    this.email,
    this.altura,
    this.alergias = const [],
    this.diagnosticos = const [],
    this.metas = const MetasClinicas(),
    required this.vinculadoEm,
    this.proximoRetorno,
  });

  Paciente copyWith({
    String? id,
    String? nome,
    Sexo? sexo,
    String? dataNascimento,
    String? telefone,
    String? email,
    double? altura,
    List<String>? alergias,
    List<Diagnostico>? diagnosticos,
    MetasClinicas? metas,
    DateTime? vinculadoEm,
    DateTime? proximoRetorno,
  }) => Paciente(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    sexo: sexo ?? this.sexo,
    dataNascimento: dataNascimento ?? this.dataNascimento,
    telefone: telefone ?? this.telefone,
    email: email ?? this.email,
    altura: altura ?? this.altura,
    alergias: alergias ?? this.alergias,
    diagnosticos: diagnosticos ?? this.diagnosticos,
    metas: metas ?? this.metas,
    vinculadoEm: vinculadoEm ?? this.vinculadoEm,
    proximoRetorno: proximoRetorno ?? this.proximoRetorno,
  );

  int get idade {
    try {
      final parts = dataNascimento.split('-');
      final birth = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }
}

class UltimaAfericao {
  final String tipo; // 'pressao' | 'glicemia' | 'peso'
  final String descricao;
  final DateTime em;

  const UltimaAfericao({
    required this.tipo,
    required this.descricao,
    required this.em,
  });
}

class PacienteResumo {
  final Paciente paciente;
  final StatusRisco status;
  final String? motivoStatus;
  final UltimaAfericao? ultimaAfericao;
  final double? adesao7d; // 0..1

  const PacienteResumo({
    required this.paciente,
    required this.status,
    this.motivoStatus,
    this.ultimaAfericao,
    this.adesao7d,
  });
}

class AlertaClinico {
  final String id;
  final String pacienteId;
  final String pacienteNome;
  final StatusRisco nivel; // critico | atencao
  final String titulo;
  final String descricao;
  final DateTime em;
  final bool lido;

  const AlertaClinico({
    required this.id,
    required this.pacienteId,
    required this.pacienteNome,
    required this.nivel,
    required this.titulo,
    required this.descricao,
    required this.em,
    this.lido = false,
  });

  AlertaClinico copyWith({bool? lido}) => AlertaClinico(
    id: id,
    pacienteId: pacienteId,
    pacienteNome: pacienteNome,
    nivel: nivel,
    titulo: titulo,
    descricao: descricao,
    em: em,
    lido: lido ?? this.lido,
  );
}

class Agendamento {
  final String id;
  final String pacienteId;
  final String pacienteNome;
  final DateTime inicio;
  final int duracaoMin;
  final String tipo; // 'presencial' | 'teleconsulta' | 'retorno'
  final String? observacao;

  const Agendamento({
    required this.id,
    required this.pacienteId,
    required this.pacienteNome,
    required this.inicio,
    this.duracaoMin = 30,
    required this.tipo,
    this.observacao,
  });
}

class Profissional {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String conselho; // CRM, COREN, etc.
  final String registro;
  final String uf;
  final String especialidade;
  final String? enderecoConsultorio;
  final String? assinaturaTexto;

  const Profissional({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    required this.conselho,
    required this.registro,
    required this.uf,
    required this.especialidade,
    this.enderecoConsultorio,
    this.assinaturaTexto,
  });

  String get carimbo => '$conselho-$uf $registro';
}
