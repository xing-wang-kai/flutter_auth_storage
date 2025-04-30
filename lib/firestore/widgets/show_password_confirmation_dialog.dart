import "package:firebase_with_flutter/authentication/services/auth_service.dart";
import "package:firebase_with_flutter/authentication/widgets/show_snackbar.dart";
import "package:flutter/material.dart";

void showPasswordConfirmationDialog({
  required BuildContext context,
  required String email,
}) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController _passwordConfirmController =
          TextEditingController();
      return AlertDialog(
        title: Text("Realmente deseja Remover sua conta com email $email?"),
        content: SizedBox(
          height: 250,
          child: Column(
            children: [
              Text("Atenção!! Todos seus dados serão perdidos permanentemente"),
              Text("Sendo assim não haverá nenhuma forma de recuperá-los."),
              Text("Para confirmar a remoção de sua Conta digite sua Senha:"),
              TextFormField(
                obscureText: true,
                controller: _passwordConfirmController,
                decoration: InputDecoration(label: Text("Password")),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AuthService().removeAccount(
                password: _passwordConfirmController.text,
              ).then((erro){
                if(erro != null){
                  showSnackBar(context: context, message: erro);
                }
                else{
                  Navigator.of(context).pop();
                }
              });
            },
            child: Text("Confirmar Remoção de Conta?"),
          ),
        ],
      );
    },
  );
}
