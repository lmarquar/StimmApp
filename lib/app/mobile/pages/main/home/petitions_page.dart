import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/search_text_field.dart';
import 'package:stimmapp/core/data/models/petition.dart';
import 'package:stimmapp/core/data/repositories/petition_repository.dart';

class PetitionsPage extends StatefulWidget {
  const PetitionsPage({super.key});

  @override
  State<PetitionsPage> createState() => _PetitionsPageState();
}

class _PetitionsPageState extends State<PetitionsPage> {
  final _repo = PetitionRepository.create();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Petitionen')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SearchTextField(hint: 'Search petitions', onChanged: (q) => setState(() => _query = q)),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Petition>>(
                stream: _repo.list(query: _query),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snap.data ?? const <Petition>[];
                  if (items.isEmpty) {
                    return const Center(child: Text('No petitions'));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = items[i];
                      return ListTile(
                        title: Text(p.title),
                        subtitle: Text(
                          p.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_note, size: 18),
                            const SizedBox(width: 4),
                            Text(p.signatureCount.toString()),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed('/petition', arguments: p.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
