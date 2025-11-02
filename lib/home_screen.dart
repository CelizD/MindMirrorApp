import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'firestore_service.dart';
import 'stats_screen.dart'; // Pantalla de estadísticas

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  // --- Guardar entrada ---
  Future<void> _saveEntry() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _firestoreService.addJournalEntry(_textController.text);
      _textController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada guardada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Ir a estadísticas ---
  void _goToStatsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatsScreen()),
    );
  }

  // --- Cerrar sesión ---
  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  // --- Emoji de sentimiento ---
  String _getSentimentEmoji(num? score) {
    if (score == null) return '⏳'; // Aún analizando
    if (score > 0.2) return '😊'; // Positivo
    if (score < -0.2) return '😞'; // Negativo
    return '😐'; // Neutral
  }

  // --- Eliminar entrada ---
  Future<void> _deleteEntry(String docId) async {
    try {
      await _firestoreService.deleteJournalEntry(docId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada eliminada'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Mi Diario'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Estadísticas',
            onPressed: _goToStatsPage,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Sección de nueva entrada ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: '¿Cómo te sientes hoy?',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveEntry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Guardar Entrada',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(thickness: 1),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Entradas Anteriores:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // --- Lista de entradas ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getJournalEntries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay entradas. ¡Escribe la primera!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final entries = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final doc = entries[index];
                    final entry = doc.data() as Map<String, dynamic>;
                    final text = entry['text'] ?? 'Sin texto';
                    final timestamp = entry['timestamp'] as Timestamp?;
                    final score = entry['sentimentScore'] as num?;
                    final emoji = _getSentimentEmoji(score);

                    final date = timestamp != null
                        ? DateFormat('dd/MM/yyyy - hh:mm a')
                            .format(timestamp.toDate())
                        : 'Sin fecha';

                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteEntry(doc.id),
                      background: Container(
                        color: Colors.red[700],
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: const Icon(Icons.delete_forever,
                            color: Colors.white),
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: Text(emoji,
                              style: const TextStyle(fontSize: 30)),
                          title: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              date,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
