import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../models/media_item_model.dart';
import '../widgets/media_card.dart';
import '../widgets/protected_route.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProtectedRoute(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meu Portfólio'),
          automaticallyImplyLeading: false,
        ),
        body: Consumer<MediaProvider>(
          builder: (context, mediaProvider, child) {
            final recentItems = mediaProvider.getRecent();
            final games = mediaProvider.getRecentByType(MediaType.game);
            final movies = mediaProvider.getRecentByType(MediaType.movie);
            final series = mediaProvider.getRecentByType(MediaType.series);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Text(
                          'Meu Universo de Mídia',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Minhas jornadas por jogos, filmes e séries, tudo em um só lugar.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.explore, size: 18),
                              label: const Text('Explorar Coleção'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Recently Added
                  if (recentItems.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      'Adicionados Recentemente',
                      Icons.add_circle_outline,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentItems.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: MediaCard(
                              item: recentItems[index],
                              width: 150,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
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
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: games.length.clamp(0, 4),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: MediaCard(
                              item: games[index],
                              width: 150,
                              showGenre: true,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
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
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length.clamp(0, 4),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: MediaCard(
                              item: movies[index],
                              width: 150,
                              showGenre: true,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
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
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: series.length.clamp(0, 4),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: MediaCard(
                              item: series[index],
                              width: 150,
                              showGenre: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/admin'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onViewAll,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        if (onViewAll != null)
          TextButton.icon(
            onPressed: onViewAll,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Ver todos', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
      ],
    );
  }
}
