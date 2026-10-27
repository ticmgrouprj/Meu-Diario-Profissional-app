import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/paciente_model.dart';


class CID10Service {
  static final CID10Service instance = CID10Service._internal();
  factory CID10Service() => instance;
  CID10Service._internal();

  List<Diagnostico> _cache = [];
  bool _isLoading = false;

  Future<void> carregarCatalogo() async {
    if (_cache.isNotEmpty || _isLoading) return;
    _isLoading = true;
    try {
      final jsonString = await rootBundle.loadString('assets/data/cid10.json');
      final List<dynamic> data = json.decode(jsonString);
      _cache = data.map((item) {
        return Diagnostico(
          codigoCid: item['codigo']?.toString() ?? '',
          descricao: item['nome']?.toString() ?? '',
        );
      }).toList();
    } catch (_) {
      // Fallback em caso de erro na leitura do bundle
      _cache = const [
        Diagnostico(codigoCid: 'I10', descricao: 'Hipertensão essencial (primária)'),
        Diagnostico(codigoCid: 'E11', descricao: 'Diabetes mellitus não-insulino-dependente'),
        Diagnostico(codigoCid: 'E10', descricao: 'Diabetes mellitus insulino-dependente'),
        Diagnostico(codigoCid: 'E78.0', descricao: 'Hipercolesterolemia pura'),
        Diagnostico(codigoCid: 'E66', descricao: 'Obesidade mórbida'),
        Diagnostico(codigoCid: 'I50.0', descricao: 'Insuficiência cardíaca congestiva'),
        Diagnostico(codigoCid: 'E03.9', descricao: 'Hipotireoidismo não especificado'),
        Diagnostico(codigoCid: 'J45', descricao: 'Asma brônquica'),
        Diagnostico(codigoCid: 'F41.1', descricao: 'Ansiedade generalizada'),
      ];
    } finally {
      _isLoading = false;
    }
  }

  String _normalizar(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .trim();
  }

  Future<List<Diagnostico>> buscar(String termo, {int limite = 12}) async {
    if (termo.trim().length < 2) return [];
    if (_cache.isEmpty) {
      await carregarCatalogo();
    }

    final t = _normalizar(termo);
    final tCod = t.replaceAll('.', '');
    final List<Diagnostico> porCodigo = [];
    final List<Diagnostico> porNome = [];

    for (final item in _cache) {
      if (porCodigo.length + porNome.length >= limite * 2) break;
      final cod = _normalizar(item.codigoCid).replaceAll('.', '');
      if (cod.startsWith(tCod)) {
        porCodigo.add(item);
      } else if (_normalizar(item.descricao).contains(t)) {
        porNome.add(item);
      }
    }

    final resultados = [...porCodigo, ...porNome];
    if (resultados.length > limite) {
      return resultados.sublist(0, limite);
    }
    return resultados;
  }
}
