
import 'package:flutter/material.dart';

// Fungsi utama untuk menjalankan aplikasi Flutter
void main() {
  runApp(const BubaApp());
}

// Widget utama aplikasi BUBA
class BubaApp extends StatelessWidget {
  const BubaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Menghilangkan tulisan debug di pojok kanan atas
      debugShowCheckedModeBanner: false,

      // Nama aplikasi
      title: 'BUBA - Kelola Materi',

      // Mengatur tema dan warna utama aplikasi
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF269B70),
        ),
        useMaterial3: true,
      ),

      // Menampilkan halaman Kelola Materi
      home: const MateriPage(),
    );
  }
}

// StatefulWidget digunakan karena tampilan dapat berubah,
// misalnya ketika dropdown dipilih atau materi ditambahkan.
class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  // Controller untuk mengambil teks dari kolom judul materi
  final TextEditingController judulController =
      TextEditingController();

  // Controller untuk mengambil teks dari kolom isi materi
  final TextEditingController isiController =
      TextEditingController();

  // Menyimpan pilihan kategori dan kelas yang dipilih pengguna
  // Nilai null berarti belum ada pilihan.
  String? kategoriTerpilih;
  String? kelasTerpilih;

  // Daftar pilihan kategori untuk dropdown
  // Data ini masih berupa contoh, belum dari database Laravel.
  final List<String> kategoriList = [
    'Huruf & Angka',
    'Warna & Bentuk',
    'Hewan & Tumbuhan',
    'Anggota Tubuh',
  ];

  // Daftar pilihan kelas untuk dropdown
  final List<String> kelasList = [
    'Kelas A',
    'Kelas B',
  ];

  // Menyimpan materi sementara selama aplikasi berjalan.
  // Data akan hilang jika aplikasi dimulai ulang.
  final List<Map<String, String>> daftarMateri = [];

  // Fungsi untuk memeriksa dan menyimpan materi
  void simpanMateri() {
    // Memastikan semua kolom telah diisi
    if (judulController.text.trim().isEmpty ||
        isiController.text.trim().isEmpty ||
        kategoriTerpilih == null ||
        kelasTerpilih == null) {

      // Menampilkan pesan jika masih ada kolom kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom harus diisi!'),
        ),
      );

      // Menghentikan proses penyimpanan
      return;
    }

    // Memperbarui tampilan dan menambahkan materi ke daftar
    setState(() {
      daftarMateri.add({
        'judul': judulController.text.trim(),
        'isi': isiController.text.trim(),
        'kategori': kategoriTerpilih!,
        'kelas': kelasTerpilih!,
      });
    });

    // Mengosongkan kolom judul dan isi setelah disimpan
    judulController.clear();
    isiController.clear();

    // Mengembalikan dropdown ke kondisi belum dipilih
    setState(() {
      kategoriTerpilih = null;
      kelasTerpilih = null;
    });

    // Menampilkan pesan bahwa materi berhasil ditambahkan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Materi berhasil ditambahkan!'),
      ),
    );
  }

  // Membersihkan controller ketika halaman tidak digunakan lagi
  @override
  void dispose() {
    judulController.dispose();
    isiController.dispose();
    super.dispose();
  }

  // Fungsi build untuk menyusun tampilan halaman
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna latar belakang halaman
      backgroundColor: const Color(0xFFF4F8F6),

      // Bagian header di atas halaman
      appBar: AppBar(
        backgroundColor: const Color(0xFF269B70),
        foregroundColor: Colors.white,
        title: const Text(
          'BUBA • Kelola Materi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // Membuat konten berada di tengah dan memiliki batas lebar
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),

          // ListView memungkinkan halaman digulir
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Judul halaman
              const Text(
                'Kelola Materi',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF206B50),
                ),
              ),

              const SizedBox(height: 6),

              // Deskripsi halaman
              const Text(
                'Tambahkan materi pembelajaran untuk anak.',
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 22),

              // Card sebagai wadah formulir tambah materi
              Card(
                elevation: 1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  // Column menyusun komponen secara vertikal
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tambah Materi Baru',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Label dropdown kategori
                      const Text('Kategori'),
                      const SizedBox(height: 8),

                      // Dropdown untuk memilih kategori materi
                      DropdownButtonFormField<String>(
                        value: kategoriTerpilih,
                        isExpanded: true,

                        // Tampilan kotak dropdown
                        decoration: InputDecoration(
                          hintText: 'Pilih kategori materi',
                          prefixIcon:
                              const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // Mengubah setiap kategori menjadi pilihan dropdown
                        items: kategoriList.map((kategori) {
                          return DropdownMenuItem<String>(
                            value: kategori,
                            child: Text(kategori),
                          );
                        }).toList(),

                        // Menyimpan kategori ketika pengguna memilihnya
                        onChanged: (value) {
                          setState(() {
                            kategoriTerpilih = value;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      // Label dropdown kelas
                      const Text('Kelas'),
                      const SizedBox(height: 8),

                      // Dropdown untuk memilih kelas
                      DropdownButtonFormField<String>(
                        value: kelasTerpilih,
                        isExpanded: true,

                        decoration: InputDecoration(
                          hintText: 'Pilih kelas',
                          prefixIcon:
                              const Icon(Icons.school_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // Menampilkan daftar kelas sebagai pilihan
                        items: kelasList.map((kelas) {
                          return DropdownMenuItem<String>(
                            value: kelas,
                            child: Text(kelas),
                          );
                        }).toList(),

                        // Menyimpan kelas yang dipilih
                        onChanged: (value) {
                          setState(() {
                            kelasTerpilih = value;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      // Label kolom judul materi
                      const Text('Judul Materi'),
                      const SizedBox(height: 8),

                      // Kolom untuk memasukkan judul materi
                      TextField(
                        controller: judulController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Mengenal Huruf A',
                          prefixIcon:
                              const Icon(Icons.menu_book_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Label kolom isi materi
                      const Text('Isi Materi'),
                      const SizedBox(height: 8),

                      // Kolom untuk memasukkan isi materi
                      // maxLines: 4 membuat kolom memiliki empat baris
                      TextField(
                        controller: isiController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tuliskan isi materi...',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Tombol untuk menjalankan fungsi simpanMateri()
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: simpanMateri,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Simpan Materi'),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF269B70),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Judul bagian daftar materi
              const Text(
                'Daftar Materi',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Pesan yang muncul jika daftar materi masih kosong
              if (daftarMateri.isEmpty)
                const Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Belum ada materi yang ditambahkan.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ),

              // Menampilkan semua materi yang telah ditambahkan
              // asMap().entries memberikan indeks dan data materi
              ...daftarMateri.asMap().entries.map((entry) {
                final index = entry.key;
                final materi = entry.value;

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    // Nomor urut materi
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFDDF4E8),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF206B50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Menampilkan judul materi
                    title: Text(
                      materi['judul']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Menampilkan kategori, kelas, dan isi materi
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Kategori: ${materi['kategori']}\n'
                        'Kelas: ${materi['kelas']}\n'
                        '${materi['isi']}',
                      ),
                    ),

                    // Memberikan ruang untuk beberapa baris teks
                    isThreeLine: true,

                    // Tombol hapus untuk menghilangkan materi dari daftar
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          daftarMateri.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}