import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  String? selectedStore = 'Home';

  final _formKey = GlobalKey<FormState>();

  void _register(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(email: email, password: password);
    }
  }

  Future<void> _saveUserDetails(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneNumberController.text.trim(),
      'storeType': selectedStore,
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          if (state.user != null) {
            await _saveUserDetails(state.user!.uid);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registered successfully')),
            );
            Navigator.pop(context);
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Register'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (val) =>
                        val!.contains('@') ? null : 'Enter valid email',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phoneNumberController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val!.length < 7 ? 'Too short' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (val) => val!.length < 6 ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedStore,
                    onChanged: (newValue) {
                      setState(() {
                        selectedStore = newValue;
                      });
                    },
                    items: <String>['Home', 'Store']
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    decoration:
                        const InputDecoration(labelText: 'Select Home or Store'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () => _register(context),
                    child: state is AuthLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Account'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
