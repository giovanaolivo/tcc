# Saúde Intestinal — versão Flutter/Dart

Protótipo de aplicativo móvel para o registro e o acompanhamento de sintomas intestinais, alimentação e hábitos. Este repositório contém **a implementação tradicional, desenvolvida em Flutter/Dart**. Ela integra Firebase Authentication para as contas de usuário e Cloud Firestore para armazenar os registros.

Este código faz parte do Trabalho de Conclusão de Curso *Análise de produtividade e viabilidade técnica: desenvolvimento tradicional vs. plataformas no-code em sistemas de mHealth*, de Giovana Olivo Cittadin, com orientação de Ana Cláudia Garcia Barbosa, no curso de Ciência da Computação da Universidade do Extremo Sul Catarinense (Unesc), 2026.

O trabalho compara esta implementação com uma segunda versão construída no FlutterFlow, sem código Dart personalizado. **A versão FlutterFlow não está neste repositório**: ela foi desenvolvida na plataforma, em projeto privado, e verificada em sua prévia no navegador. As telas das duas versões são apresentadas no texto do trabalho.

> O aplicativo é um protótipo instrumental para a comparação entre abordagens de desenvolvimento. Não realiza diagnóstico, não substitui acompanhamento profissional e foi testado somente com dados fictícios.

## Funcionalidades desta versão

- Criar conta, entrar com e-mail e senha, solicitar recuperação de senha, manter a sessão e sair.
- Registrar sintomas com tipo, intensidade, data e hora e observação opcional; consultar, buscar, filtrar e excluir esses registros.
- Registrar refeições com tipo, lista de alimentos, data e hora e observação opcional; consultar e excluir refeições.
- Registrar hábitos relacionados à evacuação, consistência das fezes pela Escala de Bristol, sono, atividade física e nível de estresse.
- Consultar sintomas, refeições e hábitos em um histórico cronológico único, com filtro por categoria.
- Visualizar na tela inicial um resumo dos registros, a frequência dos sintomas nos últimos sete dias e associações temporais descritivas quando houver pelo menos cinco registros de cada categoria. Essas associações não representam diagnóstico nem relação de causa e efeito.

## Ambiente e pré-requisitos

O desenvolvimento foi realizado no Windows 11 com Flutter SDK 3.47.2, Dart SDK 3.13.2, Android SDK e Android Emulator. A execução foi verificada em um dispositivo virtual Medium Phone com Android 15 (API 35).

Para executar o projeto, é necessário ter o Flutter instalado, um dispositivo Android ou emulador configurado e acesso à internet para a autenticação e o Firestore. O Visual Studio Code é opcional. As versões dos pacotes usados pelo projeto estão registradas em [`pubspec.lock`](pubspec.lock).

## Como executar

No terminal, a partir da pasta deste repositório:

```bash
flutter doctor
flutter pub get
flutter devices
flutter run
```

Se houver mais de um dispositivo disponível, use `flutter run -d <id-do-dispositivo>`, substituindo o identificador pelo exibido em `flutter devices`. No Visual Studio Code, também é possível selecionar o dispositivo e iniciar a execução com **F5**.

Os arquivos [`lib/firebase_options.dart`](lib/firebase_options.dart) e [`android/app/google-services.json`](android/app/google-services.json) contêm a configuração utilizada no protótipo. Para testar, crie uma conta pela própria tela do aplicativo; o repositório **não fornece credenciais de teste**. Use somente dados fictícios, nunca dados reais de pacientes.

## Roteiro rápido de verificação

1. Na tela de entrada, crie uma conta de teste ou entre com uma conta já criada.
2. Registre um sintoma, uma refeição e os hábitos do dia, usando apenas informações fictícias.
3. Confira os registros nas respectivas telas de consulta e no histórico; experimente os filtros do histórico e a busca da lista de sintomas.
4. Volte à tela inicial para visualizar os indicadores. As associações temporais descritivas dependem de pelo menos cinco registros em **cada** uma das três categorias.
5. Saia da conta e entre novamente para verificar a permanência dos registros. A recuperação de senha depende de um endereço de e-mail ao qual você tenha acesso.

## Organização do código e dos dados

| Pasta | Conteúdo |
| --- | --- |
| `lib/models/` | Representação dos registros de sintomas, alimentação e hábitos. |
| `lib/services/` | Autenticação e acesso ao Cloud Firestore. |
| `lib/screens/` | Telas de entrada, registro, consulta, histórico e início. |
| `lib/widgets/` | Navegação compartilhada entre as telas. |

As coleções utilizadas no Firestore são `registros_sintomas`, `registros_alimentacao` e `registros_habitos`. Os documentos incluem `usuarioId` para associá-los à conta autenticada e `dataHora` para apresentar os registros em ordem cronológica. Nesta versão, `alimentos` é gravado como lista de textos. O registro de hábitos usa um identificador formado pelo usuário e pela data; uma nova gravação para o mesmo usuário e dia substitui o documento anterior.