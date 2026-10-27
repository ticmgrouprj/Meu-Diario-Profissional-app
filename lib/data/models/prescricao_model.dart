class ItemPrescricao {
  final String id;
  final String medicamento;
  final String concentracao; // ex: 50mg, 500mg, 10mg/mL
  final String forma; // comprimido, cápsula, gotas, xarope
  final String posologia; // ex: 1 comprimido pela manhã em jejum
  final String? quantidade; // ex: 30 comprimidos
  final dynamic duracao; // 'continuo' ou int (número de dias)

  const ItemPrescricao({
    required this.id,
    required this.medicamento,
    required this.concentracao,
    required this.forma,
    required this.posologia,
    this.quantidade,
    required this.duracao,
  });

  bool get isUsoContinuo => duracao == 'continuo';

  String get duracaoFormatada =>
      isUsoContinuo ? 'Uso Contínuo' : 'Durante $duracao dias';
}

class Prescricao {
  final String id;
  final String pacienteId;
  final String profissionalId;
  final DateTime data;
  final List<ItemPrescricao> itens;
  final String? observacoes;
  final String codigoImportacao; // Código que o paciente lê via QR para sincronizar no seu celular

  const Prescricao({
    required this.id,
    required this.pacienteId,
    required this.profissionalId,
    required this.data,
    required this.itens,
    this.observacoes,
    required this.codigoImportacao,
  });
}
