import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../services/storage_service.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_panel.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.showAppBar = false});
  final bool showAppBar;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;
  

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      if (!mounted) return;
      
      setState(() {
        
        _isUploading = true;
      });
      
      final store = AppStateScope.of(context);
      
      String? uploadedUrl;
      if (FirebaseAuth.instance.currentUser != null) {
        uploadedUrl = await StorageService().uploadProfileImage(image.path);
        if (uploadedUrl == null) {
          throw Exception('Failed to upload profile image.');
        }
      }
      
      final finalPath = uploadedUrl ?? image.path;
      await store.updateProfile({'profileImageUrl': finalPath});
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      
      String message = 'Please check your connection and try again.';
      if (e.toString().contains('exceeds')) {
        message = 'Image size exceeds 10MB limit.';
      } else if (e.toString().contains('permission-denied')) {
        message = 'Permission denied.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile image: $message'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppStateScope.of(context).profile;
    final body = SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          widget.showAppBar ? 8 : 12,
          20,
          widget.showAppBar ? 24 : 112,
        ),
        children: [
          if (!widget.showAppBar)
            const Text(
              'Profile',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
          if (!widget.showAppBar) const SizedBox(height: 18),
          Column(
            children: [
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.elevatedCard,
                      backgroundImage: profile.profileImageUrl != null
                          ? (profile.profileImageUrl!.startsWith('http')
                              ? NetworkImage(profile.profileImageUrl!) as ImageProvider
                              : FileImage(File(profile.profileImageUrl!)))
                          : null,
                      child: profile.profileImageUrl == null
                          ? const Text(
                              'AI',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                            )
                          : null,
                    ),
                    if (_isUploading)
                      const CircularProgressIndicator(color: AppColors.primaryTeal),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.handle,
                style: const TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 10),
              const StatusChip(
                label: 'Verified Member',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  label: 'Rating',
                  value: profile.rating.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStat(
                  label: 'Trust Score',
                  value: '${profile.trustScore}%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStat(
                  label: 'Items Lent',
                  value: '${profile.itemsLent}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  label: 'Listed',
                  value: '${profile.itemsListed}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStat(
                  label: 'Borrowed',
                  value: '${profile.itemsBorrowed}',
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _ProfileStat(label: 'Saved', value: '₹0'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          AppPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ProfileMenuTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Personal Information',
                  onTap: () => _editProfile(context),
                ),
                _ProfileMenuTile(
                  icon: Icons.inventory_2_outlined,
                  label: 'My Listings',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.shell,
                    arguments: 1,
                  ),
                ),
                _ProfileMenuTile(
                  icon: Icons.bookmark_added_outlined,
                  label: 'My Bookings',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.requests),
                ),
                _ProfileMenuTile(
                  icon: Icons.reviews_outlined,
                  label: 'Reviews',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.reviews),
                ),
                _ProfileMenuTile(
                  icon: Icons.credit_card_rounded,
                  label: 'Payment Methods',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
                ),
                _ProfileMenuTile(
                  icon: Icons.card_giftcard_rounded,
                  label: 'Refer and Earn',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.refer),
                ),
                _ProfileMenuTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Help and Support',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.help),
                ),
                _ProfileMenuTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: body,
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final store = AppStateScope.of(context);
    final profile = store.profile;
    
    final nameController = TextEditingController(text: profile.displayName);
    final locationController = TextEditingController(text: profile.location ?? '');
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await store.updateProfile({
                'displayName': nameController.text.trim(),
                'location': locationController.text.trim(),
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.secondaryText),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.secondaryText,
          ),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, indent: 58),
      ],
    );
  }
}
