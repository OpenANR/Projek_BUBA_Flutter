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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2865CC),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Text(
            'DAFTAR KUIS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgroundsplash.png',
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: loadKuis,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 75, 20, 25),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2865CC),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ayo Kerjakan Kuis!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.namaKelas} • ${widget.namaKategori}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Uji pengetahuanmu dan kumpulkan bintang!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF2865CC),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kuis Tersedia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2459A6),
                          ),
                        ),
                        Text(
                          '${daftarKuis.length} Soal',
                          style: const TextStyle(
                            color: Color(0xFF2459A6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (loading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2865CC),
                        ),
                      ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildCard(KuisModel kuis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2865CC),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 7,
            offset: const Offset(0, 4),
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
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
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
                Icons.quiz_rounded,
                color: Color(0xFF2865CC),
                size: 28,
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
              color: Color(0xFF263238),
            ),
          ),

          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 5),

          const Row(
            children: [
              Icon(
                Icons.menu_book,
                size: 18,
                color: Colors.grey,
              ),
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
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Mulai Kuis',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2865CC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 60,
            color: Colors.grey,
          ),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.red,
          ),
          const SizedBox(height: 10),
          Text(
            error!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: loadKuis,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
