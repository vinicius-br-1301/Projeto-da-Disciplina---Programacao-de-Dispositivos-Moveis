import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/encounter.dart';
import '../viewmodels/encounter_viewmodel.dart';

class EncounterCalculatorView extends StatefulWidget {
  const EncounterCalculatorView({super.key});

  @override
  State<EncounterCalculatorView> createState() =>
      _EncounterCalculatorViewState();
}

class _EncounterCalculatorViewState extends State<EncounterCalculatorView> {
  final _jogadorFormKey = GlobalKey<FormState>();
  final _monstroFormKey = GlobalKey<FormState>();

  final TextEditingController _nivelController = TextEditingController();
  final TextEditingController _xpController = TextEditingController();

  @override
  void dispose() {
    _nivelController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  void _adicionarJogador() {
    if (!_jogadorFormKey.currentState!.validate()) return;

    final nivel = int.parse(_nivelController.text.trim());
    context.read<EncounterViewModel>().adicionarJogador(nivel);
    _nivelController.clear();
  }

  void _adicionarMonstro() {
    if (!_monstroFormKey.currentState!.validate()) return;

    final xp = int.parse(_xpController.text.trim());
    context.read<EncounterViewModel>().adicionarMonstro(xp);
    _xpController.clear();
  }

  Color _corDificuldade(String dificuldade) {
    final texto = dificuldade.toUpperCase();
    if (texto.contains('FACIL') || texto.contains('FÁCIL')) {
      return Colors.green;
    }
    if (texto.contains('MEDIO') || texto.contains('MÉDIO')) {
      return Colors.amber.shade800;
    }
    if (texto.contains('DIFICIL') || texto.contains('DIFÍCIL')) {
      return Colors.deepOrange;
    }
    if (texto.contains('MORTAL')) {
      return Colors.red.shade700;
    }
    return Colors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EncounterViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Seção dos Jogadores
              _buildSecaoJogadores(viewModel),
              const SizedBox(height: 16),

              // 2. Seção dos Monstros
              _buildSecaoMonstros(viewModel),
              const SizedBox(height: 20),

              // 3. Botões de Ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () {
                              _nivelController.clear();
                              _xpController.clear();
                              viewModel.limpar();
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => viewModel.calcularEncontro(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: viewModel.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.calculate),
                      label: const Text(
                        'Calcular Encontro',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 4. Mensagem de Erro (se houver)
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.red.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage!,
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // 5. Card de Resultado da API
              if (viewModel.resultado != null) ...[
                const SizedBox(height: 20),
                _buildCardResultado(viewModel.resultado!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecaoJogadores(EncounterViewModel vm) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.groups, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Grupo de Jogadores (${vm.niveisJogadores.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: _jogadorFormKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nivelController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nível do personagem',
                        hintText: 'Ex: 3',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onFieldSubmitted: (_) => _adicionarJogador(),
                      validator: (value) {
                        final nivel = int.tryParse(value?.trim() ?? '');
                        if (nivel == null || nivel < 1) {
                          return 'Informe um nível >= 1';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _adicionarJogador,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (vm.niveisJogadores.isEmpty)
              Text(
                'Nenhum jogador adicionado ainda.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.niveisJogadores.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final nivel = vm.niveisJogadores[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16,
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Jogador ${index + 1}'),
                    subtitle: Text('Nível $nivel'),
                    trailing: IconButton(
                      tooltip: 'Remover jogador',
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () => vm.removerJogador(index),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoMonstros(EncounterViewModel vm) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pest_control, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text(
                  'Monstros do Encontro (${vm.xpMonstros.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: _monstroFormKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _xpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'XP base do monstro',
                        hintText: 'Ex: 200',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onFieldSubmitted: (_) => _adicionarMonstro(),
                      validator: (value) {
                        final xp = int.tryParse(value?.trim() ?? '');
                        if (xp == null || xp < 0) {
                          return 'Informe um XP >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _adicionarMonstro,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (vm.xpMonstros.isEmpty)
              Text(
                'Nenhum monstro adicionado ainda.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.xpMonstros.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final xp = vm.xpMonstros[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.deepOrange.shade100,
                      foregroundColor: Colors.deepOrange.shade900,
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Monstro ${index + 1}'),
                    subtitle: Text('$xp XP'),
                    trailing: IconButton(
                      tooltip: 'Remover monstro',
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () => vm.removerMonstro(index),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardResultado(EncounterResponse resultado) {
    final cor = _corDificuldade(resultado.dificuldadeFinal);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resultado do Encontro',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    resultado.dificuldadeFinal,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: cor,
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'XP Ajustado do Combate:',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  '${resultado.xpAjustado} XP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
              ],
            ),
            if (resultado.limitesGrupo.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Limites de XP do Grupo:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...resultado.limitesGrupo.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        '${entry.value} XP',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
