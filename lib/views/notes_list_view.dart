import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/notes.dart';
import '../viewmodels/notes_viewmodel.dart';

class NotesListView extends StatefulWidget {
  const NotesListView({super.key});

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  final TextEditingController _buscaController = TextEditingController();
  PostItCat? _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesViewModel>().carregarNotas();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _buscar() {
    context.read<NotesViewModel>().carregarNotas(
      titulo: _buscaController.text,
      categoria: _categoriaSelecionada,
    );
  }

  Future<void> _abrirFormulario({Notes? note}) async {
    await Navigator.pushNamed(context, '/notes-form', arguments: note);
  }

  Future<void> _alternarFixacao(Notes note) async {
    final vm = context.read<NotesViewModel>();
    final ok = await vm.alternarFixacao(note.id);
    if (!mounted) return;

    _mostrarFeedback(
      ok
          ? (note.fixado ? 'Nota desafixada.' : 'Nota fixada!')
          : (vm.errorMessage ?? 'Erro ao alternar fixação.'),
      erro: !ok,
    );
  }

  Future<void> _confirmarExclusao(Notes note) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir anotação'),
        content: Text('Deseja excluir permanentemente "${note.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final vm = context.read<NotesViewModel>();
    final ok = await vm.deletarNota(note.id);
    if (!mounted) return;

    _mostrarFeedback(
      ok ? 'Anotação excluída!' : (vm.errorMessage ?? 'Erro ao excluir.'),
      erro: !ok,
    );
  }

  void _mostrarFeedback(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.red : null,
      ),
    );
  }

  Color _corCategoria(PostItCat categoria) {
    switch (categoria) {
      case PostItCat.LORE:
        return Colors.indigo;
      case PostItCat.QUEST:
        return Colors.teal;
      case PostItCat.NPC:
        return Colors.purple;
      case PostItCat.COMBATE:
        return Colors.redAccent;
      case PostItCat.LOOT:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de busca por título
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscaController,
                    decoration: InputDecoration(
                      labelText: 'Filtrar notas por título',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _buscaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _buscaController.clear();
                                _buscar();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _buscar(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _buscar,
                  tooltip: 'Buscar / Atualizar',
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),

          // Filtros rápidos por categoria (PostItCat)
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todas'),
                    selected: _categoriaSelecionada == null,
                    onSelected: (_) {
                      setState(() => _categoriaSelecionada = null);
                      _buscar();
                    },
                  ),
                ),
                ...PostItCat.values.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: _categoriaSelecionada == cat,
                      onSelected: (_) {
                        setState(() => _categoriaSelecionada = cat);
                        _buscar();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Lista reativa conectada ao NotesViewModel
          Expanded(
            child: Consumer<NotesViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.notes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null && viewModel.notes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Erro ao carregar anotações:\n${viewModel.errorMessage}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _buscar,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (viewModel.notes.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma anotação encontrada.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.carregarNotas(
                    titulo: _buscaController.text,
                    categoria: _categoriaSelecionada,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: viewModel.notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final note = viewModel.notes[index];
                      return _buildNoteCard(note);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Nova Nota'),
      ),
    );
  }

  Widget _buildNoteCard(Notes note) {
    final corCat = _corCategoria(note.categoria);

    return Card(
      elevation: note.fixado ? 4 : 2,
      color: note.fixado ? Colors.amber.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: note.fixado
            ? BorderSide(color: Colors.amber.shade700, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: note.fixado ? 'Desafixar nota' : 'Fixar nota',
                  icon: Icon(
                    note.fixado ? Icons.push_pin : Icons.push_pin_outlined,
                    color: note.fixado ? Colors.amber.shade800 : Colors.grey,
                  ),
                  onPressed: () => _alternarFixacao(note),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(
                    note.categoria.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: corCat,
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  avatar: const Icon(Icons.visibility_outlined, size: 15),
                  label: Text(
                    note.visibilidade.name,
                    style: const TextStyle(fontSize: 11),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (note.conteudo.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(note.conteudo),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  onPressed: () => _abrirFormulario(note: note),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Excluir',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => _confirmarExclusao(note),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
