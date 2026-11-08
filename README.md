# Saúde Intestinal — versão Flutter/Dart

Protótipo de aplicativo móvel para o registro e o acompanhamento de sintomas intestinais, alimentação e hábitos. Este repositório contém **a implementação tradicional, desenvolvida em Flutter/Dart**, com Firebase Authentication para as contas de usuário e Cloud Firestore para armazenar os registros.

Faz parte do Trabalho de Conclusão de Curso *Análise de produtividade e viabilidade técnica: desenvolvimento tradicional vs. plataformas no-code em sistemas de mHealth*, de Giovana Olivo Cittadin, com orientação de Ana Cláudia Garcia Barbosa, Ciência da Computação, Universidade do Extremo Sul Catarinense (Unesc), 2026. O trabalho compara esta versão com outra construída no FlutterFlow, que **não está neste repositório** (projeto privado, verificado na prévia do navegador). As telas das duas versões estão no texto do trabalho.

> Protótipo instrumental para comparar abordagens de desenvolvimento. Não realiza diagnóstico, não substitui acompanhamento profissional e foi testado somente com dados fictícios.

## Funcionalidades

- Criar conta, entrar com e-mail e senha, recuperar a senha, manter a sessão e sair.
- Registrar sintomas (tipo, intensidade, data e hora, observação opcional); consultar, buscar, filtrar e excluir.
- Registrar refeições (tipo, alimentos, data e hora, observação opcional); consultar e excluir.
- Registrar hábitos: evacuação, consistência pela Escala de Bristol, sono, atividade física e estresse.
- Histórico cronológico único de sintomas, refeições e hábitos, com filtro por categoria.
- Tela inicial com resumo dos registros, frequência dos sintomas nos últimos sete dias e associações temporais descritivas (com pelo menos cinco registros de cada categoria). Elas não representam diagnóstico nem causalidade.

## Ambiente utilizado

Windows 11, Flutter 3.47.2, Dart 3.13.2, Android SDK (Platform 36, Build-Tools 36.0.0) e emulador Medium Phone com Android 15 (API 35). As versões dos pacotes estão em [`pubspec.lock`](pubspec.lock).

## Como executar

Comandos para Windows (PowerShell).

**1. Instalar:** [Git](https://git-scm.com/downloads), o [Flutter SDK](https://docs.flutter.dev/get-started/install) (guia oficial, destino Windows e Android) e o [Android Studio](https://developer.android.com/studio). No Android Studio, em **SDK Manager > SDK Tools**, marque **Android SDK Command-line Tools**.

**2. Verificar o ambiente:**

```powershell
flutter doctor --android-licenses
flutter doctor
```

Aceite as licenças. Devem estar corretos **Flutter**, **Android toolchain** e **Android Studio**; avisos sobre Chrome ou desktop não impedem a execução.

**3. Preparar o dispositivo (escolha uma opção):** crie e inicie um emulador **Medium Phone** com **Android 15 (API 35)** em **Device Manager > Create Device** no Android Studio, ou conecte um celular Android por cabo USB com **Depuração USB** ativada.

**4. Baixar e executar:**

```powershell
git clone https://github.com/giovanaolivo/tcc.git
cd <pasta-do-repositorio>
flutter pub get
flutter devices
flutter run
```

Com mais de um dispositivo, use `flutter run -d <id>` (o id aparece em `flutter devices`). No Visual Studio Code, também é possível abrir o arquivo lib/main.dart e usar **F5**. A primeira execução pode demorar, e é preciso acesso à internet (dependências, autenticação e Firestore).

**5. Usar:** a configuração do Firebase do protótipo está em [`lib/firebase_options.dart`](lib/firebase_options.dart) e [`android/app/google-services.json`](android/app/google-services.json). Crie uma conta pela tela do aplicativo; o repositório **não fornece credenciais de teste**. Use somente dados fictícios.

## Roteiro rápido de verificação

1. Crie uma conta de teste ou entre com uma já criada.
2. Registre um sintoma, uma refeição e os hábitos do dia, com informações fictícias.
3. Confira os registros nas telas de consulta e no histórico; experimente os filtros e a busca de sintomas.
4. Na tela inicial, veja os indicadores. As associações temporais exigem pelo menos cinco registros em **cada** categoria.
5. Saia e entre novamente para verificar a permanência dos registros. A recuperação de senha exige um e-mail ao qual você tenha acesso.

## Problemas comuns

| Sintoma | O que fazer |
| --- | --- |
| `flutter` não é reconhecido | Reabra o terminal e confira se `flutter\bin` está no `PATH`. |
| Erro de licenças do Android | Execute `flutter doctor --android-licenses`; se falhar, instale o *Android SDK Command-line Tools*. |
| "Building with plugins requires symlink support" | Ative o Modo de Desenvolvedor do Windows (`start ms-settings:developers`). |
| `flutter devices` não lista o emulador | Inicie o emulador e aguarde o Android carregar por completo. |

## Organização do código e dos dados

| Pasta | Conteúdo |
| --- | --- |
| `lib/models/` | Registros de sintomas, alimentação e hábitos. |
| `lib/services/` | Autenticação e acesso ao Cloud Firestore. |
| `lib/screens/` | Telas de entrada, registro, consulta, histórico e início. |
| `lib/widgets/` | Navegação compartilhada. |

Coleções do Firestore: `registros_sintomas`, `registros_alimentacao` e `registros_habitos`. Cada documento tem `usuarioId` (conta autenticada) e `dataHora` (ordem cronológica). Aqui, `alimentos` é uma lista de textos, e o registro de hábitos usa um identificador formado pelo usuário e pela data, de modo que uma nova gravação no mesmo dia substitui a anterior.
