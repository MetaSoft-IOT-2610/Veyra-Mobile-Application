import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra_mobile_app/analytics/presentation/bloc/analytics_state.dart' show AnalyticsState, AnalyticsLoaded, AnalyticsLoading, AnalyticsError;
import 'package:veyra_mobile_app/app/di/dependency_injection.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';

class AnalyticsDashboardWidget extends StatelessWidget {
  final int nursingHomeId;

  const AnalyticsDashboardWidget({super.key, required this.nursingHomeId});

  @override
  Widget build(BuildContext context) {
    // 1. Inyectamos el BLoC localmente usando el patrón Factory de GetIt
    return BlocProvider<AnalyticsBloc>(
      create: (context) => locator<AnalyticsBloc>()
        ..add(LoadOperationalMetricsEvent(nursingHomeId: nursingHomeId)), // Disparamos el evento al nacer
      
      // 2. Escuchamos solo el estado de este widget
      child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Análisis Operativo', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              
              // Skeleton Loading (Placeholder)
              if (state is AnalyticsLoading)
                const Center(child: CircularProgressIndicator()),
                
              // Error Boundary aislado (Si Analytics cae, el resto de la app sigue viva)
              if (state is AnalyticsError)
                Card(
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.error, color: Colors.red),
                    title: Text('Error cargando métricas: ${state.message}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => context.read<AnalyticsBloc>()
                          .add(LoadOperationalMetricsEvent(nursingHomeId: nursingHomeId)),
                    ),
                  ),
                ),

              // Renderizado de Datos Reales
              if (state is AnalyticsLoaded)
                Row(
                  children: [
                    Expanded( // <-- Envuelve la primera tarjeta
                      child: _MetricCard(
                        title: 'Nuevos Ingresos', 
                        value: state.admissionsCount.toString(),
                      ),
                    ),
                    Expanded( // <-- Envuelve la segunda tarjeta
                      child: _MetricCard(
                        title: 'Bajas Staff', 
                        value: state.terminationsCount.toString(), 
                        isAlert: state.terminationsCount > 2,
                      ),
                    ),
                    Expanded( // <-- Envuelve la tercera tarjeta
                      child: _MetricCard(
                        title: 'Nuevos Contratos', 
                        value: state.hiresCount.toString(),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isAlert;

  const _MetricCard({required this.title, required this.value, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isAlert ? Colors.red : Colors.blue)),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}