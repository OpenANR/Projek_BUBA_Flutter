import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../models/kuis_model.dart';
import '../../services/kuis_services.dart';
import 'hasil_kuis.dart';

class QuisPage extends StatefulWidget {
  final int kelasId;
  final int kategoriId;
  final String namaKategori;
  final List<KuisModel> daftarKuis;

  const QuisPage({
    super.key,
    required this.kelasId,
    required this.kategoriId,
    required this.namaKategori,
    required this.daftarKuis,
  });

  @override
  State<QuisPage> createState() => _QuisPageState();
}

class _QuisPageState extends State<QuisPage> {
  final KuisServices _kuisServices = KuisServices();
  final AudioPlayer _audioPlayer = AudioPlayer();

  int nomorSoal = 0;
  final Map<int, String> jawabanSiswa = {};
  bool isSubmitting = false;

  KuisModel get soal => widget.daftarKuis[nomorSoal];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> putarAudio(String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio tidak dapat diputar.'),
        ),
      );
    }
  }

  void pilihJawaban(String pilihan) {
    setState(() {
      jawabanSiswa[soal.id] = pilihan;
    });
  }

  void soalSelanjutnya() {
    if (nomorSoal < widget.daftarKuis.length - 1) {
      setState(() {
        nomorSoal++;
      });
    }
  }

  void soalSebelumnya() {
    if (nomorSoal > 0) {
      setState(() {
        nomorSoal--;
      });
    }
  }

  Future<void> konfirmasiSelesai() async {
    final belumDijawab = widget.daftarKuis
        .where((item) => !jawabanSiswa.containsKey(item.id))
        .length;

    final lanjut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          belumDijawab > 0
              ? 'Soal belum selesai'
              : 'Selesaikan Kuis?',
        ),
        content: Text(
          belumDijawab > 0
              ? 'Masih ada $belumDijawab soal yang belum dijawab. '
                  'Apakah kamu tetap ingin mengumpulkan jawaban?'
              : 'Apakah kamu yakin ingin mengirim semua jawaban?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Periksa Lagi'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );

    if (lanjut != true) return;

    await kirimJawaban();
  }

  Future<void> kirimJawaban() async {
    if (jawabanSiswa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jawab minimal satu soal terlebih dahulu.'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final hasil = await _kuisServices.submitKuis(
        kelasId: widget.kelasId,
        kategoriId: widget.kategoriId,
        jawaban: jawabanSiswa,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HasilKuisPage(
            hasil: hasil,
            namaKategori: widget.namaKategori,
            kelasId: widget.kelasId,
            kategoriId: widget.kategoriId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim jawaban: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget pilihanJawaban({
    required String kode,
    required String teks,
    required String? audio,
  }) {
    final dipilih = jawabanSiswa[soal.id] == kode;

    return InkWell(
      onTap: isSubmitting ? null : () => pilihJawaban(kode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: dipilih
              ? const Color(0xFFE8F1FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dipilih
                ? const Color(0xFF2865CC)
                : Colors.grey.shade300,
            width: dipilih ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: dipilih
                    ? const Color(0xFF2865CC)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                kode,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: dipilih ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                teks,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (audio != null && audio.isNotEmpty)
              IconButton(
                onPressed: () => putarAudio(audio),
                icon: const Icon(
                  Icons.volume_up,
                  color: Color(0xFF2865CC),
                ),
              ),
            if (dipilih)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2865CC),
              ),
          ],
        ),
      ),
    );
  }

  Widget gambarSoal() {
    if (soal.gambarUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2865CC),
          width: 2,
        ),
      ),
      child: Column(
        children: soal.gambarUrls.map((url) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                height: 180,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text('Gambar tidak dapat dimuat'),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget progressSoal() {
    final total = widget.daftarKuis.length;
    final terjawab = jawabanSiswa.length;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2865CC),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Pengerjaan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '$terjawab / $total',
                style: const TextStyle(
                  color: Color(0xFF2865CC),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : terjawab / total,
              minHeight: 9,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF2865CC),
            ),
          ),
        ],
      ),
    );
  }

  Widget navigasiNomorSoal() {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: List.generate(widget.daftarKuis.length, (index) {
        final item = widget.daftarKuis[index];
        final aktif = index == nomorSoal;
        final terjawab = jawabanSiswa.containsKey(item.id);

        return InkWell(
          onTap: isSubmitting
              ? null
              : () {
                  setState(() {
                    nomorSoal = index;
                  });
                },
          borderRadius: BorderRadius.circular(9),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: aktif
                  ? const Color(0xFF2865CC)
                  : terjawab
                      ? Colors.green.shade100
                      : Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: aktif
                    ? const Color(0xFF2865CC)
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: aktif
                    ? Colors.white
                    : terjawab
                        ? Colors.green.shade800
                        : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.daftarKuis.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kuis')),
        body: const Center(
          child: Text('Tidak ada soal tersedia.'),
        ),
      );
    }

    return PopScope(
      canPop: !isSubmitting,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2865CC),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Text(
              'KUIS ${widget.namaKategori.toUpperCase()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgroundsplash.png',
                fit: BoxFit.cover,
              ),
            ),

            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 65, 16, 25),
                children: [
                  progressSoal(),
                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF2865CC),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                soal.kodeKuis,
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'Soal ${nomorSoal + 1} '
                              'dari ${widget.daftarKuis.length}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'PERTANYAAN',
                          style: TextStyle(
                            color: Color(0xFF2865CC),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          soal.pertanyaan,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                        if (soal.audioPertanyaanUrl != null &&
                            soal.audioPertanyaanUrl!.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => putarAudio(
                                soal.audioPertanyaanUrl,
                              ),
                              icon: const Icon(Icons.volume_up),
                              label: const Text('Dengarkan pertanyaan'),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  gambarSoal(),

                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF2865CC),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PILIHAN JAWABAN',
                          style: TextStyle(
                            color: Color(0xFF2865CC),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 15),
                        pilihanJawaban(
                          kode: 'A',
                          teks: soal.pilihanA,
                          audio: soal.audioPilihanAUrl,
                        ),
                        pilihanJawaban(
                          kode: 'B',
                          teks: soal.pilihanB,
                          audio: soal.audioPilihanBUrl,
                        ),
                        pilihanJawaban(
                          kode: 'C',
                          teks: soal.pilihanC,
                          audio: soal.audioPilihanCUrl,
                        ),
                        pilihanJawaban(
                          kode: 'D',
                          teks: soal.pilihanD,
                          audio: soal.audioPilihanDUrl,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF2865CC),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nomor Soal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 14),
                        navigasiNomorSoal(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: nomorSoal > 0 && !isSubmitting
                              ? soalSebelumnya
                              : null,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2865CC),
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            side: const BorderSide(
                              color: Color(0xFF2865CC),
                              width: 2,
                            ),
                          ),
                          child: const Text('Sebelumnya'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : nomorSoal < widget.daftarKuis.length - 1
                                  ? soalSelanjutnya
                                  : konfirmasiSelesai,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2865CC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                          child: Text(
                            nomorSoal < widget.daftarKuis.length - 1
                                ? 'Selanjutnya'
                                : 'Selesai',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (isSubmitting)
              Container(
                color: Colors.black38,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 15),
                          Text('Mengirim jawaban...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
