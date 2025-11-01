// Importa las herramientas de Firebase Functions
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {log} = require("firebase-functions/logger");

// Importa el Admin SDK de Firebase para poder escribir en la base de datos
// (Quitamos 'getFirestore' ya que no se usa)
const {initializeApp} = require("firebase-admin/app");

// Importa la IA de Natural Language
const {LanguageServiceClient} = require("@google-cloud/language");

// Inicializa las apps
initializeApp();
// const db = getFirestore(); // Quitamos esta línea (error 'no-unused-vars')
const languageClient = new LanguageServiceClient();

/**
 * Esta es nuestra Cloud Function.
 * Se activa cada vez que se crea un nuevo documento
 * en la colección "journal_entries".
 */
// Corregimos la línea larga (error 'max-len')
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

      // 2. Prepara la solicitud para la API de IA
      const document = {
        content: entryText,
        type: "PLAIN_TEXT",
      };

      try {
        // 3. Llama a la API de IA y espera la respuesta
        const [result] = await languageClient.analyzeSentiment({document});
        const sentiment = result.documentSentiment;

        // Extraemos el puntaje y la magnitud
        const score = sentiment.score; // -1.0 (negativo) a 1.0 (positivo)
        // 0 (neutral) a infinito (fuerte)
        const magnitude = sentiment.magnitude;

        log(`Sentimiento detectado: Score=${score}, Magnitude=${magnitude}`);

        // 4. Actualiza el documento original en Firestore con los nuevos datos
        const entryRef = event.data.ref;
        await entryRef.update({
          sentimentScore: score,
          sentimentMagnitude: magnitude,
          analysisComplete: true, // Marcamos que ya se analizó
        });

        log("Documento actualizado con el análisis de sentimiento.");
        return null;
      } catch (error) {
        log("Error al analizar el sentimiento:", error);
        return null;
      }
    });

