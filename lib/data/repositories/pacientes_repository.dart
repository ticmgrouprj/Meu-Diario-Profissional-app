import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paciente_model.dart';
import '../mock/mock_database.dart';

final pacientesRepositoryProvider = Provider<PacientesRepository>((ref) {
  return PacientesRepository();
});

final pacientesResumoProvider = StateNotifierProvider<PacientesNotifier, List<PacienteResumo>>((ref) {
  final repo = ref.watch(pacientesRepositoryProvider);
  return PacientesNotifier(repo);
});

final alertasProvider = StateNotifierProvider<AlertasNotifier, List<AlertaClinico>>((ref) {
  final repo = ref.watch(pacientesRepositoryProvider);
  return AlertasNotifier(repo);
});

final agendaProvider = Provider<List<Agendamento>>((ref) {
  final repo = ref.watch(pacientesRepositoryProvider);
  return repo.obterAgenda();
});

class PacientesNotifier extends StateNotifier<List<PacienteResumo>> {
  final PacientesRepository _repo;

  PacientesNotifier(this._repo) : super([]) {
    carregar();
  }

  void carregar() {
    state = _repo.obterResumos();
  }

  void filtrar(String query, {StatusRisco? statusFiltro}) {
    final todos = _repo.obterResumos();
    state = todos.where((item) {
      final matchesQuery = query.isEmpty ||
          item.paciente.nome.toLowerCase().contains(query.toLowerCase()) ||
          item.paciente.diagnosticos.any((d) =>
              d.descricao.toLowerCase().contains(query.toLowerCase()) ||
              d.codigoCid.toLowerCase().contains(query.toLowerCase()));

      final matchesStatus = statusFiltro == null || item.status == statusFiltro;

      return matchesQuery && matchesStatus;
    }).toList();
  }
}

class AlertasNotifier extends StateNotifier<List<AlertaClinico>> {
  final PacientesRepository _repo;

  AlertasNotifier(this._repo) : super([]) {
    carregar();
  }

  void carregar() {
    state = _repo.obterAlertas();
  }

  void marcarComoLido(String alertaId) {
    _repo.marcarAlertaLido(alertaId);
    state = _repo.obterAlertas();
  }

  void marcarTodosComoLidos() {
    _repo.marcarTodosAlertasLidos();
    state = _repo.obterAlertas();
  }
}

class PacientesRepository {
  final MockDatabase _db = MockDatabase.instance;

  List<PacienteResumo> obterResumos() {
    return _db.obterPacientesResumo();
  }

  Paciente? obterPacientePorId(String id) {
    try {
      return _db.pacientes.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<AlertaClinico> obterAlertas() {
    return List.from(_db.alertas);
  }

  void marcarAlertaLido(String alertaId) {
    final index = _db.alertas.indexWhere((a) => a.id == alertaId);
    if (index != -1) {
      _db.alertas[index] = _db.alertas[index].copyWith(lido: true);
    }
  }

  void marcarTodosAlertasLidos() {
    for (int i = 0; i < _db.alertas.length; i++) {
      _db.alertas[i] = _db.alertas[i].copyWith(lido: true);
    }
  }

  List<Agendamento> obterAgenda() {
    return List.from(_db.agenda);
  }

  void adicionarPaciente(Paciente novo) {
    _db.pacientes.add(novo);
  }
}
