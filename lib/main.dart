import 'package:flutter/material.dart';
import 'package:flutter_lab_3/providers/auth.dart';
import 'package:flutter_lab_3/screens/auth_screen.dart';
import 'package:flutter_lab_3/widgets/AddExam.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Model/exam.dart';
import 'Model/user.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the local notifications plugin
  initializeLocalNotifications();
  runApp(const MyApp());
}

void initializeLocalNotifications() {
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Auth(),
      child: MaterialApp(
        routes: {
          "/home": (context) => MyHomePage(title: "My Home Page", authenticatedUser: Provider.of<Auth>(context, listen: false).authenticatedUser),
          "/auth": (context) => AuthScreen(),
        },
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.amber,
        ),
        home: AuthScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({@required this.title, @required this.authenticatedUser});

  final User authenticatedUser;
  
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  DateTime selectedDate;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  void logout(){
    Provider.of<Auth>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed("/auth");
  }

  void addItemFunction(BuildContext ct) {
    showModalBottomSheet(
        context: ct,
        builder: (BuildContext context) {
          return Container(
              child: GestureDetector(
            onTap: () {},
            child: AddExam(addNewItemToList),
            behavior: HitTestBehavior.opaque,
          ));
        });
  }

  void addNewItemToList(Exam item) {
    setState(() {
      widget.authenticatedUser.exams.add(item);
    });
  }

  void resetSelectedDate(){
    setState(() {
      selectedDate = null;
    });
  }

  void deleteItem(String id) {
    setState(() {
      widget.authenticatedUser.exams.removeWhere((element) => element.id == id);
    });
  }

  void presentDatePicker() {
    showDatePicker(
            context: context,
            initialDate: selectedDate != null ? selectedDate : DateTime.now(),
            firstDate: DateTime(2019),
            lastDate: DateTime.now().add(const Duration(days: 50)))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedDate = pickedDate;
      });
    });
  }

  Widget ListOfSubjects() {
    List<Exam> appropriateSubjects = [];
    if (selectedDate == null)
      appropriateSubjects = widget.authenticatedUser.exams;
    else {
      appropriateSubjects = widget.authenticatedUser.exams.where((element) {
        return element.dateTime.day == selectedDate?.day &&
            element.dateTime.month == selectedDate?.month &&
            element.dateTime.year == selectedDate?.year;
      }).toList();
    }

    return widget.authenticatedUser.exams.length == 0
        ? Text("You haven't added any exams in the list")
        : ListView.builder(
            itemBuilder: (cntx, index) {
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                child: ListTile(
                  title: Text(appropriateSubjects[index].name,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(appropriateSubjects[index]
                      .dateTime
                      .toString()
                      .substring(0, 16)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteItem(appropriateSubjects[index].id),
                  ),
                ),
              );
            },
            itemCount: appropriateSubjects.length,
          );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.calendar_month), onPressed: presentDatePicker),
          IconButton(
              icon: Icon(Icons.add), onPressed: () => addItemFunction(context)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              Container(height: 10),
              Container(child: Text("Welcome, ${Provider.of<Auth>(context, listen: false).username}"),),
              TextButton(onPressed: logout, child: Text('Log out')),
              Container(height: 20,),
              TextButton(onPressed: resetSelectedDate, child: Text('View all of your courses')),
              Text('Open calendar to find courses on a specific date!'),
              Text(selectedDate==null? 'No date chosen' : 'Chosen date is ' + DateFormat().add_yMMMd().format(selectedDate)),
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListOfSubjects(),
              ),
            ]),
      ),
    );
  }
}
