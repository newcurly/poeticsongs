import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/poem_provider.dart';
import 'add_edit_poem_screen.dart';

class PoemListScreen extends StatefulWidget {
  const PoemListScreen({super.key});

  @override
  State<PoemListScreen> createState() => _PoemListScreenState();
}

class _PoemListScreenState extends State<PoemListScreen> {
  final _search = TextEditingController();
  String _orderBy = 'id DESC';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PoemProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('คลังบทประพันธ์เพลง'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _orderBy,
            onSelected: (v) {
              setState(() => _orderBy = v);
              context.read<PoemProvider>().fetchAll(
                    keyword: _search.text,
                    orderBy: _orderBy,
                  );
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'title ASC', child: Text('ชื่อ A→Z')),
              PopupMenuItem(value: 'year DESC', child: Text('ปี ใหม่→เก่า')),
              PopupMenuItem(value: 'id DESC', child: Text('ล่าสุดก่อน')),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'ค้นหา (ชื่อเพลง/ศิลปิน)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _search.clear();
                    context.read<PoemProvider>().fetchAll(orderBy: _orderBy);
                  },
                ),
              ),
              onSubmitted: (_) => context
                  .read<PoemProvider>()
                  .fetchAll(keyword: _search.text, orderBy: _orderBy),
            ),
          ),
          Expanded(
            child: provider.items.isEmpty
                ? const Center(child: Text('ยังไม่มีข้อมูล กด + เพื่อเพิ่ม'))
                : ListView.builder(
                    itemCount: provider.items.length,
                    itemBuilder: (_, i) {
                      final p = provider.items[i];
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              p.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              if (p.id != null) {
                                context
                                    .read<PoemProvider>()
                                    .toggleFavorite(p.id!);
                              }
                            },
                          ),
                          title: Text(p.title),
                          subtitle: Text('${p.lyricist} • ${p.composer} • ${p.year}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                tooltip: 'แก้ไข',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddEditPoemScreen(existing: p),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'ลบ',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('ยืนยันการลบ'),
                                      content: Text('ต้องการลบ "${p.title}" หรือไม่?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('ยกเลิก'),
                                        ),
                                        FilledButton.tonal(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('ลบ'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && p.id != null) {
                                    await context
                                        .read<PoemProvider>()
                                        .delete(p.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPoemScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
