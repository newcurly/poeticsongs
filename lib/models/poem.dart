
enum PoemGenre { lyric, ballad, lullaby, hymn, folk, other }

class Poem {
  final int? id;
  final String title;       // ชื่อบทเพลง/บทประพันธ์
  final String lyricist;    // ผู้ประพันธ์คำร้อง
  final String composer;    // ผู้ประพันธ์ทำนอง
  final String artist;      // ศิลปิน 
  final PoemGenre genre;    // แนว/ประเภท
  final int year;           // ปีที่เผยแพร่
  final String key;         // คีย์เพลง (เช่น C, Gm)
  final int bpm;            // ความเร็ว (BPM)
  final bool isFavorite;    // บันทึกเป็นรายการโปรด
  final String lyrics;      // เนื้อเพลง/บทกวีเต็ม

  Poem({
    this.id,
    required this.title,
    required this.lyricist,
    required this.composer,
    required this.artist,
    required this.genre,
    required this.year,
    required this.key,
    required this.bpm,
    this.isFavorite = false,
    required this.lyrics,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'lyricist': lyricist,
        'composer': composer,
        'artist': artist, 
        'genre': genre.name,
        'year': year,
        'songKey': key,
        'bpm': bpm,
        'isFavorite': isFavorite ? 1 : 0,
        'lyrics': lyrics,
      };

  factory Poem.fromMap(Map<String, dynamic> m) => Poem(
        id: m['id'] as int?,
        title: m['title'] as String,
        lyricist: (m['lyricist'] ?? '') as String,
        composer: (m['composer'] ?? '') as String,
        artist: (m['artist'] ?? '') as String,
        genre: PoemGenre.values.firstWhere(
          (g) => g.name == (m['genre'] as String? ?? 'other'),
          orElse: () => PoemGenre.other,
        ),
        year: m['year'] as int,
        key: m['songKey'] as String,
        bpm: m['bpm'] as int,
        isFavorite: (m['isFavorite'] as int) == 1,
        lyrics: m['lyrics'] as String,
      );

  Poem copyWith({
    int? id,
    String? title,
    String? lyricist,
    String? composer,
    String? artist,
    PoemGenre? genre,
    int? year,
    String? key,
    int? bpm,
    bool? isFavorite,
    String? lyrics,
  }) {
    return Poem(
      id: id ?? this.id,
      title: title ?? this.title,
      lyricist: lyricist ?? this.lyricist,
      composer: composer ?? this.composer,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      key: key ?? this.key,
      bpm: bpm ?? this.bpm,
      isFavorite: isFavorite ?? this.isFavorite,
      lyrics: lyrics ?? this.lyrics,
    );
  }
}
