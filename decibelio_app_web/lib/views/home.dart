import 'package:flutter/material.dart';
class HomeControllerPage  extends StatefulWidget {
  const HomeControllerPage ({Key? key}) : super(key: key);

  @override
  _SubirDatoState createState() => _SubirDatoState();
}

class _SubirDatoState extends State<HomeControllerPage > {

 @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HOME'),
          leading: const Icon(Icons.menu),
        ),
        body: ListView(
          children: [
            SizedBox(
              height: 200,
              width: 160,
              child: Center(
                child: Text(
                  "data",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
