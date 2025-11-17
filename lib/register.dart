import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authservice.dart';


class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirm = '';
  bool _loading = false;
  String? _error;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (_password != _confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = Provider.of<AuthService>(context, listen: false);
    final err = await auth.registerWithEmail(email: _email.trim(), password: _password);
    if (err != null) {
      setState(() {
        _error = err;
        _loading = false;
      });
    } else {
      // optionally show success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification email sent. Check your inbox.')));
      Navigator.pop(context); // send user back to login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 12),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (v) => _email = v ?? '',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter email';
                        if (!v.contains('@')) return 'Enter valid email';
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (v) => _password = v ?? '',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter password';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      onSaved: (v) => _confirm = v ?? '',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirm password';
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _loading
                        ? CircularProgressIndicator()
                        : ElevatedButton(onPressed: _submit, child: Text('Register')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
