import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Si no hay usuario, mostramos un mensaje y botón para volver al login
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bienvenido')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No has iniciado sesión.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Aquí puedes usar Navigator para ir a LoginPage
                  Navigator.of(context).pop();
                },
                child: const Text('Volver al login'),
              ),
            ],
          ),
        ),
      );
    }

    // Usuario autenticado
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Redirige al login automáticamente por AuthGate
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  user.displayName ?? 'Usuario',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('UID: ${user.uid}', textAlign: TextAlign.center),
                if (user.email != null) Text('Email: ${user.email}'),
                const SizedBox(height: 8),
                Text(
                  'Email verificado: ${user.emailVerified ? "Sí" : "No"}',
                  style: TextStyle(
                    color: user.emailVerified ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                if (!user.emailVerified)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await user.sendEmailVerification();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Correo de verificación enviado.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Enviar verificación'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
