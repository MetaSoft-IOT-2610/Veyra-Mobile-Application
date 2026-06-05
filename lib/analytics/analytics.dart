/// Archivo Barril (Barrel File) del Bounded Context Analytics.
/// Expone únicamente las interfaces públicas que otros módulos tienen permitido consumir.

// 1. Exportamos el módulo de Inyección de Dependencias
export 'analytics_module.dart';

// 2. Exportamos los Widgets Públicos
export 'presentation/widgets/analytics_dashboard_widget.dart';

// OJO: Nunca exportamos Datasources, Models o implementaciones del Repositorio.
// El exterior no debe conocer nuestra infraestructura.