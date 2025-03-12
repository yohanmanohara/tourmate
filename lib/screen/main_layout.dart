import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'travel.dart';
import '../widgets/appbar.dart';
import 'map.dart';
import 'screenshot.dart';
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _isChatVisible = false; // Track chat visibility

  final List<Widget> _screens = [
    HomePage(),
    ARMapScreen(),
    ProfilePage(),
    TravelPage(),
    GalleryScreen(),
  ];

  final List<String> _titles = [
   '',
    'Map', 
    'AR Mode',
    'Profile',
    'ScreenShots',
  ];

  void _toggleChat() {
    setState(() {
      _isChatVisible = !_isChatVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BeautifulAppBar(
        currentIndex: _currentIndex,
        titles: _titles,
      ),
      
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _screens[_currentIndex],
          ),

          // Floating Chat Preview
          if (_isChatVisible)
            Positioned(
              bottom: 90,
              right: 20,
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 350,
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ChatBot",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: _toggleChat,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(10),
                          children: [
                            ChatBubble("Hello! How can I help you?", isBot: true),
                            ChatBubble("I need some assistance.", isBot: false),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Type a message...",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send, color: Colors.deepPurpleAccent),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        selectedIconTheme: IconThemeData(
          size: 28,
          color: Colors.deepPurpleAccent,
        ),
        unselectedIconTheme: IconThemeData(
          size: 24,
          color: Colors.grey,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(12.0),
              child: Icon(
                Icons.view_in_ar,
                color: Colors.white,
              ),
            ),
            label: "AR Mode",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel), // Airplane icon
            activeIcon: Icon(Icons.card_travel),
            label: "Travel",
          ),
          BottomNavigationBarItem(
           icon: Icon(Icons.image_outlined),  // Outline version of camera icon
          activeIcon: Icon(Icons.image_outlined),     // Filled version of camera icon
          label: "ScreenShots",                   // Label for the item
          )

        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _toggleChat, // Toggle chat visibility
        backgroundColor: Colors.deepPurpleAccent,
        child: Icon(Icons.smart_toy, color: Colors.white), // Bot icon
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isBot;

  ChatBubble(this.message, {required this.isBot});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isBot ? Colors.grey[300] : Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(color: isBot ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}
