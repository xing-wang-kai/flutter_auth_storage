import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_with_flutter/firestore/helpers/enum_order_produto.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../firestore/models/listin.dart';
import '../model/produto.dart';
import 'widgets/list_tile_produto.dart';

class ProdutoScreen extends StatefulWidget {
  final Listin listin;

  const ProdutoScreen({super.key, required this.listin});

  @override
  State<ProdutoScreen> createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  List<Produto> listaProdutosPlanejados = [];

  List<Produto> listaProdutosPegos = [];

  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  orderProducts ordem = orderProducts.name;
  bool isDecrecent = false;

  late StreamSubscription stream;

  @override
  void initState() {
    setupListener();
    super.initState();
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.of(
            context,
          ).pushReplacementNamed("/");
        }, icon: Icon(Icons.keyboard_return)
        ),
        title: Text(widget.listin.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: orderProducts.name,
                  child: Text("Ordenar por Nome "),
                ),
                PopupMenuItem(
                  value: orderProducts.amount,
                  child: Text("Ordenar por quantidade "),
                ),
                PopupMenuItem(
                  value: orderProducts.price,
                  child: Text("Ordenar por Preço "),
                ),
              ];
            },
            onSelected: (value) {
              setState(() {
                isDecrecent = (ordem == value) ? !isDecrecent : false;
                ordem = value;
                refresh();
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text("R\$${calculateProductsGet().toStringAsFixed(2)}", style: TextStyle(fontSize: 42)),
                  Text(
                    "total previsto para essa compra",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Planejados",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              children: List.generate(listaProdutosPlanejados.length, (index) {
                Produto produto = listaProdutosPlanejados[index];
                return ListTileProduto(
                  produto: produto,
                  isComprado: false,
                  showModel: showFormModal,
                  toogleIsBuy: togglesProductsIsBuy,
                  removeItem: removeItem,
                );
              }),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Comprados",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              children: List.generate(listaProdutosPegos.length, (index) {
                Produto produto = listaProdutosPegos[index];
                return ListTileProduto(
                  produto: produto,
                  isComprado: true,
                  showModel: showFormModal,
                  toogleIsBuy: togglesProductsIsBuy,
                  removeItem: removeItem,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  showFormModal({Produto? model}) {
    // Labels à serem mostradas no Modal
    String labelTitle = "Adicionar Produto";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";

    // Controlador dos campos do produto
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    bool isComprado = false;

    // Caso esteja editando
    if (model != null) {
      labelTitle = "Editando ${model.name}";
      nameController.text = model.name;

      if (model.price != null) {
        priceController.text = model.price.toString();
      }

      if (model.amount != null) {
        amountController.text = model.amount.toString();
      }

      isComprado = model.isComprado;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(
                labelTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text("Nome do Produto*"),
                  icon: Icon(Icons.abc_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                decoration: const InputDecoration(
                  label: Text("Quantidade"),
                  icon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Preço"),
                  icon: Icon(Icons.attach_money_rounded),
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
                    child: Text(labelSkipButton),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Criar um objeto Produto com as infos
                      Produto produto = Produto(
                        id: (model != null) ? model.id : const Uuid().v1(),
                        name: nameController.text,
                        isComprado: isComprado,
                      );

                      if (amountController.text != "") {
                        produto.amount = double.parse(amountController.text);
                      }

                      if (priceController.text != "") {
                        produto.price = double.parse(priceController.text);
                      }

                      firestore
                          .collection(currentUserUid)
                          .doc(widget.listin.id)
                          .collection("products")
                          .doc(produto.id)
                          .set(produto.toMap());


                      // Fechar o Modal
                      Navigator.pop(context);
                    },
                    child: Text(labelConfirmationButton),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void refresh({QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    List<Produto> tempPlanejados = await productsFilter(isComprado: false, snapshot: snapshot);
    List<Produto> tempPegos = await productsFilter(isComprado: true, snapshot: snapshot);

    setState(() {
      listaProdutosPlanejados = tempPlanejados;
      listaProdutosPegos = tempPegos;
    });
  }

  Future<List<Produto>> productsFilter({
    required bool isComprado,
    QuerySnapshot<Map<String, dynamic>>? snapshot,
  }) async {
    List<Produto> temp = [];

     snapshot ??=
        await firestore
            .collection(currentUserUid)
            .doc(widget.listin.id)
            .collection("products")
            // .where("isComprado", isEqualTo: isComprado)
            .orderBy(ordem.name, descending: isDecrecent)
            .get();

    for (var doc in snapshot.docs) {
      if ((doc.data()['isComprado'] == isComprado)) {
        temp.add(Produto.fromMap(doc.data()));
      }
    }
    return temp;
  }

  void togglesProductsIsBuy(Produto produto) async {
    produto.isComprado = !produto.isComprado;

    await firestore
        .collection(currentUserUid)
        .doc(widget.listin.id)
        .collection("products")
        .doc(produto.id)
        .update({"isComprado": produto.isComprado});

  }

  void setupListener() {
    stream = firestore
        .collection(currentUserUid)
        .doc(widget.listin.id)
        .collection("products")
        .orderBy(ordem.name, descending: isDecrecent)
        .snapshots()
        .listen((snapshot) {
          setState(() {
            refresh(snapshot: snapshot);
          });
        });
  }

  void removeItem({required Produto produto}) async {
    await firestore
        .collection(currentUserUid)
        .doc(widget.listin.id)
        .collection("products")
        .doc(produto.id)
        .delete();
  }

  double calculateProductsGet(){
    double valor = 0;
    for(var products in listaProdutosPegos){
      if(products.amount != null && products.price != null) {
        valor += (products.amount! * products.price!);
      }
    }
    return valor;
  }
}
