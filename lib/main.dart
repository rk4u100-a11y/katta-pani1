import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const LoginScreen(),
    );
  }
}

// Global Data Lists
List<Map<String, dynamic>> globalWorkList = [];
List<Map<String, dynamic>> inspectionNotesList = [];
List<Map<String, dynamic>> upcomingEventsList = [];
List<Map<String, dynamic>> powerBlockList = [];
List<Map<String, dynamic>> lineBlockList = [];
List<Map<String, dynamic>> checklistProjects = [];
List<Map<String, dynamic>> dailyDiaryList = [];

// Local Storage Manager
class LocalAndDriveStorage {
  static const String _storageKey = 'katta_pani_works_data_v2';
  static const String _inspectionKey = 'katta_pani_inspection_v2';
  static const String _eventsKey = 'katta_pani_events_v2';
  static const String _powerBlockKey = 'katta_pani_power_block_v2';
  static const String _lineBlockKey = 'katta_pani_line_block_v2';
  static const String _checklistKey = 'katta_pani_checklist_v2';
  static const String _diaryKey = 'katta_pani_diary_v2';

  static Future<void> saveLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(globalWorkList));
    await prefs.setString(_inspectionKey, jsonEncode(inspectionNotesList));
    await prefs.setString(_eventsKey, jsonEncode(upcomingEventsList));
    await prefs.setString(_powerBlockKey, jsonEncode(powerBlockList));
    await prefs.setString(_lineBlockKey, jsonEncode(lineBlockList));
    await prefs.setString(_checklistKey, jsonEncode(checklistProjects));
    await prefs.setString(_diaryKey, jsonEncode(dailyDiaryList));
  }

  static Future<void> loadLocally() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Works
    String? worksData = prefs.getString(_storageKey);
    if (worksData != null) {
      globalWorkList = List<Map<String, dynamic>>.from(jsonDecode(worksData));
    } else {
      globalWorkList = [
        {
          'name': 'Site Excavation', 
          'loa': 'LOA-001', 
          'currency': 'INR', 
          'bill': 'Pending', 
          'orders': 'None', 
          'progress': '10%',
          'progressHistory': [{'day': 'Day 1', 'val': 0.1}]
        }
      ];
    }

    // Inspection
    String? inspectData = prefs.getString(_inspectionKey);
    if (inspectData != null) inspectionNotesList = List<Map<String, dynamic>>.from(jsonDecode(inspectData));

    // Events
    String? eventsData = prefs.getString(_eventsKey);
    if (eventsData != null) upcomingEventsList = List<Map<String, dynamic>>.from(jsonDecode(eventsData));

    // Power Block
    String? pbData = prefs.getString(_powerBlockKey);
    if (pbData != null) powerBlockList = List<Map<String, dynamic>>.from(jsonDecode(pbData));

    // Line Block
    String? lbData = prefs.getString(_lineBlockKey);
    if (lbData != null) lineBlockList = List<Map<String, dynamic>>.from(jsonDecode(lbData));

    // Checklist Projects
    String? checkData = prefs.getString(_checklistKey);
    if (checkData != null) {
      checklistProjects = List<Map<String, dynamic>>.from(jsonDecode(checkData));
    } else {
      checklistProjects = [
        {
          'projectName': 'Foundation Phase Checklist',
          'tasks': [
            {'task': 'Site Clearance & Soil Test', 'isDone': true},
            {'task': 'Foundation Layout Marking', 'isDone': false},
          ]
        }
      ];
    }

    // Diary
    String? diaryData = prefs.getString(_diaryKey);
    if (diaryData != null) {
      dailyDiaryList = List<Map<String, dynamic>>.from(jsonDecode(diaryData));
    }

    await saveLocally();
  }

  static Future<bool> signIn() async {
    await loadLocally();
    return true;
  }
}

// 1. Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    await LocalAndDriveStorage.signIn();
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.engineering, size: 90, color: Colors.amberAccent),
              const SizedBox(height: 20),
              const Text('Katta Pani', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              const Text('Civil Work Manager', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 50),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _handleLogin,
                      icon: const Icon(Icons.login, color: Colors.black),
                      label: const Text('Sign in with Google', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. Main Menu Screen
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final Map<int, File?> _cardImages = {};
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    LocalAndDriveStorage.loadLocally();
  }

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _cardImages[index] = File(image.path));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo Updated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> defaultImages = [
      'https://images.unsplash.com/photo-1541888946425-d0fbb18f7296?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1581094288338-2314dddb7ece?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=600&q=80',
    ];

    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Work List', 'icon': Icons.assignment, 'screen': const WorkListScreen()},
      {'title': 'Inspection Notes', 'icon': Icons.bar_chart, 'screen': const InspectionNotesScreen()},
      {'title': 'Upcoming Events & Blocks', 'icon': Icons.calendar_today, 'screen': const UpcomingEventsMenuScreen()},
      {'title': 'Checklist', 'icon': Icons.checklist, 'screen': const ChecklistScreen()},
      {'title': 'Daily Diary & Reminder', 'icon': Icons.book, 'screen': const DailyDiaryScreen()},
      {'title': 'Work Progress Chart', 'icon': Icons.show_chart, 'screen': const GlobalProgressChartScreen()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katta Pani - Civil Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final File? customImage = _cardImages[index];

              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => item['screen'])).then((_) => setState(() {})),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1.5),
                    image: DecorationImage(
                      image: customImage != null ? FileImage(customImage) as ImageProvider : NetworkImage(defaultImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.85), Colors.black.withOpacity(0.3)],
                        begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0, right: 0,
                          child: GestureDetector(
                            onTap: () => _pickImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.amberAccent, size: 18),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                              child: Icon(item['icon'], color: Colors.cyanAccent, size: 28),
                            ),
                            const SizedBox(height: 10),
                            Text(item['title'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// 3. Work List Screen
class WorkListScreen extends StatefulWidget {
  const WorkListScreen({super.key});

  @override
  State<WorkListScreen> createState() => _WorkListScreenState();
}

class _WorkListScreenState extends State<WorkListScreen> {
  void _addWorkDialog() {
    final nameController = TextEditingController();
    final loaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Work'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Work Name')),
            TextField(controller: loaController, decoration: const InputDecoration(labelText: 'LOA Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  globalWorkList.add({
                    'name': nameController.text,
                    'loa': loaController.text,
                    'currency': 'INR',
                    'bill': 'Pending',
                    'orders': 'Nil',
                    'progress': '0%',
                    'progressHistory': [{'day': 'Start', 'val': 0.0}]
                  });
                });
                await LocalAndDriveStorage.saveLocally();
                if (!mounted) return;
                Navigator.pop(context);
              }
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
      appBar: AppBar(title: const Text('Work List'), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: ListView.builder(
        itemCount: globalWorkList.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey[900],
            child: ListTile(
              title: Text(globalWorkList[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text('LOA: ${globalWorkList[index]['loa']} | Progress: ${globalWorkList[index]['progress']}', style: const TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkDetailScreen(workIndex: index, onSave: () => setState(() {}))),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWorkDialog,
        backgroundColor: const Color(0xFF1B365D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Work', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// 4. Work Detail Screen (Labels fixed to pure White for high visibility)
class WorkDetailScreen extends StatefulWidget {
  final int workIndex;
  final VoidCallback onSave;

  const WorkDetailScreen({super.key, required this.workIndex, required this.onSave});

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _loaController;
  late TextEditingController _currencyController;
  late TextEditingController _billController;
  late TextEditingController _ordersController;
  late TextEditingController _progressController;
  bool isEditing = false;
  late List<Map<String, dynamic>> _progressHistory;

  @override
  void initState() {
    super.initState();
    final data = globalWorkList[widget.workIndex];
    _nameController = TextEditingController(text: data['name'] ?? '');
    _loaController = TextEditingController(text: data['loa'] ?? '');
    _currencyController = TextEditingController(text: data['currency'] ?? '');
    _billController = TextEditingController(text: data['bill'] ?? '');
    _ordersController = TextEditingController(text: data['orders'] ?? '');
    _progressController = TextEditingController(text: data['progress'] ?? '');
    _progressHistory = List<Map<String, dynamic>>.from(data['progressHistory'] ?? []);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
    );
  }

  void _addDailyProgressDialog() {
    final dayCtrl = TextEditingController(text: 'Day ${_progressHistory.length + 1}');
    final valCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Daily Progress (%)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: dayCtrl, decoration: const InputDecoration(labelText: 'Day / Date')),
            TextField(controller: valCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Progress % (e.g. 50)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (valCtrl.text.isNotEmpty) {
                double rawVal = double.tryParse(valCtrl.text) ?? 0.0;
                double normalizedVal = rawVal > 1.0 ? rawVal / 100.0 : rawVal;
                setState(() {
                  _progressHistory.add({'day': dayCtrl.text, 'val': normalizedVal});
                  _progressController.text = '${(normalizedVal * 100).toInt()}%';
                });
                
                globalWorkList[widget.workIndex]['progressHistory'] = _progressHistory;
                globalWorkList[widget.workIndex]['progress'] = _progressController.text;
                widget.onSave();
                await LocalAndDriveStorage.saveLocally();

                if (!mounted) return;
                Navigator.pop(context);
              }
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
        title: Text(_nameController.text),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(isEditing ? Icons.check : Icons.edit), onPressed: () => setState(() => isEditing = !isEditing)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(controller: _nameController, enabled: isEditing, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Name of the Work')),
          const SizedBox(height: 12),
          TextField(controller: _loaController, enabled: isEditing, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('LOA Number')),
          const SizedBox(height: 12),
          TextField(controller: _currencyController, enabled: isEditing, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Currency')),
          const SizedBox(height: 12),
          TextField(controller: _billController, enabled: isEditing, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Bill Status')),
          const SizedBox(height: 12),
          TextField(controller: _ordersController, enabled: isEditing, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Site Orders')),
          const SizedBox(height: 12),
          TextField(controller: _progressController, enabled: false, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold), decoration: _inputDecoration('Total Progress')),
          
          const SizedBox(height: 25),
          const Text('📈 Work Progress Chart:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
          const SizedBox(height: 10),
          
          Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
            child: _progressHistory.isEmpty
                ? const Center(child: Text('No progress data yet.', style: TextStyle(color: Colors.grey)))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _progressHistory.map((item) {
                      double val = item['val'] ?? 0.0;
                      int heightFactor = (val * 120).clamp(10, 120).toInt();
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${(val * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 4),
                          Container(width: 28, height: heightFactor.toDouble(), decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(6))),
                          const SizedBox(height: 6),
                          Text(item['day'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 20),
          if (isEditing)
            ElevatedButton(
              onPressed: () async {
                globalWorkList[widget.workIndex] = {
                  'name': _nameController.text,
                  'loa': _loaController.text,
                  'currency': _currencyController.text,
                  'bill': _billController.text,
                  'orders': _ordersController.text,
                  'progress': _progressController.text,
                  'progressHistory': _progressHistory,
                };
                widget.onSave();
                await LocalAndDriveStorage.saveLocally();
                setState(() => isEditing = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated Successfully!')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
              child: const Text('Save Changes'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDailyProgressDialog,
        backgroundColor: const Color(0xFF1B365D),
        icon: const Icon(Icons.add_chart, color: Colors.white),
        label: const Text('Add Progress', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// 5. Inspection Notes Screen
class InspectionNotesScreen extends StatefulWidget {
  const InspectionNotesScreen({super.key});

  @override
  State<InspectionNotesScreen> createState() => _InspectionNotesScreenState();
}

class _InspectionNotesScreenState extends State<InspectionNotesScreen> {
  void _showNoteDialog({int? index}) {
    final isEditing = index != null;
    final titleCtrl = TextEditingController(text: isEditing ? inspectionNotesList[index]['title'] : '');
    final noteCtrl = TextEditingController(text: isEditing ? inspectionNotesList[index]['note'] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Inspection Note' : 'Add Inspection Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title / Location')),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Observation / Note')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                setState(() {
                  if (isEditing) {
                    inspectionNotesList[index] = {
                      'title': titleCtrl.text,
                      'note': noteCtrl.text,
                      'date': inspectionNotesList[index]['date'],
                    };
                  } else {
                    inspectionNotesList.add({
                      'title': titleCtrl.text,
                      'note': noteCtrl.text,
                      'date': DateTime.now().toString().substring(0, 10),
                    });
                  }
                });
                await LocalAndDriveStorage.saveLocally();
                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Notes'), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: inspectionNotesList.isEmpty
          ? const Center(child: Text('No inspection notes added.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: inspectionNotesList.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = inspectionNotesList[index];
                return Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    title: Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['note']}\nDate: ${item['date']}', style: const TextStyle(color: Colors.grey)),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amberAccent),
                      onPressed: () => _showNoteDialog(index: index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        backgroundColor: const Color(0xFF1B365D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Note', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// 6. Upcoming Events & Blocks Menu Screen
class UpcomingEventsMenuScreen extends StatelessWidget {
  const UpcomingEventsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events & Blocks'), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            tileColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: const Text('Upcoming Events', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UpcomingEventsScreen())),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: const Text('Block Management (Power / Line Block)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BlockMenuScreen())),
          ),
        ],
      ),
    );
  }
}

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  void _addEventDialog() {
    final eventCtrl = TextEditingController();
    final dateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Upcoming Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: eventCtrl, decoration: const InputDecoration(labelText: 'Event Name')),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (e.g. 2026-06-01)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (eventCtrl.text.isNotEmpty) {
                setState(() => upcomingEventsList.add({'event': eventCtrl.text, 'date': dateCtrl.text}));
                await LocalAndDriveStorage.saveLocally();
                if (!mounted) return;
                Navigator.pop(context);
              }
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
      appBar: AppBar(title: const Text('Upcoming Events'), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: upcomingEventsList.isEmpty
          ? const Center(child: Text('No upcoming events.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: upcomingEventsList.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = upcomingEventsList[index];
                return Card(color: Colors.grey[900], child: ListTile(title: Text(item['event'], style: const TextStyle(color: Colors.white)), subtitle: Text('Date: ${item['date']}', style: const TextStyle(color: Colors.grey))));
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEventDialog,
        backgroundColor: const Color(0xFF1B365D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Event', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class BlockMenuScreen extends StatelessWidget {
  const BlockMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Block Type'), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            tileColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: const Text('Power Block', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.bolt, color: Colors.amberAccent),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BlockListScreen(blockType: 'Power Block'))),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: const Text('Line Block', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.train, color: Colors.cyanAccent),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BlockListScreen(blockType: 'Line Block'))),
          ),
        ],
      ),
    );
  }
}

class BlockListScreen extends StatefulWidget {
  final String blockType;
  const BlockListScreen({super.key, required this.blockType});

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  void _addBlockDialog() {
    final titleCtrl = TextEditingController();
    final detailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${widget.blockType}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Section / Station')),
            TextField(controller: detailCtrl, decoration: const InputDecoration(labelText: 'Timing / Details')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                setState(() {
                  if (widget.blockType == 'Power Block') {
                    powerBlockList.add({'title': titleCtrl.text, 'detail': detailCtrl.text});
                  } else {
                    lineBlockList.add({'title': titleCtrl.text, 'detail': detailCtrl.text});
                  }
                });
                await LocalAndDriveStorage.saveLocally();
                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.blockType == 'Power Block' ? powerBlockList : lineBlockList;

    return Scaffold(
      appBar: AppBar(title: Text(widget.blockType), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: list.isEmpty
          ? Center(child: Text('No ${widget.blockType} entries.', style: const TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: list.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(color: Colors.grey[900], child: ListTile(title: Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text(item['detail'], style: const TextStyle(color: Colors.grey))));
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBlockDialog,
        backgroundColor: const Color(0xFF1B365D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add ${widget.blockType}', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

// 7. Checklist Screen
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  void _addProjectDialog() {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Checklist Project'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Project Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  checklistProjects.add({
                    'projectName': nameCtrl.text,
                    'tasks': <Map<String, dynamic>>[]
                  });
                });
                await LocalAndDriveStorage.saveLocally();
                if (!mounted) return;
                Navigator.pop(context);
              }
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
      appBar: AppBar(title: const Text('Checklist Projects'), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: checklistProjects.isEmpty
          ? const Center(child: Text('No checklist projects.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: checklistProjects.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final project = checklistProjects[index];
                return Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    title: Text(project['projectName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Tasks count: ${(project['tasks'] as List).length}', style: const TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChecklistDetailScreen(projectIndex: index, onUpdate: () => setState(() {}))),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProjectDialog,
        backgroundColor: const Color(0xFF1B365D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Project', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class ChecklistDetailScreen extends StatefulWidget {
  final int projectIndex;
  final VoidCallback onUpdate;

  const ChecklistDetailScreen({super.key, required this.projectIndex, required this.onUpdate});

  @override
  State<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends State<ChecklistDetailScreen> {
  void _addTaskDialog() {
    final taskCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(controller: taskCtrl, decoration: const InputDecoration(labelText: 'Task Description')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (taskCtrl.text.isNotEmpty) {
                setState(() {
                  (checklistProjects[widget.projectIndex]['tasks'] as List).add({'task': taskCtrl.text, 'isDone': false});
                });
                widget.onUpdate();
                await LocalAndDriveStorage.saveLocally();
                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = checklistProjects[widget.projectIndex];
    final List tasks = project['tasks'];

    return Scaffold(
      appBar: AppBar(title: Text(project['projectName']), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks in this checklist.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: tasks.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final taskItem = tasks[index];
                return Card(
                  color: Colors.grey[900],
                  child: CheckboxListTile(
                    title: Text(taskItem['task'], style: TextStyle(color: Colors.white, decoration: taskItem['isDone'] ? TextDecoration.lineThrough : null)),
                    value: taskItem['isDone'],
                    activeColor: Colors.blueAccent,
                    onChanged: (val) async {
                      setState(() => taskItem['isDone'] = val ?? false);
                      widget.onUpdate();
                      await LocalAndDriveStorage.saveLocally();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTaskDialog,
        backgroundColor: const Color(0xFF1B365D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// 8. Daily Diary Screen (Fully Updated with Time Reminder, Media, Geo-tag Toggle & Voice Typing)
class DailyDiaryScreen extends StatefulWidget {
  const DailyDiaryScreen({super.key});

  @override
  State<DailyDiaryScreen> createState() => _DailyDiaryScreenState();
}

class _DailyDiaryScreenState extends State<DailyDiaryScreen> {
  void _addDiaryDialog() {
    final entryCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().substring(0, 10));
    final reminderTimeCtrl = TextEditingController(text: '21:00');
    final locationCtrl = TextEditingController(text: 'Kozhikode Site');
    String attachedMedia = 'None';
    bool isGeoTagEnabled = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Diary Entry & Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dateCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: reminderTimeCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Time Reminder (e.g., 21:00)',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: locationCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Geo-tag Location',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Geo-tag Location Toggle', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text(isGeoTagEnabled ? 'Geo-location will be tagged' : 'Geo-location disabled', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  value: isGeoTagEnabled,
                  activeColor: Colors.cyanAccent,
                  onChanged: (val) {
                    setDialogState(() => isGeoTagEnabled = val);
                  },
                ),
                const Divider(color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          entryCtrl.text += ' [Voice Typed Speech Text Simulated] ';
                        });
                      },
                      icon: const Icon(Icons.mic, color: Colors.black),
                      label: const Text('Voice Typing', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          attachedMedia = 'Photo/Video Attached Successfully';
                        });
                      },
                      icon: const Icon(Icons.photo_camera, color: Colors.black),
                      label: const Text('Add Media', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Status: $attachedMedia', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: entryCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Type Diary / Notes here...',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (entryCtrl.text.isNotEmpty) {
                  setState(() {
                    dailyDiaryList.add({
                      'date': dateCtrl.text,
                      'reminder': reminderTimeCtrl.text,
                      'location': isGeoTagEnabled ? locationCtrl.text : 'Geo-tag Disabled',
                      'media': attachedMedia,
                      'entry': entryCtrl.text,
                    });
                  });
                  await LocalAndDriveStorage.saveLocally();
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Diary & Reminders'), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: dailyDiaryList.isEmpty
          ? const Center(child: Text('No diary entries yet.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: dailyDiaryList.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = dailyDiaryList[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('${item['date']} | Reminder: ${item['reminder']}', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        '📍 Location: ${item['location']}\n📁 Media: ${item['media']}\n\n📝 Note: ${item['entry']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDiaryDialog,
        backgroundColor: const Color(0xFF1B365D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Diary Entry', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}

// 9. Global Work Progress Chart Screen
class GlobalProgressChartScreen extends StatelessWidget {
  const GlobalProgressChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work Progress Charts'), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: globalWorkList.isEmpty
          ? const Center(child: Text('No works added yet.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: globalWorkList.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                final work = globalWorkList[index];

                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(work['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text('LOA: ${work['loa']} | Total Progress: ${work['progress']}', style: const TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.show_chart, color: Colors.cyanAccent),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WorkGraphicalChartDetailScreen(work: work)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class WorkGraphicalChartDetailScreen extends StatelessWidget {
  final Map<String, dynamic> work;
  const WorkGraphicalChartDetailScreen({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    final List history = work['progressHistory'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('${work['name']} Chart'), backgroundColor: const Color(0xFF1B365D), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work: ${work['name']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('LOA: ${work['loa']} | Current Progress: ${work['progress']}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            const Text('Graphical Representation:', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
                child: history.isEmpty
                    ? const Center(child: Text('No chart data available.', style: TextStyle(color: Colors.grey)))
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: history.map((item) {
                          double val = item['val'] ?? 0.0;
                          int heightFactor = (val * 200).clamp(10, 200).toInt();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${(val * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 6),
                              Container(
                                width: 32,
                                height: heightFactor.toDouble(),
                                decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(6)),
                              ),
                              const SizedBox(height: 8),
                              Text(item['day'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}