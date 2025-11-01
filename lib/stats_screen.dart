import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'firestore_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  // --- (NUEVO) Degradado para el gráfico de líneas ---
  List<Color> get _lineChartGradientColors => [
        Colors.indigoAccent,
        Colors.purpleAccent,
      ];

  // --- Función para obtener el Emoji (la movemos aquí para reusarla) ---
  String _getSentimentEmoji(num? score, {double size = 24}) {
    if (score == null) {
      return '⏳'; // Analizando...
    }
    if (score > 0.2) return '😊'; // Positivo
    if (score < -0.2) return '😞'; // Negativo
    return '😐'; // Neutral
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Estadísticas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getJournalEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState('No hay datos suficientes para mostrar estadísticas.');
          }

          // --- 1. PROCESAMIENTO DE DATOS ---
          final entries = snapshot.data!.docs;
          final List<FlSpot> lineChartSpots = [];
          int positiveCount = 0;
          int neutralCount = 0;
          int negativeCount = 0;
          double totalScore = 0;
          int entriesWithScore = 0;

          for (var doc in entries) {
            final entry = doc.data() as Map<String, dynamic>;
            final Timestamp? timestamp = entry['timestamp'];
            final num? score = entry['sentimentScore'];

            if (timestamp != null && score != null) {
              // Datos para el Gráfico de Líneas
              lineChartSpots.add(
                FlSpot(
                  timestamp.millisecondsSinceEpoch.toDouble(), // Eje X (Fecha)
                  score.toDouble(), // Eje Y (Sentimiento)
                ),
              );

              // Datos para el Gráfico de Pastel
              // (CORREGIDO) Llaves {} añadidas
              if (score > 0.2) {
                positiveCount++;
              } else if (score < -0.2) {
                negativeCount++;
              } else {
                neutralCount++;
              }
              
              totalScore += score;
              entriesWithScore++;
            }
          }
          
          // Ordenar datos para el gráfico de líneas
          lineChartSpots.sort((a, b) => a.x.compareTo(b.x));

          // Calcular datos de resumen
          final int totalEntries = entries.length;
          final double averageScore = entriesWithScore == 0 ? 0 : totalScore / entriesWithScore;
          final int totalAnalyzed = positiveCount + neutralCount + negativeCount;

          // --- 2. CONSTRUCCIÓN DE LA PANTALLA ---
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Sección de Resumen ---
                  _buildSummarySection(totalEntries, averageScore),
                  
                  const SizedBox(height: 30),

                  // --- Sección de Gráfico de Pastel ---
                  if (totalAnalyzed > 0)
                    _buildPieChartSection(positiveCount, neutralCount, negativeCount, totalAnalyzed),
                  
                  const SizedBox(height: 30),

                  // --- Sección de Gráfico de Líneas ---
                  const Text(
                    'Tu Ánimo a lo Largo del Tiempo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (lineChartSpots.length < 2)
                    _buildEmptyState('Necesitas al menos 2 entradas analizadas para ver una tendencia.')
                  else
                    SizedBox(
                      height: 300,
                      child: _buildLineChart(lineChartSpots),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget: Mensaje de "Vacío" ---
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  // --- Widget: Sección de Resumen ---
  Widget _buildSummarySection(int totalEntries, double averageScore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen General',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Total de Entradas',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        totalEntries.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Ánimo Promedio',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getSentimentEmoji(averageScore, size: 32),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Widget: Sección de Gráfico de Pastel ---
  Widget _buildPieChartSection(int positive, int neutral, int negative, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución de Sentimientos',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              borderData: FlBorderData(show: false),
              sectionsSpace: 0, // <-- (MODIFICADO) Sin espacio para un look sólido
              centerSpaceRadius: 60, // <-- (MODIFICADO) Más grande para look "dona"
              sections: [
                // Sección Positiva
                PieChartSectionData(
                  color: Colors.green[400],
                  value: positive.toDouble(),
                  title: '${((positive / total) * 100).toStringAsFixed(0)}% 😊',
                  radius: 50,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white), // <-- (MODIFICADO) Texto blanco
                ),
                // Sección Neutral
                PieChartSectionData(
                  color: Colors.grey[500],
                  value: neutral.toDouble(),
                  title: '${((neutral / total) * 100).toStringAsFixed(0)}% 😐',
                  radius: 50,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white), // <-- (MODIFICADO) Texto blanco
                ),
                // Sección Negativa
                PieChartSectionData(
                  color: Colors.red[400],
                  value: negative.toDouble(),
                  title: '${((negative / total) * 100).toStringAsFixed(0)}% 😞',
                  radius: 50,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white), // <-- (MODIFICADO) Texto blanco
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Widget: Sección de Gráfico de Líneas ---
  Widget _buildLineChart(List<FlSpot> spots) {
    // Calculamos el intervalo para las etiquetas del eje X
    double xInterval = (spots.last.x - spots.first.x) / 4; // Intentamos 4 etiquetas
    if (spots.length < 5 || xInterval <= 0) {
      xInterval = (spots.last.x - spots.first.x) / 2; // Menos etiquetas si hay pocos datos
    }
    if (spots.length == 1) {
      xInterval = spots.first.x; // Un solo punto
    }

    return LineChart(
      LineChartData(
        // --- (NUEVO) Tooltips Interactivos ---
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            // (CORREGIDO) Parámetro 'tooltipBgColor' cambiado a 'getTooltipColor'
            getTooltipColor: (spot) => Colors.black.withAlpha((255 * 0.8).round()), // (CORREGIDO) .withOpacity
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${_getSentimentEmoji(spot.y)} ${spot.y.toStringAsFixed(2)}', // Muestra '😊 0.80'
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),

        // --- (MODIFICADO) Bordes y Títulos ---
        borderData: FlBorderData(show: false), // Más limpio
        gridData: const FlGridData(show: false), // Más limpio
        titlesData: FlTitlesData(
          show: true,
          // Títulos del Eje Y (Sentimiento)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                String text = '';
                if (value == 1) text = '😊'; // Positivo
                if (value == 0) text = '😐'; // Neutral
                if (value == -1) text = '😞'; // Negativo

                if (value == 1 || value == 0 || value == -1) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(text, style: const TextStyle(fontSize: 18)),
                  );
                }
                return Container();
              },
            ),
          ),
          // Ocultamos títulos de arriba y derecha
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // Títulos del Eje X (Fecha)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                // Convertimos el milisegundo de nuevo a Fecha
                final DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());
                // Formato simple: Día/Mes
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(DateFormat('dd/MM').format(date)),
                );
              },
            ),
          ),
        ),
        // --- Rango de Y (Sentimiento) ---
        minY: -1, // -1 (Negativo)
        maxY: 1, // +1 (Positivo)

        // --- (MODIFICADO) Datos de la Línea con Degradado ---
        lineBarsData: [
          LineChartBarData(
            spots: spots, // ¡Nuestros datos!
            isCurved: true,
            // (NUEVO) Degradado para la línea
            gradient: LinearGradient(
              colors: _lineChartGradientColors,
            ),
            barWidth: 5, // Un poco más gruesa
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false), // Ocultamos los puntos fijos
            // (NUEVO) Degradado para el área bajo la línea
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: _lineChartGradientColors
                    // (CORREGIDO) .withOpacity
                    .map((color) => color.withAlpha((255 * 0.3).round())) 
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

