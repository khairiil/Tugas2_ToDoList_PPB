import 'package:flutter/material.dart';

class Task {
  String title;
  bool isCompleted;

  Task({
    required this.title,
    this.isCompleted = false,
  });

  void toggle() {
    isCompleted = !isCompleted;
  }

  @override
  String toString() {
    return 'Task{title: $title, isCompleted: $isCompleted}';
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App Pemula',
      theme: ThemeData(
        primaryColor: const Color(0xFFb6895b),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFb6895b),
          secondary: Colors.black,
        ),
      ),
      home: const TodoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> tasks = [];
  TextEditingController taskController = TextEditingController();

  void addTask() {
    String newTaskTitle = taskController.text.trim();
    if (newTaskTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Task tidak boleh kosong!'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    bool isDuplicate = tasks.any((task) =>
        task.title.toLowerCase() == newTaskTitle.toLowerCase());

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Task "$newTaskTitle" sudah ada!')),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (newTaskTitle.length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Task terlalu panjang! Maksimal 100 karakter.')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      Task newTask = Task(title: newTaskTitle);
      tasks.add(newTask);
    });

    taskController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Task "$newTaskTitle" berhasil ditambahkan!')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    debugPrint('Task ditambahkan: $newTaskTitle');
  }

  void removeTask(int index) async {
    Task taskToDelete = tasks[index];
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Konfirmasi Hapus'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apakah kamu yakin ingin menghapus task ini?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${taskToDelete.title}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        tasks.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Task "${taskToDelete.title}" dihapus')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      debugPrint('Task dihapus: ${taskToDelete.title}');
      debugPrint('Sisa tasks: ${tasks.length}');
    } else {
      debugPrint('Delete dibatalkan');
    }
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].toggle();
    });

    Task task = tasks[index];
    String message = task.isCompleted
        ? 'Selamat! Task "${task.title}" selesai! 🎉'
        : 'Task "${task.title}" ditandai belum selesai';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              task.isCompleted ? Icons.celebration : Icons.undo,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: task.isCompleted ? Colors.green : const Color(0xFFb6895b),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    debugPrint('Task ${task.isCompleted ? "completed" : "uncompleted"}: ${task.title}');
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: const Color(0xFFb6895b),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: taskController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'Ketik task baru di sini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.edit),
                      counterText: '',
                      helperText: 'Maksimal 100 karakter',
                    ),
                    onSubmitted: (value) => addTask(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: addTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFb6895b),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Add Task',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Tasks: ${tasks.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada task',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambahkan task pertamamu di atas!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          Task task = tasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: task.isCompleted ? Colors.brown[50] : Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: task.isCompleted
                                    ? Border.all(color: Colors.brown[200]!, width: 2)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Opacity(
                                opacity: task.isCompleted ? 0.7 : 1.0,
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: task.isCompleted ? Colors.brown[100] : Colors.brown[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: task.isCompleted
                                          ? Icon(Icons.check, color: Colors.brown[700])
                                          : Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: task.isCompleted ? Colors.grey[600] : Colors.black87,
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: Text(
                                    task.isCompleted ? 'Selesai ✅' : 'Belum selesai',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: task.isCompleted ? Colors.brown[700] : Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          task.isCompleted
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: task.isCompleted ? Colors.brown[700] : Colors.grey[400],
                                        ),
                                        onPressed: () => toggleTask(index),
                                        tooltip: task.isCompleted
                                            ? 'Mark as incomplete'
                                            : 'Mark as complete',
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red[400],
                                        ),
                                        onPressed: () => removeTask(index),
                                        tooltip: 'Hapus task',
                                      ),
                                    ],
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
