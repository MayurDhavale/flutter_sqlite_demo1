import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sqlite_demo_1/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DbHelper? dbRef;

  List<Map<String, dynamic>> allNotes = [];

  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NOTES"),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(allNotes[index][DbHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DbHelper.COLUMN_NOTE_DESC]),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Take minimum space
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                titleController.text =
                                    allNotes[index][DbHelper.COLUMN_NOTE_TITLE];
                                descController.text =
                                    allNotes[index][DbHelper.COLUMN_NOTE_DESC];
                                return getBottomSheetView(
                                    isUpdate: true,
                                    sno: allNotes[index]
                                        [DbHelper.COLUMN_NOTE_SNO]);
                              },
                            );
                          },
                          child: const Icon(Icons.edit),
                        ),
                        const SizedBox(width: 8.0), // Reduced spacing
                        InkWell(
                          onTap: () async {
                            bool check = await dbRef!.deleteNote(
                              sno: allNotes[index][DbHelper.COLUMN_NOTE_SNO],
                            );
                            if (check) {
                              getNotes();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Note deleted successfully!')),
                              );
                            }
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text('No Notes Yet!!!'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              titleController.clear();
              descController.clear();
              return getBottomSheetView();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetView({bool isUpdate = false, int sno = 0}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            isUpdate ? "Update Notes" : "Add Notes",
            style: const TextStyle(fontSize: 25.0),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: "Enter title here",
              label: const Text("Title *"),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Enter desc here",
              label: const Text("Desc *"),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          const SizedBox(height: 11.0),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    var title = titleController.text;
                    var desc = descController.text;

                    if (title.isNotEmpty && desc.isNotEmpty) {
                      bool check = isUpdate
                          ? await dbRef!
                              .updateNote(mTitle: title, mDesc: desc, sno: sno)
                          : await dbRef!.addNote(mTitle: title, mDesc: desc);

                      if (check) {
                        getNotes();
                        Navigator.pop(context);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please fill all the required blanks!')),
                      );
                    }
                    titleController.clear();
                    descController.clear();
                  },
                  child: Text(isUpdate ? "Update Notes" : "Add Notes"),
                ),
              ),
              const SizedBox(width: 11.0),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
