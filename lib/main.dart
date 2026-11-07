import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color gold = Color(0xFFD6B36A);
const Color background = Color(0xFF0B1018);
const Color surface = Color(0xFF151E2B);
const Color surfaceLight = Color(0xFF202C3B);
const Color muted = Color(0xFF9AA6B5);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TravelMateApp());
}

class TravelMateApp extends StatelessWidget {
  const TravelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelMate Luxury',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: gold,
          surface: surface,
        ),
        fontFamily: 'Arial',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
          ),
        ),
      ),
      home: const TravelHomePage(),
    );
  }
}

class Destination {
  final String name;
  final String country;
  final String description;
  final String image;
  final String price;
  const Destination({
    required this.name,
    required this.country,
    required this.description,
    required this.image,
    required this.price,
  });
}

const List<Destination> destinations = [
  Destination(
    name: 'Manali',
    country: 'India',
    description: 'Mountain air, pine forests and peaceful Himalayan views.',
    image: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=1200',
    price: '₹12,000',
  ),
  Destination(
    name: 'Bali',
    country: 'Indonesia',
    description: 'Tropical beaches, lush rice terraces and island sunsets.',
    image: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=1200',
    price: '₹45,000',
  ),
  Destination(
    name: 'Paris',
    country: 'France',
    description: 'Elegant streets, art, cafés and unforgettable city lights.',
    image: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1200',
    price: '₹85,000',
  ),
  Destination(
    name: 'Switzerland',
    country: 'Switzerland',
    description: 'Alpine lakes, scenic rail journeys and snow-capped peaks.',
    image: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=1200',
    price: '₹1,20,000',
  ),
];

class Trip {
  final String id;
  final String destination;
  final String country;
  final String date;
  final int travelers;
  final double budget;
  final List<String> activities;

  Trip({
    required this.id,
    required this.destination,
    required this.country,
    required this.date,
    required this.travelers,
    required this.budget,
    List<String>? activities,
  }) : activities = activities ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'destination': destination,
        'country': country,
        'date': date,
        'travelers': travelers,
        'budget': budget,
        'activities': activities,
      };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        destination: json['destination'] as String,
        country: json['country'] as String,
        date: json['date'] as String,
        travelers: json['travelers'] as int,
        budget: (json['budget'] as num).toDouble(),
        activities: List<String>.from(json['activities'] ?? []),
      );
}

class TravelHomePage extends StatefulWidget {
  const TravelHomePage({super.key});

  @override
  State<TravelHomePage> createState() => _TravelHomePageState();
}

class _TravelHomePageState extends State<TravelHomePage> {
  int selectedTab = 0;
  bool loading = true;
  List<Trip> trips = [];
  String searchQuery = '';

  final List<String> labels = const [
    'Dashboard',
    'Explore',
    'My Trips',
    'Itinerary',
    'Budget',
  ];
  final List<IconData> icons = const [
    Icons.grid_view_rounded,
    Icons.explore_outlined,
    Icons.luggage_outlined,
    Icons.route_outlined,
    Icons.account_balance_wallet_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('travelmate_trips');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        trips = decoded
            .map((item) => Trip.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } catch (_) {
        trips = [];
      }
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _saveTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'travelmate_trips',
      jsonEncode(trips.map((trip) => trip.toJson()).toList()),
    );
  }

  void _addTrip(Trip trip) {
    setState(() {
      trips = [...trips, trip];
    });
    _saveTrips();
  }

  void _deleteTrip(String id) {
    setState(() => trips.removeWhere((trip) => trip.id == id));
    _saveTrips();
  }

  void _addActivity(Trip trip, String activity) {
    if (activity.trim().isEmpty) return;
    setState(() => trip.activities.add(activity.trim()));
    _saveTrips();
  }

  void _deleteActivity(Trip trip, int index) {
    setState(() => trip.activities.removeAt(index));
    _saveTrips();
  }

  Future<void> _showAddTripDialog() async {
    final dateController = TextEditingController();
    final travelersController = TextEditingController(text: '2');
    final budgetController = TextEditingController(text: '30000');
    String chosenDestination = destinations.first.name;

    final result = await showDialog<Trip>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: surface,
          title: const Text('Create a new trip'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: chosenDestination,
                    decoration: const InputDecoration(labelText: 'Destination'),
                    items: destinations
                        .map((d) => DropdownMenuItem(
                              value: d.name,
                              child: Text('${d.name}, ${d.country}'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => chosenDestination = value);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Travel date',
                      hintText: 'e.g. 20 December 2026',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: travelersController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Travellers'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Estimated budget (₹)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final destination = destinations
                    .firstWhere((d) => d.name == chosenDestination);
                final trip = Trip(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  destination: destination.name,
                  country: destination.country,
                  date: dateController.text.trim().isEmpty
                      ? 'Date not set'
                      : dateController.text.trim(),
                  travelers:
                      int.tryParse(travelersController.text.trim()) ?? 1,
                  budget:
                      double.tryParse(budgetController.text.trim()) ?? 0,
                );
                Navigator.pop(dialogContext, trip);
              },
              child: const Text('Create trip'),
            ),
          ],
        ),
      ),
    );

    dateController.dispose();
    travelersController.dispose();
    budgetController.dispose();
    if (result != null) _addTrip(result);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (desktop) _sidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _topBar(),
                      Expanded(
                        child: loading
                            ? const Center(
                                child: CircularProgressIndicator(color: gold))
                            : _currentPage(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  backgroundColor: const Color(0xFF101722),
                  indicatorColor: gold.withValues(alpha: .16),
                  selectedIndex: selectedTab,
                  onDestinationSelected: (index) =>
                      setState(() => selectedTab = index),
                  destinations: List.generate(
                    labels.length,
                    (index) => NavigationDestination(
                      icon: Icon(icons[index]),
                      label: labels[index] == 'Dashboard'
                          ? 'Home'
                          : labels[index] == 'My Trips'
                              ? 'Trips'
                              : labels[index],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _sidebar() {
    return Container(
      width: 245,
      padding: const EdgeInsets.fromLTRB(22, 30, 18, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF101722),
        border: Border(right: BorderSide(color: Color(0x1FFFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flight_takeoff_rounded, color: gold, size: 27),
              SizedBox(width: 10),
              Text(
                'TRAVELMATE',
                style: TextStyle(
                  color: gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          ...List.generate(labels.length, (index) {
            final active = selectedTab == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                selected: active,
                selectedTileColor: gold.withValues(alpha: .12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                leading: Icon(icons[index], color: active ? gold : muted),
                title: Text(
                  labels[index],
                  style: TextStyle(
                    color: active ? gold : muted,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                onTap: () => setState(() => selectedTab = index),
              ),
            );
          }),
          const Spacer(),
          const Text(
            'EXPLORE THE WORLD\nIN YOUR OWN WAY.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.8,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 18, 25, 14),
      child: Row(
        children: [
          const Icon(Icons.public_rounded, color: gold, size: 24),
          const SizedBox(width: 10),
          const Text(
            'TravelMate',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            'YOUR NEXT CHAPTER STARTS HERE',
            style: TextStyle(
              color: muted.withValues(alpha: .8),
              fontSize: 10,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            backgroundColor: surfaceLight,
            child: Icon(Icons.person_outline, color: gold),
          ),
        ],
      ),
    );
  }

  Widget _currentPage() {
    switch (selectedTab) {
      case 1:
        return _explorePage();
      case 2:
        return _tripsPage();
      case 3:
        return _itineraryPage();
      case 4:
        return _budgetPage();
      default:
        return _dashboardPage();
    }
  }

  Widget _page(Widget child) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25, 12, 25, 35),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: child,
          ),
        ),
      );

  Widget _dashboardPage() {
    return _page(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heroBanner(),
          const SizedBox(height: 25),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _statCard('My trips', '${trips.length}', Icons.luggage_outlined),
              _statCard(
                'Travellers',
                '${trips.fold<int>(0, (sum, trip) => sum + trip.travelers)}',
                Icons.people_outline,
              ),
              _statCard(
                'Destinations',
                '${trips.map((trip) => trip.destination).toSet().length}',
                Icons.location_on_outlined,
              ),
            ],
          ),
          const SizedBox(height: 32),
          _sectionHeading('Handpicked destinations',
              'Beautiful places for your next escape'),
          const SizedBox(height: 16),
          _destinationGrid(destinations.take(4).toList()),
          const SizedBox(height: 30),
          _sectionHeading('Your upcoming trips', 'All your plans in one place'),
          const SizedBox(height: 14),
          if (trips.isEmpty)
            _emptyState(
              'Your next adventure is waiting',
              'Create a trip to start building your travel plans.',
              Icons.flight_outlined,
            )
          else
            ...trips.take(3).map(_tripCard),
        ],
      ),
    );
  }

  Widget _heroBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: SizedBox(
        height: 330,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=1600',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: surfaceLight),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: .78),
                    Colors.black.withValues(alpha: .25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DISCOVER • DREAM • DEPART',
                        style: TextStyle(
                          color: gold,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'The world is\nwaiting for you.',
                        style: TextStyle(
                          fontSize: 38,
                          height: 1.12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Plan meaningful journeys, collect moments and make every destination yours.',
                        style: TextStyle(color: Colors.white70, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _showAddTripDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Plan a trip'),
                        style: FilledButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: background,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: gold),
          ),
          const SizedBox(width: 13),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: muted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: muted, fontSize: 13)),
      ],
    );
  }

  Widget _destinationGrid(List<Destination> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 580
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: columns == 1 ? 1.45 : 0.88,
          ),
          itemBuilder: (context, index) => _destinationCard(items[index]),
        );
      },
    );
  }

  Widget _destinationCard(Destination destination) {
    return InkWell(
      borderRadius: BorderRadius.circular(19),
      onTap: () => _showDestination(destination),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              destination.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: surfaceLight),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .82),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(destination.country,
                      style: const TextStyle(
                          color: gold, fontSize: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(destination.name,
                      style: const TextStyle(
                          fontSize: 21, fontWeight: FontWeight.bold)),
                  Text('From ${destination.price}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Positioned(
              top: 13,
              right: 13,
              child: Icon(Icons.north_east, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _explorePage() {
    final filtered = destinations
        .where((d) =>
            d.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            d.country.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    return _page(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('Explore destinations',
              'Find inspiration for your next journey'),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: gold),
              hintText: 'Search places or countries...',
            ),
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            _emptyState('No destinations found',
                'Try another destination or country.', Icons.search_off)
          else
            _destinationGrid(filtered),
        ],
      ),
    );
  }

  void _showDestination(Destination destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(22),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  destination.image,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      Container(height: 190, color: surfaceLight),
                ),
              ),
              const SizedBox(height: 18),
              Text(destination.name,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold)),
              Text(destination.country,
                  style: const TextStyle(color: gold)),
              const SizedBox(height: 10),
              Text(destination.description,
                  style: const TextStyle(color: muted, height: 1.5)),
              const SizedBox(height: 12),
              Text('Estimated starting budget: ${destination.price}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddTripDialog();
                  },
                  child: const Text('Plan a trip here'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tripsPage() {
    return _page(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionHeading(
                    'My trips', 'Your saved journeys and travel plans'),
              ),
              FilledButton.icon(
                onPressed: _showAddTripDialog,
                icon: const Icon(Icons.add),
                label: const Text('New trip'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (trips.isEmpty)
            _emptyState('No trips planned yet',
                'Create your first trip and start organising your journey.',
                Icons.luggage_outlined)
          else
            ...trips.map(_tripCard),
        ],
      ),
    );
  }

  Widget _tripCard(Trip trip) {
    final destination = destinations
        .where((d) => d.name == trip.destination)
        .firstOrNull;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: destination == null
                  ? Container(
                      width: 105,
                      height: 95,
                      color: surfaceLight,
                      child: const Icon(Icons.landscape, color: gold),
                    )
                  : Image.network(
                      destination.image,
                      width: 105,
                      height: 95,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 105,
                        height: 95,
                        color: surfaceLight,
                      ),
                    ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.destination,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${trip.country} • ${trip.date}',
                      style: const TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    '${trip.travelers} travellers  •  ₹${trip.budget.toStringAsFixed(0)}',
                    style: const TextStyle(color: gold, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete trip',
              onPressed: () => _deleteTrip(trip.id),
              icon: const Icon(Icons.delete_outline, color: muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itineraryPage() {
    return _page(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
              'Itinerary planner', 'Add activities to each saved trip'),
          const SizedBox(height: 18),
          if (trips.isEmpty)
            _emptyState('Your itinerary is empty',
                'Create a trip first, then add activities here.',
                Icons.route_outlined)
          else
            ...trips.map((trip) => _itineraryTrip(trip)),
        ],
      ),
    );
  }

  Widget _itineraryTrip(Trip trip) {
    final controller = TextEditingController();
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trip.destination,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          Text(trip.date, style: const TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 12),
          if (trip.activities.isEmpty)
            const Text('No activities added yet.',
                style: TextStyle(color: muted, fontSize: 13)),
          ...trip.activities.asMap().entries.map(
                (entry) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline, color: gold),
                  title: Text(entry.value),
                  trailing: IconButton(
                    onPressed: () => _deleteActivity(trip, entry.key),
                    icon: const Icon(Icons.close, color: muted, size: 18),
                  ),
                ),
              ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Add an activity...',
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    _addActivity(trip, value);
                    controller.clear();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  _addActivity(trip, controller.text);
                  controller.clear();
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _budgetPage() {
    final total = trips.fold<double>(0, (sum, trip) => sum + trip.budget);
    return _page(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
              'Travel budget', 'A simple overview of your planned trip budgets'),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF27364A), Color(0xFF151E2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL PLANNED BUDGET',
                    style: TextStyle(
                        color: muted, fontSize: 11, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 34, fontWeight: FontWeight.bold, color: gold),
                ),
                const SizedBox(height: 6),
                Text('${trips.length} saved trip(s)',
                    style: const TextStyle(color: muted)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _sectionHeading('Budget by trip', 'Your estimated budgets'),
          const SizedBox(height: 12),
          if (trips.isEmpty)
            _emptyState('No budgets yet',
                'Add a trip with an estimated budget to see it here.',
                Icons.account_balance_wallet_outlined)
          else
            ...trips.map((trip) {
              final share = total <= 0 ? 0.0 : trip.budget / total;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(trip.destination,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Text('₹${trip.budget.toStringAsFixed(0)}',
                            style: const TextStyle(color: gold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: share.clamp(0.0, 1.0),
                        minHeight: 7,
                        backgroundColor: surfaceLight,
                        color: gold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 10),
          const Text(
            'Note: These are planned budget estimates, not recorded expenses.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 35),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: gold),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 13)),
        ],
      ),
    );
  }
}
