import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../shared/presentation/pages/admin_main_layout_page.dart';
import '../bloc/account_bloc.dart';

enum SubscriptionPeriodOption {
  monthly('MONTHLY', 'Monthly', '\$300 / month'),
  annually('ANNUALLY', 'Annual', '\$3000 / year');

  final String value;
  final String label;
  final String price;

  const SubscriptionPeriodOption(this.value, this.label, this.price);
}

class SubscriptionSetupPage extends StatefulWidget {
  final int userId;
  final int nursingHomeId;

  const SubscriptionSetupPage({
    Key? key,
    required this.userId,
    required this.nursingHomeId,
  }) : super(key: key);

  @override
  State<SubscriptionSetupPage> createState() => _SubscriptionSetupPageState();
}

class _SubscriptionSetupPageState extends State<SubscriptionSetupPage> {
  SubscriptionPeriodOption _selectedPeriod = SubscriptionPeriodOption.monthly;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<AccountBloc>(),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: const Text('Subscription'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: BlocConsumer<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountError) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is AccountSubscriptionCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subscription activated.'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      AdminMainLayoutPage(nursingHomeId: widget.nursingHomeId),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AccountLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(),
                  const SizedBox(height: 16),
                  _PlanCard(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: isLoading
                        ? null
                        : (period) {
                            setState(() => _selectedPeriod = period);
                          },
                  ),
                  const SizedBox(height: 16),
                  _PaymentNotice(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        isLoading ? 'Activating...' : 'Activate subscription',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<AccountBloc>().add(
                                CreateSubscriptionEvent(
                                  userId: widget.userId,
                                  planType: 'NURSING_HOME',
                                  period: _selectedPeriod.value,
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.workspace_premium,
              size: 56,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose your nursing home plan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Activate access for the administrator dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPeriodOption selectedPeriod;
  final ValueChanged<SubscriptionPeriodOption>? onPeriodChanged;

  const _PlanCard({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home_work_outlined, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  'Nursing Home Plan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<SubscriptionPeriodOption>(
              segments: const [
                ButtonSegment(
                  value: SubscriptionPeriodOption.monthly,
                  label: Text('Monthly'),
                  icon: Icon(Icons.calendar_view_month),
                ),
                ButtonSegment(
                  value: SubscriptionPeriodOption.annually,
                  label: Text('Annual'),
                  icon: Icon(Icons.event_available),
                ),
              ],
              selected: {selectedPeriod},
              onSelectionChanged: onPeriodChanged == null
                  ? null
                  : (selection) => onPeriodChanged!(selection.first),
            ),
            const SizedBox(height: 20),
            Text(
              selectedPeriod.price,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _FeatureRow(text: 'Administrator dashboard access'),
            _FeatureRow(text: 'Resident, staff and activities modules'),
            _FeatureRow(text: 'Operational analytics widgets'),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;

  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _PaymentNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Payment collection is not connected yet. This will create the subscription using the development payment method.',
              style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
