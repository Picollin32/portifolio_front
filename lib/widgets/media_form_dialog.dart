import 'package:flutter/material.dart';
import '../models/media_item_model.dart';

class MediaFormDialog extends StatefulWidget {
  final MediaItem? media;

  const MediaFormDialog({super.key, this.media});

  @override
  State<MediaFormDialog> createState() => _MediaFormDialogState();
}

class _MediaFormDialogState extends State<MediaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _yearController = TextEditingController();
  final _imageController = TextEditingController();

  MediaType? _selectedType;
  int _rating = 0;
  String _selectedBadge = 'Nenhum';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.media != null) {
      _titleController.text = widget.media!.title;
      _genreController.text = widget.media!.genre ?? '';
      _yearController.text = widget.media!.year?.toString() ?? '';
      _imageController.text = widget.media!.image;
      _selectedType = widget.media!.type;
      _rating = widget.media!.rating;
      _selectedBadge = widget.media!.badge ?? 'Nenhum';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  List<String> _getBadgeOptions() {
    switch (_selectedType) {
      case MediaType.game:
        return ['Nenhum', 'Zerado', 'Platinado', 'Abandonado', 'Jogando'];
      case MediaType.movie:
        return ['Nenhum', 'Assistido', 'Favorito', 'Para Reassistir'];
      case MediaType.series:
        return ['Nenhum', 'Finalizada', 'Assistindo', 'Pausada', 'Abandonada'];
      default:
        return ['Nenhum'];
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione o tipo de mídia')));
      return;
    }
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma avaliação')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implementar chamadas para API quando endpoints estiverem prontos

      // ignore: unused_local_variable
      final mediaData = {
        'title': _titleController.text.trim(),
        'genre': _genreController.text.trim(),
        'year': int.parse(_yearController.text.trim()),
        'image': _imageController.text.trim(),
        'type': _selectedType!.name,
        'rating': _rating,
        'badge': _selectedBadge == 'Nenhum' ? null : _selectedBadge,
      };

      // Placeholder - apenas mostra sucesso por enquanto
      await Future.delayed(const Duration(milliseconds: 500));

      if (widget.media == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mídia criada com sucesso!')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mídia atualizada com sucesso!')));
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.media != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Dialog(
      child: Container(
        width: isMobile ? screenWidth * 0.95 : 800,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEdit ? 'Editar Item' : 'Adicionar Novo Item',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(key: _formKey, child: isMobile ? _buildMobileLayout() : _buildDesktopLayout()),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('Cancelar')),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child:
                            _isLoading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(isEdit ? 'Atualizar' : 'Adicionar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildGenreField(),
              const SizedBox(height: 16),
              _buildYearField(),
              const SizedBox(height: 16),
              _buildBadgeSelector(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildRatingSelector(), const SizedBox(height: 16), _buildImageField()],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleField(),
        const SizedBox(height: 16),
        _buildTypeSelector(),
        const SizedBox(height: 16),
        _buildGenreField(),
        const SizedBox(height: 16),
        _buildYearField(),
        const SizedBox(height: 16),
        _buildBadgeSelector(),
        const SizedBox(height: 16),
        _buildRatingSelector(),
        const SizedBox(height: 16),
        _buildImageField(),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Título *', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Nome do jogo, filme ou série',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Título é obrigatório';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipo *', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<MediaType>(
          value: _selectedType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          hint: const Text('Selecione o tipo'),
          items: const [
            DropdownMenuItem(
              value: MediaType.game,
              child: Row(children: [Icon(Icons.videogame_asset, size: 20), SizedBox(width: 8), Text('Jogo')]),
            ),
            DropdownMenuItem(
              value: MediaType.movie,
              child: Row(children: [Icon(Icons.movie, size: 20), SizedBox(width: 8), Text('Filme')]),
            ),
            DropdownMenuItem(value: MediaType.series, child: Row(children: [Icon(Icons.tv, size: 20), SizedBox(width: 8), Text('Série')])),
          ],
          onChanged: (MediaType? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedType = newValue;
                // Reset badge when type changes
                if (!_getBadgeOptions().contains(_selectedBadge)) {
                  _selectedBadge = 'Nenhum';
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildGenreField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gênero', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _genreController,
          decoration: InputDecoration(
            hintText: 'Ex: Action/Adventure, Sci-Fi, Drama',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildYearField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ano', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _yearController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final year = int.tryParse(value);
              if (year == null || year < 1900 || year > DateTime.now().year + 5) {
                return 'Ano inválido';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBadgeSelector() {
    final options = _getBadgeOptions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedBadge,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items:
              options.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedBadge = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avaliação *', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(5, (index) {
              final starValue = index + 1;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = starValue;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      starValue <= _rating ? Icons.star : Icons.star_border,
                      size: 32,
                      color:
                          starValue <= _rating
                              ? const Color(0xFFFFB800) // Gold color for filled stars
                              : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            Text(
              _rating > 0 ? '$_rating/5' : '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Capa', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _imageController,
          decoration: InputDecoration(
            hintText: 'URL ou caminho da imagem',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'URL da imagem é obrigatória';
            }
            return null;
          },
          onChanged: (value) {
            // Force rebuild to show/hide preview
            setState(() {});
          },
        ),
        if (_imageController.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Theme.of(context).dividerColor)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                _imageController.text,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined, size: 48, color: Theme.of(context).colorScheme.error),
                          const SizedBox(height: 8),
                          Text(
                            'Imagem não encontrada',
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
