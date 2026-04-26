import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../utils/app_colors.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          final profile = profileProvider.profile;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Profile Header ─────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft:  Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          // ✅ Fixed: withValues instead of withOpacity
                          color: AppColors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            profile.name.isNotEmpty
                                ? profile.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.name.isNotEmpty ? profile.name : 'User',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email.isNotEmpty ? profile.email : 'No email',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _getProfileCompleteness(profile),
                          minHeight: 8,
                          backgroundColor: AppColors.white.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_getProfileCompleteness(profile) * 100).toStringAsFixed(0)}% Complete',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tab Navigation ─────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton('Personal',  0),
                        _buildTabButton('Medical',   1),
                        _buildTabButton('Emergency', 2),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tab Content ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTabContent(context, profile, profileProvider),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(
      BuildContext context, dynamic profile, ProfileProvider provider) {
    switch (_currentTabIndex) {
      case 0:
        return _buildPersonalTab(context, profile, provider);
      case 1:
        return _buildMedicalTab(context, profile, provider);
      case 2:
        return _buildEmergencyTab(context, profile, provider);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalTab(
      BuildContext context, dynamic profile, ProfileProvider provider) {
    return Column(
      children: [
        _buildEditableField(
          label: 'Full Name',
          value: profile.name,
          icon: Icons.person_outline,
          onEdit: () => _showEditDialog(
              context, 'Full Name', profile.name, provider.updateName),
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Email',
          value: profile.email.isEmpty ? 'Not set' : profile.email,
          icon: Icons.email_outlined,
          onEdit: () => _showEditDialog(
              context, 'Email', profile.email, provider.updateEmail),
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Phone',
          value: profile.phone.isEmpty ? 'Not set' : profile.phone,
          icon: Icons.phone_outlined,
          onEdit: () => _showEditDialog(
              context, 'Phone', profile.phone, provider.updatePhone),
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Date of Birth',
          value: profile.dateOfBirth.isEmpty ? 'Not set' : profile.dateOfBirth,
          icon: Icons.cake_outlined,
          onEdit: () =>
              _showDatePicker(context, provider.updateDateOfBirth),
        ),
      ],
    );
  }

  Widget _buildMedicalTab(
      BuildContext context, dynamic profile, ProfileProvider provider) {
    final bloodTypes = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];
    return Column(
      children: [
        _buildSelectableField(
          label: 'Blood Type',
          value: profile.bloodType,
          icon: Icons.bloodtype_outlined,
          options: bloodTypes,
          onSelect: provider.updateBloodType,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Allergies',
          value: profile.allergies.isEmpty ? 'None' : profile.allergies,
          icon: Icons.warning_outlined,
          onEdit: () => _showEditDialog(
              context, 'Allergies', profile.allergies, provider.updateAllergies,
              maxLines: 3),
        ),
      ],
    );
  }

  Widget _buildEmergencyTab(
      BuildContext context, dynamic profile, ProfileProvider provider) {
    return Column(
      children: [
        _buildEditableField(
          label: 'Emergency Contact Name',
          value: profile.emergencyContact.isEmpty
              ? 'Not set'
              : profile.emergencyContact,
          icon: Icons.contacts_outlined,
          onEdit: () => _showEditDialog(
            context,
            'Emergency Contact Name',
            profile.emergencyContact,
            (value) async => provider.updateEmergencyContact(
                value, profile.emergencyPhone),
          ),
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          label: 'Emergency Contact Phone',
          value: profile.emergencyPhone.isEmpty
              ? 'Not set'
              : profile.emergencyPhone,
          icon: Icons.phone_outlined,
          onEdit: () => _showEditDialog(
            context,
            'Emergency Contact Phone',
            profile.emergencyPhone,
            (value) async => provider.updateEmergencyContact(
                profile.emergencyContact, value),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.white : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit_outlined,
                color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: options.map((option) {
              final isSelected = option == value;
              return GestureDetector(
                onTap: () => onSelect(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String initialValue,
    Function(String) onSave, {
    int maxLines = 1,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Enter value'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(
      BuildContext context, Function(String) onDateSelected) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      onDateSelected('${selected.day}/${selected.month}/${selected.year}');
    }
  }

  double _getProfileCompleteness(dynamic profile) {
    int filled = 0;
    const total = 9;
    if (profile.name.isNotEmpty) filled++;
    if (profile.email.isNotEmpty) filled++;
    if (profile.phone.isNotEmpty) filled++;
    if (profile.dateOfBirth.isNotEmpty) filled++;
    if (profile.bloodType.isNotEmpty) filled++;
    if (profile.allergies.isNotEmpty && profile.allergies != 'None') filled++;
    if (profile.emergencyContact.isNotEmpty) filled++;
    if (profile.emergencyPhone.isNotEmpty) filled++;
    filled++; // id always present
    return filled / total;
  }
}