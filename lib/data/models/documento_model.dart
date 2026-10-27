enum TipoDocumentoClinico {
  exame,
  laudo,
  receita,
  atestado,
  imagem,
  relatorio,
}

class DocumentoClinico {
  final String id;
  final String pacienteId;
  final TipoDocumentoClinico tipo;
  final String titulo;
  final String? categoria; // "Laboratorial", "Cardiologia", "Radiologia"
  final String data; // YYYY-MM-DD
  final String? medico;
  final String? validade;
  final int? paginas;
  final String? url;
  final String? arquivoNome;
  final String? tamanhoFormatado;
  final String? observacao;
  final DateTime criadoEm;

  const DocumentoClinico({
    required this.id,
    required this.pacienteId,
    required this.tipo,
    required this.titulo,
    this.categoria,
    required this.data,
    this.medico,
    this.validade,
    this.paginas,
    this.url,
    this.arquivoNome,
    this.tamanhoFormatado,
    this.observacao,
    required this.criadoEm,
  });
}

class AtestadoMedico {
  final String id;
  final String pacienteId;
  final String tipo; // 'afastamento' | 'comparecimento' | 'aptidao'
  final int diasAfastamento;
  final String? motivo;
  final String? cid10;
  final bool autorizaCid;
  final DateTime dataEmissao;
  final String local;

  const AtestadoMedico({
    required this.id,
    required this.pacienteId,
    required this.tipo,
    this.diasAfastamento = 1,
    this.motivo,
    this.cid10,
    this.autorizaCid = false,
    required this.dataEmissao,
    this.local = 'Rio de Janeiro - RJ',
  });
}

class PedidoExame {
  final String id;
  final String pacienteId;
  final List<String> exames;
  final String? indicacaoClinica;
  final String? justificativa;
  final DateTime dataEmissao;

  const PedidoExame({
    required this.id,
    required this.pacienteId,
    required this.exames,
    this.indicacaoClinica,
    this.justificativa,
    required this.dataEmissao,
  });
}
