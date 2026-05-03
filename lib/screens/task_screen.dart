import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../db/db_helper.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  static const Color mainBg = Color(0xFF1ECB9B);
  static const Color innerBg = Color(0xFFE0F7F1);
  static const Color cardBg = Colors.white;
  static const Color primary = Color(0xFF1ECB9B);
  static const Color textDark = Color(0xFF1B3A3A);

  final TextEditingController controller = TextEditingController();
  final TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> tasks = [];
  DateTime? selectedDateTime;
  String priority = "Medium";

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final data = await DBHelper.getTasks();
    setState(() {
      tasks = data;
    });
  }

  // 📅 Pick Date & Time
  Future<void> pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // ✅ ADD TASK + SCHEDULE REMINDER
  Future<void> addTask() async {
    if (controller.text.isEmpty || selectedDateTime == null) return;

    final reminderTime = selectedDateTime;

    final task = {
      "title": controller.text,
      "desc": descController.text,
      "date": reminderTime!.toIso8601String(),
      "done": false,
      "priority": priority,
    };

    await DBHelper.insertTask(task);
    await loadTasks();

    // ✅ Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Task '${task["title"]}' added ✅"),
        backgroundColor: Colors.green,
      ),
    );

    // 🔔 ✅ SCHEDULED NOTIFICATION (MAIN FIX)
    await NotificationService.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: "⏰ Reminder",
      body: task["title"] as String,
      scheduledTime: reminderTime,
    );

    // 🔔 Optional instant confirmation
    await NotificationService.showNotification(
      title: "📌 Task Saved",
      body:
          "${task["title"]} at ${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}",
    );

    // Reset fields
    controller.clear();
    descController.clear();
    selectedDateTime = null;

    setState(() {});
  }

  // ✅ Toggle Done
  Future<void> toggle(int i) async {
    final task = tasks[i];
    final newValue = !task["done"];

    await DBHelper.updateTaskDone(task["id"], newValue);
    await loadTasks();

    if (newValue) {
      await NotificationService.showNotification(
        title: "✅ Task Completed",
        body: "Nice! '${task["title"]}' done 🎉",
      );
    }
  }

  // ❌ Delete Task
  Future<void> deleteTask(int i) async {
    final task = tasks[i];
    await DBHelper.deleteTask(task["id"]);
    await loadTasks();
  }

  int get doneCount => tasks.where((t) => t["done"] == true).length;
  int get remainingCount => tasks.length - doneCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: addTask,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: innerBg,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "My Tasks",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 📊 Stats
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Done: $doneCount"),
                          Text("Remaining: $remainingCount"),
                          Text("Total: ${tasks.length}"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 📝 Add Task UI
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: "Task Title",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: "Description",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: pickDateTime,
                            child: Text(
                              selectedDateTime == null
                                  ? "Pick Deadline"
                                  : "${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} "
                                      "${selectedDateTime!.hour}:${selectedDateTime!.minute.toString().padLeft(2, '0')}",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 📋 Task List
                    Expanded(
                      child: tasks.isEmpty
                          ? const Center(child: Text("No tasks yet 📌"))
                          : ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, i) {
                                var t = tasks[i];
                                return ListTile(
                                  title: Text(t["title"]),
                                  subtitle: Text(t["desc"] ?? ""),
                                  leading: Checkbox(
                                    value: t["done"],
                                    onChanged: (_) => toggle(i),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => deleteTask(i),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}