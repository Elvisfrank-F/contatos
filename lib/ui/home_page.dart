import 'dart:io';

import 'package:flutter/material.dart';

import '../helper_contats/contact_helper.dart';
import 'contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderA, orderB}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = [];

  @override
  void initState(){
    super.initState();

    //Contact c = Contact();

    // c.name = "Marquinhos_gratuito";
    // c.email = "marcosbalde@gmail.com";
    // c.phone = "859814404856";
    // c.img = "imgtest";

    //helper.saveContact(c);

    helper.getAllContacts().then((list){
      setState(() {
        contacts = list;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos",
        style: TextStyle(color: Colors.white),),
            centerTitle: true,
            backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
          onPressed: (){
    
            _showContactPage(null);
          },
      child: Icon(Icons.add)),
    
      body: SafeArea(
        child: ListView.builder(
          itemCount: contacts.length,
          padding: EdgeInsets.all(10.0),
          itemBuilder: (context, index){
         return contato(context, index, contacts[index]);
          },
        ),
      ),
    );
  }

  Widget contato(BuildContext context, int index, Contact contact) {
    return GestureDetector(

      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null ?
                        FileImage(File(contacts[index].img!)) :
                        AssetImage("assets/person.jpeg"),
                    fit: BoxFit.cover,
                  )
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contacts[index].name ?? "",
                  style: TextStyle(fontSize: 22,
                  fontWeight: FontWeight.bold)),
                  Text(contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18,
                      )),
                  Text(contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 18))


                ]


              ),

              )
            ],
          ),
        ),
      ),
      onTap: (){


        _showOptions(context, index);

      },
    );
  }

  void _showOptions(BuildContext context, int index) {

    showModalBottomSheet(
    context: context,
      builder: (context){
      return BottomSheet(
        onClosing: (){},
        builder: (context){
          return SafeArea(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        child: Text("Ligar"),
                        onPressed: (){
                          final Uri telLink = Uri.parse("tel:${contacts[index].phone!}");
                          launchUrl(telLink);
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        child: Text("Editar"),
                        onPressed: (){
                          Navigator.pop(context);
                          _showContactPage(contacts[index]);

                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        child: Text("Excluir"),
                        onPressed: (){


                        Navigator.pop(context);
                        setState(() {
                          helper.delContact(contacts[index].id!);
                          contacts.removeAt(index);
                        });
                        }),
                  ),
                ],
              ),
            ),
          );
        }
      );
      }
    );
  }


  Widget verBD(){
    return  FutureBuilder<List<Contact>>(
        future: helper.getAllContacts(),
        builder: (context, snapshot) {

          if(!snapshot.hasData){
            return const Center(child: CircularProgressIndicator());
          }

          List<Contact> list = snapshot.data!;

          return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index){

                Contact c = list[index];

                return SizedBox(
                  child: Column(
                    children: [
                      Text(c.name!),
                      Text(c.email!),
                      Text(c.phone!),
                    ],
                  ),
                );

              });


        });
  }

  Future<void> _showContactPage(Contact? contato) async {

    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder:(context) => ContactPage(contact: contato)));

    if(recContact != null){
      if(contato != null) {
        await helper.updateContact(recContact);
      }
      else {
        await helper.saveContact(recContact);
      }
      helper.getAllContacts().then((list){
        setState(() {
          contacts = list;
        });
      });
    }

  }
}
