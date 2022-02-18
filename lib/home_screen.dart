import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _password;
  late double passLength = 0;
  late String passText = "Please enter your password";
  RegExp numReg = RegExp(r".*[0-9].*");
  RegExp letterReg = RegExp(r".*[A-Za-z].*");
  void checkPassword (String value){
    _password = value.trim();
    if (_password.isEmpty) {
      setState(() {
        passLength = 0;
        passText = "Please enter your password";
      });

    } else if (_password.length < 6) {

     setState(() {
       passLength = 1 / 4;
       passText = "your password is short";
     });

    } else if (_password.length < 8) {

      setState(() {
        passLength = 2 / 4;
        passText = "your password is not strong";
      });

    } else if (!numReg.hasMatch(_password) || !letterReg.hasMatch(_password)) {
     setState(() {
       passLength = 3 / 4;
       passText = "your password is Strong";
     });

    } else {

      setState(() {
        passLength = 1;
        passText = "your password is very strong";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Strong"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.lock),
                hintText: "Password",
              ),
              obscureText: true,
              onChanged: (value) => checkPassword(value),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter password";
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(
              height: 20,
            ),
            LinearProgressIndicator(
              value: passLength,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: passLength <= 1 / 4
                  ? Colors.red
                  : passLength == 2 / 4
                      ? Colors.orangeAccent
                      : passLength == 3 / 4
                          ? Colors.blue
                          : Colors.green,
            ),
            Text(
              passText,
              style: const TextStyle(fontSize: 18 ,),
            ),
            ElevatedButton(
              onPressed:passLength < 2/ 4 ? null : () {},
              child: const Text("submit"),
            ),
          ],
        ),
      ),
    );
  }
}
