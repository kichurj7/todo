// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:todonotification/models/todo.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;


// void main() async {
//   await Hive.initFlutter();
//   tz.initializeTimeZones(); // Initialize timezone data
//   Hive.registerAdapter(TodoAdapter());
//   await Hive.openBox<Todo>('todos');
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       //debugShowCheckedModeBanner: false,
//       home: TodoHomePage(),
//     );
//   }
// }

// class TodoHomePage extends StatefulWidget {
//   @override
//   _TodoHomePageState createState() => _TodoHomePageState();
// }

// class _TodoHomePageState extends State<TodoHomePage> {
//    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
    

//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//       flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
//   }

//   void _initializeNotifications() async {
//     const initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

  

//   Future<void> _scheduleNotification(Todo todo) async {
//     // Convert DateTime to TZDateTime
//   final tzDateTime = tz.TZDateTime.from(todo.notificationTime, tz.local);
//     const androidDetails = AndroidNotificationDetails(
//       'todo_channel_id',
//       'Todo Notifications',
//       channelDescription: 'This channel is used for to-do notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const notificationDetails = NotificationDetails(android: androidDetails);
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//      0,
//     "Reminder: ${todo.title}",
//     todo.description,
//     tzDateTime,
//     notificationDetails,
//     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Todo App with Notifications'),
//       ),
//       body: ValueListenableBuilder<Box<Todo>>(
//         valueListenable: Hive.box<Todo>('todos').listenable(),
//         builder: (context, box, _) {
//           final todos = box.values.toList().cast<Todo>();
//           return ListView.builder(
//             itemCount: todos.length,
//             itemBuilder: (context, index) {
//               final todo = todos[index];
//               return ListTile(
//                 title: Text(todo.title),
//                 subtitle: Text(todo.description),
//                 trailing: Text(
//                     '${todo.notificationTime.hour}:${todo.notificationTime.minute}'),
//                 onTap: () {
//                   _scheduleNotification(todo);
//                 },
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showAddTodoDialog(context);
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   void _showAddTodoDialog(BuildContext context) {
//     final titleController = TextEditingController();
//     final descriptionController = TextEditingController();
//     DateTime selectedTime = DateTime.now();
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Add Todo'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: titleController,
//                 decoration: InputDecoration(labelText: 'Title'),
//               ),
//               TextField(
//                 controller: descriptionController,
//                 decoration: InputDecoration(labelText: 'Description'),
//               ),
//               ListTile(
//                 title: Text('Set Notification Time'),
//                 subtitle: Text('${selectedTime.hour}:${selectedTime.minute}'),
//                 onTap: () async {
//                   final TimeOfDay? time = await showTimePicker(
//                     context: context,
//                     initialTime: TimeOfDay.fromDateTime(selectedTime),
//                   );
//                   if (time != null) {
//                     setState(() {
//                       selectedTime = DateTime(
//                         selectedTime.year,
//                         selectedTime.month,
//                         selectedTime.day,
//                         time.hour,
//                         time.minute,
//                       );
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 final todo = Todo(
//                   title: titleController.text,
//                   description: descriptionController.text,
//                   notificationTime: selectedTime,
//                 );
//                 Hive.box<Todo>('todos').add(todo);
//                 Navigator.of(context).pop();
//               },
//               child: Text('Save'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final TextEditingController _taskController = TextEditingController();
  final List<Map<String, dynamic>> _tasks = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin(
        
      );
      

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(String task, DateTime time) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('todo_channel', 'To-Do Notifications',
            channelDescription: 'Channel for To-Do app notifications',
            importance: Importance.high,
            priority: Priority.high);

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);
    //     await _notificationsPlugin.zonedSchedule(
    //   0,
    //   'Reminder: ${TodoApp.title}',
    //   TodoApp.channelDescription,
    //    tzDateTime,
    //   notificationDetails,
    //    androidScheduleMode: AndroidScheduleMode.alarmClock,
    //   uiLocalNotificationDateInterpretation:
    //        UILocalNotificationDateInterpretation.absoluteTime,
    // );

    // await _notificationsPlugin.zonedSchedule(
    //   0, // Notification ID (unique for each notification)
    //   'Task Reminder',
    //   task,
    //   ,
    //   notificationDetails,
    // );
  }

  void _addTask(String task, DateTime time) {
    setState(() {
      _tasks.add({'task': task, 'time': time});
    });
    _scheduleNotification(task, time);
  }

  void _showAddTaskDialog() {
    DateTime? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  selectedTime = await showDateTimePicker(context);
                },
                child: Text('Select Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty && selectedTime != null) {
                  _addTask(_taskController.text, selectedTime!);
                  _taskController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        return DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 74, 155, 220) ,
      appBar: AppBar(
        title: Text('To-Do App'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task['task']),
            subtitle: Text(task['time'].toString()),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _tasks.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}