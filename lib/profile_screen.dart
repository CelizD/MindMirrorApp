import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmirrorapp/settings_screen.dart';
import 'package:mindmirrorapp/stats_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // La función de cerrar sesión ahora vive aquí
  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _signOut,
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.indigo[100],
            child: const Icon(Icons.person, size: 40, color: Colors.indigo),
          ),
          const SizedBox(height: 10),
          Text(
            user?.email ?? 'Usuario', // Usaremos el email por ahora
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          const Text(
            'Estadísticas y Logros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ListTile(
            leading:
                const Icon(Icons.bar_chart_rounded, color: Colors.indigo),
            title: const Text('Ver mis estadísticas'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
          const ListTile(
            leading:
                Icon(Icons.military_tech_outlined, color: Colors.amber),
            title: Text('Mis Logros'),
            subtitle: Text('Próximamente...'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: null, // Deshabilitado por ahora
          ),
          const ListTile(
            leading: Icon(Icons.local_fire_department_outlined,
                color: Colors.orange),
            title: Text('Racha Actual'),
            subtitle: Text('Próximamente...'),
            trailing: Text("🔥 0", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 30),
          const Text(
            'Aplicación',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ListTile(
            leading:
                const Icon(Icons.settings_outlined, color: Colors.indigo),
            title: const Text('Configuración'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
