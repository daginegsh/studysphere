import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pdf_viewer_screen.dart';
import '../db/db_helper.dart';

class ResourceScreen extends StatefulWidget {
  const ResourceScreen({super.key});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  List<Map<String, dynamic>> resources = [];

  final TextEditingController linkController = TextEditingController();

  String selectedCategory = "Math";

  final List<String> categories = [
    "Math",
    "Science",
    "Programming",
    "Fiction",
    "History",
    "Other"
  ];

  // 🔥 LOAD FROM DATABASE
  Future<void> loadResources() async {
    final data = await DBHelper.getResources();

    setState(() {
      resources = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadResources();
  }

  // 🔥 ADD LINK
  void addLink() async {
    String link = linkController.text.trim();
    if (link.isEmpty) return;

    if (!link.startsWith("http")) {
      link = "https://$link";
    }

    await DBHelper.insertResource({
      'type': 'link',
      'value': link,
      'name': link.split('/').last,
      'category': selectedCategory,
    });

    linkController.clear();
    loadResources();
  }

  // 🔥 PICK PDF
  Future<void> pickPDF() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    if (file.path == null) return;

    await DBHelper.insertResource({
      'type': 'pdf',
      'value': file.path!,
      'name': file.name,
      'category': selectedCategory,
    });

    loadResources();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF added: ${file.name}")),
    );
  }

  // 🔥 OPEN LINK
  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  // 🔥 DELETE ITEM (FIXED)
  void deleteItem(int index) async {
    final item = resources[index];

    await DBHelper.deleteResource(item['id']); // ✅ delete only one

    loadResources();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          // CATEGORY
          DropdownButtonFormField<String>(
            value: selectedCategory,
            items: categories
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
            decoration: InputDecoration(
              labelText: "Select Category",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // LINK INPUT
          TextField(
            controller: linkController,
            decoration: InputDecoration(
              hintText: "Enter link (e.g. youtube.com)",
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: addLink,
                  child: const Text("Add Link"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: pickPDF,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Upload PDF"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // LIST
          Expanded(
            child: resources.isEmpty
                ? const Center(child: Text("No resources yet 📌"))
                : ListView.builder(
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      final item = resources[index];

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            item["type"] == "link"
                                ? Icons.link
                                : Icons.picture_as_pdf,
                            color: item["type"] == "link"
                                ? Colors.blue
                                : Colors.red,
                          ),
                          title: Text(item["name"]),
                          subtitle:
                              Text("Category: ${item["category"]}"),

                          onTap: () {
                            if (item["type"] == "link") {
                              openLink(item["value"]);
                            } else {
                              final file = File(item["value"]);

                              if (file.existsSync()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PdfViewerScreen(
                                            path: item["value"]),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("PDF file not found"),
                                  ),
                                );
                              }
                            }
                          },

                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () => deleteItem(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}