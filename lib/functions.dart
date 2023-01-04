import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

List<String> extractNumbersList (List<Item> numbers) 
{ 
  List<String> _out = [];
  for (var i = 0; i < numbers.length; i++)
  {
    _out.add(numbers[i].value.toString());
  }
  return _out;
}

String numbersToString (List<String> numlist)
{
  String _out = "";
  for (var i = 0; i < numlist.length; i++)
  {
    _out = _out + numlist[i];
    if (i < numlist.length-1)
    {
      _out = _out + ", ";
    }
  }
  return _out;
}

String extractNumbersListToString (List<Item> numbers)
{
  return numbersToString(extractNumbersList(numbers));
}

List<String> extractContacts (List<Contact>? contacts)
{
  List<String> _out = [];
  if (contacts == null)
  {
    return [];
  }

  Contact _contact;
  String _name;
  List<Item> _phones;

  String _phoneStr = "";
  

  for (var i = 0; i < contacts.length; i++)
  {
    _contact = contacts[i];

    if (_contact.displayName == null) {
      _name = "";
    }
    else {
      _name = _contact.displayName!;
    }

    if (_contact.phones == null) {
      _phones = [];
    }
    else {
      _phones = _contact.phones!;
    }

    _phoneStr = extractNumbersListToString(_phones);
    _out.add(_name + "\t" + _phoneStr);
  }
  return _out;
}

String extractContactsString(List<Contact>? contacts)
{
  List<String> x = extractContacts(contacts);
  String _out = "";

  for (var i = 0; i < x.length; i++)
  {
    _out = _out + x[i];
    if (i < x.length-1)
    {
      _out = _out + "\n";
    }
  }
  return _out;
}