import 'package:flutter/material.dart';
import '../../components/editor.dart';
import '../../models/ingresso_parque.dart';

class FormularioIngresso extends StatefulWidget {
  const FormularioIngresso({super.key});

  @override
  State<FormularioIngresso> createState() => FormularioIngressoState();
}

class FormularioIngressoState extends State<FormularioIngresso> {
  final TextEditingController _controladorCampoNumeroBilhete =
      TextEditingController();
  final TextEditingController _controladorCampoValor = TextEditingController();

  static const _tituloAppBar = 'Criando ingresso';
  static const _rotuloCampoValor = 'Valor do ingresso';
  static const _dicaCampoValor = '0,00';

  static const _rotuloCampoNumeroBilhete = 'Número do bilhete';
  static const _dicaCampoNumeroBilhete = '0000';
  static const _textoBotaoConfirmar = 'Confirmar';

  @override
  void dispose() {
    _controladorCampoNumeroBilhete.dispose();
    _controladorCampoValor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tituloAppBar)),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Editor(
              controlador: _controladorCampoNumeroBilhete,
              rotulo: _rotuloCampoNumeroBilhete,
              dica: _dicaCampoNumeroBilhete,
            ),

            Editor(
              controlador: _controladorCampoValor,
              rotulo: _rotuloCampoValor,
              dica: _dicaCampoValor,
              icone: Icons.attractions,
            ),

            ElevatedButton(
              onPressed: () {
                _criaIngresso(
                  context,
                  _controladorCampoNumeroBilhete,
                  _controladorCampoValor,
                );
              },
              child: const Text(_textoBotaoConfirmar),
            ),
          ],
        ),
      ),
    );
  }
}

void _criaIngresso(
  BuildContext context,
  TextEditingController controladorCampoNumeroBilhete,
  TextEditingController controladorCampoValor,
) {
  final int? numeroBilhete = int.tryParse(controladorCampoNumeroBilhete.text);
  final double? valor = double.tryParse(controladorCampoValor.text);

  if (numeroBilhete != null && valor != null) {
    final ingressoCriado = IngressoParque(valor, numeroBilhete);
    Navigator.pop(context, ingressoCriado);
  }
}
