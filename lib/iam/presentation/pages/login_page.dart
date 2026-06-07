import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/di/dependency_injection.dart';
import '../../../nursing/presentation/pages/admin_dashboard_page.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Inyectamos el AuthBloc desde GetIt al construir la página
    return BlocProvider(
      create: (_) => locator<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      // Mostramos el error devuelto por el servidor o validación
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                      );
                    } else if (state is AuthSuccess) {
                      // Login exitoso: Redirigimos al Dashboard inyectando el ID real de su residencia
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => AdminDashboardPage(nursingHomeId: state.nursingHomeId),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.health_and_safety, size: 80, color: Colors.blue),
                        const SizedBox(height: 16),
                        const Text('Veyra Enterprise', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 32),

                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _passwordController,
                          obscureText: true, // Oculta la contraseña
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            // Desactivamos el botón si está cargando
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                              FocusScope.of(context).unfocus(); // Ocultar teclado
                              context.read<AuthBloc>().add(
                                PerformLoginEvent(_usernameController.text, _passwordController.text),
                              );
                            },
                            child: state is AuthLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Text('Ingresar', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
