import 'package:eureka/examout.dart';
import 'package:flutter/material.dart';

class ExamScreen extends StatefulWidget {
  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final _controller = TextEditingController();

  void _submitText() {
    final enteredText = _controller.text;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Examout(text: enteredText),
      ),
    );
    print(enteredText);
  }

  @override
  build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('AI Exam Paper'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 17,
                controller: _controller,
                decoration: InputDecoration(
                    hintText: 'Enter Exam Content',
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    _submitText;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Examout(text: _controller.text),
                      ),
                    );
                  },
                  child: Text('Submit'))
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'ExamPrep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Assesment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Ask',
          ),
        ]));
  }
}
