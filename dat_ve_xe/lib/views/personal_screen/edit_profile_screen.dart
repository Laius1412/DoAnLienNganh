import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dat_ve_xe/server/user_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:dat_ve_xe/service/cloudinary_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _birth;
  String _gender = 'Nam';
  bool _loading = false;
  File? _avatarFile;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userModel = await UserService().getUserById(user.uid);
      if (userModel != null) {
        setState(() {
          _nameController.text = userModel.name;
          _emailController.text = userModel.email;
          _birth = userModel.birth;
          _gender = userModel.gender.isNotEmpty ? userModel.gender : 'Nam';
          _avatarUrl = userModel.avt;
        });
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() {
        _birth = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadAvatarToCloudinary(File file) async {
    const cloudName = 'daturixq2';
    const uploadPreset = 'giap15';
    return await CloudinaryService.uploadImage(file, uploadPreset, cloudName);
  }

  Future<void> _saveProfile() async {
    final t = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate() || _birth == null) return;
    setState(() { _loading = true; });
    final user = FirebaseAuth.instance.currentUser;
    String? newAvatarUrl = _avatarUrl;
    if (_avatarFile != null) {
      final url = await _uploadAvatarToCloudinary(_avatarFile!);
      if (url != null) {
        newAvatarUrl = url;
      }
    }
    if (user != null) {
      final success = await UserService().updateUser(
        user.uid,
        name: _nameController.text.trim(),
        birth: _birth!,
        gender: _gender,
        avt: newAvatarUrl,
      );
      setState(() { _loading = false; });
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.updateSuccessful)),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.updateFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.editProfile),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: _avatarFile != null
                                ? FileImage(_avatarFile!)
                                : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                    ? NetworkImage(_avatarUrl!)
                                    : const AssetImage('assets/images/default_avatar.png')) as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: t.name,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _selectBirthDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: t.birthday,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.cake),
                            hintText: t.selectBirthday,
                          ),
                          controller: TextEditingController(
                            text: _birth != null ? DateFormat('dd/MM/yyyy').format(_birth!) : '',
                          ),
                          validator: (_) => _birth == null ? 'Vui lòng chọn ngày sinh' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
                        labelText: t.gender,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.wc),
                      ),
                      items: [
                        DropdownMenuItem(value: 'Nam', child: Text(t.male)),
                        DropdownMenuItem(value: 'Nữ', child: Text(t.female)),
                        DropdownMenuItem(value: 'Khác', child: Text(t.other)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() { _gender = value; });
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 253, 109, 37),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(t.saveChanges, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 