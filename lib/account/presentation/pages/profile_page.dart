import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/di/dependency_injection.dart';
import '../../domain/entities/subscription.dart';
import '../bloc/account_bloc.dart';

class ProfilePage extends StatelessWidget {
  final int userId;
  final int administratorId;

  const ProfilePage({
    super.key,
    required this.userId,
    required this.administratorId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<AccountBloc>()..add(LoadActiveSubscriptionEvent(userId)),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(title: const Text('Mi Cuenta')),
        body: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state is AccountLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AccountError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        onPressed: () => context.read<AccountBloc>().add(
                          LoadActiveSubscriptionEvent(userId),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is AccountSubscriptionLoaded) {
              return _AccountContent(
                subscription: state.subscription,
                administratorId: administratorId,
              );
            }

            if (state is AccountNoSubscription) {
              return const _NoSubscriptionContent();
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _NoSubscriptionContent extends StatelessWidget {
  const _NoSubscriptionContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              color: Colors.blue.shade700,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'No active subscription',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Subscription information is not available for this account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountContent extends StatelessWidget {
  final Subscription subscription;
  final int administratorId;

  const _AccountContent({
    required this.subscription,
    required this.administratorId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(administratorId: administratorId),
          const SizedBox(height: 16),
          _SubscriptionCard(subscription: subscription),
          const SizedBox(height: 16),
          _ReadOnlyNotice(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final int administratorId;

  const _ProfileHeader({required this.administratorId});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, size: 48, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 16),
            Text(
              'Administrador',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: $administratorId',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  const _SubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: Colors.amber,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  'Suscripción',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _StatusBadge(isActive: subscription.isActive),
              ],
            ),
            const Divider(height: 28),
            _InfoRow(
              icon: Icons.star_outline,
              label: 'Plan',
              value: subscription.plan,
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha de inicio',
              value: subscription.startDate.isEmpty
                  ? 'N/A'
                  : subscription.startDate,
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.event_outlined,
              label: 'Vencimiento',
              value: subscription.endDate.isEmpty
                  ? 'N/A'
                  : subscription.endDate,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text('$label:', style: TextStyle(color: Colors.grey.shade600)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _ReadOnlyNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Para gestionar tu plan o renovar tu suscripción, accede a la plataforma web.',
              style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
