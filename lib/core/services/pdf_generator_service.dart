import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../data/models/paciente_model.dart';
import '../../data/models/prescricao_model.dart';
import '../../data/models/documento_model.dart';

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
}
