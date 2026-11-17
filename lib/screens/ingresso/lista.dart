import 'package:flutter/material.dart';
import 'formulario.dart';
import '../../models/ingresso_parque.dart';
import '../../repositories/ingresso_repository.dart';
import 'package:intl/intl.dart';

class ListaIngressos extends StatefulWidget {
  final IngressoRepository repository;

  const ListaIngressos({super.key, required this.repository});

  @override
  State<ListaIngressos> createState() => ListaIngressosState();
}

class ListaIngressosState extends State<ListaIngressos> {
  static const _tituloAppBar = "Ingressos do parque";
  List<IngressoParque> _ingressos = [];
  bool _carregando = true;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final ingressos = await widget.repository.listar();
    if (!mounted) return;
    setState(() {
      _ingressos = ingressos;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloAppBar),
        actions: [
          IconButton(
            onPressed: _sincronizando ? null : _sincronizar,
            tooltip: 'Sincronizar ingressos',
            icon: _sincronizando
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
      try {
        await widget.repository.salvar(ingressoRecebido);
        await _carregar();
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Número de bilhete já cadastrado')),
        );
      }
    }
  }

  Future<void> _sincronizar() async {
    setState(() => _sincronizando = true);
    try {
      await widget.repository.sincronizar();
      await _carregar();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sincronização concluída')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem conexão com a API. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }
}

class ItemIngresso extends StatelessWidget {
  final IngressoParque ingresso;

  const ItemIngresso({super.key, required this.ingresso});

  @override
  Widget build(BuildContext context) {
    final formato = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.attractions),
        title: Text(formato.format(ingresso.valor)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bilhete nº ${ingresso.numeroBilhete}"),
            if (!ingresso.sincronizado) const Text('Pendente de sincronização'),
          ],
        ),
        trailing: Icon(
          ingresso.sincronizado ? Icons.cloud_done : Icons.cloud_off,
        ),
      ),
    );
  }
}
