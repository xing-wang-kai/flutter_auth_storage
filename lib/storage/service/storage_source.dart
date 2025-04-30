
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_with_flutter/storage/models/image_infos.dart';

class StorageService {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  String pathService = "profile_images/${FirebaseAuth.instance.currentUser!.uid}";


  Future<String> upload({required File file, required String fileName}) async {
    await _firebaseStorage.ref("$pathService/$fileName.png").putFile(file);


    String url = await _firebaseStorage.ref("$pathService/$fileName.png")
        .getDownloadURL();

    await _firebaseAuth.currentUser!.updatePhotoURL(url);
    return url;
  }

  Future<String?> getDownloadUrlByFileName({required String filename}) async {
    return await _firebaseStorage.ref("$pathService/$filename.png")
        .getDownloadURL();
  }

  Future<List<ImageInfos>?> getAllDownloadUrlFileName() async {
    ListResult results = await _firebaseStorage.ref(pathService).listAll();

    List<Reference> references = results.items;
    List<ImageInfos> imagesInfos = [];

    for (Reference reference in references) {
      String url = await reference.getDownloadURL();
      String name = reference.name;
      FullMetadata metadata = await reference.getMetadata();
      int? metaSize = metadata.size;
      String size = "Tamanho não informado";

      if (metaSize != null) {
        size = "${metaSize / 1000} Kb";
      }
      imagesInfos.add(ImageInfos(
          urlDownload: url,
          name: name,
          size: size,
          ref: reference));
    }

    return imagesInfos;
  }

  Future<void> deleteByReference({required ImageInfos imageInfo}) async {
    if(_firebaseAuth.currentUser!.photoURL != null){
      if(_firebaseAuth.currentUser!.photoURL != imageInfo.urlDownload){
        await _firebaseAuth.currentUser!.updatePhotoURL(null);
      }
    }
    return await imageInfo.ref.delete();
  }
}