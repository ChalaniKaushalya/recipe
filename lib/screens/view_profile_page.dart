import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:recipeapplication/services/locale_provider.dart';
import 'package:recipeapplication/stores/user-store.dart';
import '../l10n/app_localizations.dart';

class ViewProfilePage extends StatefulWidget {
  @override
  _ViewProfilePageState createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  late String birthday;
  Map<String, bool> isEditing = {};
  Map<String, TextEditingController> controllers = {};
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;

  // Supported language map
  final Map<String, String> options = {'en': 'English', 'es': 'Sinhala'};

  late String selectedLanguage;

  @override
  void initState() {
    super.initState();

    final userStore = Provider.of<UserStore>(context, listen: false);

    birthday =
        '${userStore.birthday?.year}-${userStore.birthday?.month.toString().padLeft(2, '0')}-${userStore.birthday?.day.toString().padLeft(2, '0')}';

    isEditing = {
      'name': false,
      'phone': false,
      'address': false,
      'birthday': false,
      'email': false,
      'language': false,
    };

    controllers['name'] = TextEditingController(text: userStore.fullName);
    controllers['phone'] = TextEditingController(text: userStore.phone);
    controllers['address'] = TextEditingController(text: userStore.address);
    controllers['birthday'] = TextEditingController(text: birthday);
    controllers['email'] = TextEditingController(text: userStore.email);

    selectedLanguage = userStore.language ?? 'en';
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void toggleEditMode(String field) {
    setState(() {
      isEditing[field] = !isEditing[field]!;
    });
  }

  Future<void> saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final userStore = Provider.of<UserStore>(context, listen: false);

      await userStore.login(
        address: controllers['address']!.text,
        birthday:
            DateTime.tryParse(controllers['birthday']!.text) ?? DateTime.now(),
        createdAt: userStore.createdAt!,
        email: controllers['email']!.text,
        fullName: controllers['name']!.text,
        phone: controllers['phone']!.text,
        profilePicture: userStore.profilePicture!,
      );

      // Update language in userStore as well
      userStore.language = selectedLanguage;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userStore.email) // Search by email field
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .update({
              'fullName': controllers['name']!.text,
              'phone': controllers['phone']!.text,
              'address': controllers['address']!.text,
              'language': selectedLanguage,
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );

        // Exit editing mode for all fields after save
        setState(() {
          isEditing.updateAll((key, value) => false);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No user found with this email.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update profile: $e")));
    } finally {
      setState(() => isSaving = false);
    }
  }

  Widget buildEditableField(
    String label,
    String field,
    String? Function(String?) validator, {
    bool isDisabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          /// Language field is special: show dropdown only if editing
          Expanded(
            flex: 5,
            child: field == 'language'
                ? (isEditing[field]!
                      ? DropdownButtonFormField<String>(
                          value: selectedLanguage,
                          items: options.entries
                              .map(
                                (entry) => DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              selectedLanguage = value;
                            });
                            Provider.of<LocaleProvider>(
                              context,
                              listen: false,
                            ).setLocale(Locale(value));
                          },

                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          validator: validator,
                        )
                      : Text(
                          options[selectedLanguage] ?? selectedLanguage,
                          style: TextStyle(fontSize: 16),
                        ))
                : (isEditing[field]! && !isDisabled
                      ? TextFormField(
                          controller: controllers[field],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            errorStyle: TextStyle(color: Colors.red),
                          ),
                          validator: validator,
                        )
                      : Text(
                          controllers[field]!.text,
                          style: TextStyle(fontSize: 16),
                        )),
          ),

          // Show edit/check button only for fields except language, which has its own toggle
          Expanded(
            flex: 2,
            child: isDisabled
                ? SizedBox.shrink()
                : IconButton(
                    icon: Icon(isEditing[field]! ? Icons.check : Icons.edit),
                    onPressed: () => toggleEditMode(field),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profileHeader,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, {'userName': controllers['name']!.text});
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(userStore.profilePicture!),
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildEditableField(
                            AppLocalizations.of(context)!.email,
                            'email',
                            (value) => value!.isEmpty
                                ? AppLocalizations.of(context)!.emailEmptyError
                                : null,
                            isDisabled: true,
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          buildEditableField(
                            AppLocalizations.of(context)!.name,
                            'name',
                            (value) => value!.isEmpty
                                ? AppLocalizations.of(context)!.nameEmptyError
                                : null,
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          buildEditableField(
                            AppLocalizations.of(context)!.phone,
                            'phone',
                            (value) => value!.isEmpty
                                ? AppLocalizations.of(context)!.phoneEmptyError
                                : null,
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          buildEditableField(
                            AppLocalizations.of(context)!.address,
                            'address',
                            (value) => value!.isEmpty
                                ? AppLocalizations.of(
                                    context,
                                  )!.addressEmptyError
                                : null,
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          buildEditableField(
                            AppLocalizations.of(context)!.birthday,
                            'birthday',
                            (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                )!.birthdayEmptyError;
                              }
                              return null;
                            },
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          buildEditableField(
                            AppLocalizations.of(context)!.language,
                            'language',
                            (value) => value == null || value.isEmpty
                                ? AppLocalizations.of(
                                    context,
                                  )!.languageEmptyError
                                : null,
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSaving ? null : saveProfileChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(24, 114, 234, 1),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: isSaving
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppLocalizations.of(context)!.saveProfile,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
