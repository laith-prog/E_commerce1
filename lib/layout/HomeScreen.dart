import 'package:e_commerce1/Cart/CartScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/ProfilePage.dart';
import '../cubit/ProfileCubit.dart';
import '../cubit/CartCubit.dart'; // Import CartCubit
import 'FavoritesScreen.dart';
import 'HomeContentScreen.dart';
import 'OrdersScreen.dart';
import 'SearchScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // List of screens corresponding to bottom navigation bar items
  final List<Widget> _screens = [
    HomeContentScreen(), // Your Home content
    SearchScreen(), // Replace with your actual Search screen
    CartScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchProfile(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => CartCubit()), // Provide CartCubit here
        ],
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: Text('Home')),
              drawer: _buildDrawer(context, state),
              // Pass the state to the drawer
              body: _screens[_currentIndex],
              // Display the selected screen
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (_currentIndex == 2) {
                    // Fetch the cart when the "Cart" tab is clicked
                    context.read<CartCubit>().fetchCart();
                  }
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart), label: 'Cart'), // Cart tab

                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'Favorites',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ProfileState state) {
    if (state.isLoading) {
      return Drawer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.profile == null) {
      return Drawer(
        child: Center(child: Text('Failed to load profile')),
      );
    }

    // Profile data
    var profile = state.profile!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(profile['profile_image'] ??
                      'https://via.placeholder.com/150'),
                ),
                SizedBox(height: 10),
                Text(
                    '${profile['first_name'] ?? 'Unknown'} ${profile['last_name'] ?? 'User'}'),
                Text(profile['phone_number'] ?? 'No phone number'),
              ],
            ),
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString('auth_token');

              if (token != null) {
                // Call the signOut method from the ProfileCubit
                await context.read<ProfileCubit>().signOut(token);
                await prefs.remove('auth_token'); // Remove the token locally
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
