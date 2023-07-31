import 'package:flutter/material.dart';
import 'package:flutter_lab_3/Model/exam.dart';
import 'package:nanoid/nanoid.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class AddExam extends StatefulWidget {
  final Function addNewItem;
  AddExam(this.addNewItem);

  @override
  State<StatefulWidget> createState() => AddExamState();
}

class AddExamState extends State<AddExam> {
  final nameController = TextEditingController();
  // final dateTimeController = TextEditingController();

  String name = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void presentDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
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

  void presentTimePicker() {
    showTimePicker(
        context: context,
        initialTime: selectedTime == null ? TimeOfDay(
          hour: 10,
          minute: 10,
        ) : selectedTime).then((pickedTime) {
          if (pickedTime == null) {
            return;
          }
          setState(() {
            selectedTime = pickedTime;
          });
        });
  }

  void submitData() {
    if (nameController.text.isEmpty) {
      return;
    }
    final vnesenoIme = nameController.text;
    final vnesenDatum = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
    final newItem =
        Exam(id: nanoid(5), name: vnesenoIme, dateTime: vnesenDatum);
    widget.addNewItem(newItem);

    Provider.of<Auth>(context, listen: false).scheduleNotificationsForLoggedInUser();
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Име на предметот"),
            onSubmitted: (_) => submitData(),
          ),
          Container(
            height: 50,
            child: Row(
              children: [
                Expanded(child: Text(selectedDate == null ? 'No date chosen' :  DateFormat().add_yMMMd().format(selectedDate))),
                TextButton(child: Text('Choose date', style: TextStyle(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.bold),), onPressed: presentDatePicker,),
              ],
            ),
          ),

          Container(
            height: 50,
            child: Row(
              children: [
                Expanded(child: Text(selectedTime == null ? 'No time chosen' : '${selectedTime.hour}:${selectedTime.minute}')),
                TextButton(child: Text('Choose time', style: TextStyle(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.bold),), onPressed: presentTimePicker,),
              ],
            ),
          ),


          Container(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor),
            child: Text("Add"),
            onPressed: () => submitData(),
          )
        ],
      ),
    );
  }
}
