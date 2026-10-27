import 'dart:math';
import '../models/paciente_model.dart';
import '../models/vitals_model.dart';
import '../models/consulta_soap_model.dart';
import '../models/prescricao_model.dart';
import '../models/documento_model.dart';
import '../models/mensagem_model.dart';

class MockDatabase {
  static final MockDatabase instance = MockDatabase._internal();
  factory MockDatabase() => instance;

  MockDatabase._internal() {
    _initializeData();
  }

  // Profissional Logado Padrão
  final Profissional profissionalDemo = const Profissional(
    id: 'prof_demo',
    nome: 'Dra. Helena Moraes',
    email: 'demo@meudiario.pro',
    telefone: '(21) 99876-5432',
    conselho: 'CRM',
    registro: '123456',
    uf: 'RJ',
    especialidade: 'Cardiologia & Clínica Médica',
    enderecoConsultorio: 'Av. das Américas, 500 — Sala 1204, Barra da Tijuca, Rio de Janeiro/RJ',
    assinaturaTexto: 'Dra. Helena Moraes — Cardiologista CRM-RJ 123456',
  );

  final List<Paciente> pacientes = [];
  final List<RegistroPressao> pressoes = [];
  final List<RegistroGlicemia> glicemias = [];
  final List<RegistroPeso> pesos = [];
  final List<MedicamentoPaciente> medicamentos = [];
  final List<RegistroTomada> tomadas = [];
  final List<DocumentoClinico> documentos = [];
  final List<ConsultaSOAP> consultas = [];
  final List<Prescricao> prescricoes = [];
  final List<Agendamento> agenda = [];
  final List<AlertaClinico> alertas = [];
  final List<MensagemPaciente> mensagens = [];


  String _dateIso(int offsetDays) {
    final now = DateTime.now().add(Duration(days: offsetDays));
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  void _initializeData() {
    final random = Random(20261026);
    int varia(int base, int amp) => (base + (random.nextDouble() * 2 - 1) * amp).round();

    // 1. Paciente Maria Silva (Hipertensão + Diabetes - Risco Crítico)
    final pacMaria = Paciente(
      id: 'pac_maria',
      nome: 'Maria Silva Santos',
      sexo: Sexo.f,
      dataNascimento: '1962-04-12',
      telefone: '(21) 98888-1111',
      email: 'maria.silva@email.com',
      altura: 1.62,
      alergias: const ['Dipirona'],
      diagnosticos: const [
        Diagnostico(codigoCid: 'I10', descricao: 'Hipertensão essencial (primária)'),
        Diagnostico(codigoCid: 'E11', descricao: 'Diabetes mellitus não-insulino-dependente'),
      ],
      metas: const MetasClinicas(paSistolicaMax: 130, paDiastolicaMax: 80, glicemiaJejumMax: 100),
      vinculadoEm: DateTime.now().subtract(const Duration(days: 60)),
      proximoRetorno: DateTime.now().add(const Duration(days: 2)),
    );

    // 2. Paciente Ana Paula (Diabetes Tipo 1 - Hipoglicemia de Madrugada)
    final pacAna = Paciente(
      id: 'pac_ana',
      nome: 'Ana Paula Ferreira',
      sexo: Sexo.f,
      dataNascimento: '1988-09-30',
      telefone: '(21) 97777-2222',
      altura: 1.68,
      alergias: const [],
      diagnosticos: const [
        Diagnostico(codigoCid: 'E10', descricao: 'Diabetes mellitus insulino-dependente'),
      ],
      metas: const MetasClinicas(glicemiaJejumMax: 140),
      vinculadoEm: DateTime.now().subtract(const Duration(days: 45)),
      proximoRetorno: DateTime.now().add(const Duration(days: 5)),
    );

    // 3. Paciente José Carlos (Hipertensão + Colesterol - Retorno Hoje)
    final pacJose = Paciente(
      id: 'pac_jose',
      nome: 'José Carlos Oliveira',
      sexo: Sexo.m,
      dataNascimento: '1955-01-22',
      telefone: '(21) 96666-3333',
      altura: 1.74,
      alergias: const ['Penicilina', 'Frutos do mar'],
      diagnosticos: const [
        Diagnostico(codigoCid: 'I10', descricao: 'Hipertensão essencial (primária)'),
        Diagnostico(codigoCid: 'E78.0', descricao: 'Hipercolesterolemia pura'),
      ],
      vinculadoEm: DateTime.now().subtract(const Duration(days: 90)),
      proximoRetorno: DateTime.now(),
    );

    // 4. Paciente Roberto Mendes (Obesidade e Pré-diabetes)
    final pacRoberto = Paciente(
      id: 'pac_roberto',
      nome: 'Roberto Mendes Lima',
      sexo: Sexo.m,
      dataNascimento: '1970-06-05',
      telefone: '(21) 95555-4444',
      altura: 1.78,
      alergias: const [],
      diagnosticos: const [
        Diagnostico(codigoCid: 'E66', descricao: 'Obesidade mórbida'),
        Diagnostico(codigoCid: 'R73.0', descricao: 'Teste de tolerância a glicose anormal'),
      ],
      metas: const MetasClinicas(pesoMeta: 95),
      vinculadoEm: DateTime.now().subtract(const Duration(days: 30)),
      proximoRetorno: DateTime.now().add(const Duration(days: 9)),
    );

    // 5. Paciente Luiza Andrade (Hipotireoidismo - Estável)
    final pacLuiza = Paciente(
      id: 'pac_luiza',
      nome: 'Luiza Andrade',
      sexo: Sexo.f,
      dataNascimento: '1985-11-18',
      telefone: '(21) 94444-5555',
      altura: 1.65,
      alergias: const ['Sulfa'],
      diagnosticos: const [
        Diagnostico(codigoCid: 'E03.9', descricao: 'Hipotireoidismo não especificado'),
      ],
      vinculadoEm: DateTime.now().subtract(const Duration(days: 120)),
      proximoRetorno: DateTime.now().add(const Duration(days: 30)),
    );

    // 6. Paciente Carlos Eduardo (Diabetes Tipo 2 - Adesão excelente)
    final pacCarlos = Paciente(
      id: 'pac_carlos',
      nome: 'Carlos Eduardo Rocha',
      sexo: Sexo.m,
      dataNascimento: '1966-08-14',
      telefone: '(21) 92222-7777',
      altura: 1.81,
      alergias: const [],
      diagnosticos: const [
        Diagnostico(codigoCid: 'E11', descricao: 'Diabetes mellitus não-insulino-dependente'),
      ],
      vinculadoEm: DateTime.now().subtract(const Duration(days: 75)),
      proximoRetorno: DateTime.now().add(const Duration(days: 14)),
    );

    pacientes.addAll([pacMaria, pacAna, pacJose, pacRoberto, pacLuiza, pacCarlos]);

    // Geração de telemetria dos últimos 30 dias
    for (int d = -29; d <= 0; d++) {
      final dataStr = _dateIso(d);

      // Maria Silva (PA alterada com picos críticos)
      final mariaPas = d == -1 ? 186 : (d == 0 ? 172 : varia(148, 10));
      final mariaPad = d == -1 ? 114 : (d == 0 ? 104 : varia(92, 7));
      pressoes.add(RegistroPressao(
        id: 'pa_m_1_$d',
        pacienteId: pacMaria.id,
        data: dataStr,
        hora: '07:30',
        periodo: 'Manhã',
        sistolica: mariaPas,
        diastolica: mariaPad,
      ));
      pressoes.add(RegistroPressao(
        id: 'pa_m_2_$d',
        pacienteId: pacMaria.id,
        data: dataStr,
        hora: '21:00',
        periodo: 'Noite',
        sistolica: mariaPas - 6,
        diastolica: mariaPad - 4,
      ));
      glicemias.add(RegistroGlicemia(
        id: 'gl_m_1_$d',
        pacienteId: pacMaria.id,
        data: dataStr,
        hora: '06:45',
        periodo: 'Jejum',
        valor: varia(145, 20),
      ));

      // Ana Paula (Glicemias oscilando com episódios de hipoglicemia)
      final anaGlic = d == 0 ? 48 : (d == -2 ? 62 : varia(128, 30));
      glicemias.add(RegistroGlicemia(
        id: 'gl_a_1_$d',
        pacienteId: pacAna.id,
        data: dataStr,
        hora: d == 0 ? '03:15' : '07:00',
        periodo: d == 0 ? 'Madrugada' : 'Jejum',
        valor: anaGlic,
      ));

      // José Carlos (PA controlada)
      pressoes.add(RegistroPressao(
        id: 'pa_j_1_$d',
        pacienteId: pacJose.id,
        data: dataStr,
        hora: '08:00',
        periodo: 'Manhã',
        sistolica: varia(126, 8),
        diastolica: varia(82, 6),
      ));

      // Roberto Mendes (PA e Glicemia levemente elevados)
      pressoes.add(RegistroPressao(
        id: 'pa_r_1_$d',
        pacienteId: pacRoberto.id,
        data: dataStr,
        hora: '07:45',
        periodo: 'Manhã',
        sistolica: varia(128, 6),
        diastolica: varia(82, 5),
      ));
      glicemias.add(RegistroGlicemia(
        id: 'gl_r_1_$d',
        pacienteId: pacRoberto.id,
        data: dataStr,
        hora: '07:00',
        periodo: 'Jejum',
        valor: varia(118, 14),
      ));

      // Luiza (Estável)
      pressoes.add(RegistroPressao(
        id: 'pa_l_1_$d',
        pacienteId: pacLuiza.id,
        data: dataStr,
        hora: '08:30',
        periodo: 'Manhã',
        sistolica: varia(114, 5),
        diastolica: varia(74, 4),
      ));

      // Carlos (Controlado)
      glicemias.add(RegistroGlicemia(
        id: 'gl_c_1_$d',
        pacienteId: pacCarlos.id,
        data: dataStr,
        hora: '07:15',
        periodo: 'Jejum',
        valor: varia(108, 10),
      ));
      pressoes.add(RegistroPressao(
        id: 'pa_c_1_$d',
        pacienteId: pacCarlos.id,
        data: dataStr,
        hora: '08:00',
        periodo: 'Manhã',
        sistolica: varia(122, 6),
        diastolica: varia(78, 5),
      ));

      // Pesos periódicos (a cada 3 dias)
      if (d % 3 == 0) {
        pesos.add(RegistroPeso(id: 'ps_m_$d', pacienteId: pacMaria.id, data: dataStr, peso: 78.4 + d * 0.03));
        pesos.add(RegistroPeso(id: 'ps_a_$d', pacienteId: pacAna.id, data: dataStr, peso: 61.2));
        pesos.add(RegistroPeso(id: 'ps_j_$d', pacienteId: pacJose.id, data: dataStr, peso: 84.0 + d * 0.04));
        pesos.add(RegistroPeso(id: 'ps_r_$d', pacienteId: pacRoberto.id, data: dataStr, peso: 108.6 + d * 0.1));
        pesos.add(RegistroPeso(id: 'ps_l_$d', pacienteId: pacLuiza.id, data: dataStr, peso: 63.5 - d * 0.02));
        pesos.add(RegistroPeso(id: 'ps_c_$d', pacienteId: pacCarlos.id, data: dataStr, peso: 86.0 - d * 0.02));
      }
    }

    // Medicamentos Ativos
    medicamentos.addAll([
      MedicamentoPaciente(
        id: 'med_m_1',
        pacienteId: pacMaria.id,
        nome: 'Losartana Potássica',
        dosagem: '50mg',
        frequencia: '2x ao dia (12/12h)',
        instrucoes: '1 comprimido às 08h e 20h',
        horarios: const [
          HorarioMedicamento(id: 'h1', hora: '08:00', periodo: 'Manhã'),
          HorarioMedicamento(id: 'h2', hora: '20:00', periodo: 'Noite'),
        ],
        adesaoPercentual: 0.72,
      ),
      MedicamentoPaciente(
        id: 'med_m_2',
        pacienteId: pacMaria.id,
        nome: 'Metformina',
        dosagem: '850mg',
        frequencia: '2x ao dia',
        instrucoes: '1 comprimido após almoço e jantar',
        horarios: const [
          HorarioMedicamento(id: 'h3', hora: '13:00', periodo: 'Almoço'),
          HorarioMedicamento(id: 'h4', hora: '20:30', periodo: 'Jantar'),
        ],
        adesaoPercentual: 0.85,
      ),
      MedicamentoPaciente(
        id: 'med_a_1',
        pacienteId: pacAna.id,
        nome: 'Insulina Glargina',
        dosagem: '100UI/ml',
        frequencia: '1x ao dia',
        instrucoes: '22 UI às 22h',
        horarios: const [
          HorarioMedicamento(id: 'h5', hora: '22:00', periodo: 'Noite'),
        ],
        adesaoPercentual: 0.96,
      ),
    ]);

    // Alertas de Telemetria Crítica
    alertas.addAll([
      AlertaClinico(
        id: 'alt_1',
        pacienteId: pacMaria.id,
        pacienteNome: pacMaria.nome,
        nivel: StatusRisco.critico,
        titulo: 'Crise Hipertensiva Detectada',
        descricao: 'Aferição de 186/114 mmHg registrada ontem às 15:20.',
        em: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      AlertaClinico(
        id: 'alt_2',
        pacienteId: pacAna.id,
        pacienteNome: pacAna.nome,
        nivel: StatusRisco.critico,
        titulo: 'Hipoglicemia Severa na Madrugada',
        descricao: 'Glicemia capilar em 48 mg/dL registrada hoje às 03:15.',
        em: DateTime.now().subtract(const Duration(hours: 7)),
      ),
      AlertaClinico(
        id: 'alt_3',
        pacienteId: pacMaria.id,
        pacienteNome: pacMaria.nome,
        nivel: StatusRisco.atencao,
        titulo: 'Adesão Medicamentosa Baixa',
        descricao: 'Adesão aos anti-hipertensivos caiu para 72% nos últimos 7 dias.',
        em: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AlertaClinico(
        id: 'alt_4',
        pacienteId: pacRoberto.id,
        pacienteNome: pacRoberto.nome,
        nivel: StatusRisco.atencao,
        titulo: 'Glicemias pós-prandiais acima do alvo',
        descricao: '3 aferições consecutivas de glicemia acima de 190 mg/dL.',
        em: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);

    // Agenda Médica do Dia
    final hoje = DateTime.now();
    agenda.addAll([
      Agendamento(
        id: 'ag_1',
        pacienteId: pacJose.id,
        pacienteNome: pacJose.nome,
        inicio: DateTime(hoje.year, hoje.month, hoje.day, 10, 0),
        tipo: 'presencial',
        observacao: 'Retorno com exames de perfil lipídico',
      ),
      Agendamento(
        id: 'ag_2',
        pacienteId: pacMaria.id,
        pacienteNome: pacMaria.nome,
        inicio: DateTime(hoje.year, hoje.month, hoje.day, 11, 30),
        tipo: 'teleconsulta',
        observacao: 'Avaliação de pico pressórico recente',
      ),
      Agendamento(
        id: 'ag_3',
        pacienteId: pacCarlos.id,
        pacienteNome: pacCarlos.nome,
        inicio: DateTime(hoje.year, hoje.month, hoje.day, 15, 0),
        tipo: 'presencial',
        observacao: 'Acompanhamento trimestral de DM2',
      ),
    ]);

    // Documentos Clínicos dos Pacientes
    documentos.addAll([
      DocumentoClinico(
        id: 'doc_1',
        pacienteId: pacMaria.id,
        tipo: TipoDocumentoClinico.exame,
        titulo: 'Hemograma Completo e Glicada',
        categoria: 'Laboratorial',
        data: _dateIso(-14),
        medico: 'Laboratório Sérgio Franco',
        paginas: 2,
        arquivoNome: 'hemograma_glicada.pdf',
        tamanhoFormatado: '420 KB',
        observacao: 'HbA1c em 7.8%, leucócitos normais.',
        criadoEm: DateTime.now().subtract(const Duration(days: 14)),
      ),
      DocumentoClinico(
        id: 'doc_2',
        pacienteId: pacMaria.id,
        tipo: TipoDocumentoClinico.laudo,
        titulo: 'Ecocardiograma Transtorácico',
        categoria: 'Cardiologia',
        data: _dateIso(-35),
        medico: 'Dr. Paulo Lins (CRM 52.88776-1)',
        paginas: 3,
        arquivoNome: 'eco_transtoracico.pdf',
        tamanhoFormatado: '1.2 MB',
        observacao: 'FEVE 64%, hipertrofia ventricular esquerda leve.',
        criadoEm: DateTime.now().subtract(const Duration(days: 35)),
      ),
      DocumentoClinico(
        id: 'doc_3',
        pacienteId: pacJose.id,
        tipo: TipoDocumentoClinico.exame,
        titulo: 'Perfil Lipídico e Função Renal',
        categoria: 'Laboratorial',
        data: _dateIso(-5),
        medico: 'Laboratório Lâmina',
        paginas: 2,
        arquivoNome: 'perfil_lipidico.pdf',
        tamanhoFormatado: '380 KB',
        observacao: 'Colesterol Total 188, Creatinina 0.9 mg/dL.',
        criadoEm: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);

    // Consultas Anteriores SOAP
    consultas.add(ConsultaSOAP(
      id: 'cs_1',
      pacienteId: pacMaria.id,
      profissionalId: profissionalDemo.id,
      data: DateTime.now().subtract(const Duration(days: 45)),
      tipo: 'presencial',
      subjetivo: 'Paciente refere cefaleia occipital esporádica e cansaço. Nega dor precordial.',
      objetivo: 'BEG, corada, hidratada. PA 148/92 mmHg, FC 74 bpm. AC: RCR 2T BNF sem sopros.',
      vitais: const VitaisConsulta(sistolica: 148, diastolica: 92, fc: 74, peso: 78.4),
      avaliacao: 'Hipertensão arterial não controlada. Necessário ajuste posológico.',
      hipoteses: pacMaria.diagnosticos,
      plano: 'Ajustar Losartana para 50mg 12/12h. Solicitar MAPA 24h e monitoramento no app.',
      retornoEmDias: 45,
    ));

    // Prescrição Ativa
    prescricoes.add(Prescricao(
      id: 'rx_1',
      pacienteId: pacMaria.id,
      profissionalId: profissionalDemo.id,
      data: DateTime.now().subtract(const Duration(days: 45)),
      itens: const [
        ItemPrescricao(
          id: 'rx_it_1',
          medicamento: 'Losartana Potássica',
          concentracao: '50mg',
          forma: 'Comprimido',
          posologia: '1 comprimido por via oral de 12 em 12 horas',
          duracao: 'continuo',
        ),
        ItemPrescricao(
          id: 'rx_it_2',
          medicamento: 'Metformina',
          concentracao: '850mg',
          forma: 'Comprimido',
          posologia: '1 comprimido por via oral após o almoço e o jantar',
          duracao: 'continuo',
        ),
      ],
      codigoImportacao: 'MARIA2026',
    ));

    // Mensagens e Avisos Enviados aos Pacientes
    mensagens.addAll([
      MensagemPaciente(
        id: 'msg_1',
        pacienteId: pacMaria.id,
        profissionalId: profissionalDemo.id,
        tipo: TipoAvisoPaciente.alertaTelemetria,
        titulo: 'Alerta de Pico Pressórico',
        conteudo: 'Dona Maria, notei que sua pressão atingiu 186/114 ontem. Por favor, mantenha repouso, tome a medicação prescrita e realize uma nova aferição dentro de 2 horas.',
        enviadoEm: DateTime.now().subtract(const Duration(hours: 17)),
        canal: CanalEnvio.ambos,
      ),
      MensagemPaciente(
        id: 'msg_2',
        pacienteId: pacMaria.id,
        profissionalId: profissionalDemo.id,
        tipo: TipoAvisoPaciente.retorno,
        titulo: 'Lembrete de Retorno no Consultório',
        conteudo: 'Seu retorno presencial está agendado para daqui a 2 dias. Lembre-se de trazer os exames solicitados.',
        enviadoEm: DateTime.now().subtract(const Duration(days: 3)),
        canal: CanalEnvio.notificacaoApp,
      ),
      MensagemPaciente(
        id: 'msg_3',
        pacienteId: pacAna.id,
        profissionalId: profissionalDemo.id,
        tipo: TipoAvisoPaciente.alertaTelemetria,
        titulo: 'Aviso de Hipoglicemia',
        conteudo: 'Ana, vi a glicemia de 48 mg/dL na madrugada. Seguiu a regra dos 15g de carboidrato rápido? Se persistir, entre em contato imediatamente.',
        enviadoEm: DateTime.now().subtract(const Duration(hours: 6)),
        canal: CanalEnvio.ambos,
      ),
    ]);
  }


  // Triagem do Paciente
  StatusRisco calcularStatusRisco(Paciente paciente) {
    final pas = pressoes.where((p) => p.pacienteId == paciente.id).toList();
    final gls = glicemias.where((g) => g.pacienteId == paciente.id).toList();

    // 1. Crítico Absoluto (PA >= 180/110 ou Glicemia < 54 ou >= 300)
    final temCrisePa = pas.any((p) => p.sistolica >= 180 || p.diastolica >= 110);
    final temHipoGrave = gls.any((g) => g.valor < 54);
    final temHiperGrave = gls.any((g) => g.valor >= 300);

    if (temCrisePa || temHipoGrave || temHiperGrave) {
      return StatusRisco.critico;
    }

    // 2. Atenção (aferições fora da meta ou hipoglicemia leve)
    final paFora = pas.where((p) =>
        p.sistolica > paciente.metas.paSistolicaMax ||
        p.diastolica > paciente.metas.paDiastolicaMax).length;

    if (pas.isNotEmpty && (paFora / pas.length) >= 0.3) {
      return StatusRisco.atencao;
    }

    final glcFora = gls.where((g) =>
        g.valor > paciente.metas.glicemiaJejumMax ||
        g.valor < paciente.metas.glicemiaJejumMin).length;

    if (gls.isNotEmpty && (glcFora / gls.length) >= 0.3) {
      return StatusRisco.atencao;
    }

    return StatusRisco.estavel;
  }

  List<PacienteResumo> obterPacientesResumo() {
    return pacientes.map((p) {
      final status = calcularStatusRisco(p);
      final ultPa = pressoes.where((item) => item.pacienteId == p.id).toList();
      UltimaAfericao? ultima;

      if (ultPa.isNotEmpty) {
        final last = ultPa.last;
        ultima = UltimaAfericao(
          tipo: 'pressao',
          descricao: '${last.sistolica}/${last.diastolica} mmHg',
          em: last.dateTime,
        );
      }

      String? motivo;
      if (status == StatusRisco.critico) {
        motivo = p.id == 'pac_maria'
            ? 'PA 186/114 mmHg (Crise hipertensiva)'
            : 'Glicemia 48 mg/dL (Hipoglicemia severa)';
      } else if (status == StatusRisco.atencao) {
        motivo = 'Aferições frequentes acima da meta recomendada';
      }

      double? adesao;
      final meds = medicamentos.where((m) => m.pacienteId == p.id).toList();
      if (meds.isNotEmpty) {
        final soma = meds.fold<double>(0.0, (acc, m) => acc + (m.adesaoPercentual ?? 0.8));
        adesao = soma / meds.length;
      }

      return PacienteResumo(
        paciente: p,
        status: status,
        motivoStatus: motivo,
        ultimaAfericao: ultima,
        adesao7d: adesao,
      );
    }).toList()
      ..sort((a, b) {
        // Ordenação por gravidade: Crítico > Atenção > Estável
        final order = {StatusRisco.critico: 0, StatusRisco.atencao: 1, StatusRisco.estavel: 2};
        return (order[a.status] ?? 3).compareTo(order[b.status] ?? 3);
      });
  }
}
