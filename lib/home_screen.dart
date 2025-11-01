import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'firestore_service.dart';
import 'stats_screen.dart'; // Importamos la pantalla de estadísticas

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  // --- (ACTUALIZADO) Función de Guardar ---
  Future<void> _saveEntry() async {
    if (_textController.text.isEmpty) {
      // No guardar si está vacío
      return;
    }
    
    // Mostramos el círculo de carga
    setState(() {
      _isLoading = true;
    });

    try {
      // Guardamos en Firestore
      await _firestoreService.addJournalEntry(_textController.text);
      
      // Limpiamos el texto
      _textController.clear();

      // Ocultamos el círculo de carga
      setState(() {
        _isLoading = false;
      });

      // Mostramos un mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada guardada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      // Ocultamos el círculo de carga
      setState(() {
        _isLoading = false;
      });
      // Mostramos error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- (NUEVO) Función para ir a Estadísticas ---
  void _goToStatsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatsScreen()),
    );
  }

  // --- Función para Cerrar Sesión ---
  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  // --- Función para obtener Emoji ---
  String _getSentimentEmoji(num? score) {
    if (score == null) {
      return '⏳'; // Analizando...
    }
    if (score > 0.2) return '😊'; // Positivo
    if (score < -0.2) return '😞'; // Negativo
    return '😐'; // Neutral
  }

  // --- Función para Borrar Entrada ---
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
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- (MODIFICADO) Fondo gris ---
      backgroundColor: Colors.grey[200], 

      // --- (MODIFICADO) AppBar moderna ---
      appBar: AppBar(
        title: const Text('Mi Diario'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Botón de Estadísticas
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: _goToStatsPage,
            tooltip: 'Estadísticas',
          ),
          // Botón de Cerrar Sesión
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          // --- (MODIFICADO) Sección para nueva entrada ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- (MODIFICADO) Campo de texto moderno ---
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: '¿Cómo te sientes hoy?',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none, // Sin borde
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // --- (MODIFICADO) Botón moderno ---
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
          
          // --- Separador ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(thickness: 1),
          ),
          
          // --- Título de la lista ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Entradas Anteriores:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // --- Lista de Entradas ---
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
                    
                    final String text = entry['text'] ?? 'Sin texto';
                    final Timestamp? timestamp = entry['timestamp'];
                    final num? score = entry['sentimentScore'];

                    final String date = timestamp != null
                        ? DateFormat('dd/MM/yyyy - hh:mm a').format(timestamp.toDate())
                        : 'Sin fecha';
                    
                    final String emoji = _getSentimentEmoji(score);
                    
                    return Dismissible(
                      // Key única para el widget
                      key: Key(doc.id), 
                      // Dirección del deslizamiento
                      direction: DismissDirection.endToStart, 
                      // Qué hacer al deslizar
                      onDismissed: (direction) {
                        _deleteEntry(doc.id);
                      },
                      // Fondo rojo que aparece al deslizar
                      background: Container(
                        color: Colors.red[700],
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                      ),
                      child: Card(
                        // --- (MODIFICADO) Bordes redondeados ---
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          // Emoji del Sentimiento
                          leading: Text(
                            emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                          // Texto de la entrada
                          title: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Fecha
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

