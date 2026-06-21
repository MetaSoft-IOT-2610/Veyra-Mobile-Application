import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../account/presentation/pages/subscription_setup_page.dart';
import '../../../app/di/dependency_injection.dart';
import '../../../shared/presentation/pages/admin_main_layout_page.dart';
import '../../../shared/infrastructure/local/token_manager.dart';
import '../bloc/nursing_home_setup_bloc.dart';

class CreateNursingHomePage extends StatelessWidget {
  final int administratorId;

  CreateNursingHomePage({super.key, required this.administratorId});

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(
    text: 'Peru',
  );
  final TextEditingController _rucController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<NursingHomeSetupBloc>(),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(title: const Text('Create Nursing Home')),
        body: BlocConsumer<NursingHomeSetupBloc, NursingHomeSetupState>(
          listener: (context, state) {
            if (state is NursingHomeSetupError) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is NursingHomeSetupCreated) {
              final userId = TokenManager.getUserId();
              TokenManager.saveNursingHomeId(state.nursingHome.id);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nursing home created successfully.'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => userId == null
                      ? AdminMainLayoutPage(nursingHomeId: state.nursingHome.id)
                      : SubscriptionSetupPage(
                          userId: userId,
                          nursingHomeId: state.nursingHome.id,
                        ),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is NursingHomeSetupLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.home_work,
                        size: 64,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nursing Home Information',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _textField(
                        controller: _businessNameController,
                        label: 'Business Name',
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        controller: _rucController,
                        label: 'RUC',
                        icon: Icons.badge,
                        keyboardType: TextInputType.number,
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
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  context.read<NursingHomeSetupBloc>().add(
                                    CreateNursingHomeEvent(
                                      administratorId: administratorId,
                                      businessName:
                                          _businessNameController.text,
                                      emailAddress: _emailController.text,
                                      phoneNumber: _phoneController.text,
                                      street: _streetController.text,
                                      number: _numberController.text,
                                      city: _cityController.text,
                                      postalCode: _postalCodeController.text,
                                      country: _countryController.text,
                                      ruc: _rucController.text,
                                    ),
                                  );
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
                              : const Text(
                                  'Create Nursing Home',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
}
