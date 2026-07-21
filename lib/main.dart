import 'package:flutter/material.dart';

void main() {
  runApp(const CivilWorkManagerApp());
}

class CivilWorkManagerApp extends StatelessWidget {
  const CivilWorkManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katta Pani',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katta Pani - Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildGridButton(
                    context,
                    'Work List',
                    Icons.assignment,
                    'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?q=80&w=300&auto=format&fit=crop',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildGridButton(
                    context,
                    'Inspection Notes',
                    Icons.analytics,
                    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?q=80&w=300&auto=format&fit=crop',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InspectionNotesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildGridButton(
                    context,
                    'Upcoming Events',
                    Icons.event,
                    'https://images.unsplash.com/photo-1531834685032-c34bf0d8b999?q=80&w=300&auto=format&fit=crop',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UpcomingEventsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildGridButton(
                    context,
                    'Checklist',
                    Icons.playlist_add_check,
                    'https://images.unsplash.com/photo-1581094288338-2314dddb7ece?q=80&w=300&auto=format&fit=crop',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChecklistEventsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildGridButton(
                    context,
                    'Daily Diary',
                    Icons.book,
                    'https://images.unsplash.com/photo-1517842645767-c639042777db?q=80&w=300&auto=format&fit=crop',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DailyDiaryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildGridButton(
                    context,
                    'Add New',
                    Icons.add_circle_outline,
                    'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?q=80&w=300&auto=format&fit=crop',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Custom feature addition coming soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(BuildContext context, String title, IconData icon,
      String imageUrl, VoidCallback onPressed) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.blue.shade50),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 1. WORK LIST SCREEN (Updated with Name, LOA, Currency, Bill Status, Site Order, Daily Progress & Add Provision) ---
class WorkListScreen extends StatefulWidget {
  const WorkListScreen({super.key});

  @override
  State<WorkListScreen> createState() => _WorkListScreenState();
}

class _WorkListScreenState extends State<WorkListScreen> {
  final List<Map<String, String>> _works = [
    {
      'name': 'Site Excavation',
      'loa': 'LOA-001',
      'currency': 'INR',
      'billStatus': 'Paid',
      'siteOrder': 'SO-101',
      'dailyProgress': '50% Completed'
    },
    {
      'name': 'Foundation Work',
      'loa': 'LOA-002',
      'currency': 'INR',
      'billStatus': 'Pending',
      'siteOrder': 'SO-102',
      'dailyProgress': '20% Completed'
    },
  ];

  void _addNewWork() {
    final nameController = TextEditingController();
    final loaController = TextEditingController();
    final currencyController = TextEditingController();
    final billStatusController = TextEditingController();
    final siteOrderController = TextEditingController();
    final progressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Work'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: loaController, decoration: const InputDecoration(labelText: 'LOA')),
              TextField(controller: currencyController, decoration: const InputDecoration(labelText: 'Currency')),
              TextField(controller: billStatusController, decoration: const InputDecoration(labelText: 'Bill Status')),
              TextField(controller: siteOrderController, decoration: const InputDecoration(labelText: 'Site Order')),
              TextField(controller: progressController, decoration: const InputDecoration(labelText: 'Daily Progress')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _works.add({
                    'name': nameController.text,
                    'loa': loaController.text,
                    'currency': currencyController.text,
                    'billStatus': billStatusController.text,
                    'siteOrder': siteOrderController.text,
                    'dailyProgress': progressController.text,
                  });
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewWork,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _works.length,
        itemBuilder: (context, index) {
          final work = _works[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(work['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const Divider(),
                  Text('LOA: ${work['loa']}'),
                  Text('Currency: ${work['currency']}'),
                  Text('Bill Status: ${work['billStatus']}'),
                  Text('Site Order: ${work['siteOrder']}'),
                  Text('Daily Progress: ${work['dailyProgress']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- 2. INSPECTION NOTES SCREEN ---
class InspectionNotesScreen extends StatelessWidget {
  const InspectionNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notes = [
      {'site': 'Block A', 'note': 'Check reinforcement spacing before pouring slab.', 'date': '2026-07-18'},
      {'site': 'Block B', 'note': 'Curing process needs to be improved for columns.', 'date': '2026-07-19'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Notes')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.analytics, color: Colors.orange),
              title: Text(notes[index]['site']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${notes[index]['note']}\nDate: ${notes[index]['date']}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

// --- 3. UPCOMING EVENTS SCREEN (Updated with Inspection Block & Add Provision) ---
class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  final List<Map<String, String>> _events = [
    {'title': 'Client Site Visit', 'inspectionBlock': 'Block A', 'date': '2026-07-25', 'time': '10:00 AM'},
    {'title': 'Material Quality Inspection', 'inspectionBlock': 'Block B', 'date': '2026-07-27', 'time': '02:00 PM'},
  ];

  void _addEvent() {
    final titleController = TextEditingController();
    final blockController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Upcoming Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Event Title')),
              TextField(controller: blockController, decoration: const InputDecoration(labelText: 'Inspection Block')),
              TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Date')),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _events.add({
                    'title': titleController.text,
                    'inspectionBlock': blockController.text,
                    'date': dateController.text,
                    'time': timeController.text,
                  });
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addEvent),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.green),
              title: Text(event['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Inspection Block: ${event['inspectionBlock']}\nDate: ${event['date']} at ${event['time']}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

// --- CHECKLIST EVENTS SCREEN ---
class ChecklistEventsScreen extends StatefulWidget {
  const ChecklistEventsScreen({super.key});

  @override
  State<ChecklistEventsScreen> createState() => _ChecklistEventsScreenState();
}

class _ChecklistEventsScreenState extends State<ChecklistEventsScreen> {
  final List<String> _events = ['Foundation Work', 'First Floor Slab'];
  final TextEditingController _eventController = TextEditingController();

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Checklist Event'),
        content: TextField(
            controller: _eventController,
            decoration: const InputDecoration(hintText: 'Event Name')),
        actions: [
          TextButton(
            onPressed: () {
              if (_eventController.text.isNotEmpty) {
                setState(() {
                  _events.add(_eventController.text);
                });
                _eventController.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist Events'),
        actions: [
          IconButton(onPressed: _addEvent, icon: const Icon(Icons.add))
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_events[index], style: const TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChecklistItemsScreen(eventName: _events[index]))),
            ),
          );
        },
      ),
    );
  }
}

// --- CHECKLIST ITEMS SCREEN (Updated with Checkbox column on the side) ---
class ChecklistItemsScreen extends StatefulWidget {
  final String eventName;
  const ChecklistItemsScreen({super.key, required this.eventName});

  @override
  State<ChecklistItemsScreen> createState() => _ChecklistItemsScreenState();
}

class _ChecklistItemsScreenState extends State<ChecklistItemsScreen> {
  final List<Map<String, dynamic>> _items = [
    {'title': 'Shuttering & Formwork Verification', 'checked': false},
    {'title': 'Reinforcement Steel Spacing Check', 'checked': false},
    {'title': 'Cover Block Placement', 'checked': false}
  ];
  final TextEditingController _itemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _itemController,
                        decoration: const InputDecoration(
                            hintText: 'Enter new check item'))),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_itemController.text.isNotEmpty) {
                      setState(() {
                        _items.add(
                            {'title': _itemController.text, 'checked': false});
                      });
                      _itemController.clear();
                    }
                  },
                  child: const Text('Add Item'),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _items[index]['title'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          // Side Checkbox Column Provision
                          Checkbox(
                            value: _items[index]['checked'],
                            onChanged: (val) {
                              setState(() {
                                _items[index]['checked'] = val ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- DAILY DIARY SCREEN ---
class DailyDiaryScreen extends StatefulWidget {
  const DailyDiaryScreen({super.key});

  @override
  State<DailyDiaryScreen> createState() => _DailyDiaryScreenState();
}

class _DailyDiaryScreenState extends State<DailyDiaryScreen> {
  final TextEditingController _diaryController = TextEditingController();
  String _location = '';
  String _reminderTime = '09:00 PM';
  bool _isReminderOn = true;

  void _fetchLocation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text('Allow Katta Pani to access this device\'s location?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Deny')),
          TextButton(
            onPressed: () {
              setState(() {
                _location = 'Kozhikode, Kerala - Verified via GPS';
              });
              Navigator.pop(context);
            },
            child: const Text('Allow'),
          )
        ],
      ),
    );
  }

  void _selectTime() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: ['08:00 PM', '09:00 PM', '10:00 PM', '11:00 PM'].map((time) {
          return ListTile(
            title: Text(time),
            onTap: () {
              setState(() {
                _reminderTime = time;
              });
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Diary')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.blue),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _selectTime,
                      child: Text('Daily Reminder Set for $_reminderTime',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    Switch(
                        value: _isReminderOn,
                        onChanged: (val) {
                          setState(() {
                            _isReminderOn = val;
                          });
                        })
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text('Attach Site Photo'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _diaryController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Observations / Work Done',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {
                    _diaryController.text =
                        "Concrete pouring completed for slab 2 without any deflection.";
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                    onPressed: _fetchLocation,
                    child: const Text('Fetch Location')),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(_location,
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50)),
              onPressed: () {},
              child: const Text('Save Diary Entry',
                  style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
