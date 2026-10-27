# Meu Diário Profissional (Mobile Flutter)

Aplicativo mobile nativo em **Flutter 3.44+ (Dart 3.12+)** desenvolvido para médicos e profissionais de saúde, focado em ergonomia para smartphones, telemetria clínica tátil e integração direta com o paciente.

---

## 🚀 Funcionalidades Principais

- **Biometria Nativa:** Desbloqueio seguro e instantâneo por Face ID ou Impressão Digital (`local_auth`).
- **Dashboard & Triagem Clínica:** Classificação por gravidade (Crítico, Atenção, Estável) conforme diretrizes SBC e SBD com busca instantânea.
- **Prontuário 360° em Abas Móveis:**
  - **Vitals:** Gráficos interativos táteis de PA sistólica/diastólica com meta clínica 120x80 mmHg, glicemia e IMC via `fl_chart`.
  - **Medicamentos:** Cronograma diário com alarmes e taxa de adesão 7 dias.
  - **Documentos:** Histórico categorizado de exames laboratoriais, laudos e receitas.
  - **SOAP:** Histórico de consultas anteriores com expansão em sanfona.
- **Comunicação Direta & Avisos Clínicos aos Pacientes:**
  - **Avisos Rápidos Pré-configurados:** Alertas de pico pressórico/glicêmico, avisos de medicação/adesão, lembretes de retorno e orientações de jejum/preparo para exames.
  - **Canais de Envio Selecionáveis:** Notificação Push no App do Paciente (*Meu Diário de Saúde*), envio direto para o **WhatsApp** do paciente ou ambos simultaneamente.
  - **Aba "Avisos" no Prontuário 360°:** Histórico completo de comunicações enviadas com status de entrega e botão de reenvio.
- **Ações Clínicas & Emissão em PDF A4:**

  - **Evolução SOAP:** Anamnese em 4 passos com busca no catálogo oficial DATASUS CID-10 (`cid10.json`).
  - **Prescritor Digital:** Adição de fármacos, posologias e código QR de importação.
  - **Atestados Médicos CFM:** Emissão com conformidade às resoluções CFM 1.658/02 e 1.851/08.
  - **Pedidos de Exames:** Requisições laboratoriais com pacotes de rotina.
  - **Compartilhamento 1-Toque:** Envio direto do PDF A4 com carimbo oficial para o WhatsApp do paciente (`share_plus`).
- **Hardware & Câmera:**
  - **Scanner QR:** Leitor de alta velocidade com a câmera traseira (`mobile_scanner`).
  - **Alertas de Emergência:** Notificações locais com som e vibração háptica (`HapticFeedback.heavyImpact()`).
  - **Teleconsulta:** Atendimento virtual com PIP do médico, cronômetro e anotações clínicas integradas.

---

## 🛠️ Como Executar

### 1. Requisitos
- Flutter SDK versão 3.44 ou superior.
- Smartphone físico conectado via USB com depuração ativada, ou emulador Android / iOS.

### 2. Instalação de Dependências
```bash
flutter pub get
```

### 3. Validação Estática e Testes
```bash
flutter analyze
flutter test
```

### 4. Executar no Smartphone
```bash
flutter run
```

### 5. Compilar APK de Depuração
```bash
flutter build apk --debug
```

---

## 📂 Estrutura Arquitetural

```
lib/
├── main.dart                          # Inicialização, tema e injeção Riverpod
├── core/
│   ├── theme/                         # Tokens Deep Navy, Medical Teal e Tipografia
│   ├── router/                        # GoRouter com navegação por abas e rotas clínicas
│   ├── services/                      # Biometria, Notificações, Gerador de PDF e Share
│   └── widgets/                       # Cards táteis, Badges de risco e Botões
├── data/
│   ├── models/                        # Modelos fortemente tipados (Paciente, Vitals, SOAP, PDF)
│   ├── mock/                          # Base determinística com 6 perfis de pacientes reais
│   └── repositories/                  # Repositórios de dados e Riverpod Notifiers
└── presentation/
    ├── auth/                          # Login biométrico e Credenciamento CRM
    ├── home/                          # Dashboard de triagem, Alertas, Agenda e Perfil
    ├── paciente/                      # Ficha clínica 360° com gráficos táteis fl_chart
    ├── clinical_actions/              # SOAP, Prescrição Digital, Atestado CFM e Exames
    └── tools/                         # Scanner de QR Code e Sala de Teleconsulta
```
