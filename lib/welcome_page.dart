import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'contact_notes.dart';
import 'settings.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _isAndroid = false;
  bool _accessGranted = false;
  List<Contact>? contacts;

  @override
  void initState() {
    _askPermissions();
    super.initState();
  }

  Widget ContactCard(Contact contact)
  {
    String name;
    List<Item> phones;

    if (contact.displayName == null) {
      name = "";
    }
    else {
      name = contact.displayName!;
    }

    if (contact.phones == null) {
      phones = [];
    }
    else {
      phones = contact.phones!;
    }

    List<Widget> list = <Widget>[];
    for(var i = 0; i < phones.length; i++)
    {
      list.add(Text(phones[i].value.toString(), style: TextStyle(color: color_text_displaycard),));
    }

    return TextButton (
      onPressed: () {
        if (name != "")  
        {
          setState(() {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ContactNotes(name: name, numbers: phones),)
            );
            
          });
        }
        else
        {
          final snackBar =
            SnackBar(content: Text('No name = no note'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: TextStyle(color: color_text_displaycard),),
          Spacer(),
          Column(
            children: list
          )
        ],
      )
    );
  }

  Widget ContactCardsList(List<Contact>? contacts)
  {
    if (contacts == null || contacts.length == 0)
    {
      return Column(children: [Text("No contacts detected", style: TextStyle(color: color_text_error),)],);
    }
    List<Widget> list = <Widget>[];
    for(var i = 0; i < contacts.length; i++)
    {
        list.add(
          ContactCard(contacts[i])
        );
    }
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [
        Column
        (
          children: list
        )
      ]
    );
    
  }

  Future<void> _askPermissions() async 
  {
    setState(() {
      _isLoading = true;
    });
    if (Platform.isAndroid)
    {
      setState(() {
        _isAndroid = true;
      });
      PermissionStatus permissionStatus = await _getContactPermission();
      if (permissionStatus == PermissionStatus.granted) 
      {
        contacts = await ContactsService.getContacts();
        setState(() {
          _accessGranted = true;
        });
      } 
      else 
      {
        _handleInvalidPermissions(permissionStatus);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) 
    {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } 
    else 
    {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome", style: TextStyle(color: color_text_appbar, fontWeight: FontWeight.values[6], fontStyle: FontStyle.italic, fontSize: 25),)
          ],
        ),
        backgroundColor: color_appbar,
      ),
      backgroundColor: color_background_1,
      body: Container (
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * margin_vertical, bottom: MediaQuery.of(context).size.height * margin_vertical, left: MediaQuery.of(context).size.width * margin_horizontal, right: MediaQuery.of(context).size.width * margin_horizontal),
        child: Container (
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Column( 
                  children: [
                    _isLoading
                      ? Text("LOADING...")
                      : _isAndroid
                        ? _accessGranted
                          ? Column(
                              children: [
                                Text("Detected contacts: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                                ContactCardsList(contacts),
                              ],
                            ) 
                          : GestureDetector(
                            onTap: openAppSettings,
                            child: Text(
                              "ACCESS NOT GRANTED\n(CHANGE PERMISSIONS IN THE SETTINGS AND REFRESH)\n(Premissions -> Contacts -> Allow)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color_text_error
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Text("WRONG PLATFORM (WORKS ONLY ON ANDROID)", style: TextStyle(fontWeight: FontWeight.bold, color: color_text_error),)
                  ],
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _askPermissions();
                      setState(() {
                        
                      });
                    }, 
                    child: Row (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh)
                      ]
                    )
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
                  ElevatedButton(
                    onPressed: () async{
                      await _storage.deleteAll();
                      final snackBar = 
                        SnackBar(content: Text('Notes have been erased'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      setState(() {
                      });
                    }, 
                    child: Row (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever)
                      ]
                    )
                  )
                ],
              )
            ],
          )
        )
      ),
    );
  }
}