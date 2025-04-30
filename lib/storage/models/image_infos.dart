import 'package:firebase_storage/firebase_storage.dart';

class ImageInfos{

  String urlDownload;
  String name;
  String size;
  Reference ref;

  ImageInfos({
    required this.urlDownload,
    required this.name,
    required this.size,
    required this.ref
  });
}