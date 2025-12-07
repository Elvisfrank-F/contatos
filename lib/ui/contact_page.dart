import 'dart:io';

import 'package:flutter/material.dart';
import 'package:contatos/helper_contats/contact_helper.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:image_picker/image_picker.dart';
class ContactPage extends StatefulWidget {

final Contact? contact;

  const ContactPage({super.key, required this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  Contact? _editedContact;



  TextEditingController _controllerNome = new TextEditingController();
  TextEditingController _controllerEmail = new TextEditingController();
  TextEditingController _controllerPhone = new TextEditingController();

  bool _userEdited = false; //variavel para saber se o usuario ta ou nao editando

  var maskNumber = new MaskTextInputFormatter(
    mask: '+## (##)#####-####',
    filter: {"#" : RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy
  );

  @override
  void initState(){
    super.initState();

    if(widget.contact == null){
    _editedContact = Contact();
    }
    else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _controllerEmail.text = _editedContact!.email ?? "";
      _controllerPhone.text = _editedContact!.phone ?? "";
      _controllerNome.text = _editedContact!.name ?? "";
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(_editedContact!.name ?? "Novo Contato",
        style: TextStyle(color: Colors.white),),
        leading: IconButton(onPressed: () {
          if (_userEdited) {
            showDialog<void>(context: context,

                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("ALERTA"),
                    content: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.7,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.05,
                      child: Column(
                        children: [
                          Text("Deseja descartar as alterações?")
                        ],
                      ),
                    ),

                    actions: [
                      TextButton(child: Text("CANCELAR"), onPressed: () {
                        Navigator.pop(context);
                      },),
                      TextButton(child: Text("DESCARTAR"), onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },)
                    ],
                  );
                });
          }
          else {
            Navigator.pop(context);
          }
        }, icon: Icon(Icons.arrow_back)),
        centerTitle: true,
        backgroundColor: Colors.red,


      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        if(_editedContact!.name!.isNotEmpty){
          Navigator.pop(context, _editedContact);
        }
      },
      child: Icon(Icons.save, color: Colors.white),
      backgroundColor: Colors.red,),

      body: SingleChildScrollView(
        child: Center(
          child: Padding(padding: EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 300,
                  height: 300,
                
                  decoration: BoxDecoration(
                
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContact!.img != null ?
                          FileImage(File(_editedContact!.img!)) :
                          AssetImage("assets/person.jpeg"),
                      fit: BoxFit.cover
                    )
                
                  )
                ),
                onTap:(){
               _showOptions(context);
                }
              ),
              TextField(
                controller: _controllerNome,
                decoration: InputDecoration(
                  label: Text("Nome")
                ),

                onChanged: (text){
                  _userEdited = true;
                  setState(() {
                    _editedContact!.name = text;
                  });
                  if(text ==""){
                    _userEdited = false;
                    _editedContact!.name = "Novo contato";
                  }
                },

              ),
              SizedBox(height: 10,),
              TextField(
                controller: _controllerEmail,
                decoration: InputDecoration(
                    label: Text("Email")
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (text){
                  _editedContact!.email = text;                },
              ),
              SizedBox(height: 10,),
              TextField(
                keyboardType: TextInputType.phone,
                inputFormatters: [maskNumber],
                decoration: InputDecoration(
                    label: Text("Phone")
                ),
                onChanged: (text){
                  _editedContact!.phone = text;
                  },
              )







            ],
          )),
        ),
      ),

    );
  }

  Future<File?> pickFromGallery() async{
    final ImagePicker picker = new ImagePicker();

    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      imageQuality: 80,
    );
    if(image == null) return null;
    return File(image.path);
  }

  Future<File?> pickFromCamera() async{
    final ImagePicker picker = new ImagePicker();

    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1080,
    );

    if(photo == null) return null;
    return File(photo.path);
  }

  void _showOptions(BuildContext context){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(onClosing: (){},
            builder: (context){

          return SafeArea(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(onPressed: () async{

                      File? img = await pickFromCamera();

                      setState(() {

                        if(img == null){

                        }
                        else {
                          _editedContact!.img = img.path;
                        }

                      });


                      Navigator.pop(context);


                    }, icon: Icon(Icons.camera_alt))
                  ),


                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(onPressed: () async{
                      File? img = await pickFromGallery();
                      setState(() {
                       if(img == null){

                       }
                       else {
                         _editedContact!.img = img.path;
                       }
                       Navigator.pop(context);

                      });
                    }, icon: Icon(Icons.add_photo_alternate_outlined))
                  )
                ],
              ),
            ),
          );
            });
      }
    );
  }

}
