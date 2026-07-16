import 'package:flutter/material.dart';

import '../models.dart';
import '../services/supabase_service.dart';
import 'admin_pack_form.dart';

class AdminPacksScreen extends StatefulWidget {
  const AdminPacksScreen({super.key});

  @override
  State<AdminPacksScreen> createState() => _AdminPacksScreenState();
}

class _AdminPacksScreenState extends State<AdminPacksScreen> {
  bool _isLoading = true;
  List<Dish> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      _items = await SupabaseService.fetchMenuPaged(from: 0, limit: 30);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _deletePack(Dish dish) async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.removeMenuItem(dish.id);
      await _loadItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pack supprimé.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de supprimer le pack : $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editPack(Dish dish) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminPackForm(dish: dish)));
    await _loadItems();
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final more = await SupabaseService.fetchMenuPaged(from: _items.length, limit: 30);
      setState(() => _items.addAll(more));
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Packs')),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                itemCount: _items.length + 1,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _loadMore,
                          child: const Text('Charger plus'),
                        ),
                      ),
                    );
                  }
                  final d = _items[index];
                  return ListTile(
                    title: Text(d.name),
                    subtitle: Text(d.category),
                    onTap: () => _editPack(d),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editPack(d);
                        } else if (value == 'delete') {
                          _deletePack(d);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Modifier')),
                        PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPackForm()));
          await _loadItems();
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un pack',
      ),
    );
  }
}
