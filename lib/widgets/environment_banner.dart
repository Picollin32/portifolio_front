import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/config.dart';

/// Banner visual mostrando o ambiente atual (DEV/PROD)
/// Apenas visível em modo debug
class EnvironmentBanner extends StatelessWidget {
  final Widget child;
  final bool showDebugInfo;

  const EnvironmentBanner({super.key, required this.child, this.showDebugInfo = false});

  @override
  Widget build(BuildContext context) {
    // Só mostra o banner em modo debug
    if (!kDebugMode) {
      return child;
    }

    return Banner(
      message: Config.environmentName,
      location: BannerLocation.topEnd,
      color: Config.isProduction ? Colors.red : Colors.green,
      child: Stack(children: [child, if (showDebugInfo) _buildDebugInfo(context)]),
    );
  }

  Widget _buildDebugInfo(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Config.isProduction ? Colors.red : Colors.green, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Ambiente:', Config.environmentName),
            _buildInfoRow('API:', Config.apiUrl),
            _buildInfoRow('Debug:', Config.isDevelopment ? 'ON' : 'OFF'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: Config.isProduction ? Colors.red : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
