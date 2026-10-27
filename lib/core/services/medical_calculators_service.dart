import 'dart:math';

// ─── 1. RISCO CARDIOVASCULAR DE FRAMINGHAM (10 ANOS) ───
class FraminghamResult {
  final double percentual; // 0..100
  final String categoria; // 'Baixo Risco', 'Risco Intermediário', 'Alto Risco'
  final String recomendacao;

  const FraminghamResult({
    required this.percentual,
    required this.categoria,
    required this.recomendacao,
  });
}

// ─── 2. ESCORE CHA2DS2-VASc ───
class Cha2ds2VascResult {
  final int pontuacao;
  final double riscoAvcAno; // % risco de AVC ao ano
  final String recomendacao;

  const Cha2ds2VascResult({
    required this.pontuacao,
    required this.riscoAvcAno,
    required this.recomendacao,
  });
}

// ─── 3. TAXA DE FILTRAÇÃO GLOMERULAR (CKD-EPI) ───
class CkdEpiResult {
  final double tfg; // mL/min/1.73m²
  final String estagio; // G1 a G5
  final String descricao;
  final String conduta;

  const CkdEpiResult({
    required this.tfg,
    required this.estagio,
    required this.descricao,
    required this.conduta,
  });
}

// ─── 4. IMC & SUPERFÍCIE CORPÓREA ───
class ImcResult {
  final double imc;
  final String classificacao;
  final double pesoIdealMin;
  final double pesoIdealMax;
  final double superficieCorporea; // m² (fórmula de Mosteller)

  const ImcResult({
    required this.imc,
    required this.classificacao,
    required this.pesoIdealMin,
    required this.pesoIdealMax,
    required this.superficieCorporea,
  });
}

class MedicalCalculatorsService {
  MedicalCalculatorsService._();

  // ────────────────── FRAMINGHAM (SBC / AHA) ──────────────────
  static FraminghamResult calcularFramingham({
    required int idade,
    required bool isFeminino,
    required int colesterolTotal,
    required int hdl,
    required int paSistolica,
    required bool tratadoHipertensao,
    required bool tabagista,
    required bool diabetico,
  }) {
    int pontos = 0;

    // Idade
    if (isFeminino) {
      if (idade >= 20 && idade <= 34) {
        pontos -= 7;
      } else if (idade <= 39) {
        pontos -= 3;
      } else if (idade <= 44) {
        pontos += 0;
      } else if (idade <= 49) {
        pontos += 3;
      } else if (idade <= 54) {
        pontos += 6;
      } else if (idade <= 59) {
        pontos += 8;
      } else if (idade <= 64) {
        pontos += 10;
      } else if (idade <= 69) {
        pontos += 12;
      } else if (idade <= 74) {
        pontos += 14;
      } else {
        pontos += 16;
      }
    } else {
      if (idade >= 20 && idade <= 34) {
        pontos -= 9;
      } else if (idade <= 39) {
        pontos -= 4;
      } else if (idade <= 44) {
        pontos += 0;
      } else if (idade <= 49) {
        pontos += 3;
      } else if (idade <= 54) {
        pontos += 6;
      } else if (idade <= 59) {
        pontos += 8;
      } else if (idade <= 64) {
        pontos += 10;
      } else if (idade <= 69) {
        pontos += 11;
      } else if (idade <= 74) {
        pontos += 12;
      } else {
        pontos += 13;
      }
    }

    // Colesterol Total
    if (colesterolTotal >= 280) {
      pontos += isFeminino ? 8 : 5;
    } else if (colesterolTotal >= 240) {
      pontos += isFeminino ? 6 : 4;
    } else if (colesterolTotal >= 200) {
      pontos += isFeminino ? 3 : 2;
    } else if (colesterolTotal >= 160) {
      pontos += isFeminino ? 1 : 1;
    }

    // HDL
    if (hdl >= 60) {
      pontos -= 1;
    } else if (hdl < 40) {
      pontos += 2;
    } else if (hdl < 50 && isFeminino) {
      pontos += 1;
    }

    // PA Sistólica
    if (paSistolica >= 160) {
      pontos += tratadoHipertensao ? (isFeminino ? 6 : 3) : (isFeminino ? 4 : 2);
    } else if (paSistolica >= 140) {
      pontos += tratadoHipertensao ? (isFeminino ? 5 : 2) : (isFeminino ? 3 : 1);
    } else if (paSistolica >= 130) {
      pontos += tratadoHipertensao ? (isFeminino ? 4 : 2) : (isFeminino ? 2 : 1);
    } else if (paSistolica >= 120) {
      pontos += tratadoHipertensao ? (isFeminino ? 3 : 1) : 0;
    }

    // Tabagismo
    if (tabagista) {
      pontos += isFeminino ? 7 : 5;
    }

    // Diabetes
    if (diabetico) {
      pontos += 2;
    }

    double percentual;
    if (pontos <= 0) {
      percentual = 1.0;
    } else if (pontos <= 4) {
      percentual = 2.0;
    } else if (pontos <= 8) {
      percentual = 5.0;
    } else if (pontos <= 12) {
      percentual = 10.0;
    } else if (pontos <= 15) {
      percentual = 16.0;
    } else if (pontos <= 17) {
      percentual = 21.0;
    } else {
      percentual = min(35.0, 20.0 + (pontos - 17) * 2.5);
    }

    String categoria;
    String recomendacao;
    if (percentual < 10.0) {
      categoria = 'Baixo Risco (< 10%)';
      recomendacao = 'Manter estilo de vida saudável e monitoramento anual de PA e perfil lipídico.';
    } else if (percentual < 20.0) {
      categoria = 'Risco Intermediário (10% - 20%)';
      recomendacao = 'Meta de LDL < 100 mg/dL. Considerar estatina de intensidade moderada e metas estritas de PA.';
    } else {
      categoria = 'Alto Risco (> 20%)';
      recomendacao = 'Indicação de estatina de alta potência (Atorvastatina 40-80mg ou Rosuvastatina 20mg). Meta de LDL < 70 mg/dL.';
    }

    return FraminghamResult(
      percentual: percentual,
      categoria: categoria,
      recomendacao: recomendacao,
    );
  }

  // ────────────────── CHA2DS2-VASc ──────────────────
  static Cha2ds2VascResult calcularCha2ds2Vasc({
    required int idade,
    required bool isFeminino,
    required bool insuficienciaCardiaca,
    required bool hipertensao,
    required bool diabetes,
    required bool avcOuAitPrevio,
    required bool doencaVascular,
  }) {
    int pontos = 0;

    if (insuficienciaCardiaca) {
      pontos += 1;
    }
    if (hipertensao) {
      pontos += 1;
    }
    if (idade >= 75) {
      pontos += 2;
    } else if (idade >= 65) {
      pontos += 1;
    }
    if (diabetes) {
      pontos += 1;
    }
    if (avcOuAitPrevio) {
      pontos += 2;
    }
    if (doencaVascular) {
      pontos += 1;
    }
    if (isFeminino) {
      pontos += 1;
    }

    final Map<int, double> tabelaRisco = {
      0: 0.2,
      1: 0.6,
      2: 2.2,
      3: 3.2,
      4: 4.8,
      5: 7.2,
      6: 9.7,
      7: 11.2,
      8: 12.5,
      9: 15.2,
    };

    final risco = tabelaRisco[min(9, pontos)] ?? 15.2;

    String recomendacao;
    final pontosSemSexo = isFeminino ? pontos - 1 : pontos;

    if (pontosSemSexo == 0) {
      recomendacao = 'Baixo risco de AVC. Anticoagulação oral não recomendada (Classe III).';
    } else if (pontosSemSexo == 1) {
      recomendacao = 'Risco intermediário. Anticoagulação oral com DOACs deve ser considerada (Classe IIa).';
    } else {
      recomendacao = 'Alto risco de tromboembolismo. Anticoagulação oral plena fortemente indicada (Classe I). Preferência por DOACs sobre Varfarina.';
    }

    return Cha2ds2VascResult(
      pontuacao: pontos,
      riscoAvcAno: risco,
      recomendacao: recomendacao,
    );
  }

  // ────────────────── CKD-EPI (2021) ──────────────────
  static CkdEpiResult calcularCkdEpi({
    required double creatinina,
    required int idade,
    required bool isFeminino,
  }) {
    if (creatinina <= 0) {
      return const CkdEpiResult(
        tfg: 0,
        estagio: 'Indeterminado',
        descricao: 'Valor inválido de creatinina',
        conduta: 'Informe um valor válido de creatinina sérica.',
      );
    }

    final kappa = isFeminino ? 0.7 : 0.9;
    final alpha = isFeminino ? -0.241 : -0.302;
    final genderFactor = isFeminino ? 1.012 : 1.0;

    final ratio = creatinina / kappa;
    final minPart = pow(min(ratio, 1.0), alpha);
    final maxPart = pow(max(ratio, 1.0), -1.200);
    final agePart = pow(0.9938, idade);

    final tfg = 142 * minPart * maxPart * agePart * genderFactor;
    final tfgArredondada = double.parse(tfg.toStringAsFixed(1));

    String estagio;
    String descricao;
    String conduta;

    if (tfg >= 90) {
      estagio = 'Estágio G1';
      descricao = 'Função renal normal ou elevada (TFG ≥ 90)';
      conduta = 'Dose plena de medicações. Investigar albuminúria se hipertenso/diabético.';
    } else if (tfg >= 60) {
      estagio = 'Estágio G2';
      descricao = 'Discreta redução da TFG (60 - 89)';
      conduta = 'Seguimento regular. Manter controle pressórico e glicêmico estritos.';
    } else if (tfg >= 45) {
      estagio = 'Estágio G3a';
      descricao = 'Redução leve a moderada (45 - 59)';
      conduta = 'Ajustar posologia de fármacos nefrotóxicos. Metformina pode ser mantida com cautela.';
    } else if (tfg >= 30) {
      estagio = 'Estágio G3b';
      descricao = 'Redução moderada a grave (30 - 44)';
      conduta = 'Suspender ou reduzir Metformina pela metade (máx 1000mg/dia). Atenção a AINEs.';
    } else if (tfg >= 15) {
      estagio = 'Estágio G4';
      descricao = 'Redução grave da TFG (15 - 29)';
      conduta = 'Suspender Metformina. Avaliação conjunta com Nefrologista. Preparo para TRS.';
    } else {
      estagio = 'Estágio G5';
      descricao = 'Falência Renal Terminal (TFG < 15)';
      conduta = 'Indicação iminente de Terapia Renal Substitutiva (Hemodiálise ou Transplante).';
    }

    return CkdEpiResult(
      tfg: tfgArredondada,
      estagio: estagio,
      descricao: descricao,
      conduta: conduta,
    );
  }

  // ────────────────── IMC & SUPERFÍCIE CORPÓREA ──────────────────
  static ImcResult calcularImc({
    required double pesoKg,
    required double alturaMetros,
  }) {
    if (alturaMetros <= 0 || pesoKg <= 0) {
      return const ImcResult(
        imc: 0,
        classificacao: 'Indeterminado',
        pesoIdealMin: 0,
        pesoIdealMax: 0,
        superficieCorporea: 0,
      );
    }

    final imc = pesoKg / (alturaMetros * alturaMetros);
    final imcArredondado = double.parse(imc.toStringAsFixed(1));

    String classificacao;
    if (imc < 18.5) {
      classificacao = 'Baixo Peso';
    } else if (imc < 25.0) {
      classificacao = 'Eutrófico (Peso Normal)';
    } else if (imc < 30.0) {
      classificacao = 'Sobrepeso (Pré-obesidade)';
    } else if (imc < 35.0) {
      classificacao = 'Obesidade Grau I';
    } else if (imc < 40.0) {
      classificacao = 'Obesidade Grau II (Severa)';
    } else {
      classificacao = 'Obesidade Grau III (Mórbida)';
    }

    final pesoIdealMin = 18.5 * (alturaMetros * alturaMetros);
    final pesoIdealMax = 24.9 * (alturaMetros * alturaMetros);

    final alturaCm = alturaMetros * 100;
    final sc = sqrt((alturaCm * pesoKg) / 3600.0);

    return ImcResult(
      imc: imcArredondado,
      classificacao: classificacao,
      pesoIdealMin: double.parse(pesoIdealMin.toStringAsFixed(1)),
      pesoIdealMax: double.parse(pesoIdealMax.toStringAsFixed(1)),
      superficieCorporea: double.parse(sc.toStringAsFixed(2)),
    );
  }
}
