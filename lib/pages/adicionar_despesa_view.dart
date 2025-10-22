import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mvvm/despesa_viewmodel.dart';
import '../mvvm/categoria_viewmodel.dart';
import '../mvvm/usuario_viewmodel.dart';
import '../models/despesa/despesa.dart';
import '../models/categoria/categoria.dart';

class AdicionarDespesaView extends StatefulWidget {
  final Despesa? despesa;
  const AdicionarDespesaView({super.key, this.despesa});

  @override
  State<AdicionarDespesaView> createState() => _AdicionarDespesaViewState();
}

class _AdicionarDespesaViewState extends State<AdicionarDespesaView> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _data = DateTime.now();
  int? _categoriaId;
  List<Categoria> _categorias = [];
  bool _isLoading = false;
  String _pagamentoTipo = 'AVISTA';
  int _parcelasTotal = 1;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    if (widget.despesa != null) {
      final d = widget.despesa!;
      _descricaoController.text = d.descricao;
      _valorController.text = d.valor.toString();
      _data = d.data;
      _categoriaId = d.categoriaId;
      _pagamentoTipo = d.pagamentoTipo;
      _parcelasTotal = d.parcelasTotal;
    }
  }

  Future<void> _loadCategorias() async {
    final categoriaVM = Provider.of<CategoriaViewModel>(context, listen: false);
    final categorias = await categoriaVM.getCategoriasPorTipo('DESPESA');
    setState(() {
      _categorias = categorias;
      if (_categorias.isNotEmpty) _categoriaId = _categorias.first.id;
    });
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final usuarioVM = Provider.of<UsuarioViewModel>(context, listen: false);
    final despesaVM = Provider.of<DespesaViewModel>(context, listen: false);

    if (usuarioVM.usuarioAtual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final valorStr = _valorController.text.replaceAll(',', '.');
    final valor = double.tryParse(valorStr) ?? 0.0;

    if (widget.despesa != null) {
      final atual = widget.despesa!;
      atual.descricao = _descricaoController.text.trim();
      atual.valor = valor;
      atual.data = _data;
      atual.categoriaId = _categoriaId;

      await despesaVM.atualizarDespesa(atual);

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Despesa atualizada')),
      );
      return;
    }

    if (_pagamentoTipo == 'PARCELADO' && widget.despesa == null) {
      // Create N parcel entries
      final parcelaValor =
          double.parse((valor / _parcelasTotal).toStringAsFixed(2));
      DateTime parcelaData = _data;
      for (int i = 1; i <= _parcelasTotal; i++) {
        final desp = Despesa(
          usuarioId: usuarioVM.usuarioAtual!.id!,
          categoriaId: _categoriaId,
          descricao:
              '${_descricaoController.text.trim()} (Parcela $i/$_parcelasTotal)',
          valor: parcelaValor,
          data: parcelaData,
          pagamentoTipo: 'PARCELADO',
          parcelasTotal: _parcelasTotal,
          parcelaNumero: i,
        );
        await despesaVM.adicionarDespesa(desp);
        parcelaData =
            DateTime(parcelaData.year, parcelaData.month + 1, parcelaData.day);
      }
    } else {
      final despesa = Despesa(
        usuarioId: usuarioVM.usuarioAtual!.id!,
        categoriaId: _categoriaId,
        descricao: _descricaoController.text.trim(),
        valor: valor,
        data: _data,
        pagamentoTipo: _pagamentoTipo,
        parcelasTotal: _parcelasTotal,
        parcelaNumero: 1,
      );

      await despesaVM.adicionarDespesa(despesa);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Despesa adicionada')),
    );
  }

  Future<void> _delete() async {
    if (widget.despesa == null) return;
    final despesaVM = Provider.of<DespesaViewModel>(context, listen: false);
    await despesaVM.removerDespesa(widget.despesa!.id!);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Despesa removida')),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _data = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.despesa != null ? 'Editar Despesa' : 'Adicionar Despesa'),
        actions: [
          if (widget.despesa != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Confirmar exclusão'),
                    content: const Text('Deseja remover esta despesa?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancelar')),
                      TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Remover')),
                    ],
                  ),
                );
                if (ok == true) await _delete();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valorController,
                decoration:
                    const InputDecoration(labelText: 'Valor (ex: 1000.50)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Data: ${_data.day}/${_data.month}/${_data.year}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: _categoriaId,
                items: _categorias.map((c) {
                  return DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(c.nome),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _categoriaId = v),
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _pagamentoTipo,
                items: const [
                  DropdownMenuItem(value: 'AVISTA', child: Text('À vista')),
                  DropdownMenuItem(
                      value: 'PARCELADO', child: Text('Parcelado')),
                ],
                onChanged: (v) =>
                    setState(() => _pagamentoTipo = v ?? 'AVISTA'),
                decoration:
                    const InputDecoration(labelText: 'Tipo de pagamento'),
              ),
              const SizedBox(height: 12),
              if (_pagamentoTipo == 'PARCELADO') ...[
                TextFormField(
                  initialValue: _parcelasTotal.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Número de parcelas'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (v) =>
                      setState(() => _parcelasTotal = int.tryParse(v) ?? 1),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
