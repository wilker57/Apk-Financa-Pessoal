import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mvvm/receita_viewmodel.dart';
import '../mvvm/categoria_viewmodel.dart';
import '../mvvm/usuario_viewmodel.dart';
import '../models/receita/receita.dart';
import '../models/categoria/categoria.dart';

class AdicionarReceitaView extends StatefulWidget {
  final Receita? receita;
  const AdicionarReceitaView({super.key, this.receita});

  @override
  State<AdicionarReceitaView> createState() => _AdicionarReceitaViewState();
}

class _AdicionarReceitaViewState extends State<AdicionarReceitaView> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  DateTime _data = DateTime.now();
  int? _categoriaId;
  List<Categoria> _categorias = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    // If editing, populate fields
    if (widget.receita != null) {
      final r = widget.receita!;
      _descricaoController.text = r.descricao;
      _valorController.text = r.valor.toString();
      _data = r.data;
      _categoriaId = r.categoriaId;
    }
  }

  Future<void> _loadCategorias() async {
    final categoriaVM = Provider.of<CategoriaViewModel>(context, listen: false);
    final categorias = await categoriaVM.getCategoriasPorTipo('RECEITA');
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
    final receitaVM = Provider.of<ReceitaViewModel>(context, listen: false);

    if (usuarioVM.usuarioAtual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final valorStr = _valorController.text.replaceAll(',', '.');
    final valor = double.tryParse(valorStr) ?? 0.0;

    // If editing, update existing; otherwise create new
    if (widget.receita != null) {
      final atual = widget.receita!;
      atual.descricao = _descricaoController.text.trim();
      atual.valor = valor;
      atual.data = _data;
      atual.categoriaId = _categoriaId;

      await receitaVM.atualizarReceita(atual);

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receita atualizada')),
      );
      return;
    }

    final receita = Receita(
      usuarioId: usuarioVM.usuarioAtual!.id!,
      categoriaId: _categoriaId,
      descricao: _descricaoController.text.trim(),
      valor: valor,
      data: _data,
    );

    await receitaVM.adicionarReceita(receita);

    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receita adicionada')),
    );
  }

  Future<void> _delete() async {
    if (widget.receita == null) return;
    final receitaVM = Provider.of<ReceitaViewModel>(context, listen: false);
    await receitaVM.removerReceita(widget.receita!.id!);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receita removida')),
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
            widget.receita != null ? 'Editar Receita' : 'Adicionar Receita'),
        actions: [
          if (widget.receita != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Confirmar exclusão'),
                    content: const Text('Deseja remover esta receita?'),
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
