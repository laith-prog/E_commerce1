import 'package:e_commerce1/cubit/TrendingProductCubit.dart';
import 'package:e_commerce1/cubit/TrendingStoresCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/ProfilePage.dart';
import '../Cart/CartScreen.dart';
import '../Product/AllProductsScreen.dart';
import '../cubit/CartCubit.dart';
import '../cubit/ProfileCubit.dart';
import '../stores/AllStoresScreen.dart';
import 'Drawer/OrdersScreen.dart';
import 'FavoritesScreen.dart';
import 'HomeContentScreen.dart';
import 'SearchScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    HomeContentScreen(),
    SearchScreen(),
    CartScreen(),
    FavoritesScreen(),
  ];

  final List<String> _screenTitles = [
    'Home',
    'Search',
    'Cart',
    'Favorites',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchProfile(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => CartCubit()),
          BlocProvider(create: (context) => TrendingStoresCubit()),
          BlocProvider(create: (context) => ProductsCubit()),
        ],
        child: BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF47C7C), Color(0xFFD64A4A)], // Warm Pink to Deep Pink
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Text(
                _screenTitles[_currentIndex],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'Roboto', // Replace with your custom font
                ),
              ),
              centerTitle: true,
              actions: [
                if (_currentIndex == 0)
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
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
            drawer: _buildDrawer(context, state),
            body: _screens[_currentIndex],
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF47C7C), Color(0xFFD64A4A)], // Warm Pink to Deep Pink
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (_currentIndex == 2) {
                    context.read<CartCubit>().fetchCart();
                  }
                },
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey[300],
                type: BottomNavigationBarType.fixed,
                items: [
                  _buildNavItem(icon: Icons.home, label: 'Home'),
                  _buildNavItem(icon: Icons.search, label: 'Search'),
                  _buildNavItem(icon: Icons.shopping_cart, label: 'Cart'),
                  _buildNavItem(icon: Icons.favorite, label: 'Favorites'),
                ],
              ),
            ),
            // Refresh profile data when the drawer is opened
            onDrawerChanged: (isOpened) {
              if (isOpened) {
                context.read<ProfileCubit>().fetchProfile();
              }
            },
          );
        }),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({required IconData icon, required String label}) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _currentIndex == _getIndexForLabel(label) ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: _currentIndex == _getIndexForLabel(label) ? 30 : 24,
          color: _currentIndex == _getIndexForLabel(label) ? Colors.white : Colors.grey[300],
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
                gradient: LinearGradient(
                  colors: [Color(0xFFF47C7C), Color(0xFFD64A4A)], // Warm Pink to Deep Pink
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF4F4F4F), // Charcoal Gray for the border
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(
                        profile['profile_image'] != null
                            ? 'http://192.168.45.88:8000/storage/' + profile['profile_image']
                            : 'https://via.placeholder.com/150',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      '${profile['first_name'] ?? 'Unknown'} ${profile['last_name'] ?? 'User'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
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
                        color: Color(0xFFFAFAFA), // Off White for the phone number
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                ).then((_) {
                  // Refresh profile data after returning from the edit profile screen
                  context.read<ProfileCubit>().fetchProfile();
                });
              },
            ),
            Divider(color: Color(0xFF4F4F4F)), // Charcoal Gray for dividers
            _buildDrawerItem(
              icon: Icons.list_alt_outlined,
              title: 'My Orders',
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
            Divider(color: Color(0xFF4F4F4F)),
            _buildDrawerItem(
              icon: Icons.store,
              title: 'All Stores',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllStoresScreen()),
                );
              },
            ),
            Divider(color: Color(0xFF4F4F4F)),
            _buildDrawerItem(
              icon: Icons.shopping_bag,
              title: 'All Products',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllProductsScreen()),
                );
              },
            ),
            Divider(color: Color(0xFF4F4F4F)),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('auth_token');

                if (token != null) {
                  await context.read<ProfileCubit>().signOut(token);
                  await prefs.remove('auth_token');
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
            ),
            Divider(color: Color(0xFF4F4F4F)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFFF47C7C)), // Warm Pink for icons
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFF4F4F4F), // Charcoal Gray for text
          fontSize: 16,
          fontFamily: 'Roboto', // Replace with your custom font
        ),
      ),
      onTap: onTap,
    );
  }
}