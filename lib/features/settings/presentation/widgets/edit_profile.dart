import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/core/theme/colors_thems.dart';
import 'package:instagram/core/provider/theme_provider.dart';
import 'package:instagram/features/home/data/userdata.dart';
import 'package:instagram/features/settings/data/update_user_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EditProfile extends StatefulWidget {
  static const String routname = "editProfile";

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final user = Userdata();
  final auth = FirebaseAuth.instance;
  final updateData = UpdateUserData();
  XFile? selectedFile;
  late TextEditingController usernameController;
  late TextEditingController bioController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    bioController = TextEditingController();
    emailController = TextEditingController();
    fetchData();
  }

  @override
  void dispose() {
    usernameController.dispose();
    bioController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void fetchData() async {
    await user.fetchUser();
    setState(() {
      usernameController.text = user.username ?? '';
      bioController.text = user.bio ?? '';
      emailController.text = auth.currentUser!.email ?? '';
    });
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedFile = image;
    });
  }

  void saveChanges() async {
    await updateData.updateUserProfile(
        username: usernameController.text,
        bio: bioController.text,
        profileImage: user.profileImage ?? "",
        email: emailController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.grey
                        : Colors.black),

              ),
            ),
            Text(
              AppLocalizations.of(context)!.editProfile,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // Save changes
            TextButton(
              onPressed: () {
                saveChanges();
              },
              child: Text(
                AppLocalizations.of(context)!.done,
                style: TextStyle(
                    color: ThemingColor.blueFontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          children: [
            //Profile photo
            CircleAvatar(
              backgroundImage: user.profileImage != null
                  ? AssetImage(user.profileImage!)
                  : const AssetImage("assets/posts/post (16).png"),
              radius: 70,
            ),
            // Change profile photo button
            TextButton(
              onPressed: () => pickImage(),
              child: Text(
                AppLocalizations.of(context)!.changeProfilePhoto,
                style: TextStyle(
                    color: ThemingColor.blueFontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 10),

            // Username field
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.username,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Bio field
            TextField(
              controller: bioController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.bio,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Email field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
