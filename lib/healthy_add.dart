import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ternak/animal_menu.dart';

class HealthyAdd extends StatefulWidget {
  final User user;
  const HealthyAdd({super.key, required this.user});

  @override
  State<HealthyAdd> createState() => HealthyAddState();
}

class HealthyAddState extends State<HealthyAdd> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tanggalController = TextEditingController();

  bool _demamCheck = false;
  bool _nafsuCheck = false;

  File? _image;
  final picker = ImagePicker();

  DocumentSnapshot<Map<String, dynamic>>? animal;

  Future _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addHealthy() {
    var kesehatan = FirebaseFirestore.instance.collection('kesehatan');

    List<String> gejala = [];
    _demamCheck ? gejala.add("Demam") : null;
    _nafsuCheck ? gejala.add("Nafsu Makan Turun") : null;

    kesehatan.add({
      "user_uid": widget.user.uid,
      "hewan_nama": animal?.data()?["nama"],
      "hewan_id": animal?.id,
      "tanggal": _tanggalController.text,
      "gejala": gejala,
    }).then((value) {
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child("kesehatan");
        final imagesRef = storageRef.child(value.id);
        imagesRef.putFile(_image!);
      }

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 145, 170, 0.5),
        title: const Text(
          "Kesehatan",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Foto Gejala",
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _showPicker(context),
                child: _image == null
                    ? DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(5),
                        dashPattern: const [10, 10],
                        color: const Color.fromRGBO(26, 107, 125, 1),
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Color.fromRGBO(26, 107, 125, 1),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Upload Gejala",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromRGBO(26, 107, 125, 1),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    : Image.file(_image!),
              ),
              const SizedBox(height: 20),
              const Text(
                "Gejala",
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                value: _demamCheck,
                onChanged: (value) => setState(() {
                  _demamCheck = !_demamCheck;
                }),
                title: const Text("Demam"),
              ),
              CheckboxListTile(
                value: _nafsuCheck,
                onChanged: (value) => setState(() {
                  _nafsuCheck = !_nafsuCheck;
                }),
                title: const Text("Nafsu Makan Turun"),
              ),
              TextFormField(
                controller: _tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Sakit',
                  suffix: Icon(Icons.date_range_outlined),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Masukan tanggal sakit";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Hewan Sakit",
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                // height: 80,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10.0,
                      offset: Offset(1, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        (animal == null)
                            ? "Pilih Hewan yang Sakit"
                            : (animal!.data()?["nama"] ?? ""),
                        style: TextStyle(
                            fontSize: 18,
                            color:
                                (animal == null) ? Colors.grey : Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromRGBO(48, 130, 148, 0.45),
                      ),
                      onPressed: () {
                        Navigator.push<DocumentSnapshot<Map<String, dynamic>>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuAnimal(
                                user: widget.user,
                                isForHealthy: true,
                              ),
                            )).then((value) => setState(() {
                              animal = value;
                            }));
                      },
                      child: const Text(
                        "Pilih",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // padding: EdgeInsets.all(20),
                  backgroundColor: const Color.fromRGBO(26, 107, 125, 1),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    _addHealthy();
                  }
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
