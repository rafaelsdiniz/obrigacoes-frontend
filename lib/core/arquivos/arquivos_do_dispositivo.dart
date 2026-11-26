import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ArquivoEscolhido = ({String nome, int? tamanho, Future<Uint8List> Function() ler});

ArquivoEscolhido arquivoSolto(XFile arquivo) => (nome: arquivo.name, tamanho: null, ler: arquivo.readAsBytes);

final arquivosDoDispositivoProvider = Provider((ref) => const ArquivosDoDispositivo());

class ArquivosDoDispositivo {
  const ArquivosDoDispositivo();

  Future<ArquivoEscolhido?> escolher({required List<String> extensoes}) async {
    final arquivo = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: extensoes);
    if (arquivo == null) {
      return null;
    }
    return (nome: arquivo.name, tamanho: await arquivo.length(), ler: arquivo.readAsBytes);
  }

  Future<bool> baixar(Uri endereco) =>
      launchUrl(endereco, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
}
