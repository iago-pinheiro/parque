import 'package:flutter/material.dart';
import 'formulario.dart';
import '../../models/ingresso_parque.dart';
import 'package:intl/intl.dart';

class ListaIngressos extends StatefulWidget {
  const ListaIngressos({super.key});

  @override
  State<ListaIngressos> createState() => ListaIngressosState();
}

class ListaIngressosState extends State<ListaIngressos> {
  static const _tituloAppBar = "Ingressos do parque";
  final List<IngressoParque> _ingressos = <IngressoParque>[
    IngressoParque(45.00, 1001),
    IngressoParque(80.50, 1002),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tituloAppBar)),
      body: ListView.builder(
        itemCount: _ingressos.length,
        itemBuilder: (context, indice) {
          final ingresso = _ingressos[indice];
          return ItemIngresso(ingresso: ingresso);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const FormularioIngresso();
              },
            ),
          ).then((ingressoRecebido) => _atualiza(ingressoRecebido));
        },
        child: const Icon(Icons.attractions),
      ),
    );
  }

  Future<void> _atualiza(IngressoParque? ingressoRecebido) async {
    if (ingressoRecebido != null) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _ingressos.add(ingressoRecebido);
      });
    }
  }
}

class ItemIngresso extends StatelessWidget {
  final IngressoParque ingresso;

  const ItemIngresso({super.key, required this.ingresso});

  @override
  Widget build(BuildContext context) {
    NumberFormat formato = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.attractions),
        title: Text(formato.format(ingresso.valor).toString()),
        subtitle: Text("Bilhete nº ${ingresso.numeroBilhete}"),
      ),
    );
  }
}
