import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vitals_model.dart';
import '../models/consulta_soap_model.dart';
import '../models/prescricao_model.dart';
import '../models/documento_model.dart';
import '../models/mensagem_model.dart';
import '../mock/mock_database.dart';

final clinicoRepositoryProvider = Provider<ClinicoRepository>((ref) {
  return ClinicoRepository();
});

class ClinicoRepository {
  final MockDatabase _db = MockDatabase.instance;

  // Sinais Vitais & Telemetria
  List<RegistroPressao> obterPressoes(String pacienteId) {
    return _db.pressoes.where((p) => p.pacienteId == pacienteId).toList();
  }

  List<RegistroGlicemia> obterGlicemias(String pacienteId) {
    return _db.glicemias.where((g) => g.pacienteId == pacienteId).toList();
  }

  List<RegistroPeso> obterPesos(String pacienteId) {
    return _db.pesos.where((p) => p.pacienteId == pacienteId).toList();
  }

  List<MedicamentoPaciente> obterMedicamentos(String pacienteId) {
    return _db.medicamentos.where((m) => m.pacienteId == pacienteId).toList();
  }

  List<RegistroTomada> obterTomadas(String pacienteId) {
    return _db.tomadas.toList();
  }

  // Documentos Clínicos
  List<DocumentoClinico> obterDocumentos(String pacienteId) {
    return _db.documentos.where((d) => d.pacienteId == pacienteId).toList();
  }

  void adicionarDocumento(DocumentoClinico documento) {
    _db.documentos.insert(0, documento);
  }

  // Consultas SOAP
  List<ConsultaSOAP> obterConsultas(String pacienteId) {
    return _db.consultas.where((c) => c.pacienteId == pacienteId).toList();
  }

  void salvarConsultaSOAP(ConsultaSOAP consulta) {
    _db.consultas.insert(0, consulta);
  }

  // Prescrições
  List<Prescricao> obterPrescricoes(String pacienteId) {
    return _db.prescricoes.where((p) => p.pacienteId == pacienteId).toList();
  }

  void salvarPrescricao(Prescricao prescricao) {
    _db.prescricoes.insert(0, prescricao);
  }

  // Mensagens e Notificações ao Paciente
  List<MensagemPaciente> obterMensagens(String pacienteId) {
    return _db.mensagens.where((m) => m.pacienteId == pacienteId).toList()
      ..sort((a, b) => b.enviadoEm.compareTo(a.enviadoEm));
  }

  void enviarMensagem(MensagemPaciente mensagem) {
    _db.mensagens.insert(0, mensagem);
  }
}

