import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models.dart';
import '../services/supabase_service.dart';

class AdminGalleryScreen extends StatefulWidget {
  const AdminGalleryScreen({super.key});

  @override
  State<AdminGalleryScreen> createState() => _AdminGalleryScreenState();
}

class _AdminGalleryScreenState extends State<AdminGalleryScreen> {
  bool _isLoading = true;
  bool _isUploading = false;
  final TextEditingController _albumTitleController = TextEditingController();
  List<PlatformFile> _selectedFiles = [];
  List<GalleryPhoto> _photos = [];
  final int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      _photos = await SupabaseService.fetchGalleryPhotosPaged(from: 0, limit: _pageSize);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final more = await SupabaseService.fetchGalleryPhotosPaged(from: _photos.length, limit: _pageSize);
      if (more.isNotEmpty) {
        setState(() => _photos.addAll(more));
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _selectGalleryFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _selectedFiles = result.files;
    });
  }

  Future<void> _uploadGalleryPhotos() async {
    final title = _albumTitleController.text.trim();

    if (title.isEmpty || _selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renseignez le titre de l’album et sélectionnez des photos.')),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      for (final file in _selectedFiles) {
        if (file.bytes == null) continue;
        await SupabaseService.uploadGalleryPhoto(title, file.bytes!, file.name);
      }
      _albumTitleController.clear();
      setState(() => _selectedFiles = []);
      await _loadPhotos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Album uploadé dans la galerie.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d’upload : $error')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteGalleryPhoto(GalleryPhoto photo) async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.removeGalleryPhoto(photo);
      await _loadPhotos();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galerie')),
      body: RefreshIndicator(
        onRefresh: _loadPhotos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Ajouter un album',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            TextField(
              controller: _albumTitleController,
              decoration: const InputDecoration(labelText: 'Titre de l’album'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _selectGalleryFiles,
              icon: const Icon(Icons.upload_file),
              label: const Text('Choisir des photos'),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFiles.isEmpty
                  ? 'Aucune photo sélectionnée'
                  : '${_selectedFiles.length} photo(s) sélectionnée(s)',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: (_isUploading || _selectedFiles.isEmpty) ? null : _uploadGalleryPhotos,
              icon: const Icon(Icons.photo_library),
              label: _isUploading ? const Text('Upload en cours...') : const Text('Uploader l’album'),
            ),
            const SizedBox(height: 24),
            Text('Photos déjà présentes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            if (_isLoading && _photos.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_photos.isEmpty)
              Text('Aucune photo dans la galerie.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
            else ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(photo.imageUrl, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.delete, size: 18, color: Colors.white),
                            onPressed: () => _deleteGalleryPhoto(photo),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: _loadMore,
                  child: const Text('Charger plus'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
