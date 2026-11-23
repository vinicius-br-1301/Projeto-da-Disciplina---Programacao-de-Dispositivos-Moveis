import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/campaign.dart';
import '../../domain/entities/enums.dart';
import 'campaign_view_model.dart';

class CampaignFormScreen extends StatefulWidget {
  final Campaign? campaign;
  final String? mestreIdInicial;

  const CampaignFormScreen({super.key, this.campaign, this.mestreIdInicial});

  @override
  State<CampaignFormScreen> createState() => _CampaignFormScreenState();
}

class _CampaignFormScreenState extends State<CampaignFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _mestreIdController;
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _sistemaController;
  late final TextEditingController _minJogadoresController;
  late final TextEditingController _maxJogadoresController;

  bool get _isEdicao => widget.campaign != null;

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  void initState() {
    super.initState();
    final c = widget.campaign;
    _mestreIdController = TextEditingController(
      text: c?.mestreId ?? widget.mestreIdInicial ?? '',
    );
    _tituloController = TextEditingController(text: c?.titulo ?? '');
    _descricaoController = TextEditingController(text: c?.descricao ?? '');
    _sistemaController = TextEditingController(text: c?.sistema ?? '');
    _minJogadoresController = TextEditingController(
      text: c != null ? c.minJogadores.toString() : '2',
    );
    _maxJogadoresController = TextEditingController(
      text: c != null ? c.maxJogadores.toString() : '5',
    );
  }

  @override
  void dispose() {
    _mestreIdController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    _sistemaController.dispose();
    _minJogadoresController.dispose();
    _maxJogadoresController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final campaignEntity = Campaign(
      id: widget.campaign?.id ?? '',
      mestreId: _mestreIdController.text.trim(),
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      sistema: _sistemaController.text.trim(),
      status: widget.campaign?.status ?? StatusEnum.ATIVA,
      minJogadores: int.parse(_minJogadoresController.text.trim()),
      maxJogadores: int.parse(_maxJogadoresController.text.trim()),
      capacidadeDescricao: widget.campaign?.capacidadeDescricao ?? '',
      criadaEm: widget.campaign?.criadaEm ?? DateTime.now(),
    );

    final viewModel = context.read<CampaignViewModel>();
    final sucesso = _isEdicao
        ? await viewModel.atualizarCampanha(widget.campaign!.id, campaignEntity)
        : await viewModel.criarCampanha(campaignEntity);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdicao
                ? 'Campanha atualizada com sucesso!'
                : 'Campanha criada com sucesso!',
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Erro ao salvar campanha.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CampaignViewModel>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Campanha' : 'Nova Campanha'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _mestreIdController,
                decoration: const InputDecoration(
                  labelText: 'ID do Mestre (UUID) *',
                  hintText: 'Ex: 550e8400-e29b-41d4-a716-446655440000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O ID do mestre é obrigatório.';
                  }
                  if (!_uuidRegex.hasMatch(value.trim())) {
                    return 'Informe um UUID válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título da Campanha *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shield_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O título é obrigatório.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sistemaController,
                decoration: const InputDecoration(
                  labelText: 'Sistema de RPG *',
                  hintText: 'Ex: D&D 5e, Tormenta20, Ordem Paranormal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O sistema é obrigatório.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minJogadoresController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Mín. Jogadores *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                      validator: (value) {
                        final n = int.tryParse(value?.trim() ?? '');
                        if (n == null || n < 1) {
                          return 'Mínimo deve ser >= 1';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxJogadoresController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Máx. Jogadores *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      validator: (value) {
                        final max = int.tryParse(value?.trim() ?? '');
                        final min = int.tryParse(
                          _minJogadoresController.text.trim(),
                        );
                        if (max == null || max < 1) {
                          return 'Máximo deve ser >= 1';
                        }
                        if (min != null && max < min) {
                          return 'Deve ser >= ao mínimo';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isEdicao ? 'Salvar Alterações' : 'Criar Campanha',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
