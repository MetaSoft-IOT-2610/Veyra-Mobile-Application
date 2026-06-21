import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../bloc/staff_bloc.dart';

class CreateStaffPage extends StatefulWidget {
  final int nursingHomeId;

  const CreateStaffPage({super.key, required this.nursingHomeId});

  @override
  State<CreateStaffPage> createState() => _CreateStaffPageState();
}

class _CreateStaffPageState extends State<CreateStaffPage> {
  static const int _totalSteps = 3;

  final _dniController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Peru');
  final _emergencyFirstNameController = TextEditingController();
  final _emergencyLastNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  DateTime? _birthDate;
  int _currentStep = 0;

  @override
  void dispose() {
    _dniController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _emergencyFirstNameController.dispose();
    _emergencyLastNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<StaffBloc>(),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: const Text('Register staff'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: _StepIndicator(
                  currentStep: _currentStep + 1,
                  totalSteps: _totalSteps,
                ),
              ),
            ),
          ],
        ),
        body: BlocConsumer<StaffBloc, StaffState>(
          listener: (context, state) {
            if (state is StaffError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is StaffCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Staff registered successfully.'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            final isLoading = state is StaffLoading;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(999),
                ),
                const SizedBox(height: 16),
                _buildCurrentStep(),
                const SizedBox(height: 12),
                _StepNavigation(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                  isLoading: isLoading,
                  onBack: _currentStep == 0
                      ? null
                      : () => setState(() => _currentStep--),
                  onNext: () => setState(() => _currentStep++),
                  onSubmit: () => _submit(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _Section(
          title: 'Personal information',
          icon: Icons.badge_outlined,
          children: [
            _Field(controller: _dniController, label: 'DNI'),
            _Field(controller: _firstNameController, label: 'First name'),
            _Field(controller: _lastNameController, label: 'Last name'),
            _BirthDateTile(birthDate: _birthDate, onPick: _pickBirthDate),
            _Field(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            _Field(
              controller: _phoneController,
              label: 'Phone number',
              keyboardType: TextInputType.phone,
            ),
          ],
        );
      case 1:
        return _Section(
          title: 'Address',
          icon: Icons.home_work_outlined,
          children: [
            _Field(controller: _streetController, label: 'Street'),
            _Field(controller: _numberController, label: 'Number'),
            _Field(controller: _cityController, label: 'City'),
            _Field(controller: _postalCodeController, label: 'Postal code'),
            _Field(controller: _countryController, label: 'Country'),
          ],
        );
      default:
        return _Section(
          title: 'Emergency contact',
          icon: Icons.contact_emergency_outlined,
          children: [
            _Field(
              controller: _emergencyFirstNameController,
              label: 'First name',
            ),
            _Field(
              controller: _emergencyLastNameController,
              label: 'Last name',
            ),
            _Field(
              controller: _emergencyPhoneController,
              label: 'Phone number',
              keyboardType: TextInputType.phone,
            ),
          ],
        );
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _submit(BuildContext context) {
    context.read<StaffBloc>().add(
      CreateStaffEvent(
        nursingHomeId: widget.nursingHomeId,
        dni: _dniController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        birthDate: _birthDate,
        emailAddress: _emailController.text,
        street: _streetController.text,
        number: _numberController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        country: _countryController.text,
        phoneNumber: _phoneController.text,
        emergencyContactFirstName: _emergencyFirstNameController.text,
        emergencyContactLastName: _emergencyLastNameController.text,
        emergencyContactPhoneNumber: _emergencyPhoneController.text,
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$currentStep/$totalSteps',
        style: TextStyle(
          color: Colors.blue.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StepNavigation extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isLoading;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _StepNavigation({
    required this.currentStep,
    required this.totalSteps,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == totalSteps - 1;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            onPressed: isLoading ? null : onBack,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isLastStep ? Icons.person_add_alt_1 : Icons.arrow_forward,
                  ),
            label: Text(isLastStep ? 'Save' : 'Next'),
            onPressed: isLoading ? null : (isLastStep ? onSubmit : onNext),
          ),
        ),
      ],
    );
  }
}

class _BirthDateTile extends StatelessWidget {
  final DateTime? birthDate;
  final VoidCallback onPick;

  const _BirthDateTile({required this.birthDate, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final text = birthDate == null
        ? 'Birth date'
        : '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        tileColor: Colors.grey.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        title: Text(text),
        trailing: const Icon(Icons.calendar_today),
        onTap: onPick,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
