import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../data/models/paciente_model.dart';
import '../../data/models/prescricao_model.dart';
import '../../data/models/documento_model.dart';
import '../../data/models/vitals_model.dart';
import '../../data/models/consulta_soap_model.dart';

class PdfGeneratorService {
  static final PdfGeneratorService instance = PdfGeneratorService._internal();
  factory PdfGeneratorService() => instance;
  PdfGeneratorService._internal();

  // ─── 1. GERAR RECEITA MÉDICA OFICIAL A4 ───
  Future<Uint8List> gerarReceitaPdf({
    required Profissional profissional,
    required Paciente paciente,
    required Prescricao prescricao,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho da Clínica
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        profissional.nome,
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                      ),
                      pw.Text(
                        '${profissional.especialidade} • ${profissional.carimbo}',
                        style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey700),
                      ),
                      if (profissional.enderecoConsultorio != null)
                        pw.Text(
                          profissional.enderecoConsultorio!,
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                    ],
                  ),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'meudiariosaude://importar-prescricao?codigo=${prescricao.codigoImportacao}',
                    width: 55,
                    height: 55,
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1.5, color: PdfColors.blueGrey800),
              pw.SizedBox(height: 16),

              // Identificação do Paciente
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PACIENTE:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                        pw.Text(paciente.nome, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('DATA DE EMISSÃO:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                        pw.Text(dateFormat.format(prescricao.data), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              pw.Center(
                child: pw.Text(
                  'RECEITUÁRIO MÉDICO',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 1),
                ),
              ),
              pw.SizedBox(height: 16),

              // Itens Prescritos
              ...prescricao.itens.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final it = entry.value;

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '$idx. ${it.medicamento} ${it.concentracao}',
                            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                          ),
                          if (it.quantidade != null)
                            pw.Text(
                              it.quantidade!,
                              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                            ),
                        ],
                      ),
                      pw.SizedBox(height: 3),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 14),
                        child: pw.Text(
                          'Uso: ${it.forma} • ${it.posologia}',
                          style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 14, top: 2),
                        child: pw.Text(
                          it.duracaoFormatada,
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey600),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.Spacer(),

              // Rodapé e Carimbo
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      profissional.nome,
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      profissional.carimbo,
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Código de sincronização pelo app do paciente: ${prescricao.codigoImportacao}',
                      style: pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey600, fontStyle: pw.FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─── 2. GERAR ATESTADO MÉDICO CFM ───
  Future<Uint8List> gerarAtestadoPdf({
    required Profissional profissional,
    required Paciente paciente,
    required AtestadoMedico atestado,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          String corpoTexto;
          if (atestado.tipo == 'afastamento') {
            corpoTexto =
                'Atesto para os devidos fins que o(a) paciente ${paciente.nome}, esteve sob meus cuidados médicos no dia de hoje, necessitando de ${atestado.diasAfastamento} (${atestado.diasAfastamento == 1 ? "um" : atestado.diasAfastamento}) dia(s) de afastamento de suas atividades laborais e/ou escolares por motivo de tratamento de saúde.';
          } else if (atestado.tipo == 'comparecimento') {
            corpoTexto =
                'Atesto para os devidos fins que o(a) paciente ${paciente.nome}, compareceu a esta unidade de saúde no dia de hoje para realização de consulta médica e acompanhamento clínico das ${DateFormat('HH:mm').format(DateTime.now().subtract(const Duration(hours: 1)))} às ${DateFormat('HH:mm').format(DateTime.now())}.';
          } else {
            corpoTexto =
                'Atesto que examinei clinicamente nesta data o(a) paciente ${paciente.nome}, encontrando-se o(a) mesmo(a) APTO(A) para a prática de atividades físicas regulares no presente momento.';
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Cabeçalho
              pw.Text(
                profissional.nome,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
              ),
              pw.Text(
                '${profissional.especialidade} • ${profissional.carimbo}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey700),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1.5, color: PdfColors.blueGrey800),
              pw.SizedBox(height: 48),

              pw.Text(
                'ATESTADO MÉDICO',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, letterSpacing: 2),
              ),
              pw.SizedBox(height: 36),

              // Texto do Atestado
              pw.Paragraph(
                text: corpoTexto,
                style: const pw.TextStyle(fontSize: 13, height: 1.8),
                textAlign: pw.TextAlign.justify,
              ),

              if (atestado.autorizaCid && atestado.cid10 != null) ...[
                pw.SizedBox(height: 24),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'Classificação Internacional de Doenças: CID-10 ${atestado.cid10} (Divulgação autorizada expressamente pelo paciente)',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey800),
                  ),
                ),
              ],

              pw.SizedBox(height: 40),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '${atestado.local}, ${dateFormat.format(atestado.dataEmissao)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),

              pw.Spacer(),

              // Assinatura e Conformidade CFM
              pw.Container(
                width: 250,
                child: pw.Column(
                  children: [
                    pw.Divider(thickness: 1),
                    pw.Text(profissional.nome, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text(profissional.carimbo, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Documento emitido em conformidade com as Resoluções CFM 1.658/2002 e 1.851/2008.',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─── 3. GERAR PEDIDO DE EXAME LABORATORIAL ───
  Future<Uint8List> gerarPedidoExamePdf({
    required Profissional profissional,
    required Paciente paciente,
    required PedidoExame pedido,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(profissional.nome, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('${profissional.especialidade} • ${profissional.carimbo}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey700)),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1.5, color: PdfColors.blueGrey800),
              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Text(
                  'SOLICITAÇÃO DE EXAMES COMPLEMENTARES',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text('Paciente: ${paciente.nome}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('Data: ${dateFormat.format(pedido.dataEmissao)}', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 20),

              pw.Text('Exames Solicitados:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              ...pedido.exames.asMap().entries.map((e) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: pw.Text('${e.key + 1}. [ ] ${e.value}', style: const pw.TextStyle(fontSize: 11)),
                );
              }),

              if (pedido.indicacaoClinica != null && pedido.indicacaoClinica!.isNotEmpty) ...[
                pw.SizedBox(height: 24),
                pw.Text('Indicação Clínica / Hipótese Diagnóstica:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text(pedido.indicacaoClinica!, style: const pw.TextStyle(fontSize: 11)),
              ],

              pw.Spacer(),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(width: 200, child: pw.Divider(thickness: 1)),
                    pw.Text(profissional.nome, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text(profissional.carimbo, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─── 4. GERAR DOSSIÊ CLÍNICO 360° CONSOLIDADO ───
  Future<Uint8List> gerarDossieClinicoPdf({
    required Profissional profissional,
    required Paciente paciente,
    required List<RegistroPressao> pressoes,
    required List<RegistroGlicemia> glicemias,
    required List<ItemPrescricao> medicamentos,
    ConsultaSOAP? ultimaConsulta,
    String? observacoesGerais,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Estatísticas de telemetria
    final mediaSis = pressoes.isNotEmpty
        ? (pressoes.map((m) => m.sistolica).reduce((a, b) => a + b) / pressoes.length).round()
        : null;
    final mediaDia = pressoes.isNotEmpty
        ? (pressoes.map((m) => m.diastolica).reduce((a, b) => a + b) / pressoes.length).round()
        : null;

    final dentroDaMeta = pressoes.where((m) =>
        m.sistolica <= paciente.metas.paSistolicaMax &&
        m.diastolica <= paciente.metas.paDiastolicaMax).length;
    final tir = pressoes.isNotEmpty ? ((dentroDaMeta / pressoes.length) * 100).round() : 100;

    final mediaGlic = glicemias.isNotEmpty
        ? (glicemias.map((m) => m.valor).reduce((a, b) => a + b) / glicemias.length).round()
        : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Cabeçalho Institucional
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DOSSIÊ CLÍNICO 360° • MEU DIÁRIO DE SAÚDE',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    profissional.nome,
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                  ),
                  pw.Text(
                    '${profissional.especialidade} • ${profissional.carimbo}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700),
                  ),
                  if (profissional.enderecoConsultorio != null)
                    pw.Text(
                      profissional.enderecoConsultorio!,
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                    ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'https://meudiariodesaude.com.br/verificar?paciente=${paciente.id}',
                    width: 48,
                    height: 48,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Emissão: ${dateFormat.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 1.5, color: PdfColors.teal700),
          pw.SizedBox(height: 10),

          // Bloco do Paciente
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PACIENTE: ${paciente.nome}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${paciente.idade} anos • Sexo: ${paciente.sexo == Sexo.f ? "Feminino" : "Masculino"} • Nasc: ${paciente.dataNascimento}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      if (paciente.telefone != null)
                        pw.Text('Contato: ${paciente.telefone}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Alergias:',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: paciente.alergias.isNotEmpty ? PdfColors.red800 : PdfColors.grey700),
                      ),
                      pw.Text(
                        paciente.alergias.isNotEmpty ? paciente.alergias.join(', ') : 'Nenhuma relatada',
                        style: pw.TextStyle(fontSize: 9, color: paciente.alergias.isNotEmpty ? PdfColors.red900 : PdfColors.black),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('Diagnósticos (CID-10):', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        paciente.diagnosticos.isNotEmpty
                            ? paciente.diagnosticos.map((d) => '${d.codigoCid} - ${d.descricao}').join('; ')
                            : 'Em investigação',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Seção 1: Resumo Estatístico de Telemetria
          pw.Text('1. RESUMO DE TELEMETRIA E CONTROLE CLÍNICO (ÚLTIMOS REGISTROS)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blueGrey200), borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PA Média', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text(mediaSis != null ? '$mediaSis/$mediaDia mmHg' : '—', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                      pw.Text('Meta: ≤ ${paciente.metas.paSistolicaMax.toInt()}/${paciente.metas.paDiastolicaMax.toInt()}', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blueGrey200), borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Time in Range (TIR)', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('$tir% no alvo', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: tir >= 70 ? PdfColors.green800 : PdfColors.amber800)),
                      pw.Text('Alvo terapêutico: ≥ 70%', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blueGrey200), borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Glicemia Média', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text(mediaGlic != null ? '$mediaGlic mg/dL' : '—', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                      pw.Text('Meta: ${paciente.metas.glicemiaJejumMin.toInt()} - ${paciente.metas.glicemiaJejumMax.toInt()} mg/dL', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blueGrey200), borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total de Aferições', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('${pressoes.length + glicemias.length} regs', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                      pw.Text('Monitoramento Ativo', style: const pw.TextStyle(fontSize: 7, color: PdfColors.green800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Tabela das últimas 6 medições de PA
          if (pressoes.isNotEmpty) ...[
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Data / Hora', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('PA Sistólica', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('PA Diastólica', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Período / Contexto', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...pressoes.take(6).map((m) {
                  final alterada = m.sistolica >= paciente.metas.paSistolicaMax || m.diastolica >= paciente.metas.paDiastolicaMax;
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${m.data} ${m.hora}', style: const pw.TextStyle(fontSize: 8))),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '${m.sistolica} mmHg',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: alterada ? pw.FontWeight.bold : pw.FontWeight.normal,
                            color: alterada ? PdfColors.red800 : PdfColors.black,
                          ),
                        ),
                      ),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${m.diastolica} mmHg', style: const pw.TextStyle(fontSize: 8))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(m.periodo ?? 'Rotina', style: const pw.TextStyle(fontSize: 8))),
                    ],
                  );
                }),
              ],
            ),
          ],
          pw.SizedBox(height: 14),

          // Seção 2: Medicamentos em Uso
          pw.Text('2. FARMACOTERAPIA ATUAL EM USO', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
          pw.SizedBox(height: 6),
          if (medicamentos.isEmpty)
            pw.Text('Nenhum medicamento registrado no prontuário.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700))
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(4),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Medicamento', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Concentração / Forma', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Posologia Recomendada', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Regime', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...medicamentos.map((it) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(it.medicamento, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${it.concentracao} (${it.forma})', style: const pw.TextStyle(fontSize: 8))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(it.posologia, style: const pw.TextStyle(fontSize: 8))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(it.duracao == 'continuo' ? 'Uso Contínuo' : it.duracao, style: const pw.TextStyle(fontSize: 8))),
                    ],
                  );
                }),
              ],
            ),
          pw.SizedBox(height: 14),

          // Seção 3: Última Evolução Clínica (SOAP)
          if (ultimaConsulta != null) ...[
            pw.Text('3. ÚLTIMA EVOLUÇÃO CLÍNICA REGISTRADA (SOAP)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Data da Consulta: ${dateFormat.format(ultimaConsulta.data)}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                  pw.SizedBox(height: 4),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(text: 'S (Subjetivo): ', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.TextSpan(text: '${ultimaConsulta.subjetivo}\n', style: const pw.TextStyle(fontSize: 8)),
                        pw.TextSpan(text: 'O (Objetivo): ', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.TextSpan(text: '${ultimaConsulta.objetivo}\n', style: const pw.TextStyle(fontSize: 8)),
                        pw.TextSpan(text: 'A (Avaliação): ', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.TextSpan(text: '${ultimaConsulta.avaliacao}\n', style: const pw.TextStyle(fontSize: 8)),
                        pw.TextSpan(text: 'P (Plano / Conduta): ', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                        pw.TextSpan(text: ultimaConsulta.plano, style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),
          ],

          // Assinatura e Carimbo
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Documento emitido pelo prontuário eletrônico do profissional.', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  pw.Text('Conforme Resoluções CFM nº 1.821/2007 e 2.299/2021 sobre documentos médicos eletrônicos.', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                ],
              ),
              pw.Container(
                width: 200,
                child: pw.Column(
                  children: [
                    pw.Divider(thickness: 1, color: PdfColors.black),
                    pw.Text(profissional.nome, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text(profissional.carimbo, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
