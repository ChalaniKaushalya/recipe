import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:recipeapplication/stores/user-store.dart';
import 'package:recipeapplication/widgets/BottomNavBar.dart';
import 'package:recipeapplication/widgets/RecipeCard.dart';
import 'settingspage.dart';
import 'favorite_list_page.dart';
import 'view_profile_page.dart';
import 'recipedetailspage.dart';
import '../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userPicture;
  final String birthday;
  final String address;
  final String phone;
  final String email;

  HomePage({
    required this.email,
    required this.userName,
    required this.userPicture,
    required this.phone,
    required this.birthday,
    required this.address,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    FavoriteListPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.userPicture),
                  ),
                  SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.welcome +
                        ' ' +
                        (userStore.fullName ?? ''),

                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.black),
                  onPressed: () {
                    _showNotificationDialog(context);
                  },
                ),
              ],
            )
          : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      backgroundColor: Colors.white,
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.notification,
          ), // e.g. "Notification"
          content: Text(
            AppLocalizations.of(context)!.whatWouldYouLikeToDo,
          ), // e.g. "What would you like to do?"
          actions: [
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewProfilePage()),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.viewProfile,
              ), // e.g. "View Profile"
            ),
            TextButton(
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
              child: Text(
                AppLocalizations.of(context)!.logout,
              ), // e.g. "Log Out"
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logOut),
          content: Text(
            AppLocalizations.of(context)!.areYouSureYouWantToLogOut,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  late Stream<QuerySnapshot> _recipeStream;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  void fetchRecipes() {
    setState(() {
      _recipeStream = selectedCategory == "All"
          ? FirebaseFirestore.instance.collection('recipes').snapshots()
          : FirebaseFirestore.instance
                .collection('recipes')
                .where('category', isEqualTo: selectedCategory)
                .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        fetchRecipes();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.homeGreeting,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search any recipes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF1872EA), Color(0xFF6249EB)],
                    stops: [0.24, 0.945],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.homeHeader,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                    Image.asset('assets/chef.png', height: 80),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.categories,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryButton('All'),
                    _buildCategoryButton('Main Course'),
                    _buildCategoryButton('Appetizers'),
                    _buildCategoryButton('Desserts'),
                    _buildCategoryButton('Soup'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.allRecipes,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: _recipeStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No recipes found.'));
                  }

                  final recipes = snapshot.data!.docs;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      final docId = recipe.id;
                      final recipeData = recipe.data() as Map<String, dynamic>;

                      return RecipeCard(
                        recipies: recipeData,
                        docId: docId,
                        onTap: () async {
                          // Await the result from the Recipe Details page.
                          bool? updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailsPage(docId: docId),
                            ),
                          );
                          // If the favorite status was changed, refresh the HomeScreen.
                          if (updated == true) {
                            setState(() {});
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedCategory = label;
            fetchRecipes();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedCategory == label
              ? Colors.blue
              : Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selectedCategory == label ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
