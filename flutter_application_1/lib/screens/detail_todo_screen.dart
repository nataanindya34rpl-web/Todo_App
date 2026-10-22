import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';
import 'edit_todo_screen.dart';

class DetailTodoScreen extends StatelessWidget {
  final Map todoData;

  const DetailTodoScreen({super.key, required this.todoData});

  Future<void> deleteTodo(BuildContext context) async {
    CustomDialog.showConfirmation(
      context: context,
      title: "Hapus TODO",
      message: "Apakah Anda yakin ingin menghapus TODO ini?",
      onConfirm: () async {
        try {
          String uid = FirebaseAuth.instance.currentUser!.uid;
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection("todos")
              .doc(todoData['task_id'])
              .delete();

          if (context.mounted) {
            CustomSnackBar.showSuccess(context, "Data berhasil dihapus");
            Navigator.pop(context);
          }
        } catch (e) {
          if (context.mounted) {
            CustomSnackBar.showError(context, e.toString());
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleC = TextEditingController(text: todoData['title']);
    final descC = TextEditingController(text: todoData['description']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail TODO"),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.secondary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTodoScreen(todoData: todoData),
                ),
              );
            },
            child: const Text("Edit"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomInput(
            controller: titleC,
            label: "Nama TODO",
            hint: "",
            disabled: true,
          ),
          CustomInput(
            controller: descC,
            label: "Deskripsi",
            hint: "",
            disabled: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.warning,
              ),
              onPressed: () => deleteTodo(context),
              child: const Text(
                "Hapus TODO",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}