import 'package:flutter/material.dart';
import 'package:mindmirrorapp/gemini_service.dart';
import 'package:mindmirrorapp/journal_context_screen.dart'; // Lo crearemos en el siguiente paso

class JournalEditorScreen extends StatefulWidget {
  // Puedes pasar una pregunta inicial si vienes del Check-in
  final String? initialPrompt; 

  const JournalEditorScreen({super.key, this.initialPrompt});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  
  bool _isGenerating = false;
  String? _aiSuggestion;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null) {
      _aiSuggestion = widget.initialPrompt;
    }
  }

  // Llamada a la IA cuando no saben qué escribir
  Future<void> _requestCreativeSpark() async {
    setState(() => _isGenerating = true);
    try {
      final suggestion = await _geminiService.generateCreativeWritingPrompt();
      setState(() => _aiSuggestion = suggestion);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _goToContextStep() {
    if (_bodyController.text.isEmpty && (_titleController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe algo antes de continuar ✨')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalContextScreen(
          title: _titleController.text,
          body: _bodyController.text,
          moodContext: _aiSuggestion, // Pasamos el prompt como contexto opcional
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco puro para "Editor Limpio"
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón mágico de IA
          IconButton(
            icon: _isGenerating 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Icon(Icons.auto_awesome, color: Colors.indigoAccent),
            tooltip: '¿No sabes qué escribir?',
            onPressed: _isGenerating ? null : _requestCreativeSpark,
          ),
          const SizedBox(width: 16),
          // Botón Continuar
          TextButton(
            onPressed: _goToContextStep,
            child: const Text("Siguiente", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Área de Sugerencia (Aparece si hay prompt) ---
            if (_aiSuggestion != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 18, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Text("Inspiración", style: TextStyle(color: Colors.indigo.shade800, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => setState(() => _aiSuggestion = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _aiSuggestion!,
                      style: TextStyle(color: Colors.indigo.shade900, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

            // --- Editor ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      decoration: const InputDecoration(
                        hintText: 'Título (Opcional)',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black26),
                      ),
                    ),
                    const Divider(height: 30),
                    TextField(
                      controller: _bodyController,
                      style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                      maxLines: null, // Expansión infinita
                      decoration: const InputDecoration(
                        hintText: 'Empieza a escribir aquí...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(height: 300), // Espacio extra al final para scrollear cómodamente
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}