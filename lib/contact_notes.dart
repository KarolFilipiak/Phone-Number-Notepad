import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'functions.dart';
import 'settings.dart';

class ContactNotes extends StatefulWidget {
  const ContactNotes({Key? key, required String this.name, required List<Item> this.numbers}) : super(key: key);

  final String name;
  final List<Item> numbers;

  @override
  State<ContactNotes> createState() => _ContactNotesState();
}

class _ContactNotesState extends State<ContactNotes> {
  final notesTextControl = TextEditingController();
  final _storage = const FlutterSecureStorage();
  String notes = "";
  bool _isLoading = true;
  String name = "";

  void initNotes() async 
  {
    setState(() {
      name = widget.name;
    });

    if (await _storage.containsKey(key: name) == false || await _storage.read(key: name) == null)
    {
      await _storage.write(key: name, value: "");
    }
    else
    {
      notes = (await _storage.read(key: name))!;
      setState(() {
        notesTextControl.text = notes;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void clear_input()
  {
    setState(()  {
      notesTextControl.clear();
      notes = "";
    });
  }

  @override
  void initState() {
    super.initState();
    initNotes();   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: color_text_appbar
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Notes about ${widget.name}", 
              style: TextStyle(
                color: color_text_appbar, 
                fontWeight: FontWeight.values[6], 
                fontStyle: FontStyle.italic, fontSize: 25
              ),
            )
          ],
        ),
        backgroundColor: color_appbar,
      ),
      backgroundColor: color_background_1,
      body: _isLoading
      ? Center(child: CircularProgressIndicator())
      : ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * margin_vertical, bottom: MediaQuery.of(context).size.height * margin_vertical, left: MediaQuery.of(context).size.width * margin_horizontal, right: MediaQuery.of(context).size.width * margin_horizontal),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, interline_padding),
                    child: Text(
                      "Name: ${widget.name}",
                      style: TextStyle(color: color_text_info, fontWeight: FontWeight.bold),
                      maxLines: null,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 2 * interline_padding),
                    child: Text(
                      "Phone numbers: ${extractNumbersListToString(widget.numbers)}",
                      style: TextStyle(color: color_text_info, fontWeight: FontWeight.bold),
                      maxLines: null,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * (1 - (2 * margin_horizontal)),
                    height: MediaQuery.of(context).size.height * 0.7 * (1 - (2 * margin_vertical)),
                    child: TextField(
                      onChanged: ((var value) {
                        setState(() {
                          notes = value;
                        });
                      }
                      ),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Your notes will appear here",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            left: 8, right: 8, bottom: 8
                          )
                      ),
                      controller: notesTextControl,
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                  SizedBox(height: 2 * sizedbox_height),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: (() async{
                          await _storage.write(key: name, value: notes);
                          setState(() {
                            notesTextControl.text = notes;
                          });
                          final snackBar = SnackBar(content: Text('Note saved successfully'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        ),
                        style: ElevatedButton.styleFrom(

                          primary: color_button_1,
                        ),
                        child: Text(
                          'SAVE', 
                          style: TextStyle(color: color_text_button),
                        )
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                      ElevatedButton(
                        onPressed: () async {
                          initNotes();
                        }, 
                        style: ElevatedButton.styleFrom(

                          primary: color_button_1,
                        ),
                        child: Text(
                          'RESTORE', 
                          style: TextStyle(color: color_text_button)),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                      ElevatedButton(
                        onPressed: () async {
                          clear_input();
                        }, 
                        style: ElevatedButton.styleFrom(

                          primary: color_button_1,
                        ),
                        child: Text(
                          'CLEAR', 
                          style: TextStyle(color: color_text_button)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ]
        ),
    );
  }
}