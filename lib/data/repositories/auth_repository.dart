import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/paciente_model.dart';
import '../mock/mock_database.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final currentProfissionalProvider = StateProvider<Profissional?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.currentProfissional;
});

class AuthRepository {
  Profissional? _currentProfissional = MockDatabase.instance.profissionalDemo;

  Profissional? get currentProfissional => _currentProfissional;
  bool get isAuthenticated => _currentProfissional != null;

  Future<bool> login(String email, String senha) async {
    // Simulação com validação do mock
    if (email.trim().isNotEmpty && senha.length >= 4) {
      _currentProfissional = MockDatabase.instance.profissionalDemo;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentProfissional = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
  }

  Future<void> atualizarPerfil(Profissional atualizado) async {
    _currentProfissional = atualizado;
  }
}
