import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Obtener la colección de entradas
  final CollectionReference _entriesCollection =
      FirebaseFirestore.instance.collection('journal_entries');

  // Obtener el ID del usuario actual
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // --- CREAR: Añadir una nueva entrada ---
  Future<void> addJournalEntry(String text) {
    final String? userId = currentUserId;
    if (userId == null) {
      throw Exception("Usuario no autenticado. No se puede guardar la entrada.");
    }

    return _entriesCollection.add({
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
      // Los campos de sentimiento (sentimentScore, etc.)
      // se añadirán automáticamente por la Cloud Function
    });
  }

  // --- LEER: Obtener el stream de entradas del usuario actual ---
  Stream<QuerySnapshot> getJournalEntries() {
    final String? userId = currentUserId;
    if (userId == null) {
      // Devuelve un stream vacío si el usuario no está logueado
      return const Stream.empty();
    }

    // Consulta que filtra por 'userId' Y ordena por 'timestamp'
    return _entriesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- (NUEVO) BORRAR: Eliminar una entrada ---
  Future<void> deleteJournalEntry(String docId) {
    // Simplemente elimina el documento usando su ID
    return _entriesCollection.doc(docId).delete();
  }
}

