import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models.dart';
import '../services/supabase_service.dart';

class AdminApartmentsScreen extends StatefulWidget {
  const AdminApartmentsScreen({super.key});

  @override
  State<AdminApartmentsScreen> createState() => _AdminApartmentsScreenState();
}

class _AdminApartmentsScreenState extends State<AdminApartmentsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<PlatformFile> _selectedFiles = [];
  List<Apartment> _items = [];
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      _items = await SupabaseService.fetchApartmentsPaged(from: 0, limit: _pageSize);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final more = await SupabaseService.fetchApartmentsPaged(from: _items.length, limit: _pageSize);
      if (more.isNotEmpty) {
        setState(() => _items.addAll(more));
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _selectApartmentFiles() async {
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

  Future<void> _addApartment() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    if (title.isEmpty || description.isEmpty || price <= 0 || _selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez le titre, la description, le prix et sélectionnez au moins une photo.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final imageUrls = <String>[];
      for (final file in _selectedFiles) {
        if (file.bytes == null) continue;
        imageUrls.add(await SupabaseService.uploadApartmentImage(file.bytes!, file.name));
      }

      if (imageUrls.isEmpty) {
        throw 'Aucune photo valide n’a été sélectionnée.';
      }

      await SupabaseService.addApartment(
        Apartment(
          id: '',
          title: title,
          description: description,
          price: price,
          imageUrls: imageUrls,
        ),
      );

      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      setState(() => _selectedFiles = []);
      await _loadItems();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appartement ajouté.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d’ajouter l’appartement : $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteApartment(Apartment apartment) async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.removeApartment(apartment.id);
      await _loadItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appartement supprimé.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de supprimer l’appartement : $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editApartment(Apartment apartment) async {
    final titleController = TextEditingController(text: apartment.title);
    final descriptionController = TextEditingController(text: apartment.description);
    final priceController = TextEditingController(text: apartment.price.toString());

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Modifier l’appartement', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Prix (USD)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final description = descriptionController.text.trim();
                  final price = int.tryParse(priceController.text.trim()) ?? 0;

                  if (title.isEmpty || description.isEmpty || price <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Remplissez le titre, la description et un prix valide.')),
                    );
                    return;
                  }

                  try {
                    await SupabaseService.updateApartment(
                      Apartment(
                        id: apartment.id,
                        title: title,
                        description: description,
                        price: price,
                        imageUrls: apartment.imageUrls,
                      ),
                    );
                    if (!mounted) return;
                    Navigator.of(sheetContext).pop();
                    await _loadItems();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appartement mis à jour.')),
                    );
                  } catch (error) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Impossible de mettre à jour : $error')),
                    );
                  }
                },
                child: const Text('Enregistrer les modifications'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appartements')),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Ajouter un appartement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix (USD)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _selectApartmentFiles,
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
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: (_isSaving || _selectedFiles.isEmpty) ? null : _addApartment,
              child: _isSaving ? const CircularProgressIndicator() : const Text('Ajouter l’appartement'),
            ),
            const SizedBox(height: 24),
            Text('Appartements déjà présents',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            if (_isLoading && _items.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_items.isEmpty)
              Text('Aucun appartement trouvé.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: _loadMore,
                        child: const Text('Charger plus'),
                      ),
                    );
                  }
                  final apartment = _items[index];
                  return Card(
                    child: ListTile(
                      title: Text(apartment.title),
                      subtitle: Text(apartment.displayPrice),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editApartment(apartment);
                          } else if (value == 'delete') {
                            _deleteApartment(apartment);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Modifier')),
                          PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
