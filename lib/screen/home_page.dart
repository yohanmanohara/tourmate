import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search for places...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Featured Destinations
                const Text(
                  'Featured AR Destinations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      destinationCard('Historic Castle', 'assets/castle.jpg'),
                      destinationCard('Ancient Ruins', 'assets/ruins.jpg'),
                      destinationCard('City Tour', 'assets/city.jpg'),
                      destinationCard('Mountain View', 'assets/mountain.jpg'),
                      destinationCard('Cultural Heritage', 'assets/culture.jpg'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Navigation Buttons
                const Text(
                  'Explore Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  children: [
                    categoryButton(Icons.museum, 'Museums'),
                    categoryButton(Icons.nature, 'Nature Parks'),
                    categoryButton(Icons.vrpano, 'AR Experiences'),
                    categoryButton(Icons.hiking, 'Hiking Trails'),
                    categoryButton(Icons.beach_access, 'Beaches'),
                    categoryButton(Icons.local_florist, 'Botanical Gardens'),
                  ],
                ),
                const SizedBox(height: 20),

                // More Content
                const Text(
                  'Popular Destinations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.location_on, color: Colors.blueAccent),
                      title: Text('Destination ${index + 1}'),
                      subtitle: const Text('Explore this beautiful place'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Destination Card Widget
  Widget destinationCard(String title, String imagePath) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Category Button Widget
  Widget categoryButton(IconData icon, String title) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blueAccent,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],

    );
  }
}
