enum TipoAvisoPaciente {
  orientacao,
  alertaTelemetria,
  medicacao,
  retorno,
  exames,
  personalizada,
}

enum CanalEnvio {
  notificacaoApp,
  whatsApp,
  ambos,
}

class MensagemPaciente {
  final String id;
  final String pacienteId;
  final String profissionalId;
  final TipoAvisoPaciente tipo;
  final String titulo;
  final String conteudo;
  final DateTime enviadoEm;
  final CanalEnvio canal;
  final bool entregue;

  const MensagemPaciente({
    required this.id,
    required this.pacienteId,
    required this.profissionalId,
    required this.tipo,
    required this.titulo,
    required this.conteudo,
    required this.enviadoEm,
    this.canal = CanalEnvio.ambos,
    this.entregue = true,
  });

  String get tipoFormatado {
    switch (tipo) {
      case TipoAvisoPaciente.alertaTelemetria:
        return 'Alerta Clínico';
      case TipoAvisoPaciente.medicacao:
        return 'Aviso de Medicação';
      case TipoAvisoPaciente.retorno:
        return 'Lembrete de Retorno';
      case TipoAvisoPaciente.exames:
        return 'Orientação de Exames';
      case TipoAvisoPaciente.orientacao:
        return 'Orientação Médica';
      case TipoAvisoPaciente.personalizada:
        return 'Mensagem Direta';
    }
  }
}
