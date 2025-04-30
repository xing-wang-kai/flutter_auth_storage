import 'package:flutter/material.dart';
import '../../model/produto.dart';

class ListTileProduto extends StatelessWidget {
  final Produto produto;
  final bool isComprado;
  final Function showModel;
  final Function toogleIsBuy;
  final Function removeItem;
  const ListTileProduto({
    super.key,
    required this.produto,
    required this.isComprado,
    required this.showModel,
    required this.toogleIsBuy,
    required this.removeItem,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: (){
        showModel(model: produto);
      },
      onTap: () async {
        toogleIsBuy(produto);
      },
      leading: Icon(
        (isComprado) ? Icons.shopping_basket : Icons.check,
      ),
      trailing: IconButton(onPressed: (){
        removeItem(produto: produto);
      }, icon: Icon(Icons.delete, color: Colors.red,)),
      title: Text(
        (produto.amount == null)
            ? produto.name
            : "${produto.name} (x${produto.amount!.toInt()})",
      ),
      subtitle: Text(
        (produto.price == null)
            ? "Clique para adicionar preço"
            : "R\$ ${produto.price!}",
      ),
    );
  }
}
