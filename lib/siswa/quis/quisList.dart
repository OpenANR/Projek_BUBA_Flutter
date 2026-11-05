import 'package:flutter/material.dart';

import '../../models/kuis_model.dart';
import '../../services/kuis_services.dart';
import 'quis.dart';

class QuisListPage extends StatefulWidget {
  final int kelasId;
  final int kategoriId;
  final String namaKelas;
  final String namaKategori;

  const QuisListPage({
    super.key,
    required this.kelasId,
    required this.kategoriId,
    this.namaKelas = '',
    this.namaKategori = '',
  });

  @override
  State<QuisListPage> createState() => _QuisListPageState();
}

class _QuisListPageState extends State<QuisListPage> {
  final KuisServices _services = KuisServices();

  List<KuisModel> daftarKuis = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadKuis();
  }

  Future<void> loadKuis() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await _services.getKuis(
        kelasId: widget.kelasId,
        kategoriId: widget.kategoriId,
      );

      if (!mounted) return;

      setState(() {
        daftarKuis = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daftar Kuis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadKuis,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ayo Kerjakan Kuis!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.namaKelas} • ${widget.namaKategori}',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Uji pengetahuanmu dan kumpulkan bintang!',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kuis Tersedia',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${daftarKuis.length} Soal',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              _buildError()
            else if (daftarKuis.isEmpty)
              _buildEmpty()
            else
              ...daftarKuis.map((kuis) => _buildCard(kuis)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(KuisModel kuis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kuis.kodeKuis,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(
                Icons.quiz_outlined,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            kuis.pertanyaan,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 5),
          const Row(
            children: [
              Icon(Icons.menu_book, size: 18, color: Colors.grey),
              SizedBox(width: 7),
              Text(
                'Pertanyaan kuis',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuisPage(
                      kelasId: widget.kelasId,
                      kategoriId: widget.kategoriId,
                      namaKategori: widget.namaKategori,
                      daftarKuis: daftarKuis,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Mulai Kuis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.all(35),
      child: Column(
        children: [
          Icon(Icons.quiz_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Belum ada kuis tersedia',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 50, color: Colors.red),
        const SizedBox(height: 10),
        Text(error!, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: loadKuis,
          child: const Text('Coba Lagi'),
        ),
      ],
    );
  }
}
