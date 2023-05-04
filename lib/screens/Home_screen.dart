import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todoapp/models/api.dart';
import 'package:todoapp/models/sprint.dart';
import 'package:todoapp/models/task.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';

class BacklogScreen extends StatefulWidget {
  const BacklogScreen({Key? key}) : super(key: key);

  @override
  _BacklogScreenState createState() => _BacklogScreenState();
}

class _BacklogScreenState extends State<BacklogScreen> {
  List<Sprint> _sprints = [];
  List<Task> _tasks = [];
  late String formattedDate;
  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _getSprintsAndTasks();
  }


void _onDragEnd(BuildContext context, Task task) async {
  final sprint = await showDialog<Sprint>(
    context: context,
    builder: (context) => _SprintSelectionDialog(
      sprints: _sprints,
    ),
  );

  if (sprint != null) {
    task.sprintId = sprint.id;
    await Api.updateTask(task);
    await _getSprintsAndTasks();
  }
}


  Future<void> _getSprintsAndTasks() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/sprints?_embed=tasks'));

    if (response.statusCode == 200) {
      List<Sprint> sprints = [];
      List<dynamic> jsonList = jsonDecode(response.body);
      for (var jsonSprint in jsonList) {
        sprints.add(Sprint.fromJson(jsonSprint));
      }
      setState(() {
        _sprints = sprints;
        _tasks = sprints.expand((sprint) => sprint.tasks).toList();
      });
    } else {
      throw Exception('Failed to load sprints');
    }
  }

  

  Future<void> addSprint(BuildContext context) async {
    String name = '';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    await showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: Text('Add Sprint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(hintText: 'Sprint Name'),
              onChanged: (value) => name = value,
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final newStartDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (newStartDate != null) {
                  startDate = newStartDate;
                }
              },
              child: Text(
                  'Start Date: ${DateFormat('dd MMM yyyy').format(startDate)}'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final newEndDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (newEndDate != null) {
                  endDate = newEndDate;
                }
              },
              child: Text(
                  'End Date: ${DateFormat('dd MMM yyyy').format(endDate)}'),
            ),
          ],
        ),
        actions: <Widget>[
          BasicDialogAction(
            title: Text('CANCEL'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          BasicDialogAction(
            title: Text('ADD'),
            onPressed: () async {
              Sprint sprint = Sprint(
                id: 0,
                name: name,
                startDate: startDate,
                endDate: endDate,
                tasks: [],
              );

              await Api.addSprint(sprint);
               await _getSprintsAndTasks();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditSprintDialog(Sprint sprint) async {
    String sprintName = sprint.name;
    DateTime startDate = sprint.startDate ?? DateTime.now();
    DateTime endDate = sprint.endDate ?? DateTime.now();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier le sprint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(hintText: 'Nom du sprint'),
              onChanged: (value) => sprintName = value,
              controller: TextEditingController(text: sprint.name),
            ),
            SizedBox(height: 16),
            Text('Date de début:'),
            SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2015),
                    lastDate: DateTime(2100));
                if (picked != null && picked != startDate)
                  setState(() {
                    startDate = picked;
                  });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                    'Start Date: ${DateFormat('dd MMM yyyy').format(startDate)}'),
              ),
            ),
            SizedBox(height: 16),
            Text('Date de fin:'),
            SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: DateTime(2015),
                    lastDate: DateTime(2100));
                if (picked != null && picked != endDate)
                  setState(() {
                    endDate = picked;
                  });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromARGB(255, 110, 103, 103),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                    'Start Date: ${DateFormat('dd MMM yyyy').format(startDate)}'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              sprint.name = sprintName;
              sprint.startDate = startDate;
              sprint.endDate = endDate;
              await Api.updateSprint(sprint);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _deleteSprint(Sprint sprint) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text(
            'Voulez-vous vraiment supprimer le sprint et toutes les tâches associées?'),
        actions: <Widget>[
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Confirmer'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirm != null && confirm) {
      await Api.deleteSprint(sprint.id);
      await _getSprintsAndTasks();
      
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('To Do'),
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Sprints',
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () => addSprint(context),
                  child: Text('Ajouter un sprint'),
                ),
              ],
            ),
          ),
          ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: _sprints.length,
  itemBuilder: (_, index) {
    final sprint = _sprints[index];
    final sprintTasks = sprint.tasks;
    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: EdgeInsets.all(16.0),
      child: ExpansionTile(
        title: Text(
          '${sprint.name} (${DateFormat('dd/MM/yyyy').format(sprint.startDate)})',
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: sprintTasks.length,
            itemBuilder: (_, index) {
              final task = sprintTasks[index];
              return Draggable<Task>(
                data: task,
                child: _buildTaskItem(task),
                feedback: Material(
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.description),
                  ),
                ),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  _onDragEnd(context, task);
                },
              );
            },
          ),
          SizedBox(height: 16.0),
          DragTarget<Task>(
            builder: (BuildContext context, List<Task?> incoming, List<dynamic> rejected) {
              return ListTile(
                title: Text(sprint.name),
                subtitle: Text('(${sprint.tasks.length} tâches)'),
              );
            },
            onAccept: (task) {
              task.sprintId = sprint.id;
              Api.updateTask(task);
              _getSprintsAndTasks();
            },
          ),
        ],
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _showEditSprintDialog(sprint);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteSprint(sprint),
            ),
          ],
        ),
      ),
    );
  },
),

ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: _tasks.length,
  itemBuilder: (_, index) {
    final task = _tasks[index];
    return Draggable<Task>(
      data: task,
      child: _buildTaskItem(task),
      feedback: Material(
        child: ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
        ),
      ),
      childWhenDragging: Container(),
      onDragEnd: (details) {
        _onDragEnd(context, task);
      },
    );
  },
)
]
)),
);
}

Widget _buildTaskItem(Task task) {
  return Card(
    color: Color.fromARGB(255, 205, 179, 210),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    margin: EdgeInsets.all(16.0),
    child: ListTile(
      title: Text(task.title),
      subtitle: Text(task.description),
      trailing: Text(task.status),
    
    ),
  );
}
}
class _SprintSelectionDialog extends StatelessWidget {
  final List<Sprint> sprints;

  const _SprintSelectionDialog({
    Key? key,
    required this.sprints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select a Sprint'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sprints.length,
          itemBuilder: (context, index) {
            final sprint = sprints[index];
            return ListTile(
              title: Text(sprint.name),
              onTap: () {
                Navigator.pop(context, sprint);
              },
            );
          },
        ),
      ),
    );
  }
}
