import 'package:flutter/material.dart';

class CategoryFilters extends StatelessWidget {
  final String searchTerm;
  final Function(String) onSearchChange;
  final String sortBy;
  final Function(String) onSortChange;

  const CategoryFilters({
    super.key,
    required this.searchTerm,
    required this.onSearchChange,
    required this.sortBy,
    required this.onSortChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar por título ou gênero...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: onSearchChange,
        ),
        const SizedBox(height: 16),
        
        // Sort dropdown
        Row(
          children: [
            Text(
              'Ordenar por:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: sortBy,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'date',
                    child: Text('Mais recentes'),
                  ),
                  DropdownMenuItem(
                    value: 'rating-desc',
                    child: Text('Maior avaliação'),
                  ),
                  DropdownMenuItem(
                    value: 'rating-asc',
                    child: Text('Menor avaliação'),
                  ),
                  DropdownMenuItem(
                    value: 'alphabetical',
                    child: Text('Ordem alfabética'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onSortChange(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
