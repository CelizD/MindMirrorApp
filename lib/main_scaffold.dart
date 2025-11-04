import 'package:flutter/material.dart';
import 'package:mindmirrorapp/calendar_screen.dart';
import 'package:mindmirrorapp/explore_screen.dart';
import 'package:mindmirrorapp/home_screen.dart';
import 'package:mindmirrorapp/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  // (NUEVO) Acepta la pregunta generada desde el check-in
  final String? generatedQuestion;

  const MainScaffold({
    super.key,
    this.generatedQuestion, // <-- ESTA LÍNEA ES LA SOLUCIÓN
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // (NUEVO) Lista de pantallas que ahora se inicializa
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Pasa la pregunta generada a la HomeScreen
    _screens = [
      HomeScreen(generatedQuestion: widget.generatedQuestion),
      const ExploreScreen(),
      const CalendarScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Principal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Estilos para que la barra se vea bien
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
      ),
    );
  }
}

