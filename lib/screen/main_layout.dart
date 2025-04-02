import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'FavouritePage.dart';
import 'travel.dart';
import '../widgets/appbar.dart';
import 'map.dart';
import 'screenshot.dart';
import '../widgets/chat_bubble.dart';
import '../screen/NewFeatureScreen.dart';
import '../screen/sos.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _isChatVisible = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatBubble> _messages = [
    ChatBubble(
      message: "Hello! I'm your Sri Lanka travel assistant. How can I help you today?",
      isBot: true,
      timestamp: DateTime.now(),
    ),
  ];

  final List<Widget> _screens = [
    HomePage(),
    FavouritePage(),
    MapScreen(),
    TravelPage(),
    GalleryScreen(),
  ];

  final List<String> _titles = [
    'TourMate',
    'Favourite',
    'Explore Destinations',
    'Travel',
    'ScreenShots',
  ];

  void _toggleChat() {
    setState(() {
      _isChatVisible = !_isChatVisible;
    });
  }

 void _Sos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SOS()),
    );
  }

  void _openNewFeatureScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewFeatureScreen()),
    );
  }

  Future<String> _getBotResponse(String userMessage) async {
    try {
      const String baseUrl = 'https://18bb-35-188-228-58.ngrok-free.app/';
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return data['response'] ?? "I didn't get a response. Please try again.";
        } catch (e) {
          debugPrint('JSON decode error: $e');
          return "Sorry, I'm having trouble understanding the response.";
        }
      } else if (response.statusCode == 404) {
        return "The chat service is currently unavailable. [404]";
      } else if (response.statusCode >= 500) {
        return "Server error. Please try again later. [${response.statusCode}]";
      } else {
        return "Sorry, I couldn't get a proper response. [Status: ${response.statusCode}]";
      }
    } on http.ClientException catch (e) {
      debugPrint('HTTP Client Exception: $e');
      return "Connection failed. Please check your internet connection.";
    } on SocketException catch (e) {
      debugPrint('Socket Exception: $e');
      return "Network error. Are you connected to the internet?";
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return "An unexpected error occurred. Please try again.";
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final userMessage = _messageController.text;
    _messageController.clear();
    
    setState(() {
      _messages.insert(0, ChatBubble(
        message: userMessage,
        isBot: false,
        timestamp: DateTime.now(),
      ));
    });

    _scrollToTop();

    try {
      final botResponse = await _getBotResponse(userMessage);
      setState(() {
        _messages.insert(0, ChatBubble(
          message: botResponse,
          isBot: true,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToTop();
    } catch (e) {
      setState(() {
        _messages.insert(0, ChatBubble(
          message: "Sorry, I encountered an error. Please try again.",
          isBot: true,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
          if (_isChatVisible)
            Positioned(
              bottom: 100,
              right: 80,
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 310,
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
                          color: Colors.indigoAccent,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sri Lanka Travel Assistant",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: _toggleChat,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(10),
                          reverse: true,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _messages[index];
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: "Ask about Sri Lanka...",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send, 
                                color: Colors.indigoAccent),
                              onPressed: _sendMessage,
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
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.indigoAccent,
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
          color: Colors.indigoAccent,
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
            icon: Icon(Icons.star_border_rounded),
            activeIcon: Icon(Icons.star_border_purple500),
            label: "Favourite",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.indigoAccent,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(12.0),
              child: Icon(Icons.map_outlined, 
              color: Colors.white),
              
            ),
            label: "Locations",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            activeIcon: Icon(Icons.card_travel),
            label: "Travel",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_outlined),
            activeIcon: Icon(Icons.image_outlined),
            label: "ScreenShots",
          ),
        ],
      ),
     floatingActionButton: _currentIndex == 0
    ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _toggleChat,

            backgroundColor: Colors.indigoAccent,

            heroTag: 'chatButton',
            child: Icon(Icons.travel_explore, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _openNewFeatureScreen,
            backgroundColor: const Color.fromARGB(255, 76, 228, 5),
            heroTag: 'newFeatureButton',
            child: Icon(Icons.calculate, color: Colors.white),
          ),
          SizedBox(height: 16), // Add spacing
          FloatingActionButton(
            onPressed: _Sos, // Emergency function
            backgroundColor: Colors.red, // Emergency red color
            heroTag: 'sosButton', // Emergency icon
            elevation: 6,
            child: Icon(Icons.emergency, color: Colors.white), // Slightly higher elevation for prominence
          ),
        ],
      )
    : FloatingActionButton(
        onPressed: _toggleChat,

        backgroundColor: Colors.indigoAccent,

        heroTag: 'chatButton',
        child: Icon(Icons.travel_explore, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


