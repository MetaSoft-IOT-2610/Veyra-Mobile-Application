import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../bloc/nursing_bloc.dart';

class CreateResidentPage extends StatefulWidget {
  final int nursingHomeId;

  const CreateResidentPage({super.key, required this.nursingHomeId});

  @override
  State<CreateResidentPage> createState() => _CreateResidentPageState();
}

class _CreateResidentPageState extends State<CreateResidentPage> {
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
  final _legalFirstNameController = TextEditingController();
  final _legalLastNameController = TextEditingController();
  final _legalPhoneController = TextEditingController();
  final _emergencyFirstNameController = TextEditingController();
  final _emergencyLastNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  DateTime? _birthDate;

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
    _legalFirstNameController.dispose();
    _legalLastNameController.dispose();
    _legalPhoneController.dispose();
    _emergencyFirstNameController.dispose();
    _emergencyLastNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<NursingBloc>(),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(title: const Text('Register Resident')),
        body: BlocConsumer<NursingBloc, NursingState>(
          listener: (context, state) {
            if (state is NursingError) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is NursingResidentCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resident registered successfully.'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            final isLoading = state is NursingLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Section(
                    title: 'Personal information',
                    icon: Icons.person_outline,
                    children: [
                      _textField(
                        _dniController,
                        'DNI',
                        Icons.badge,
                        keyboardType: TextInputType.number,
                      ),
                      _gap,
                      _textField(
                        _firstNameController,
                        'First name',
                        Icons.person,
                      ),
                      _gap,
                      _textField(
                        _lastNameController,
                        'Last name',
                        Icons.person_outline,
                      ),
                      _gap,
                      _BirthDateTile(
                        birthDate: _birthDate,
                        age: _birthDate == null
                            ? null
                            : _calculateAge(_birthDate!),
                        onTap: isLoading ? null : _pickBirthDate,
                      ),
                      _gap,
                      _textField(
                        _emailController,
                        'Email',
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _gap,
                      _textField(
                        _phoneController,
                        'Phone number',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  _Section(
                    title: 'Address',
                    icon: Icons.home_outlined,
                    children: [
                      _textField(_streetController, 'Street', Icons.route),
                      _gap,
                      _textField(_numberController, 'Number', Icons.tag),
                      _gap,
                      _textField(_cityController, 'City', Icons.location_city),
                      _gap,
                      _textField(
                        _postalCodeController,
                        'Postal code',
                        Icons.local_post_office_outlined,
                      ),
                      _gap,
                      _textField(_countryController, 'Country', Icons.public),
                    ],
                  ),
                  _Section(
                    title: 'Legal representative',
                    icon: Icons.assignment_ind_outlined,
                    children: [
                      _textField(
                        _legalFirstNameController,
                        'First name',
                        Icons.person,
                      ),
                      _gap,
                      _textField(
                        _legalLastNameController,
                        'Last name',
                        Icons.person_outline,
                      ),
                      _gap,
                      _textField(
                        _legalPhoneController,
                        'Phone number',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  _Section(
                    title: 'Emergency contact',
                    icon: Icons.contact_emergency_outlined,
                    children: [
                      _textField(
                        _emergencyFirstNameController,
                        'First name',
                        Icons.person,
                      ),
                      _gap,
                      _textField(
                        _emergencyLastNameController,
                        'Last name',
                        Icons.person_outline,
                      ),
                      _gap,
                      _textField(
                        _emergencyPhoneController,
                        'Phone number',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        isLoading ? 'Registering...' : 'Register resident',
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
                              FocusScope.of(context).unfocus();
                              context.read<NursingBloc>().add(
                                CreateResidentEvent(
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
                                  legalRepresentativeFirstName:
                                      _legalFirstNameController.text,
                                  legalRepresentativeLastName:
                                      _legalLastNameController.text,
                                  legalRepresentativePhoneNumber:
                                      _legalPhoneController.text,
                                  emergencyContactFirstName:
                                      _emergencyFirstNameController.text,
                                  emergencyContactLastName:
                                      _emergencyLastNameController.text,
                                  emergencyContactPhoneNumber:
                                      _emergencyPhoneController.text,
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

  Widget get _gap => const SizedBox(height: 12);

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 75, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    final hadBirthdayThisYear =
        today.month > birthDate.month ||
        (today.month == birthDate.month && today.day >= birthDate.day);
    if (!hadBirthdayThisYear) age--;
    return age;
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
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _BirthDateTile extends StatelessWidget {
  final DateTime? birthDate;
  final int? age;
  final VoidCallback? onTap;

  const _BirthDateTile({
    required this.birthDate,
    required this.age,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final value = birthDate == null
        ? 'Select birth date'
        : '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Birth date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Row(
          children: [
            Expanded(child: Text(value)),
            if (age != null)
              Text(
                '$age years',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
