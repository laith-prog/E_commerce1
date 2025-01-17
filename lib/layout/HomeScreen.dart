import 'package:e_commerce1/layout/Drawer/OrdersScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/ProfilePage.dart';
import '../cubit/CartCubit.dart';
import '../cubit/ProfileCubit.dart';
import 'FavoritesScreen.dart';
import 'HomeContentScreen.dart';
import 'SearchScreen.dart';
import 'cart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeContentScreen(),
    SearchScreen(),
    CartScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileCubit()..fetchProfile(),
        ),
        BlocProvider(
          create: (context) => CartCubit(),
        ),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Builder(
                builder: (context) {
                  return AppBar(
                    backgroundColor: Color(0xFF2C2C2C),
                    elevation: 0,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {
                          // Add notification action here
                        },
                      ),
                    ],
                    leading: IconButton(
                      icon: Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  );
                },
              ),
            ),
            drawer: _buildDrawer(context, state),
            body: _screens[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Color(0xFF2C2C2C),
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                if (_currentIndex == 2) {
                  context.read<CartCubit>().fetchCart();
                }
              },
              selectedItemColor: Color(0xFFF47C7C),
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: [
                _buildNavItem(icon: Icons.home, label: 'Home'),
                _buildNavItem(icon: Icons.search, label: 'Search'),
                _buildNavItem(icon: Icons.shopping_cart, label: 'Cart'),
                _buildNavItem(icon: Icons.favorite, label: 'Favorites'),
              ],
            ),
          );
        },
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      {required IconData icon, required String label}) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(8), // Added padding around the icon
        decoration: BoxDecoration(
          color: _currentIndex == _getIndexForLabel(label)
              ? Color(0xFFF47C7C)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
              12), // Rounded corners for the selected icon
        ),
        child: Icon(
          icon,
          size: _currentIndex == _getIndexForLabel(label) ? 30 : 24,
          // Increase size for selected item
          color: _currentIndex == _getIndexForLabel(label)
              ? Colors.white
              : Colors.grey,
        ),
      ),
      label: label,
    );
  }

  int _getIndexForLabel(String label) {
    switch (label) {
      case 'Home':
        return 0;
      case 'Search':
        return 1;
      case 'Cart':
        return 2;
      case 'Favorites':
        return 3;
      default:
        return 0;
    }
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

    var profile = state.profile!;
    return Drawer(
      child: Container(
        color: Color(0xFFFAFAFA), // Off White for the drawer background
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFF47C7C), // Warm Pink for the header background
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF4F4F4F),
                    // Charcoal Gray for the border
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(profile['profile_image'] ??
                          'https://via.placeholder.com/150'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      '${profile['first_name'] ?? 'Unknown'} ${profile['last_name'] ?? 'User'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white, // White text for the name
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Flexible(
                    child: Text(
                      profile['phone_number'] ?? 'No phone number',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFAFAFA),
                        // Off White for the phone number
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFFF47C7C)),
              // Warm Pink for icons
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Color(0xFF4F4F4F), // Charcoal Gray for text
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            Divider(color: Color(0xFF4F4F4F)), // Light Gray for dividers
            ListTile(
              leading: Icon(Icons.list_alt_outlined, color: Color(0xFFF47C7C)),
              // Warm Pink for icons
              title: Text(
                'My Orders',
                style: TextStyle(
                  color: Color(0xFF4F4F4F), // Charcoal Gray for text
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('auth_token');

                if (token != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrdersScreen(token: token)),
                  );
                }
              },
            ),
            Divider(color: Color(0xFF4F4F4F)), // Light Gray for dividers

            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFFF47C7C)),
              // Warm Pink for icons
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFF4F4F4F), // Charcoal Gray for text
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('auth_token');

                if (token != null) {
                  await context.read<ProfileCubit>().signOut(token);
                  await prefs.remove('auth_token');
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }
              },
            ),
            Divider(color: Color(0xFF4F4F4F)), // Light Gray for dividers
          ],
        ),
      ),
    );
  }
}
