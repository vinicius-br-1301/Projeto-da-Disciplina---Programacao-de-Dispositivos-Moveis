import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/notes.dart';
import '../viewmodels/campaign_viewmodel.dart';
import '../viewmodels/notes_viewmodel.dart';

class NotesFormView extends StatefulWidget {
  final Notes? note;
  final String? campaignIdInicial;
  final String? sessionIdInicial;
  final String? authorIdInicial;

  const NotesFormView({
    super.key,
    this.note,
    this.campaignIdInicial,
    this.sessionIdInicial,
    this.authorIdInicial,
  });

  @override
  State<NotesFormView> createState() => _NotesFormViewState();
}

class _NotesFormViewState extends State<NotesFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _campaignIdController;
  late final TextEditingController _sessionIdController;
  late final TextEditingController _authorIdController;
  late final TextEditingController _tituloController;
  late final TextEditingController _conteudoController;

  late PostItCat _categoria;
  late RoleEnum _visibilidade;
  late bool _fixado;

  bool get _isEdicao => widget.note != null;

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    final campaignVm = context.read<CampaignViewModel>();

    // Se a lista de campanhas ainda estiver vazia, tenta carregar para o seletor rápido
    if (campaignVm.campaigns.isEmpty && !campaignVm.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CampaignViewModel>().carregarCampanhas();
      });
    }

    _campaignIdController = TextEditingController(
      text: n?.campaignId ?? widget.campaignIdInicial ?? '',
    );
    _sessionIdController = TextEditingController(
      text:
          n?.sessionId ??
          widget.sessionIdInicial ??
          campaignVm.ultimoSessionId ??
          '',
    );
    _authorIdController = TextEditingController(
      text: n?.authorId ?? widget.authorIdInicial ?? '',
    );
    _tituloController = TextEditingController(text: n?.titulo ?? '');
    _conteudoController = TextEditingController(text: n?.conteudo ?? '');

    _categoria = n?.categoria ?? PostItCat.LORE;
    _visibilidade = n?.visibilidade ?? RoleEnum.MESTRE;
    _fixado = n?.fixado ?? false;
  }

  @override
  void dispose() {
    _campaignIdController.dispose();
    _sessionIdController.dispose();
    _authorIdController.dispose();
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  String? _validarUuid(String? value, String nomeCampo) {
    if (value == null || value.trim().isEmpty) {
      return 'O $nomeCampo é obrigatório.';
    }
    if (!_uuidRegex.hasMatch(value.trim())) {
      return 'Informe um UUID válido para o $nomeCampo.';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      'campaignId': _campaignIdController.text.trim(),
      'sessionId': _sessionIdController.text.trim(),
      'authorId': _authorIdController.text.trim(),
      'titulo': _tituloController.text.trim(),
      'categoria': _categoria.name,
      'visibilidade': _visibilidade.name,
      'fixado': _fixado,
      'conteudo': _conteudoController.text.trim(),
    };

    final viewModel = context.read<NotesViewModel>();
    final sucesso = _isEdicao
        ? await viewModel.atualizarNota(widget.note!.id, body)
        : await viewModel.criarNota(body);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdicao
                ? 'Anotação atualizada com sucesso!'
                : 'Anotação criada com sucesso!',
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Erro ao salvar anotação.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<NotesViewModel>().isLoading;
    final campaigns = context.watch<CampaignViewModel>().campaigns;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Anotação' : 'Nova Anotação'),
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
              // Atalho opcional: escolhe uma campanha carregada para preencher IDs
              if (campaigns.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Preencher rápido a partir de uma Campanha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shield_outlined),
                  ),
                  items: campaigns.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(c.titulo, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (campaignIdSelecionada) {
                    if (campaignIdSelecionada == null) return;
                    final selecionada = campaigns.firstWhere(
                      (c) => c.id == campaignIdSelecionada,
                    );
                    setState(() {
                      _campaignIdController.text = selecionada.id;
                      if (_authorIdController.text.trim().isEmpty) {
                        _authorIdController.text = selecionada.mestreId;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _campaignIdController,
                decoration: const InputDecoration(
                  labelText: 'ID da Campanha (UUID) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                ),
                validator: (value) => _validarUuid(value, 'ID da campanha'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _sessionIdController,
                decoration: const InputDecoration(
                  labelText: 'ID da Sessão (UUID) *',
                  hintText: 'Use o UUID gerado em "Iniciar Sessão"',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event_note_outlined),
                ),
                validator: (value) => _validarUuid(value, 'ID da sessão'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _authorIdController,
                decoration: const InputDecoration(
                  labelText: 'ID do Autor (UUID) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => _validarUuid(value, 'ID do autor'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tituloController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Título da Nota *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O título é obrigatório.';
                  }
                  if (value.trim().length > 100) {
                    return 'O título deve ter no máximo 100 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<PostItCat>(
                      initialValue: _categoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoria *',
                        border: OutlineInputBorder(),
                      ),
                      items: PostItCat.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _categoria = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<RoleEnum>(
                      initialValue: _visibilidade,
                      decoration: const InputDecoration(
                        labelText: 'Visibilidade *',
                        border: OutlineInputBorder(),
                      ),
                      items: RoleEnum.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _visibilidade = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fixar anotação (Post-it em destaque)'),
                secondary: Icon(
                  _fixado ? Icons.push_pin : Icons.push_pin_outlined,
                  color: _fixado ? Colors.amber[800] : null,
                ),
                value: _fixado,
                onChanged: (value) => setState(() => _fixado = value),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _conteudoController,
                maxLines: 5,
                maxLength: 2000,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo da Anotação',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.length > 2000) {
                    return 'O conteúdo deve ter no máximo 2000 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

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
                  _isEdicao ? 'Salvar Alterações' : 'Criar Anotação',
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
