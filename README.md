# parque

Aplicação Flutter de controle de ingressos de parque de diversões.

Avaliação prática da disciplina de Programação para Dispositivos Móveis II.

## Como rodar

1. Instale o Flutter: https://docs.flutter.dev/get-started/install

2. Abra o terminal na pasta do projeto:

```bash
git clone https://github.com/iago-pinheiro/parque.git
cd parque
```

3. Baixe as dependências:

```bash
flutter pub get
```

4. Rode no navegador:

```bash
flutter run -d chrome --web-port 8080
```

O app abre em `http://localhost:8080`.

Para rodar em outro dispositivo, use `flutter devices` para ver as opções
(ex.: `flutter run -d linux`).

## Como usar

- A tela inicial mostra a lista de ingressos.
- Toque no botão roxo no canto inferior direito para abrir o formulário.
- Preencha o número do bilhete e o valor (**com ponto**, ex.: `12.50`) e toque em **Confirmar**.
- Após 1 segundo o ingresso aparece na lista.
