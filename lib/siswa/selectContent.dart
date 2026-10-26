import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContentWidget extends StatefulWidget {
  const ContentWidget({super.key});

  @override
  State<ContentWidget> createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  String apiText = 'Memuat data...';

  @override
  void initState() {
    super.initState();
    fetchTextFromAPI();
  }

  Future<void> fetchTextFromAPI() async {
    try {
      final url = Uri.parse('http://localhost:8000/test.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          apiText = response.body;
        });
      } else {
        setState(() {
          apiText = 'Gagal memuat data (${response.statusCode})';
        });
      }
    } catch (exception) {
      setState(() {
        apiText = ('Gagal mengambil API : $exception');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('OpenANR Application'),
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_reaction_rounded, size: 50),
              Text(apiText, style: TextStyle(fontSize: 30)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          elevation: 40.0,
          child: Icon(Icons.info, color: Colors.white, size: 30),
          onPressed: () {
            showDialog(
              context: context, builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Info A1'),
                  content: Text('Ini adalah popup yang bagus kawan'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      }, 
                      child: Text('Tutup'),
                    ),
                  ],
                );
              }
            );
          },
        ),
      ),
    );
  }
}
