# Parque

Aplicativo Flutter para cadastro de ingressos de parque de diversões, com
persistência offline-first em SQLite e sincronização manual com uma API Dart e
PostgreSQL.

Projeto avaliativo da disciplina de Programação para Dispositivos Móveis II.

## Arquitetura

- **SQLite:** o ingresso é salvo primeiro no dispositivo como pendente.
- **Repository:** coordena a persistência local e remota.
- **Service:** faz a comunicação HTTP com a API.
- **PostgreSQL:** armazena os ingressos sincronizados na API.
- **Sincronização manual:** o botão na barra superior envia os pendentes e
  atualiza a base local com os registros remotos.

## Executar o aplicativo

```bash
flutter pub get
flutter run
```

Por padrão, o aplicativo usa a API publicada em
`https://parque-api-cmuk.onrender.com`. Para usar uma API local, informe outra
URL com `--dart-define=API_URL=http://10.0.2.2:8080` no emulador Android.

## Executar a API

A API exige um PostgreSQL e lê a conexão da variável `DATABASE_URL`.

API publicada: https://parque-api-cmuk.onrender.com

```bash
cd api
dart pub get
DATABASE_URL=postgresql://usuario:senha@localhost:5432/parque dart run bin/server.dart
```

A tabela `ingressos` é criada automaticamente ao iniciar a API.

## Rotas da API

| Método | Rota | Descrição |
| --- | --- | --- |
| `GET` | `/health` | Confirma que a API está disponível. |
| `GET` | `/ingressos` | Lista os ingressos persistidos no PostgreSQL. |
| `POST` | `/ingressos` | Cria ou atualiza um ingresso pelo número do bilhete. |

Corpo de `POST /ingressos`:

```json
{
  "valor": 45.0,
  "numeroBilhete": 1001
}
```

## Testes

```bash
flutter analyze
flutter test
cd api
dart analyze
dart test
```

O arquivo `render.yaml` configura a publicação da API e de um PostgreSQL no
Render. O banco gratuito do Render expira após 30 dias.
