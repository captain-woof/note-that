import 'dart:io';
import 'package:flutter/foundation.dart';
import "dart:convert" as convert;

enum NoteIndividualDataType { title, text, image, video, audio, url }

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

    // Iterate over each individual serialised data
    for (String individualSerializedData in serializedData) {
      // If data is title
      if (TitleData.isTitleSerializedData(
          individualData: individualSerializedData)) {
        newBodyData.add(TitleData.fromSerialized(
            titleSerialized: individualSerializedData));
      }
      // If data is text
      else if (TextData.isTextSerializedData(
          individualData: individualSerializedData)) {
        newBodyData.add(
            TextData.fromSerialized(textSerialized: individualSerializedData));
      }
      // If data is image
      else if (ImageData.isImgSerializedData(
          individualData: individualSerializedData)) {
        newBodyData.add(ImageData.fromSerialized(
            imgDataSerialized: individualSerializedData));
      }
      // If data is video
      else if (VideoData.isVideoSerializedData(
          individualData: individualSerializedData)) {
        newBodyData.add(VideoData.fromSerialized(
            videoDataSerialized: individualSerializedData));
      }
      // If data is audio
      else if (AudioData.isAudioSerializedData(
          individualData: individualSerializedData)) {
        newBodyData.add(AudioData.fromSerialized(
            audioDataSerialized: individualSerializedData));
      }
      // If data is url
      else if (UrlData.isUrlSerializedData(
          individualData: individualSerializedData)) {
        newBodyData.add(
            UrlData.fromSerialized(urlSerialized: individualSerializedData));
      }
    }
    _bodyData = newBodyData;
  }

  void setFromNoteData({required NoteData noteData}) {
    _id = noteData.getId();
    _bodyData = noteData.getBodyData();
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
      {required dynamic noteIndividualData,
      required NoteIndividualDataType type}) {
    // If data to add is text
    if (type == NoteIndividualDataType.text) {
      _bodyData.add(TextData(text: noteIndividualData));
    }
    // If data to add is image
    else if (type == NoteIndividualDataType.image) {
      _bodyData.add(ImageData.fromPath(imgPath: noteIndividualData));
    }
    // If data to add is video
    else if (type == NoteIndividualDataType.video) {
      _bodyData.add(VideoData.fromPath(videoPath: noteIndividualData));
    }
    // If data to add is audio
    else if (type == NoteIndividualDataType.audio) {
      _bodyData.add(AudioData.fromPath(audioPath: noteIndividualData));
    }
    // If data to add is url
    else if (type == NoteIndividualDataType.url) {
      _bodyData.add(UrlData(url: noteIndividualData));
    }
    notifyListeners();
  }

  void setIndividualData(
      {required int index,
      required dynamic newNoteIndividualData,
      required NoteIndividualDataType type}) {
    if (index < 0 || index >= _bodyData.length) {
      throw ("Invalid index of individual data");
    } else {
      // If data to add is text
      if (type == NoteIndividualDataType.text) {
        (_bodyData[index] as TextData).setText(newText: newNoteIndividualData);
      }
      // If data to add is image
      else if (type == NoteIndividualDataType.image) {
        (_bodyData[index] as ImageData)
            .setImgFileWithPath(newImgPath: newNoteIndividualData);
      }
      // If data to add is video
      else if (type == NoteIndividualDataType.video) {
        (_bodyData[index] as VideoData)
            .setVideoFileWithPath(newVideoPath: newNoteIndividualData);
      }
      // If data to add is audio
      else if (type == NoteIndividualDataType.audio) {
        (_bodyData[index] as AudioData)
            .setAudioFileWithPath(newAudioPath: newNoteIndividualData);
      }
      // If data to add is url
      else if (type == NoteIndividualDataType.url) {
        (_bodyData[index] as UrlData).setUrl(newUrl: newNoteIndividualData);
      }
      notifyListeners();
    }
  }

  Future<void> removeIndividualData({required int index}) async {
    if (index < 0 || index >= _bodyData.length) {
      throw ("Invalid index of individual data");
    } else {
      // Delete file
      NoteIndividualData individualDataToDelete = _bodyData.elementAt(index);
      if (individualDataToDelete.getType() == NoteIndividualDataType.image ||
          individualDataToDelete.getType() == NoteIndividualDataType.video ||
          individualDataToDelete.getType() == NoteIndividualDataType.audio) {
        File fileToDelete = individualDataToDelete.getDisplayData();
        await fileToDelete.delete();
      }

      // Delete data
      _bodyData.removeAt(index);

      notifyListeners();
    }
  }

  Future<void> removeAllIndividualData() async {
    if (_bodyData.isNotEmpty) {
      // First delete all media
      List<Future<FileSystemEntity>> filesToDeletePromises = [];
      for (int i = 0; i < _bodyData.length; i++) {
        NoteIndividualData individualDataToDelete = _bodyData.elementAt(i);
        if (individualDataToDelete.getType() == NoteIndividualDataType.image ||
            individualDataToDelete.getType() == NoteIndividualDataType.video ||
            individualDataToDelete.getType() == NoteIndividualDataType.audio) {
          File fileToDelete = individualDataToDelete.getDisplayData();
          filesToDeletePromises.add(fileToDelete.delete());
        }
      }
      await Future.wait(filesToDeletePromises);

      // Now blank out
      blankOut();

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
  NoteIndividualDataType getType();
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
    return individualData.length >= 6 &&
        individualData.substring(0, 5) == "title";
  }

  @override
  NoteIndividualDataType getType() => NoteIndividualDataType.title;
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
    return individualData.length >= 5 &&
        individualData.substring(0, 4) == "text";
  }

  @override
  NoteIndividualDataType getType() => NoteIndividualDataType.text;
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
    return individualData.length >= 6 &&
        individualData.substring(0, 5) == "image";
  }

  @override
  NoteIndividualDataType getType() => NoteIndividualDataType.image;
}

class VideoData extends NoteIndividualData {
  late File _videoFile;

  VideoData({required File videoFile}) {
    _videoFile = videoFile;
  }

  VideoData.fromSerialized({required String videoDataSerialized}) {
    String videoFilePath = videoDataSerialized.substring(6);
    File newVideoFile = File(videoFilePath);
    _videoFile = newVideoFile;
  }

  VideoData.fromPath({required String videoPath}) {
    File newVideoFile = File(videoPath);
    _videoFile = newVideoFile;
  }

  @override
  bool search(String searchTerm) => false;

  @override
  File getDisplayData() => _videoFile;

  File getVideoFile() => _videoFile;

  void setVideoFile({required File newVideoFile}) {
    _videoFile = newVideoFile;
  }

  void setVideoFileWithPath({required String newVideoPath}) {
    File newVideoFile = File(newVideoPath);
    _videoFile = newVideoFile;
  }

  @override
  String serialize() => "video:${_videoFile.path}";

  static bool isVideoSerializedData({required String individualData}) {
    return individualData.length >= 6 &&
        individualData.substring(0, 5) == "video";
  }

  @override
  NoteIndividualDataType getType() => NoteIndividualDataType.video;
}

class AudioData extends NoteIndividualData {
  late File _audioFile;

  AudioData({required File audioFile}) {
    _audioFile = audioFile;
  }

  AudioData.fromSerialized({required String audioDataSerialized}) {
    String audioFilePath = audioDataSerialized.substring(6);
    File newAudioFile = File(audioFilePath);
    _audioFile = newAudioFile;
  }

  AudioData.fromPath({required String audioPath}) {
    File newAudioFile = File(audioPath);
    _audioFile = newAudioFile;
  }

  @override
  bool search(String searchTerm) => false;

  @override
  File getDisplayData() => _audioFile;

  File getAudioFile() => _audioFile;

  void setAudioFile({required File newAudioFile}) {
    _audioFile = newAudioFile;
  }

  void setAudioFileWithPath({required String newAudioPath}) {
    File newAudioFile = File(newAudioPath);
    _audioFile = newAudioFile;
  }

  @override
  String serialize() => "audio:${_audioFile.path}";

  static bool isAudioSerializedData({required String individualData}) {
    return individualData.length >= 6 &&
        individualData.substring(0, 5) == "audio";
  }

  @override
  NoteIndividualDataType getType() => NoteIndividualDataType.audio;
}

class UrlData extends NoteIndividualData {
  late String _url;

  UrlData({required String url}) {
    _url = url;
  }

  UrlData.fromSerialized({required String urlSerialized}) {
    _url = urlSerialized.substring(4);
  }

  @override
  bool search(String searchTerm) {
    return _url.toLowerCase().contains(searchTerm.toLowerCase());
  }

  @override
  String getDisplayData() => _url;

  String getText() => _url;

  void setUrl({required String newUrl}) {
    _url = newUrl;
  }

  @override
  String serialize() => "url:$_url";

  static bool isUrlSerializedData({required String individualData}) {
    return individualData.length >= 4 &&
        individualData.substring(0, 3) == "url";
  }

  @override
  NoteIndividualDataType getType() => NoteIndividualDataType.url;
}
