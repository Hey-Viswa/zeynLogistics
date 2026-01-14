import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:easy_localization/easy_localization.dart';
import '../../shared/services/user_repository.dart';
import '../../shared/data/user_model.dart';

class SavedPlacesScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const SavedPlacesScreen({super.key, required this.user});

  @override
  ConsumerState<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends ConsumerState<SavedPlacesScreen> {
  final TextEditingController _placeController = TextEditingController();

  Future<void> _addPlace() async {
    final newPlace = _placeController.text.trim();
    if (newPlace.isEmpty) return;

    final updatedPlaces = List<String>.from(widget.user.savedPlaces)
      ..add(newPlace);
    await ref
        .read(userRepositoryProvider)
        .updateSavedPlaces(widget.user.id, updatedPlaces);

    _placeController.clear();
    // Optimistic update or wait for stream, here we rely on stream
  }

  Future<void> _removePlace(String place) async {
    final updatedPlaces = List<String>.from(widget.user.savedPlaces)
      ..remove(place);
    await ref
        .read(userRepositoryProvider)
        .updateSavedPlaces(widget.user.id, updatedPlaces);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to real-time updates
    final userAsync = ref.watch(userStreamProvider(widget.user.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Places')),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          final places = user.savedPlaces;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _placeController,
                        decoration: const InputDecoration(
                          hintText: 'Add a place (e.g., Home, Work)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 32),
                      onPressed: _addPlace,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return ListTile(
                      leading: const Icon(Icons.place),
                      title: Text(place),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removePlace(place),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
