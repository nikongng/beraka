import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:beraka_hotel_restaurant/theme/app_theme.dart';

import '../models.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _galleryLabelController = TextEditingController();
  final TextEditingController _menuNameController = TextEditingController();
  final TextEditingController _menuDescriptionController = TextEditingController();
  final TextEditingController _menuPriceController = TextEditingController();
  final TextEditingController _menuCategoryController = TextEditingController();
  final TextEditingController _apartmentTitleController = TextEditingController();
  final TextEditingController _apartmentDescriptionController = TextEditingController();
  final TextEditingController _apartmentPriceController = TextEditingController();
  List<PlatformFile> _selectedApartmentFiles = [];
  PlatformFile? _selectedGalleryFile;
  PlatformFile? _selectedMenuImageFile;
  Dish? _editingMenuItem;
  bool _isLoading = false;
  bool _isAdmin = false;
  String? _userEmail;
  List<Reservation> _reservations = [];
  List<GalleryPhoto> _galleryPhotos = [];
  List<Dish> _menuItems = [];
  List<Apartment> _apartments = [];

  @override
  void initState() {
    super.initState();
    _checkAdminSession();
  }

  Future<void> _checkAdminSession() async {
    final user = currentSupabaseUser();
    if (user != null && currentUserIsAdmin()) {
      setState(() {
        _isAdmin = true;
        _userEmail = user.email;
      });
      await _loadReservations();
      await _loadGalleryPhotos();
      await _loadMenuItems();
      await _loadApartments();
    }
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _reservations = await SupabaseService.fetchReservations();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Impossible de charger les réservations : $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGalleryPhotos() async {
    try {
      _galleryPhotos = await SupabaseService.fetchGalleryPhotos();
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de charger la galerie : $error')),
      );
    }
  }

  Future<void> _loadMenuItems() async {
    try {
      _menuItems = await SupabaseService.fetchMenu();
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de charger le menu : $error')),
      );
    }
  }

  Future<void> _loadApartments() async {
    try {
      _apartments = await SupabaseService.fetchApartments();
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de charger les appartements : $error')),
      );
    }
  }

  Future<void> _addApartment() async {
    final title = _apartmentTitleController.text.trim();
    final description = _apartmentDescriptionController.text.trim();
    final price = int.tryParse(_apartmentPriceController.text.trim()) ?? 0;
    final files = _selectedApartmentFiles;

    if (title.isEmpty || description.isEmpty || price <= 0 || files.isEmpty || files.any((file) => file.bytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez le titre, la description, le prix et sélectionnez au moins une photo.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final imageUrls = <String>[];
      for (final file in files) {
        if (file.bytes == null) continue;
        final imageUrl = await SupabaseService.uploadApartmentImage(file.bytes!, file.name);
        imageUrls.add(imageUrl);
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
      _apartmentTitleController.clear();
      _apartmentDescriptionController.clear();
      _apartmentPriceController.clear();
      setState(() {
        _selectedApartmentFiles = [];
      });
      await _loadApartments();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteApartment(Apartment apartment) async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.removeApartment(apartment.id);
      await _loadApartments();
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

  Widget _buildAdminPanel() {
    final total = _reservations.length;
    final upcoming = _reservations
        .where((r) => _reservationDateTime(r).isAfter(DateTime.now()))
        .length;
    final confirmed = _reservations
        .where((r) => r.status.toLowerCase().contains('confirm'))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Connecté comme : ${_userEmail ?? 'admin'}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _loadReservations,
                icon: const Icon(Icons.refresh),
                label: const Text('Rafraîchir'),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading) const LinearProgressIndicator(),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _adminStatCard(
                'Réservations totales', total.toString(), Icons.event_note),
            _adminStatCard(
                'À venir', upcoming.toString(), Icons.calendar_month),
            _adminStatCard(
                'Confirmées', confirmed.toString(), Icons.check_circle),
          ],
        ),
        const SizedBox(height: 20),
        Text('Ajouter une photo à la galerie',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        TextField(
          controller: _galleryLabelController,
          decoration: const InputDecoration(labelText: 'Titre de la photo'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _selectGalleryFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Choisir une photo'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _selectedGalleryFile == null
              ? 'Aucune photo sélectionnée'
              : 'Photo : ${_selectedGalleryFile!.name}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: (!_isLoading && _selectedGalleryFile != null)
              ? _uploadGalleryPhoto
              : null,
          icon: const Icon(Icons.photo_library),
          label: const Text('Uploader dans la galerie'),
        ),
        const SizedBox(height: 24),
        Text('Photos déjà présentes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        if (_galleryPhotos.isEmpty)
          Text('Aucune photo dans la galerie.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
        else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _galleryPhotos.map((photo) {
              return SizedBox(
                width: 220,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          photo.imageUrl,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                photo.label.isEmpty ? 'Sans titre' : photo.label,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteGalleryPhoto(photo),
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              tooltip: 'Supprimer',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 20),
        Text('Gérer les packs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        TextField(
          controller: _menuNameController,
          decoration: const InputDecoration(labelText: 'Nom du pack'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _menuDescriptionController,
          decoration: const InputDecoration(labelText: 'Description du pack'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _menuPriceController,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: 'Prix du pack (en centimes)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _menuCategoryController,
          decoration: const InputDecoration(labelText: 'Type de pack (Standard, Premium, VIP)'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _selectMenuImageFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Choisir une photo de pack'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _selectedMenuImageFile == null
              ? 'Aucune photo sélectionnée'
              : 'Photo sélectionnée : ${_selectedMenuImageFile!.name}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _addMenuItem,
          icon: const Icon(Icons.card_giftcard),
          label: Text(_editingMenuItem == null ? 'Ajouter un pack' : 'Modifier le pack'),
        ),
        if (_editingMenuItem != null) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isLoading ? null : _cancelMenuEditing,
            child: const Text('Annuler la modification'),
          ),
        ],
        const SizedBox(height: 20),
        Text('Packs déjà présents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        if (_menuItems.isEmpty)
          Text('Aucun pack trouvé.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _menuItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final dish = _menuItems[index];
              return Card(
                child: ListTile(
                  title: Text(dish.name),
                  subtitle: Text('${dish.category} • ${(dish.price/100).toStringAsFixed(2)}€'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _startEditingMenuItem(dish),
                        tooltip: 'Modifier',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteMenuItem(dish),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 20),
        Text('Gérer les appartements',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        TextField(
          controller: _apartmentTitleController,
          decoration: const InputDecoration(labelText: 'Titre de l’appartement'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _apartmentDescriptionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _apartmentPriceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Prix (en USD)'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _selectApartmentFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text('Choisir une ou plusieurs photos'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _selectedApartmentFiles.isEmpty
              ? 'Aucune photo sélectionnée'
              : '${_selectedApartmentFiles.length} photo(s) sélectionnée(s)',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _addApartment,
          icon: const Icon(Icons.apartment_rounded),
          label: const Text('Ajouter un appartement'),
        ),
        const SizedBox(height: 20),
        Text('Appartements déjà présents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        if (_apartments.isEmpty)
          Text('Aucun appartement trouvé.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _apartments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final apartment = _apartments[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (apartment.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            apartment.imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 160,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Center(child: Icon(Icons.broken_image, size: 48)),
                            ),
                          ),
                        ),
                      if (apartment.imageUrls.isNotEmpty) const SizedBox(height: 8),
                      if (apartment.imageUrls.isNotEmpty)
                        SizedBox(
                          height: 72,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: apartment.imageUrls.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, imgIndex) {
                              final imgUrl = apartment.imageUrls[imgIndex];
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showApartmentPreview(imgUrl),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imgUrl,
                                        width: 100,
                                        height: 72,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 100,
                                          height: 72,
                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          child: const Icon(Icons.broken_image, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _confirmRemoveApartmentImage(apartment, imgIndex),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  apartment.title,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  apartment.description,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Prix : ${apartment.displayPrice}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteApartment(apartment),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 20),
        Text('Dernières réservations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        _reservations.isEmpty
            ? Center(child: Text('Aucune réservation trouvée.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)))
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 16),
                itemBuilder: (context, index) {
                  final reservation = _reservations[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Text(
                          '${reservation.guestName} • ${reservation.guests} personnes'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${reservation.date.day}/${reservation.date.month}/${reservation.date.year} à ${reservation.time.format(context)}'),
                          const SizedBox(height: 4),
                          Text(
                            reservation.status,
                            style: TextStyle(
                              color: reservation.isConfirmed
                                  ? Theme.of(context).colorScheme.primary
                                  : reservation.isPending
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      trailing: reservation.isPending
                          ? PopupMenuButton<String>(
                              onSelected: (choice) =>
                                  _handleReservationAction(reservation, choice),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'confirm',
                                  child: Text('Confirmer'),
                                ),
                                PopupMenuItem(
                                  value: 'refuse',
                                  child: Text('Refuser'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Supprimer'),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert),
                            )
                          : IconButton(
                              icon: Icon(Icons.delete,
                                  color: Theme.of(context).colorScheme.error),
                              onPressed: () => _cancelReservation(reservation),
                              tooltip: 'Annuler la réservation',
                            ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _reservations.length,
              ),
      ],
    );
  }

  Widget _adminStatCard(String label, String value, IconData icon) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
          const SizedBox(height: 16),
          Text(value,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  DateTime _reservationDateTime(Reservation reservation) {
    return DateTime(
      reservation.date.year,
      reservation.date.month,
      reservation.date.day,
      reservation.time.hour,
      reservation.time.minute,
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!success || !currentUserIsAdmin()) {
        await signOut();
        throw 'Compte admin non autorisé.';
      }

      setState(() {
        _isAdmin = true;
        _userEmail = currentSupabaseUser()?.email;
      });
      await _loadReservations();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion admin réussie.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await signOut();
    setState(() {
      _isAdmin = false;
      _userEmail = null;
      _reservations = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnecté.')),
    );
  }

  Future<void> _cancelReservation(Reservation reservation) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await SupabaseService.cancelReservation(reservation.id);
      _reservations.removeWhere((item) => item.id == reservation.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation annulée.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’annulation : $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateReservationStatus(
      Reservation reservation, String newStatus) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final updated = await SupabaseService.updateReservationStatus(
        reservation.id,
        newStatus,
      );
      final index = _reservations.indexWhere((item) => item.id == reservation.id);
      if (index != -1) {
        _reservations[index] = updated;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour : ${updated.status}')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleReservationAction(Reservation reservation, String action) {
    if (action == 'confirm') {
      _updateReservationStatus(reservation, 'Confirmée');
    } else if (action == 'refuse') {
      _updateReservationStatus(reservation, 'Refusée');
    } else if (action == 'delete') {
      _cancelReservation(reservation);
    }
  }

  Future<void> _selectGalleryFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _selectedGalleryFile = result.files.first;
    });
  }

  Future<void> _selectMenuImageFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _selectedMenuImageFile = result.files.first;
    });
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
      _selectedApartmentFiles = result.files;
    });
  }

  void _showApartmentPreview(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: imageUrl.startsWith('http')
                  ? Image.network(imageUrl, fit: BoxFit.contain)
                  : Image.asset(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemoveApartmentImage(Apartment apartment, int imageIndex) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l’image'),
        content: const Text('Voulez-vous vraiment supprimer cette image ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _removeApartmentImage(apartment, imageIndex);
    }
  }

  Future<void> _removeApartmentImage(Apartment apartment, int imageIndex) async {
    final updatedImages = List<String>.from(apartment.imageUrls);
    updatedImages.removeAt(imageIndex);

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.updateApartmentImages(apartment.id, updatedImages);
      await _loadApartments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image supprimée.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de supprimer l’image : $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadGalleryPhoto() async {
    final label = _galleryLabelController.text.trim();
    final file = _selectedGalleryFile;

    if (label.isEmpty || file == null || file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sélectionnez une photo et renseignez un titre.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.uploadGalleryPhoto(label, file.bytes!, file.name);
      await _loadGalleryPhotos();
      _galleryLabelController.clear();
      setState(() {
        _selectedGalleryFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo uploadée dans la galerie.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d’upload : $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteGalleryPhoto(GalleryPhoto photo) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrl = photo.imageUrl;
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.isNotEmpty ? pathSegments.last : '';
      final storagePath = fileName.isEmpty ? '' : 'uploads/$fileName';

      if (storagePath.isNotEmpty) {
        await supabase.storage.from('gallery').remove([storagePath]);
      }
      await supabase.from('gallery').delete().eq('id', photo.id).select().single();

      await _loadGalleryPhotos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo supprimée.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addMenuItem() async {
    final name = _menuNameController.text.trim();
    final description = _menuDescriptionController.text.trim();
    final price = int.tryParse(_menuPriceController.text.trim()) ?? 0;
    final category = _menuCategoryController.text.trim();
    final selectedFile = _selectedMenuImageFile;

    if (name.isEmpty || description.isEmpty || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez tous les champs du plat.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = '';
      if (selectedFile != null && selectedFile.bytes != null) {
        imageUrl = await SupabaseService.uploadApartmentImage(selectedFile.bytes!, selectedFile.name);
      }

      final dish = Dish(
        id: _editingMenuItem?.id ?? '',
        name: name,
        category: category,
        description: description,
        price: price,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : (_editingMenuItem?.imageUrl ?? ''),
      );

      final isEditing = _editingMenuItem != null;
      final createdDish = isEditing
          ? await SupabaseService.updateMenuItem(dish)
          : await SupabaseService.addMenuItem(dish);

      if (createdDish.id.isEmpty) {
        throw 'Le plat n’a pas été enregistré.';
      }

      _menuNameController.clear();
      _menuDescriptionController.clear();
      _menuPriceController.clear();
      _menuCategoryController.clear();
      _selectedMenuImageFile = null;
      _editingMenuItem = null;
      await _loadMenuItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Pack modifié.' : 'Plat ajouté au menu.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’enregistrement du pack : $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startEditingMenuItem(Dish dish) {
    setState(() {
      _editingMenuItem = dish;
      _menuNameController.text = dish.name;
      _menuDescriptionController.text = dish.description;
      _menuPriceController.text = dish.price.toString();
      _menuCategoryController.text = dish.category;
      _selectedMenuImageFile = null;
    });
  }

  void _cancelMenuEditing() {
    setState(() {
      _editingMenuItem = null;
      _menuNameController.clear();
      _menuDescriptionController.clear();
      _menuPriceController.clear();
      _menuCategoryController.clear();
      _selectedMenuImageFile = null;
    });
  }

  Future<void> _deleteMenuItem(Dish dish) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (dish.id.isEmpty) {
        throw 'Le plat n’a pas d’identifiant valide.';
      }
      await SupabaseService.removeMenuItem(dish.id);
      await _loadMenuItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plat supprimé du menu.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _galleryLabelController.dispose();
    _menuNameController.dispose();
    _menuDescriptionController.dispose();
    _menuPriceController.dispose();
    _menuCategoryController.dispose();
    _apartmentTitleController.dispose();
    _apartmentDescriptionController.dispose();
    _apartmentPriceController.dispose();
    super.dispose();
  }

  Future<void> _openAssistantPanel() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assistant IA Beraka',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Générez une réponse naturelle et personnalisée avec Gemini Flash.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              _assistantActionCard(
                title: 'Réponse à une réservation',
                subtitle: 'Produit une réponse chaleureuse pour un client qui a réservé ou demandé une place.',
                onGenerate: () async {
                  final reservation = _reservations.isNotEmpty ? _reservations.first : null;
                  final contextText = reservation == null
                      ? 'Le client a demandé une réservation au restaurant Beraka’s Valley.'
                      : 'Réservation du client ${reservation.guestName} pour ${reservation.date.day}/${reservation.date.month}/${reservation.date.year} à ${reservation.time.format(context)} pour ${reservation.guests} personnes.';
                  return GeminiService.generateReply(
                    context: contextText,
                    request: 'Rédige une réponse professionnelle, chaleureuse et concise pour confirmer ou remerciement la réservation.',
                  );
                },
              ),
              const SizedBox(height: 12),
              _assistantActionCard(
                title: 'Présentation de Beraka’s Valley',
                subtitle: 'Génère une proposition élégante pour présenter le lieu à un client.',
                onGenerate: () async {
                  return GeminiService.generateReply(
                    context: 'Beraka’s Valley est un restaurant et hôtel de charme, avec une ambiance chaleureuse, une cuisine raffinée et un cadre idéal pour les repas, les événements et les séjours.',
                    request: 'Rédige une réponse convaincante et naturelle pour présenter Beraka’s Valley à un client potentiel.',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _assistantActionCard({
    required String title,
    required String subtitle,
    required Future<String> Function() onGenerate,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final generated = await onGenerate();
                    await Clipboard.setData(ClipboardData(text: generated));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Réponse générée et copiée.')),
                    );
                  } catch (error) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur d’IA : $error')),
                    );
                  }
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Générer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Beraka'),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Déconnexion',
              onPressed: _logout,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isAdmin
            ? SingleChildScrollView(
                child: _buildAdminPanel(),
              )
            : _buildLoginForm(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAssistantPanel,
        tooltip: 'Assistant IA',
        backgroundColor: AppTheme.primary,
        child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Connexion admin',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email admin'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Se connecter'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
