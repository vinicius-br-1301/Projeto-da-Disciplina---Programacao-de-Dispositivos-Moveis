import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/campaign.dart';
import '../models/enums.dart';
import '../viewmodels/campaign_viewmodel.dart';

class CampaignListView extends StatefulWidget {
  const CampaignListView({super.key});

  @override
  State<CampaignListView> createState() => _CampaignListViewState();
}

class _CampaignListViewState extends State<CampaignListView> {
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carrega as campanhas logo após o primeiro frame ser montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CampaignViewModel>().carregarCampanhas();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _buscar() {
    context.read<CampaignViewModel>().carregarCampanhas(
      titulo: _buscaController.text,
    );
  }

  Future<void> _abrirFormulario({Campaign? campaign}) async {
    await Navigator.pushNamed(context, '/campaign-form', arguments: campaign);
  }

  Future<void> _confirmarExclusao(Campaign campaign) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir campanha'),
        content: Text('Deseja excluir permanentemente "${campaign.titulo}"?'),
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

    final vm = context.read<CampaignViewModel>();
    final ok = await vm.deletarCampanha(campaign.id);
    if (!mounted) return;

    _mostrarFeedback(
      ok ? 'Campanha excluída!' : (vm.errorMessage ?? 'Erro ao excluir.'),
      erro: !ok,
    );
  }

  Future<void> _confirmarEncerramento(Campaign campaign) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar campanha'),
        content: Text(
          'Encerrar "${campaign.titulo}" é permanente e impede novas sessões. Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final vm = context.read<CampaignViewModel>();
    final ok = await vm.encerrarCampanha(campaign.id);
    if (!mounted) return;

    _mostrarFeedback(
      ok ? 'Campanha encerrada.' : (vm.errorMessage ?? 'Erro ao encerrar.'),
      erro: !ok,
    );
  }

  Future<void> _iniciarSessao(Campaign campaign) async {
    final vm = context.read<CampaignViewModel>();
    final sessionId = await vm.iniciarSessao(campaign.id);
    if (!mounted) return;

    if (sessionId == null) {
      _mostrarFeedback(
        vm.errorMessage ?? 'Erro ao iniciar sessão.',
        erro: true,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sessão Iniciada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Campanha: ${campaign.titulo}'),
            const SizedBox(height: 12),
            const Text(
              'UUID da Sessão:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SelectableText(sessionId),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: sessionId));
              Navigator.pop(context);
              _mostrarFeedback(
                'Session ID copiado para a área de transferência!',
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar ID'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
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

  Color _corStatus(StatusEnum status) {
    switch (status) {
      case StatusEnum.ATIVA:
        return Colors.green;
      case StatusEnum.PAUSADA:
        return Colors.orange;
      case StatusEnum.FINALIZADA:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de filtro por título + atualizar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscaController,
                    decoration: InputDecoration(
                      labelText: 'Filtrar por título',
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

          // Corpo reativo conectado ao CampaignViewModel
          Expanded(
            child: Consumer<CampaignViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.campaigns.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null &&
                    viewModel.campaigns.isEmpty) {
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
                            'Erro ao carregar campanhas:\n${viewModel.errorMessage}',
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

                if (viewModel.campaigns.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma campanha encontrada.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.carregarCampanhas(
                    titulo: _buscaController.text,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: viewModel.campaigns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final c = viewModel.campaigns[index];
                      return _buildCampaignCard(c, viewModel);
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
        icon: const Icon(Icons.add),
        label: const Text('Nova Campanha'),
      ),
    );
  }

  Widget _buildCampaignCard(Campaign c, CampaignViewModel vm) {
    final capacidade = c.capacidadeDescricao.isNotEmpty
        ? c.capacidadeDescricao
        : '${c.minJogadores} a ${c.maxJogadores} jogadores';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    c.status.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _corStatus(c.status),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Sistema: ${c.sistema} • $capacidade',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            if (c.descricao.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(c.descricao),
            ],
            const Divider(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (c.status == StatusEnum.ATIVA) ...[
                  ActionChip(
                    avatar: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Iniciar Sessão'),
                    onPressed: () => _iniciarSessao(c),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.pause, size: 18),
                    label: const Text('Pausar'),
                    onPressed: () async {
                      final ok = await vm.pausarCampanha(c.id);
                      if (!mounted) return;
                      _mostrarFeedback(
                        ok
                            ? 'Campanha pausada.'
                            : (vm.errorMessage ?? 'Erro ao pausar.'),
                        erro: !ok,
                      );
                    },
                  ),
                ],
                if (c.status == StatusEnum.PAUSADA)
                  ActionChip(
                    avatar: const Icon(Icons.play_circle_outline, size: 18),
                    label: const Text('Reativar'),
                    onPressed: () async {
                      final ok = await vm.reativarCampanha(c.id);
                      if (!mounted) return;
                      _mostrarFeedback(
                        ok
                            ? 'Campanha reativada!'
                            : (vm.errorMessage ?? 'Erro ao reativar.'),
                        erro: !ok,
                      );
                    },
                  ),
                if (c.status != StatusEnum.FINALIZADA) ...[
                  ActionChip(
                    avatar: const Icon(Icons.stop_circle_outlined, size: 18),
                    label: const Text('Encerrar'),
                    onPressed: () => _confirmarEncerramento(c),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    onPressed: () => _abrirFormulario(campaign: c),
                  ),
                ],
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
                  onPressed: () => _confirmarExclusao(c),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
