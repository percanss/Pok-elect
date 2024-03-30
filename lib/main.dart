import 'package:flutter/material.dart';
import 'db.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elecciones Liga Pokémon',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headline6: TextStyle(color: Colors.red),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: EventListScreen(),
    );
  }
}

class Event {
  int? id;
  DateTime date;
  String title;
  String description;
  File? imageFile;

  Event({
    this.id,
    required this.date,
    required this.title,
    required this.description,
    this.imageFile,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    List<Event> loadedEvents = await DatabaseHelper.instance.getAllEvents();
    setState(() {
      events = loadedEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poki-Eventos electorales'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: const Text('Poki-Eventos'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Poke-Liberar'),
              onTap: () {
                Navigator.pop(context);
                _showConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(events[index].title),
            subtitle: Text(events[index].description),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EventDetailsScreen(event: events[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventScreen()),
          ).then((value) {
            if (value != null && value is Event) {
              _loadEvents();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: const Text(
              "¿Estás seguro de que deseas eliminar todos los eventos?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteAllEvents();
                _loadEvents();
                Navigator.of(context).pop();
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }
}

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late DateTime _selectedDate;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Mote de evento'),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Lore del evento'),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Poke-ilustración:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => _getImage(),
              child: const Text('Poke-imagen'),
            ),
            _imageFile != null
                ? Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const SizedBox(height: 0),
            const SizedBox(height: 20.0),
            const Text(
              'Fecha:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text("Seleccionar fecha: ${_selectedDate.toLocal()}"
                  .split(' ')[0]),
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () async {
                Event newEvent = Event(
                  date: _selectedDate,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  imageFile: _imageFile,
                );
                int eventId =
                    await DatabaseHelper.instance.insertEvent(newEvent);
                newEvent.id = eventId;
                Navigator.pop(context, newEvent);
              },
              child: const Text('Agregar Poke-situacion'),
            ),
          ],
        ),
      ),
    );
  }
}

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  EventDetailsScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Poke-Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              event.title,
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            Text(
              event.description,
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 12.0),
            event.imageFile != null
                ? Image.file(
                    event.imageFile!,
                    height: 200.0,
                    fit: BoxFit.cover,
                  )
                : const SizedBox(),
            const SizedBox(height: 20.0),
            Text(
              'Fecha: ${event.date.toString()}',
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/8.jpg'),
            ),
            SizedBox(height: 20),
            Text(
              'Jose Dipre 2020-10345',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'En la pokedemocracia, cada entrenador tiene el poder de elegir el camino de su equipo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
