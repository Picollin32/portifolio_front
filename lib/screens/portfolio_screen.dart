import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../providers/auth_provider.dart';
import '../models/media_item_model.dart';
import '../models/user_model.dart';
import '../widgets/media_card.dart';
import '../widgets/protected_route.dart';
import '../widgets/media_form_dialog.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  void _showMediaDialog(BuildContext context, MediaItem? media) async {
    final result = await showDialog(context: context, builder: (context) => MediaFormDialog(media: media));

    // Se retornou true, apenas mostra uma mensagem
    // A recarga será feita através do Provider quando o backend estiver conectado
    if (result == true && context.mounted) {
      // Placeholder - quando o backend estiver pronto, aqui recarregaremos os dados
    }
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Saída'),
            content: const Text('Deseja realmente sair do sistema?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Sair'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProtectedRoute(
      child: Consumer2<MediaProvider, AuthProvider>(
        builder: (context, mediaProvider, authProvider, child) {
          final recentItems = mediaProvider.getRecent();
          final games = mediaProvider.getRecentByType(MediaType.game);
          final movies = mediaProvider.getRecentByType(MediaType.movie);
          final series = mediaProvider.getRecentByType(MediaType.series);
          final isAdmin = authProvider.user?.role == UserRole.admin;

          return Scaffold(
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Header - Non-fixed, scrolls with content
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Row(
                          children: [
                            // User Avatar
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              backgroundImage: authProvider.user?.photo != null ? NetworkImage(authProvider.user!.photo!) : null,
                              child:
                                  authProvider.user?.photo == null
                                      ? Text(
                                        authProvider.user?.name.isNotEmpty == true ? authProvider.user!.name[0].toUpperCase() : 'U',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authProvider.user?.name ?? 'Usuário',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    authProvider.user?.email ?? '',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Action Buttons
                            if (isAdmin) ...[
                              IconButton(
                                icon: const Icon(Icons.admin_panel_settings_outlined),
                                tooltip: 'Painel Admin',
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/admin');
                                },
                              ),
                              const SizedBox(width: 4),
                            ],
                            // Logout Button
                            ElevatedButton.icon(
                              onPressed: () => _handleLogout(context, authProvider),
                              icon: const Icon(Icons.logout, size: 18),
                              label: const Text('Sair'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Hero Section with gradient - CENTERED
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), width: 1),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.collections, size: 56, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 16),
                              Text(
                                'Meu Universo de Mídia',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Minhas jornadas por jogos, filmes e séries, tudo em um só lugar.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildStatChip(context, Icons.videogame_asset, 'Jogos', games.length),
                                  _buildStatChip(context, Icons.movie, 'Filmes', movies.length),
                                  _buildStatChip(context, Icons.tv, 'Séries', series.length),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Recently Added
                      if (recentItems.isNotEmpty) ...[
                        _buildSectionHeader(context, 'Adicionados Recentemente', Icons.fiber_new),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recentItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: MediaCard(
                                  item: recentItems[index],
                                  width: 160,
                                  onTap: isAdmin ? () => _showMediaDialog(context, recentItems[index]) : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],

                      // Latest Games
                      if (games.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          'Últimos Jogos Concluídos',
                          Icons.videogame_asset,
                          onViewAll: () => Navigator.pushNamed(context, '/jogos'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: games.length.clamp(0, 6),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: MediaCard(
                                  item: games[index],
                                  width: 160,
                                  showGenre: true,
                                  onTap: isAdmin ? () => _showMediaDialog(context, games[index]) : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],

                      // Latest Movies
                      if (movies.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          'Últimos Filmes Vistos',
                          Icons.movie,
                          onViewAll: () => Navigator.pushNamed(context, '/filmes'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movies.length.clamp(0, 6),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: MediaCard(
                                  item: movies[index],
                                  width: 160,
                                  showGenre: true,
                                  onTap: isAdmin ? () => _showMediaDialog(context, movies[index]) : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],

                      // Latest Series
                      if (series.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          'Últimas Séries Finalizadas',
                          Icons.tv,
                          onViewAll: () => Navigator.pushNamed(context, '/series'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: series.length.clamp(0, 6),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: MediaCard(
                                  item: series[index],
                                  width: 160,
                                  showGenre: true,
                                  onTap: isAdmin ? () => _showMediaDialog(context, series[index]) : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton:
                isAdmin
                    ? FloatingActionButton(
                      onPressed: () => _showMediaDialog(context, null),
                      tooltip: 'Adicionar Mídia',
                      child: const Icon(Icons.add),
                    )
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {VoidCallback? onViewAll}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
          if (onViewAll != null)
            TextButton.icon(onPressed: onViewAll, icon: const Icon(Icons.arrow_forward, size: 18), label: const Text('Ver Todos')),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
