# firebase_with_flutter

Essa aplicacão tem como objetivo explocar diversas possibilidades de uso do Firebase, Nesse projeto usamos:

- **Banco de dados** : Banco de dados __noSQL__ do firebase para se conectar e enviar arquivos, além de coletar arquivo com conexão Async, além disso usei Streams para veririfar mudançaas com o banco de dados do firebase em tempo real.

- **Firebase Auth** : Autenticação do firebase simples com login e senha, validação de existencia de conta e criação de outras contas, além de configurar e-mail de esqueci password. Configurado e conectado o banco de dados noSql para que somente os usuários logados possam acessas suas informações.

- **Firebase Store** : Usado o Firebase Store para conectar a API e gravar arquivos como a foto de perfil do usuário, além de configurar regras de negócio onde somente o usuários logados poderão acessar suas respectivas pasta, impedindo assim o acesso publico ao Store de arquivos.

# TELAS
___

## LOGIN / RESET PASSWORD / CREATE ACCOUNT

Ao iniciar a aplicação o usuário terá a visão da tela de login com as sequintes funções:

- **LOGIN**: Caso já tenha conta, poderá realizar o login com senha e e-mail, caso ocorra um error será noticado que conta é inválida.
- **CRIAR CONTA**: Criar um novo usuário, caso não tenha conta poderá criar um novo usuário com e-mail e senha.
- **RESET DE SENHA**: Atribuída a responsábilidade para o usuário resetar sua senha caso tenha perdido, ao preencher o formulário de reset de senha receberá um e-mail com link para executar o reset manual de seu password.

## Tela de Login
<div align="center">

![img.png](img.png)

</div>

## Tela de Reset Password

<div align="center">

![img_1.png](img_1.png)

</div>

## Tela de Create Account

<div align="center">

![img_2.png](img_2.png)

</div>