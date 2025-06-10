// custom_bottom_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:recipeapplication/l10n/app_localizations.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      selectedItemColor: Color(0xFF1872EA),
      unselectedItemColor: Colors.grey,
      currentIndex: selectedIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: AppLocalizations.of(context)!.favouritesHeader,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: AppLocalizations.of(context)!.settingsHeader,
        ),
      ],
      onTap: (index) {
        onItemTapped(index);
      },
    );
  }
}
