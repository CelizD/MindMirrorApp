// Importa las herramientas de Firebase Functions
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { log } = require("firebase-functions/logger");

// Importa el Admin SDK de Firebase
const { initializeApp } = require("firebase-admin/app");

// Importa las IAs de Google
const { LanguageServiceClient } = require("@google-cloud/language");
const { VertexAI } = require("@google-cloud/vertex-ai");

// Inicializa las apps
initializeApp();
const languageClient = new LanguageServiceClient();

// --- INICIALIZACIÓN DE VERTEX AI (GEMINI) ---
const vertexAI = new VertexAI({
  project: process.env.GCLOUD_PROJECT, // Usa el proyecto de Firebase
  location: "us-central1", // O la región que prefieras
});

// Configura el modelo
const generativeModel = vertexAI.preview.getGenerativeModel({
  model: "gemini-1.0-pro", // Modelo estable
  generationConfig: {
    "maxOutputTokens": 256,
    "temperature": 0.5,
    "topP": 0.8,
    "topK": 40,
  },
});

/**
 * --- FUNCIÓN 1 (LA QUE YA FUNCIONA) ---
 * Se activa cada vez que se crea un nuevo documento
 * en la colección "journal_entries".
 */
exports.analyzeSentiment = onDocumentCreated(
    "journal_entries/{entryId}",
    async (event) => {
      // 1. Obtiene el texto de la entrada que se acaba de crear
      const data = event.data.data();
      const entryText = data.text;

      // Si no hay texto, no hace nada
      if (!entryText) {
        log("El documento no tiene texto. Saliendo.");
        return null;
      }

      log(`Analizando sentimiento para el texto: ${entryText}`);

      // 2. Prepara la solicitud para la API de IA (Language)
      const document = {
        content: entryText,
        type: "PLAIN_TEXT",
      };

      try {
        // 3. Llama a la API de IA (Language) y espera la respuesta
        const [result] = await languageClient.analyzeSentiment({ document });
        const sentiment = result.documentSentiment;

        // Extraemos el puntaje y la magnitud
        const score = sentiment.score;
        const magnitude = sentiment.magnitude;

        log(`Sentimiento detectado: Score=${score}, Magnitude=${magnitude}`);

        // 4. Actualiza el documento original en Firestore
        const entryRef = event.data.ref;
        await entryRef.update({
          sentimentScore: score,
          sentimentMagnitude: magnitude,
          analysisComplete: true,
        });

        log("Documento actualizado con el análisis de sentimiento.");
        return null;
      } catch (error) {
        log("Error al analizar el sentimiento:", error);
        return null;
      }
    });

/**
 * --- FUNCIÓN 2 (TU NUEVA API) ---
 * Se activa cuando la app de Flutter la llama.
 * Recibe un "prompt" y devuelve una respuesta de Gemini.
 */
exports.generateText = onCall(async (request) => {
  // 1. Obtiene el prompt que envió la app
  const prompt = request.data.prompt;

  if (!prompt) {
    throw new HttpsError(
        "invalid-argument",
        "La función debe ser llamada con un 'prompt'.",
    );
  }

  try {
    // 2. Prepara la solicitud para Gemini (Vertex AI)
    const req = {
      contents: [{ role: "user", parts: [{ text: prompt }] }],
    };

    // 3. Llama al modelo Gemini
    const streamingResp = await generativeModel.generateContentStream(req);
    const response = await streamingResp.response;

    // 4. Devuelve el texto a la app de Flutter
    const text = response.candidates[0].content.parts[0].text;
    return { text: text };
  } catch (error) {
    log("Error al generar texto con Vertex AI:", error);
    throw new HttpsError(
        "internal",
        "No se pudo generar una respuesta de la IA.",
        error,
    );
  }
});

