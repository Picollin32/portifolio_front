import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class ImageUploadWidget extends StatefulWidget {
  final String? imageUrl;
  final Function(String) onImageSelected;
  final double size;

  const ImageUploadWidget({super.key, this.imageUrl, required this.onImageSelected, this.size = 120});

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 1200, imageQuality: 85);

      if (image != null) {
        // Convert to base64 for storage
        final bytes = await image.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        widget.onImageSelected(base64Image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: widget.size,
        height: widget.size * 1.5, // 2:3 aspect ratio
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
          color: Theme.of(context).colorScheme.surface,
        ),
        child:
            widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(10), child: _buildImage(widget.imageUrl!))
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 40, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    Text('Adicionar\nImagem', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('data:')) {
      try {
        final comma = imageUrl.indexOf(',');
        if (comma != -1) {
          final data = imageUrl.substring(comma + 1);
          final bytes = base64Decode(data);
          return Image.memory(bytes, fit: BoxFit.cover);
        }
      } catch (_) {}
      return Container(color: Colors.grey[800]);
    } else if (imageUrl.startsWith('/') || imageUrl.contains('\\')) {
      return Image.file(File(imageUrl), fit: BoxFit.cover);
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    } else {
      return Image.network(imageUrl, fit: BoxFit.cover);
    }
  }
}
