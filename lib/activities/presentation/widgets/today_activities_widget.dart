import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra_mobile_app/app/di/dependency_injection.dart';
import '../bloc/activities_bloc.dart';

class TodayActivitiesWidget extends StatelessWidget {
  final int nursingHomeId;

  const TodayActivitiesWidget({Key? key, required this.nursingHomeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActivitiesBloc>(
      create: (_) => locator<ActivitiesBloc>()..add(FetchTodayActivitiesEvent(nursingHomeId: nursingHomeId)),
      child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
        builder: (context, state) {
          if (state is ActivitiesLoading) return const LinearProgressIndicator();
          
          if (state is ActivitiesError) return const Text('Fallo al cargar agenda.');

          if (state is ActivitiesLoaded) {
            final activities = state.todayActivities;
            
            return Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text('Actividades de Hoy', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.calendar_today),
                  ),
                  const Divider(height: 1),
                  if (activities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No hay actividades programadas para hoy.'),
                    ),
                  ...activities.map((activity) => ListTile(
                    leading: const Icon(Icons.event_available, color: Colors.green),
                    title: Text(activity.name), // Entidad Activity de Domain
                    subtitle: Text('${activity.schedule.startTime} - ${activity.schedule.endTime}'),
                  )).toList(),
                ],
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}