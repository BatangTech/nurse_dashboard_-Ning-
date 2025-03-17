import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/action_buttons_row.dart';
import '../../widgets/general_info_section.dart';
import '../../widgets/medical_info_section.dart';
import '../../widgets/personal_info_section.dart';
import '../../widgets/sheet_handle.dart';
import '../../widgets/user_profile_header.dart';

class UserDetailsBottomSheet extends StatelessWidget {
  final String userId;

  const UserDetailsBottomSheet({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'เกิดข้อผิดพลาด: ${snapshot.error}',
                    style: GoogleFonts.kanit(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Text(
                    'ไม่พบข้อมูลผู้ใช้',
                    style: GoogleFonts.kanit(),
                  ),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Handle
                  const SheetHandle(),
                  const SizedBox(height: 20),

                  // User profile header
                  UserProfileHeader(userData: userData, userId: userId),
                  const SizedBox(height: 24),

                  // User information sections
                  PersonalInfoSection(userData: userData),
                  const SizedBox(height: 16),

                  GeneralInfoSection(userData: userData, userId: userId),
                  const SizedBox(height: 16),

                  MedicalInfoSection(userData: userData),
                  const SizedBox(height: 24),

                  // Action buttons
                  ActionButtonsRow(userId: userId),
                ],
              );
            },
          ),
        );
      },
    );
  }
}