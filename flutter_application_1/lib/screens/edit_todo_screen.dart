import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';

class EditTodoScreen extends StatefulWidget {
  final Map todoData;

  const EditTodoScreen({super.key, required this.todoData});

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  late TextEditingController titleC;
  late TextEditingController descC;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.todoData['title']);
    descC = TextEditingController(text: widget.todoData['description']);
  }

  Future<void> updateTodo() async {
    if (titleC.text.isEmpty || descC.text.isEmpty) {
      CustomSnackBar.showError(context, "Semua form wajib diisi");
      return;
    }
    setState(() => isLoading = true);
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("todos")
          .doc(widget.todoData['task_id'])
          .update({
        "title": titleC.text,
        "description": descC.text,
      });
      if (mounted) {
        CustomSnackBar.showSuccess(context, "Berhasil memperbarui TODO");
        Navigator.pop(context); // Pop halaman edit
        Navigator.pop(context); // Pop halaman detail agar kembali ke list/home
      }
    } catch (e) {
      CustomSnackBar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    titleC.dispose();
    descC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit TODO"),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.secondary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomInput(
            controller: titleC,
            label: "Nama TODO",
            hint: "Edit Judul",
          ),
          CustomInput(
            controller: descC,
            label: "Deskripsi",
            hint: "Edit Deskripsi",
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
              ),
              onPressed: isLoading ? null : updateTodo,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Simpan Perubahan",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}