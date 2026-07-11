import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:beraca/theme/app_theme.dart';

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
  final TextEditingController _galleryAlbumTitleController = TextEditingController();
  final TextEditingController _menuNameController = TextEditingController();
  final TextEditingController _menuDescriptionController = TextEditingController();
  final TextEditingController _menuPriceController = TextEditingController();
  final TextEditingController _menuTagController = TextEditingController();
  String _menuCategoryId = 'Mariage';
  final TextEditingController _menuDefaultMenuPackController = TextEditingController();
  final TextEditingController _menuPriceNoteController = TextEditingController();

  bool get _isServiceTraiteur => _menuCategoryId == 'Services traiteurs';
  bool get _isShortMenuCategory => _isServiceTraiteur || _menuCategoryId == 'Cocktail';
  final TextEditingController _menuIncludesController = TextEditingController();

  final TextEditingController _adminReservationNameController = TextEditingController();
  final TextEditingController _adminReservationPhoneController = TextEditingController();
  final TextEditingController _adminReservationEmailController = TextEditingController();
  final TextEditingController _adminReservationGuestsController = TextEditingController(text: '4');
  final TextEditingController _adminReservationNoteController = TextEditingController();
  final List<String> _adminReservationEventTypes = [
    'Mariage',
    'Anniversaire',
    'Réunion',
    'Conférence',
    'Cérémonie',
    'Cocktail',
    'Autre',
  ];
  String? _adminSelectedEventType = 'Mariage';
  String? _adminSelectedMenuPack;
  DateTime? _adminSelectedDate;
  TimeOfDay? _adminSelectedTime;

  final TextEditingController _apartmentTitleController = TextEditingController();
  bool _menuPremium = false;
  final TextEditingController _apartmentDescriptionController = TextEditingController();
  final TextEditingController _apartmentPriceController = TextEditingController();
  List<PlatformFile> _selectedApartmentFiles = [];
  List<PlatformFile> _selectedGalleryFiles = [];
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
        Text('Créer une réservation admin',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        TextField(
          controller: _adminReservationNameController,
          decoration:
              const InputDecoration(labelText: 'Nom du client'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _adminReservationPhoneController,
          keyboardType: TextInputType.phone,
          decoration:
              const InputDecoration(labelText: 'Téléphone'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _adminReservationEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration:
              const InputDecoration(labelText: 'Email (facultatif)'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _adminSelectedEventType,
                decoration: const InputDecoration(labelText: 'Type d’événement'),
                items: _adminReservationEventTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _adminSelectedEventType = value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _adminSelectedMenuPack,
                decoration: const InputDecoration(labelText: 'Menu pack'),
                items: _menuItems
                    .map((item) => DropdownMenuItem(value: item.name, child: Text(item.name)))
                    .toList(),
                onChanged: (value) => setState(() => _adminSelectedMenuPack = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _pickAdminReservationDate,
                child: Text(_adminSelectedDate == null
                    ? 'Choisir une date'
                    : '${_adminSelectedDate!.day}/${_adminSelectedDate!.month}/${_adminSelectedDate!.year}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _pickAdminReservationTime,
                child: Text(_adminSelectedTime == null
                    ? 'Choisir une heure'
                    : _adminSelectedTime!.format(context)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _adminReservationGuestsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Nombre de personnes'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _adminReservationNoteController,
          decoration: const InputDecoration(labelText: 'Notes supplémentaires'),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _createAdminReservation,
          child: const Text('Créer la réservation (confirmée)'),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        Text('Ajouter un album à la galerie',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        TextField(
          controller: _galleryAlbumTitleController,
          decoration: const InputDecoration(labelText: 'Titre de l’album'),
        ),
        const SizedBox(height: 12),
        Text(
          'Sélectionnez une photo de couverture et des sous-photos.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _selectGalleryFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text('Choisir des photos'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _selectedGalleryFiles.isEmpty
              ? 'Aucune photo sélectionnée'
              : '${_selectedGalleryFiles.length} photo(s) sélectionnée(s)',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Text(
          'La première photo sélectionnée sera utilisée comme couverture sur la page d’accueil.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: (!_isLoading && _selectedGalleryFiles.isNotEmpty)
              ? _uploadGalleryPhotos
              : null,
          icon: const Icon(Icons.photo_library),
          label: const Text('Uploader l’album'),
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
          decoration: InputDecoration(
            labelText: _isShortMenuCategory ? 'Détail du plat' : 'Description du pack',
          ),
          maxLines: _isShortMenuCategory ? 4 : 2,
        ),
        if (!_isShortMenuCategory) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _menuPriceController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Prix du pack (USD)'),
          ),
        ],
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _menuCategoryId,
          decoration: const InputDecoration(labelText: 'Catégorie'),
          items: const [
            DropdownMenuItem(value: 'Mariage', child: Text('Mariage')),
            DropdownMenuItem(value: 'Autres cérémonies', child: Text('Autres cérémonies')),
            DropdownMenuItem(value: 'Espace extérieur', child: Text('Espace extérieur')),
            DropdownMenuItem(value: 'Services traiteurs', child: Text('Services traiteurs')),
            DropdownMenuItem(value: 'Cocktail', child: Text('Cocktail')),
            DropdownMenuItem(value: 'Tous', child: Text('Tous')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _menuCategoryId = value;
              });
            }
          },
        ),
        if (!_isShortMenuCategory) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _menuDefaultMenuPackController,
            decoration: const InputDecoration(labelText: 'Sous menu'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _menuTagController,
            decoration: const InputDecoration(labelText: 'tag'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _menuPriceNoteController,
            decoration: const InputDecoration(labelText: 'price_note'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Premium'),
                  value: _menuPremium,
                  onChanged: (value) {
                    setState(() {
                      _menuPremium = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _menuIncludesController,
            decoration: const InputDecoration(labelText: 'Services inclus (séparées par des virgules)'),
          ),
        ],
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
                  subtitle: Text('${dish.category} • ${dish.priceText.isNotEmpty ? dish.priceText : '${dish.price} USD'}'),
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
                                        decoration: const BoxDecoration(
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            tooltip: 'Voir les détails',
                            onPressed: () => _showReservationDetails(reservation),
                          ),
                          reservation.isPending
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
                        ],
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
      await _loadGalleryPhotos();
      await _loadMenuItems();
      await _loadApartments();
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

  Future<void> _pickAdminReservationDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      locale: const Locale('fr', 'FR'),
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedDate != null) {
      setState(() => _adminSelectedDate = selectedDate);
    }
  }

  Future<void> _pickAdminReservationTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 19, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedTime != null) {
      setState(() => _adminSelectedTime = selectedTime);
    }
  }

  Future<void> _createAdminReservation() async {
    final name = _adminReservationNameController.text.trim();
    final phone = _adminReservationPhoneController.text.trim();
    final email = _adminReservationEmailController.text.trim();
    final guests = int.tryParse(_adminReservationGuestsController.text.trim()) ?? 1;
    final eventType = _adminSelectedEventType ?? 'Autre';
    final menuPack = _adminSelectedMenuPack ?? '';
    final note = _adminReservationNoteController.text.trim();

    if (name.isEmpty || phone.isEmpty || _adminSelectedDate == null || _adminSelectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez le nom, le téléphone, la date et l’heure.')),
      );
      return;
    }

    if (guests <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indiquez un nombre de personnes valide.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final reservation = Reservation(
        id: '',
        guestName: name,
        phone: phone,
        email: email,
        date: _adminSelectedDate!,
        time: _adminSelectedTime!,
        guests: guests,
        eventType: eventType,
        menuPack: menuPack,
        note: note.isEmpty ? 'Réservation créée par l’admin.' : 'Réservation créée par l’admin.\n$note',
        status: 'Confirmée',
      );
      final createdReservation = await SupabaseService.createReservation(reservation);
      setState(() {
        _reservations.insert(0, createdReservation);
        _adminReservationNameController.clear();
        _adminReservationPhoneController.clear();
        _adminReservationEmailController.clear();
        _adminReservationGuestsController.text = '4';
        _adminReservationNoteController.clear();
        _adminSelectedEventType = 'Mariage';
        _adminSelectedMenuPack = null;
        _adminSelectedDate = null;
        _adminSelectedTime = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation admin créée et validée automatiquement.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création de la réservation : $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  void _showReservationDetails(Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la réservation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Nom', reservation.guestName),
              _detailRow('Téléphone', reservation.phone),
              _detailRow('Email', reservation.email),
              _detailRow('Date',
                  '${reservation.date.day}/${reservation.date.month}/${reservation.date.year}'),
              _detailRow('Heure', reservation.time.format(context)),
              _detailRow('Nombre de personnes', reservation.guests.toString()),
              _detailRow('Type d’événement', reservation.eventType.isEmpty ? '-' : reservation.eventType),
              _detailRow('Pack', reservation.menuPack.isEmpty ? '-' : reservation.menuPack),
              _detailRow('Statut', reservation.status),
              const SizedBox(height: 12),
              const Text(
                'Note',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(reservation.note.isEmpty ? '-' : reservation.note),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
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
      _selectedGalleryFiles = result.files;
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

  Future<void> _uploadGalleryPhotos() async {
    final title = _galleryAlbumTitleController.text.trim();

    if (title.isEmpty || _selectedGalleryFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Renseignez le titre de l’album et sélectionnez des photos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      for (final file in _selectedGalleryFiles) {
        if (file.bytes == null) {
          continue;
        }
        await SupabaseService.uploadGalleryPhoto(title, file.bytes!, file.name);
      }
      await _loadGalleryPhotos();
      _galleryAlbumTitleController.clear();
      setState(() {
        _selectedGalleryFiles = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Album uploadé dans la galerie.')),
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
    final categoryId = _menuCategoryId;
    final defaultMenuPack = _menuDefaultMenuPackController.text.trim();
    final tag = _menuTagController.text.trim();
    final priceNote = _menuPriceNoteController.text.trim();
    final premium = _menuPremium;
    final selectedFile = _selectedMenuImageFile;

    // Transformation du champ texte en liste (séparé par des virgules)
    final includesList = _menuIncludesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (name.isEmpty || description.isEmpty || categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez tous les champs obligatoires du pack.')),
      );
      return;
    }

    if (_isShortMenuCategory && selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une photo pour ce type de menu.')),
      );
      return;
    }

    if (!_isShortMenuCategory && price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indiquez un prix valide pour le pack.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = '';
      if (selectedFile != null && selectedFile.bytes != null) {
        // Note: Nous utilisons uploadApartmentImage comme méthode générique d'upload d'image selon votre service
        imageUrl = await SupabaseService.uploadApartmentImage(selectedFile.bytes!, selectedFile.name);
      }

      final dish = Dish(
        id: _editingMenuItem?.id ?? '',
        name: name,
        category: categoryId,
        categoryId: categoryId,
        defaultMenuPack: defaultMenuPack,
        tag: tag,
        priceNote: priceNote,
        premium: premium,
        description: description,
        price: price,
        priceText: price > 0 ? '$price USD' : '',
        includes: includesList,  // Ajout de la liste des inclusions
        imageUrl: imageUrl.isNotEmpty ? imageUrl : (_editingMenuItem?.imageUrl ?? ''),
      );

      final isEditing = _editingMenuItem != null;
      final createdDish = isEditing
          ? await SupabaseService.updateMenuItem(dish)
          : await SupabaseService.addMenuItem(dish);

      if (createdDish.id.isEmpty) {
        throw 'Le plat n’a pas été enregistré.';
      }

      // Nettoyage de tous les champs
      _menuNameController.clear();
      _menuDescriptionController.clear();
      _menuPriceController.clear();
      _menuCategoryId = 'Mariage';
      _menuDefaultMenuPackController.clear();
      _menuTagController.clear();
      _menuPriceNoteController.clear();
      _menuIncludesController.clear(); 
      _menuPremium = false;
      _selectedMenuImageFile = null;
      _editingMenuItem = null;
      
      await _loadMenuItems();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Pack modifié.' : 'Plat ajouté au menu.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’enregistrement du pack : $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
void _startEditingMenuItem(Dish dish) {
    setState(() {
      _editingMenuItem = dish;
      _menuNameController.text = dish.name;
      _menuDescriptionController.text = dish.description;
      _menuPriceController.text = dish.price.toString();
      _menuCategoryId = _normalizeCategoryForDropdown(
        dish.categoryId.isNotEmpty ? dish.categoryId : dish.category,
      );
      _menuDefaultMenuPackController.text = dish.defaultMenuPack;
      _menuTagController.text = dish.tag;
      _menuPriceNoteController.text = dish.priceNote;
      _menuPremium = dish.premium;
      _menuIncludesController.text = dish.includes.join(', ');
      _selectedMenuImageFile = null;
    });
  }

  String _normalizeCategoryForDropdown(String category) {
    final normalized = category.toLowerCase().trim();
    if (normalized == 'autres_ceremonies' ||
        normalized == 'autres cérémonies' ||
        normalized == 'autres ceremonies') {
      return 'Autres cérémonies';
    }
    if (normalized == 'espace_exterieur' ||
        normalized == 'espace extérieur' ||
        normalized == 'espace exterieur') {
      return 'Espace extérieur';
    }
    if (normalized == 'services_traiteurs' ||
        normalized == 'services traiteurs' ||
        normalized == 'services traiteur') {
      return 'Services traiteurs';
    }
    if (normalized == 'cocktail' || normalized == 'cocktails') return 'Cocktail';
    if (normalized == 'mariage') return 'Mariage';
    if (normalized == 'tous') return 'Tous';
    return category;
  }

void _cancelMenuEditing() {
    setState(() {
      _editingMenuItem = null;
      _menuNameController.clear();
      _menuDescriptionController.clear();
      _menuPriceController.clear();
      _menuCategoryId = 'Mariage';
      _menuDefaultMenuPackController.clear();
      _menuTagController.clear();
      _menuPriceNoteController.clear();
      _menuIncludesController.clear();
      _menuPremium = false;
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
    _galleryAlbumTitleController.dispose();
    _menuNameController.dispose();
    _menuDescriptionController.dispose();
    _menuPriceController.dispose();
    _menuTagController.dispose();
    _menuDefaultMenuPackController.dispose();
    _menuPriceNoteController.dispose();
    _menuIncludesController.dispose();
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
                'Assistant IA Beraca',
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
                      ? 'Le client a demandé une réservation au restaurant Beraca’s Valley.'
                      : 'Réservation du client ${reservation.guestName} pour ${reservation.date.day}/${reservation.date.month}/${reservation.date.year} à ${reservation.time.format(context)} pour ${reservation.guests} personnes.';
                  return GeminiService.generateReply(
                    context: contextText,
                    request: 'Rédige une réponse professionnelle, chaleureuse et concise pour confirmer ou remerciement la réservation.',
                  );
                },
              ),
              const SizedBox(height: 12),
              _assistantActionCard(
                title: 'Présentation de Beraca’s Valley',
                subtitle: 'Génère une proposition élégante pour présenter le lieu à un client.',
                onGenerate: () async {
                  return GeminiService.generateReply(
                    context: 'Beraca’s Valley est une salle de reception de charme, avec une ambiance chaleureuse, une cuisine raffinée et un cadre idéal pour les repas, les événements et les séjours.',
                    request: 'Rédige une réponse convaincante et naturelle pour présenter Beraca’s Valley à un client potentiel.',
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
        title: const Text('Admin Beraca'),
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
