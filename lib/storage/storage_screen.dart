import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_with_flutter/authentication/widgets/show_snackbar.dart';
import 'package:firebase_with_flutter/storage/service/storage_source.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'models/image_infos.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();
  List<ImageInfos> imageInfos = [];
  String? urlPhoto;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Image"),
        actions: [
          IconButton(
            onPressed: () {
              return uploadImage(context: context);
            },
            icon: Icon(Icons.upload),
          ),
          IconButton(
            onPressed: () {
              refresh();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
        leading: IconButton(onPressed: (){
          Navigator.of(
            context,
          ).pushReplacementNamed("/");
        }, icon: Icon(Icons.keyboard_return)
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(32.00),
        padding: EdgeInsets.all(16.00),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [BoxShadow(color: Colors.black)],
        ),
        child: Column(
          children: [
            (urlPhoto != null)
                ?
                  ClipRRect(
                    borderRadius: BorderRadius.circular(64),
                    child: SizedBox(
                      height: 128,
                      width: 128,
                      child: Image.network(
                            urlPhoto!,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                        ),
                    ),
                  )
                : Center(
                  child: CircleAvatar(
                    radius: 64,
                    child: Icon(Icons.person, size: 64),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Divider(color: Colors.black),
            ),
            Text(
              "Histórico de Imagens",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(imageInfos.length, (index) {
                    String url = imageInfos[index].urlDownload;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: ListTile(
                        onTap: (){
                          redifineUrlPhoto(url: url);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.network(
                              url,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          imageInfos[index].name,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            imageInfos[index].size,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)
                        ),
                        trailing: IconButton(
                            onPressed: (){
                              removePhotoByRef(image: imageInfos[index]);
                            },
                            icon: Icon(Icons.delete , color: Colors.red),
                          )
                      ),
                    );
                  })
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void uploadImage({required BuildContext context}) async {
    ImagePicker imagePicker = ImagePicker();

    imagePicker
        .pickImage(
          source: ImageSource.gallery,
          maxHeight: 2000,
          maxWidth: 2000,
          imageQuality: 50,
        )
        .then((XFile? file) {
          if (file != null) {
            _storageService
                .upload(file: File(file.path), fileName: DateTime.now().toString())
                .then((url) {

                  urlPhoto = url;
                  refresh();
                });
          } else {
            showSnackBar(
              context: context,
              message: "Error ao carregar o arquivo! ",
            );
          }
        });
  }

  void refresh() {

    setState(() {
      urlPhoto = _firebaseAuth.currentUser!.photoURL;
    });
    _storageService.getAllDownloadUrlFileName().then((infos){
      setState(() {
        if(infos != null) {
          imageInfos = infos;
        }
      });
    });
  }

  void redifineUrlPhoto({required String url}){
    setState(() async {
      await _firebaseAuth.currentUser!.updatePhotoURL(url);
      refresh();
    });
  }

  void removePhotoByRef({required ImageInfos image}){
    _storageService.deleteByReference(imageInfo: image).then((value){
      if(urlPhoto == image.urlDownload){
        setState(() {
          urlPhoto == null;
        });

      }
      refresh();
    });
  }
}
