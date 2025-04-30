import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_with_flutter/authentication/services/auth_service.dart';
import 'package:firebase_with_flutter/firestore/widgets/show_password_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/listin.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listListins = [];

  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            Center(
              child: UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: (widget.user.photoURL != null)?
                        NetworkImage(widget.user.photoURL!) :
                        null,
                  backgroundColor: Colors.white,
                ),
                accountName: Text(
                  (widget.user.displayName != null)
                      ? widget.user.displayName!
                      : "",
                ),
                accountEmail: Text(widget.user.email!),
                onDetailsPressed: (){
                  Navigator.of(
                    context,
                  ).pushReplacementNamed("change_profile_photo");
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text("Apagar Conta?"),
              onTap: () {
                showPasswordConfirmationDialog(context: context, email: "");
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout!"),
              onTap: () {
                AuthService().logoutUser();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: const Text("Kodersolutions - Feira Colaborativa")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body:
          (listListins.isEmpty)
              ? const Center(
                child: Text(
                  "Nenhuma lista ainda.\nVamos criar a primeira?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
              : RefreshIndicator(
                onRefresh: () async {
                  return refresh();
                },
                child: ListView(
                  children: List.generate(listListins.length, (index) {
                    Listin model = listListins[index];
                    return Dismissible(
                      key: ValueKey<Listin>(model),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(color: Colors.red),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                      onDismissed: (directional) {
                        remove(model);
                      },
                      child: ListTile(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed("produtos", arguments: model);
                        },
                        onLongPress: () {
                          showFormModal(model: model);
                        },
                        leading: const Icon(Icons.list_alt_rounded),
                        title: Text(model.name),
                        subtitle: Text(model.id),
                      ),
                    );
                  }),
                ),
              ),
    );
  }

  showFormModal({Listin? model}) {
    // Labels à serem mostradas no Modal
    String title = (model != null) ? "Editar o Item?" : "Adicionar Listin";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    // Controlador do campo que receberá o nome do Listin
    TextEditingController nameController = TextEditingController();

    if (model != null) {
      nameController.text = model.name;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,

      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  label: Text("Nome do Listin"),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(skipButton),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Listin listin = Listin(
                        id: (model != null) ? model.id : Uuid().v1(),
                        name: nameController.text,
                      );

                      firestore
                          .collection(currentUserUid)
                          .doc(listin.id)
                          .set(listin.toMap());

                      refresh();

                      Navigator.pop(context);
                    },
                    child: Text(confirmationButton),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void refresh() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection(currentUserUid).get();

    List<Listin> listins = [];
    for (var doc in snapshot.docs) {
      listins.add(Listin.fromMap(doc.data()));
    }
    setState(() {
      listListins = listins;
    });
  }

  void remove(Listin model) {
    firestore.collection(currentUserUid).doc(model.id).delete();
    refresh();
  }
}
