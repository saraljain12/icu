//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icu/screens/home_screen/home_screen.dart';

import './quiz.dart';

class Questions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyQuestionsState();
  }
}

class _MyQuestionsState extends State<Questions> {
  final _questions = const [
    {
      'questionText': 'Who created flutter',
      'answers': [
        {'text': 'Facebook', 'score': -2},
        {'text': 'Adobe', 'score': -2},
        {'text': 'Google', 'score': 10},
        {'text': 'Microsoft', 'score': -2},
      ],
    },
    {
      'questionText': ' What is Flutter?',
      'answers': [
        {'text': 'Android Development Kit', 'score': -2},
        {'text': 'IOS Development Kit', 'score': -2},
        {'text': 'Web Development Kit', 'score': -2},
        {
          'text':
              'SDK to build beautiful IOS, Android, Web & Desktop Native Apps',
          'score': 10
        },
      ],
    },
    {
      'questionText': '  Which programing language is used by Flutter',
      'answers': [
        {'text': 'Ruby', 'score': -2},
        {'text': 'Dart', 'score': 10},
        {'text': 'C++', 'score': -2},
        {'text': 'Kotlin', 'score': -2},
      ],
    },
    {
      'questionText': ' Who created Dart programing language?',
      'answers': [
        {'text': 'Lars Bak and Kasper Lund', 'score': 10},
        {'text': 'Brendan Eich', 'score': -2},
        {'text': 'Bjarne Stroustrup', 'score': -2},
        {'text': 'Jeremy Ashkenas', 'score': -2},
      ],
    },
    {
      'questionText': 'prefgender',
      'answers': [
        {
          'text': 'Male',
          'score': -2,
        },
        {'text': 'Female', 'score': 10},
      ],
    },
  ];

  var _questionIndex = 0;
  Map<String, dynamic> demodata = {};

  void _answerQuestion(String text) {
    setState(() {
      _questionIndex = _questionIndex + 1;
    });
    String uid = FirebaseAuth.instance.currentUser.uid;
    demodata.addAll(
        {_questions[_questionIndex - 1].values.elementAt(0): text.toString()});
    DocumentReference docReference =
        FirebaseFirestore.instance.collection('Users').doc(uid);
    docReference.update(demodata);

    if (_questionIndex < _questions.length) {
      print('We have more questions!');
    } else {
      print('No more questions!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(30.0),
            child: _questionIndex < _questions.length
                ? Quiz(
                    answerQuestion: _answerQuestion,
                    questionIndex: _questionIndex,
                    questions: _questions,
                  ) //Quiz
                : Navigator.pushNamedAndRemoveUntil(
                    context, '/homeScreen', ModalRoute.withName('/'))),
      ), //Padding //Scaffold
      debugShowCheckedModeBanner: false,
    ); //MaterialApp
  }
}
