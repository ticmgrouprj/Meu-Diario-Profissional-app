import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Cores Primárias Clínicas
  static const Color primary = Color(0xFF0284C7); // Medical Teal / Sky
  static const Color primaryDark = Color(0xFF0369A1);
  static const Color primaryLight = Color(0xFFE0F2FE);
  static const Color primaryAccent = Color(0xFF38BDF8);

  // Paleta Navy & Slate
  static const Color navyDark = Color(0xFF0F172A); // Slate 900
  static const Color navyMedium = Color(0xFF1E293B); // Slate 800
  static const Color slateCard = Color(0xFF334155); // Slate 700
  static const Color slateTextMuted = Color(0xFF64748B); // Slate 500
  static const Color slateBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color slateLight = Color(0xFFF1F5F9); // Slate 100

  // Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0B1120);

  // Status de Risco Clínico
  // Crítico (PAs elevadas, emergências)
  static const Color riskCritico = Color(0xFFEF4444);
  static const Color riskCriticoBg = Color(0xFFFEE2E2);
  static const Color riskCriticoText = Color(0xFF991B1B);

  // Atenção (Quadro limítrofe, remédio atrasado)
  static const Color riskAtencao = Color(0xFFF59E0B);
  static const Color riskAtencaoBg = Color(0xFFFEF3C7);
  static const Color riskAtencaoText = Color(0xFF92400E);

  // Estável (Controlado, metas atingidas)
  static const Color riskEstavel = Color(0xFF10B981);
  static const Color riskEstavelBg = Color(0xFFD1FAE5);
  static const Color riskEstavelText = Color(0xFF065F46);

  // Auxiliares
  static const Color purpleConsult = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color divider = Color(0xFFE2E8F0);
}
