import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static final ShareService instance = ShareService._internal();
  factory ShareService() => instance;
  ShareService._internal();

  Future<void> compartilharTexto(String texto, {String? assunto}) async {
    try {
      await Share.share(texto, subject: assunto);
    } catch (_) {}
  }

  Future<void> compartilharArquivoPdf({
    required Uint8List bytes,
    required String nomeArquivo,
    String? mensagem,
  }) async {
    try {
      final xfile = XFile.fromData(
        bytes,
        name: nomeArquivo,
        mimeType: 'application/pdf',
      );
      await Share.shareXFiles([xfile], text: mensagem);
    } catch (_) {}
  }
}
