import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/user_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;
  final Function(User) onUserUpdated;
  const EditProfileScreen({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  User? _user;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  Map<String, String> _errors = {};
  String _showMessage = '';

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    if (_user != null) {
      _nameController.text = _user!.name;
      _emailController.text = _user!.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Profile')),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: _errors['name'] ?? null,
                ),
              ),
              subtitle: _formKey.currentState?.validate() == false &&
                      _errors['name'] != null
                  ? Text('Name is required',
                      style: TextStyle(color: Colors.red))
                  : null,
            ),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _errors['email'] ?? null,
                ),
              ),
              subtitle: _formKey.currentState?.validate() == false &&
                      _errors['email'] != null
                  ? Text('Email is required',
                      style: TextStyle(color: Colors.red))
                  : null,
            ),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  errorText: _errors['current_password'] ?? null,
                ),
                obscureText: true,
              ),
              subtitle: _formKey.currentState?.validate() == false
                  ? Text('Password is required',
                      style: TextStyle(color: Colors.red))
                  : null,
            ),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  errorText: _errors['password'] ?? null,
                ),
                obscureText: true,
              ),
              subtitle: _formKey.currentState?.validate() == false
                  ? Text('Passwords do not match',
                      style: TextStyle(color: Colors.red))
                  : null,
            ),
            if (_showMessage.isNotEmpty)
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(_showMessage, style: TextStyle(color: Colors.blue)),
              ),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                        _showMessage = '';
                        _errors = {};
                      });
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _user!.name = _nameController.text;
                        _user!.email = _emailController.text;
                        _user!.currentPassword =
                            _currentPasswordController.text.isEmpty
                                ? null
                                : _currentPasswordController.text;
                        _user!.password = _newPasswordController.text.isEmpty
                            ? null
                            : _newPasswordController.text;

                        final result = await UserService().updateUser(_user!);
                        print('result: $result');
                        if (result != null && result['errors'] != null) {
                          setState(() {
                            print('error: ${result['errors']}');
                            _errors = result['errors']
                                .map((key, value) =>
                                    MapEntry(key, value.join('\n')))
                                .cast<String, String>();
                            _showMessage = 'Error updating profile';
                          });
                        }

                        if (_errors.isEmpty) {
                          final user = result;

                          if (user != null) {
                            _user = User.fromJson(user);
                            _nameController.text = _user!.name;
                            _emailController.text = _user!.email;
                            _currentPasswordController.clear();
                            _newPasswordController.clear();
                          }
                          setState(() {
                            _showMessage = 'Profile updated successfully';
                          });
                          widget.onUserUpdated(_user!);
                          AuthService().setLoggedInUser(_user!);
                        }
                      }
                      setState(() {
                        _isLoading = false;
                      });
                      // out focus form
                      if (mounted) {
                        FocusScope.of(context).unfocus();
                      }
                      UserBroadcast().notifyUserChanged();
                    },
              leading: Icon(Icons.save, color: Theme.of(context).primaryColor),
              title: _isLoading
                  ? Text('Saving...',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ))
                  : Text('Save',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
