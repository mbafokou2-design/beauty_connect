import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late TextEditingController _specialtyController;

  File? _pickedImage;
  bool _isUploadingImage = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _specialtyController = TextEditingController(text: user?.specialty ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (picked == null) return;

    setState(() {
      _pickedImage = File(picked.path);
      _isUploadingImage = true;
    });

    try {
      final response = await ApiClient.postWithImage(
        AppConstants.uploadAvatar,
        {},
        picked.path,
        'avatar',
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authProvider = context.read<AuthProvider>();
        final updatedUser =
            authProvider.user!.copyWith(profileImage: data['profileImage']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.userKey,
          jsonEncode(updatedUser.toJson()),
        );

        authProvider.setUserFromOutside(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated'),
              backgroundColor: AppColors.pinkRose,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Upload failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection error during upload'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    final data = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'location': _locationController.text.trim(),
      'bio': _bioController.text.trim(),
    };

    if (user?.isTechnician == true) {
      data['specialty'] = _specialtyController.text.trim();
    }

    final success = await authProvider.updateProfile(data);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.pinkRose,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isTechnician = user?.isTechnician == true;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Avatar with upload
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _pickedImage == null &&
                                user?.profileImage == null
                            ? AppColors.primaryGradient
                            : null,
                        image: _pickedImage != null
                            ? DecorationImage(
                                image: FileImage(_pickedImage!),
                                fit: BoxFit.cover,
                              )
                            : (user?.profileImage != null
                                ? DecorationImage(
                                    image: NetworkImage(user!.profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      ),
                      child: (_pickedImage == null &&
                              user?.profileImage == null)
                          ? Center(
                              child: Text(
                                user?.firstName.substring(0, 1) ?? 'U',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingImage ? null : _pickAndUploadImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: AppColors.white, width: 2),
                            ),
                          ),
                          child: _isUploadingImage
                              ? const Padding(
                                  padding: EdgeInsets.all(7),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: AppColors.white,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // First / Last Name
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'FIRST NAME',
                        controller: _firstNameController,
                        validator: (v) =>
                            v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'LAST NAME',
                        controller: _lastNameController,
                        validator: (v) =>
                            v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildField(
                  label: 'PHONE NUMBER',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone_outlined,
                ),

                const SizedBox(height: 16),

                _buildField(
                  label: 'LOCATION',
                  controller: _locationController,
                  icon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 16),

                if (isTechnician) ...[
                  _buildField(
                    label: 'SPECIALTY',
                    controller: _specialtyController,
                    icon: Icons.star_outline,
                    hint: 'e.g. Senior Hair Stylist',
                  ),
                  const SizedBox(height: 16),
                ],

                _buildField(
                  label: 'BIO',
                  controller: _bioController,
                  maxLines: 4,
                  hint: 'Tell us about yourself...',
                ),

                const SizedBox(height: 32),

                _isSaving
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.pinkRose,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    IconData? icon,
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textGrey,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                icon != null ? Icon(icon, color: AppColors.textGrey) : null,
          ),
        ),
      ],
    );
  }
}