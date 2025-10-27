// lib/screens/add_edit_poem_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/poem.dart';
import '../providers/poem_provider.dart';

class AddEditPoemScreen extends StatefulWidget {
  final Poem? existing;
  const AddEditPoemScreen({super.key, this.existing});

  @override
  State<AddEditPoemScreen> createState() => _AddEditPoemScreenState();
}

class _AddEditPoemScreenState extends State<AddEditPoemScreen> {
  final _form = GlobalKey<FormState>();
  late String _title, _composer, _lyricist, _key, _lyrics;
  late int _year, _bpm;
  PoemGenre _genre = PoemGenre.other;
  
  bool _isFav = false;
  String _youtubeUrl = '';  

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = e?.title ?? '';
    _composer = e?.composer ?? '';
    _lyricist = e?.lyricist ?? '';
    _genre = e?.genre ?? PoemGenre.other;
    _year = e?.year ?? DateTime.now().year;
    _key = e?.key ?? 'C';
    _bpm = e?.bpm ?? 90;
    _isFav = e?.isFavorite ?? false;
    _lyrics = e?.lyrics ?? '';
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    _form.currentState!.save();
    final p = Poem(
      id: widget.existing?.id,
      title: _title,
      composer: _composer,
      lyricist: _lyricist,
      genre: _genre,
      year: _year,
      key: _key,
      bpm: _bpm,
      isFavorite: _isFav,
      lyrics: _lyrics,
    );
    if (p.id == null) {
      await context.read<PoemProvider>().add(p);
    } else {
      await context.read<PoemProvider>().update(p);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'เพิ่มเพลง' : 'แก้ไขเพลง'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'ชื่อเพลง/บทประพันธ์'),
                validator: (v) => v == null || v.trim().isEmpty ? 'กรอกชื่อ' : null,
                onSaved: (v) => _title = v!.trim(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _composer,
                      decoration: const InputDecoration(labelText: 'ผู้ประพันธ์คำร้อง'),
                      validator: (v) => v == null || v.isEmpty ? 'กรอกชื่อ' : null,
                      onSaved: (v) => _composer = v!.trim(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _lyricist,
                      decoration: const InputDecoration(labelText: 'ผู้ประพันธ์ทำนอง'),
                      validator: (v) => v == null || v.isEmpty ? 'กรอกชื่อ' : null,
                      onSaved: (v) => _lyricist = v!.trim(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _lyricist,
                      decoration: const InputDecoration(labelText: 'ศิลปิน'),
                      validator: (v) => v == null || v.isEmpty ? 'กรอกชื่อ' : null,
                      onSaved: (v) => _lyricist = v!.trim(),
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<PoemGenre>(
                value: _genre,
                decoration: const InputDecoration(labelText: 'แนว'),
                items: PoemGenre.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                    .toList(),
                onChanged: (g) => setState(() => _genre = g!),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '$_year',
                      decoration: const InputDecoration(labelText: 'ปี'),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => _year = int.tryParse(v!.trim()) ?? _year,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _key,
                      decoration: const InputDecoration(labelText: 'คีย์ (เช่น C, Gm)'),
                      onSaved: (v) => _key = v!.trim(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: '$_bpm',
                      decoration: const InputDecoration(labelText: 'BPM'),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => _bpm = int.tryParse(v!.trim()) ?? _bpm,
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: _isFav,
                onChanged: (b) => setState(() => _isFav = b),
                title: const Text('เพิ่มในรายการโปรด'),
              ),
              TextFormField(
                initialValue: _lyrics,
                decoration: const InputDecoration(
                  labelText: 'เนื้อเพลง/บทกวี',
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                onSaved: (v) => _lyrics = v!.trim(),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('บันทึก'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
