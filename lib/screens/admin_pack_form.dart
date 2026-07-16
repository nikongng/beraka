import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models.dart';
import '../services/supabase_service.dart';

class AdminPackForm extends StatefulWidget {
  final Dish? dish;

  const AdminPackForm({super.key, this.dish});

  @override
  State<AdminPackForm> createState() => _AdminPackFormState();
}

class _AdminPackFormState extends State<AdminPackForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _satPrice = TextEditingController();
  final TextEditingController _friSunPrice = TextEditingController();
  bool _premium = false;
  bool _priceVarious = false;
  PlatformFile? _image;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.dish != null) {
      _name.text = widget.dish!.name;
      _description.text = widget.dish!.description;
      _price.text = widget.dish!.price.toString();
      _satPrice.text = widget.dish!.saturdayPrice.toString();
      _friSunPrice.text = widget.dish!.friSunPrice.toString();
      _premium = widget.dish!.premium;
      _priceVarious = widget.dish!.priceVarious;
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _image = result.files.first);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      String imageUrl = widget.dish?.imageUrl ?? '';
      if (_image?.bytes != null) {
        imageUrl = await SupabaseService.uploadApartmentImage(_image!.bytes!, _image!.name);
      }
      final dish = Dish(
        id: widget.dish?.id ?? '',
        name: _name.text.trim(),
        category: widget.dish?.category ?? 'Tous',
        description: _description.text.trim(),
        price: int.tryParse(_price.text.trim()) ?? 0,
        saturdayPrice: int.tryParse(_satPrice.text.trim()) ?? 0,
        friSunPrice: int.tryParse(_friSunPrice.text.trim()) ?? 0,
        priceVarious: _priceVarious,
        priceText: (_price.text.trim().isNotEmpty ? '${_price.text.trim()} USD' : ''),
        includes: widget.dish?.includes ?? [],
        imageUrl: imageUrl,
        categoryId: widget.dish?.categoryId ?? '',
        defaultEventType: widget.dish?.defaultEventType ?? '',
        tag: widget.dish?.tag ?? '',
        priceNote: widget.dish?.priceNote ?? '',
        defaultMenuPack: widget.dish?.defaultMenuPack ?? '',
      );

      if (widget.dish == null) {
        await SupabaseService.addMenuItem(dish);
      } else {
        await SupabaseService.updateMenuItem(dish);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.dish == null ? 'Ajouter un pack' : 'Modifier le pack')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Prix général (USD)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _satPrice,
                decoration: const InputDecoration(labelText: 'Prix Samedi (USD)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _friSunPrice,
                decoration: const InputDecoration(labelText: 'Prix Vendredi & Dimanche (USD)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Prix divers'),
                value: _priceVarious,
                onChanged: (v) => setState(() => _priceVarious = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choisir une photo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const CircularProgressIndicator() : Text(widget.dish == null ? 'Enregistrer' : 'Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
