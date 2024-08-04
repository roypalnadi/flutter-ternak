import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ternak/components/home.dart';
import 'package:ternak/profile.dart';
import 'package:ternak/qr_scanner.dart';

class MainMenu extends StatefulWidget {
  final User user;
  const MainMenu({super.key, required this.user});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Map<String, dynamic> _docUser = {};
  int _countAnimal = 0;
  int _countMale = 0;
  int _countFemale = 0;

  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.uid)
        .snapshots()
        .first
        .then((value) {
      setState(() {
        Map<String, dynamic>? dataUser = value.data();
        if (dataUser != null) {
          _docUser = dataUser;
        }

        FirebaseFirestore.instance
            .collection("hewan")
            .where("user_uid", isEqualTo: widget.user.uid)
            .get()
            .then((value) {
          var list = value.docs.toList();
          setState(() {
            _countAnimal = value.size;
            _countMale = list
                .where((element) => element.data()["jenis_kelamin"] == "Jantan")
                .length;
            _countFemale = list
                .where((element) => element.data()["jenis_kelamin"] == "Betina")
                .length;
          });
        });
      });
    });
  }

  int _currentIndex = 0;

  void _onTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Home(
        user: widget.user,
        countAnimal: _countAnimal,
        countMale: _countMale,
        countFemale: _countFemale,
        getData: getData,
      ),
      const QRScanner(),
      Profile(
        docUser: _docUser,
        user: widget.user,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 145, 170, 0.5),
        // Tambahkan identitas pengguna di sini
        title: Row(
          children: [
            Image.asset(
              "assets/images/icon-user.png",
            ),
            const SizedBox(
              width: 10,
            ),
            Text(_docUser["name"] ?? ""),
          ],
        ),
        // Misalnya, aksi Logout
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              size: 34,
              color: Color.fromRGBO(26, 107, 125, 1),
            ),
            onPressed: () {
              // Tambahkan logika untuk logout di sini
              print("notif");
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 15,
        backgroundColor: const Color.fromRGBO(26, 107, 125, 1),
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const QRScanner(),
            //     ));
            _currentIndex = 1; // Pindah ke tab search
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(29, 145, 170, 0.5),
        selectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      body: pages[_currentIndex],
    );
  }
}
