import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../iam/presentation/pages/family_home_page.dart';
import '../bloc/person_profile_bloc.dart';

class CreatePersonProfilePage extends StatefulWidget {
  const CreatePersonProfilePage({Key? key}) : super(key: key);

  @override
  State<CreatePersonProfilePage> createState() =>
      _CreatePersonProfilePageState();
}

class _CreatePersonProfilePageState extends State<CreatePersonProfilePage> {
  int _currentStep = 0;

  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(
    text: 'Peru',
  );

  bool get _isPersonalStep => _currentStep == 0;
  DateTime? _selectedBirthDate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<PersonProfileBloc>(),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: const Text('Complete Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: BlocConsumer<PersonProfileBloc, PersonProfileState>(
          listener: (context, state) {
            if (state is PersonProfileError) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is PersonProfileCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile created successfully.'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => FamilyHomePage(profile: state.profile),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is PersonProfileLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_ind,
                            size: 64,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isPersonalStep
                                ? 'Personal Information'
                                : 'Address Information',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_isPersonalStep) ...[
                            _textField(
                              controller: _dniController,
                              label: 'DNI',
                              icon: Icons.badge,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            _textField(
                              controller: _firstNameController,
                              label: 'First Name',
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 12),
                            _textField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 12),
                            _textField(
                              controller: _birthDateController,
                              label: 'Birth Date (YYYY-MM-DD)',
                              icon: Icons.calendar_today,
                              readOnly: true,
                              onTap: () => _pickBirthDate(context),
                            ),
                            const SizedBox(height: 12),
                            _textField(
                              controller: _ageController,
                              label: 'Age',
                              icon: Icons.cake,
                              keyboardType: TextInputType.number,
                              readOnly: true,
                            ),
                            const SizedBox(height: 12),
                            _textField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            _textField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                            ),
                          ] else ...[
                            _textField(
                              controller: _streetController,
                              label: 'Street',
                              icon: Icons.route,
                            ),
                            const SizedBox(height: 12),
                            _textField(
                              controller: _numberController,
                              label: 'Street Number',
                              icon: Icons.tag,
                            ),
                            const SizedBox(height: 12),
                            _textField(
                              controller: _cityController,
                              label: 'City',
                              icon: Icons.location_city,
                            ),
                            const SizedBox(height: 12),
                            _textField(
                              controller: _postalCodeController,
                              label: 'Postal Code',
                              icon: Icons.local_post_office,
                            ),
                            const SizedBox(height: 12),
                            _textField(
                              controller: _countryController,
                              label: 'Country',
                              icon: Icons.public,
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (!_isPersonalStep)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () => setState(() => _currentStep = 0),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Back'),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      FocusScope.of(context).unfocus();
                                      if (_isPersonalStep) {
                                        setState(() => _currentStep = 1);
                                        return;
                                      }

                                      _submit(context);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isPersonalStep
                                          ? 'Next'
                                          : 'Create Profile',
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),
                        ],
                      ),
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

  void _submit(BuildContext context) {
    context.read<PersonProfileBloc>().add(
      CreatePersonProfileEvent(
        dni: _dniController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        birthDate: _birthDateController.text,
        age: _ageController.text,
        emailAddress: _emailController.text,
        street: _streetController.text,
        number: _numberController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        country: _countryController.text,
        phoneNumber: _phoneController.text,
      ),
    );
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthDate ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedBirthDate = pickedDate;
      _birthDateController.text =
          '${pickedDate.year.toString().padLeft(4, '0')}-'
          '${pickedDate.month.toString().padLeft(2, '0')}-'
          '${pickedDate.day.toString().padLeft(2, '0')}';
      _ageController.text = _calculateAge(pickedDate, now).toString();
    });
  }

  int _calculateAge(DateTime birthDate, DateTime today) {
    var age = today.year - birthDate.year;
    final hasNotHadBirthdayThisYear =
        today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day);

    if (hasNotHadBirthdayThisYear) {
      age--;
    }

    return age;
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
