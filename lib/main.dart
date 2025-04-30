import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_with_flutter/authentication/screens/authentication_screen.dart';
import 'package:firebase_with_flutter/designer/general_theme_data.dart';
import 'package:firebase_with_flutter/firestore_produtos/presentation/produto_screen.dart';
import 'package:firebase_with_flutter/storage/storage_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '_core/my_colors.dart';
import 'firebase_options.dart';
import 'firestore/presentation/home_screen.dart';
import '../firestore/models/listin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore
      .collection("only for testing")
      .doc("this is only a firestore testing")
      .set({"thisworking": true});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: generalThemeData,
      initialRoute: "/",
      routes: {
        "/": (context) => ScreensRouters(),
        "change_profile_photo": (context) => StorageScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == "produtos") {
          final Listin listin = settings.arguments as Listin;
          return MaterialPageRoute(
            builder: (context) {
              return ProdutoScreen(listin: listin);
            },
          );
        }
        return null;
      },
    );
  }
}

class ScreensRouters extends StatelessWidget {
  const ScreensRouters({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        }
        else{
          if(snapshot.hasData){
            return HomeScreen(user: snapshot.data!);
          }
          else{
            return AuthScreen();
          }
        }
      },
    );
  }
}
