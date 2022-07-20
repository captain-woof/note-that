import 'dart:io';
import 'package:flutter/foundation.dart';
import "dart:convert" as convert;

class NoteData with ChangeNotifier {
  int? _id;
  late List<NoteIndividualData> _bodyData;

  NoteData({required int id, required List<NoteIndividualData> bodyData}) {
    _id = id;
    _bodyData = bodyData.isEmpty ? [TitleData(title: "")] : bodyData;
  }

  NoteData.blank() {
    blankOut();
  }

  NoteData.fromSerialized(
      {required int id, required List<String> serializedData}) {
    _id = id;
    List<NoteIndividualData> newBodyData = [];

    for (String individualSerializedData in serializedData) {
      if (TitleData.isTitleSerializedData(
          individualData: individualSerializedData)) {
        newBodyData.add(TitleData.fromSerialized(
            titleSerialized: individualSerializedData));
      } else if (TextData.isTextSerializedData(
          individualData: individualSerializedData)) {
        newBodyData.add(
            TextData.fromSerialized(textSerialized: individualSerializedData));
      } else if (ImageData.isImgSerializedData(
          individualData: individualSerializedData)) {
        newBodyData.add(ImageData.fromSerialized(
            imgDataSerialized: individualSerializedData));
      }
    }
    _bodyData = newBodyData;
  }

  int? getId() => _id;

  void setId(int newId) {
    _id = newId;
    notifyListeners();
  }

  void setTitle({required String newTitle}) {
    if (_bodyData.isEmpty) {
      _bodyData.add(TitleData(title: newTitle));
    } else {
      (_bodyData[0] as TitleData).setTitle(newTitle: newTitle);
    }
    notifyListeners();
  }

  void addIndividualData(
      {required dynamic noteIndividualData, required String type}) {
    if (type == "text") {
      _bodyData.add(TextData(text: noteIndividualData));
    } else if (type == "image") {
      _bodyData.add(ImageData.fromPath(imgPath: noteIndividualData));
    }
    notifyListeners();
  }

  void setIndividualData(
      {required int index,
      required dynamic newNoteIndividualData,
      required String type}) {
    if (index < 0 || index >= _bodyData.length) {
      throw ("Invalid index of individual data");
    } else {
      if (type == "text") {
        (_bodyData[index] as TextData).setText(newText: newNoteIndividualData);
      } else if (type == "image") {
        (_bodyData[index] as ImageData)
            .setImgFileWithPath(newImgPath: newNoteIndividualData);
      }
      notifyListeners();
    }
  }

  void removeIndividualData({required int index}) {
    if (index < 0 || index >= _bodyData.length) {
      throw ("Invalid index of individual data");
    } else {
      _bodyData.removeAt(index);
      notifyListeners();
    }
  }

  List<NoteIndividualData> getBodyData() => _bodyData;

  void setBodyData(List<NoteIndividualData> newBodyData) {
    _bodyData = newBodyData;
    notifyListeners();
  }

  String serialize() {
    List<String> bodyDataSerialized = (_bodyData
        .map((individualData) => individualData.serialize())
        .toList());

    return convert.jsonEncode(bodyDataSerialized);
  }

  void blankOut() {
    _id = null;
    _bodyData = [TitleData(title: "")];
  }
}

// REQUIRED CLASSES FOR INDIVIDUAL DATA
abstract class NoteIndividualData {
  dynamic getDisplayData();
  String getType();
  String serialize();
  bool search(String searchTerm);
}

class TitleData extends NoteIndividualData {
  late String _title;

  TitleData({required String title}) {
    _title = title;
  }

  TitleData.fromSerialized({required String titleSerialized}) {
    _title = titleSerialized.substring(6);
  }

  @override
  bool search(String searchTerm) {
    return _title.toLowerCase().contains(searchTerm.toLowerCase());
  }

  @override
  String getDisplayData() => _title;

  String getTitle() => _title;

  void setTitle({required String newTitle}) {
    _title = newTitle;
  }

  @override
  String serialize() => "title:$_title";

  static bool isTitleSerializedData({required String individualData}) {
    return individualData.substring(0, 5) == "title";
  }

  @override
  String getType() => "title";
}

class TextData extends NoteIndividualData {
  late String _text;

  TextData({required String text}) {
    _text = text;
  }

  TextData.fromSerialized({required String textSerialized}) {
    _text = textSerialized.substring(5);
  }

  @override
  bool search(String searchTerm) {
    return _text.toLowerCase().contains(searchTerm.toLowerCase());
  }

  @override
  String getDisplayData() => _text;

  String getText() => _text;

  void setText({required String newText}) {
    _text = newText;
  }

  @override
  String serialize() => "text:$_text";

  static bool isTextSerializedData({required String individualData}) {
    return individualData.substring(0, 4) == "text";
  }

  @override
  String getType() => "text";
}

class ImageData extends NoteIndividualData {
  late File _imgFile;

  ImageData({required File imgFile}) {
    _imgFile = imgFile;
  }

  ImageData.fromSerialized({required String imgDataSerialized}) {
    String imgFilePath = imgDataSerialized.substring(6);
    File newImgFile = File(imgFilePath);
    _imgFile = newImgFile;
  }

  ImageData.fromPath({required String imgPath}) {
    File newImgFile = File(imgPath);
    _imgFile = newImgFile;
  }

  @override
  bool search(String searchTerm) => false;

  @override
  File getDisplayData() => _imgFile;

  File getImageFile() => _imgFile;

  void setImgFile({required File newImgFile}) {
    _imgFile = newImgFile;
  }

  void setImgFileWithPath({required String newImgPath}) {
    File newImgFile = File(newImgPath);
    _imgFile = newImgFile;
  }

  @override
  String serialize() => "image:${_imgFile.path}";

  static bool isImgSerializedData({required String individualData}) {
    return individualData.substring(0, 5) == "image";
  }

  @override
  String getType() => "image";
}
