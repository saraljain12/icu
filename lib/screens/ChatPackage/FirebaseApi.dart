//@dart=2.9
import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:icu/screens/ChatPackage/virtualdate.dart';
import 'package:icu/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

String url;
class Chat extends StatefulWidget {
    String uid2;
   Chat({ this.uid2});
   @override
  _ChatState createState() => _ChatState(uid2: uid2);
}

class _ChatState extends State<Chat> {

   String uid2;
  _ChatState({ this.uid2});

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageEditingController = new TextEditingController();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  final String uid = _auth.currentUser.uid;
  final controller = ScrollController();
  ClientRole _role = ClientRole.Broadcaster;
  // late bool isShowSticker;

  sendMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageEditingController.text,
        "send by": databaseMethods.uid,
        "read": false,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch
      };

      databaseMethods.addMessage(uid2, messageMap);
    }
  }

  gotobottom() {
      Timer(Duration(milliseconds: 150),
          () {  controller.hasClients ?
            controller.animateTo(controller.position.maxScrollExtent, duration: Duration(milliseconds: 500), curve:Curves.easeOut):
            gotobottom();
        }
      );

  }


  @override
  void didChangeDependencies() {
    gotobottom();
  }

  // String url;
  String name;

    getimage() async{
      DocumentReference docref =  FirebaseFirestore.instance.collection("Users").doc(uid2);
      var docSnapshot = await docref.get();
     if (docSnapshot.exists) {
       setState(() {
         Map<String, dynamic>data = docSnapshot.data();
         url = data['image1url'];
         name = data['name'];
       });
     }
   }

   Future<void> onJoin() async {
     // update input validation
     // await for camera and mic permissions before pushing video page
     await _handleCameraAndMic(Permission.camera);
     await _handleCameraAndMic(Permission.microphone);
     // push video page with given channel name
     await Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => CallPage(
           channelName: 'firstchannel',
           role: _role,
         ),
       ),
     );
   }

   Future<void> _handleCameraAndMic(Permission permission) async {
     final status = await permission.request();
     print(status);
   }

  @override
  void initState() {
      getimage();
     gotobottom();
    super.initState();
  }



  Widget chatMessages(){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Match").doc(uid)
          .collection(uid+"_"+uid2).orderBy("time").snapshots(),
      builder: (context, snapshot){
        return snapshot.hasData ?  ListView.builder(
          controller: controller,
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index){
              int dateTime = snapshot.data.docs[index].get("time");
              var date = DateTime.fromMillisecondsSinceEpoch(dateTime);
              var formattedDate = DateFormat('HH:mm').format(date);

              return MessageTile(
                message : snapshot.data.docs[index].get("message"),
                sendByMe: (snapshot.data.docs[index].get("send by")==uid)?true:false,
                dateTime: formattedDate,
              );
            }
            ) : Container();
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
            leading: GestureDetector(onTap: (){Navigator.pop(context);},child: Icon(Icons.arrow_back_ios,color: Colors.black,)),
           shadowColor: ( Color(0x29000000)),
         actions: <Widget>[
           InkWell(
               onTap:() {
                onJoin();
               },
               child: Padding(
                 padding: new EdgeInsets.fromLTRB(0, 0, 20, 0),
                 child: Icon(
                   Icons.video_call,
                   color: Colors.black,
                 ),
               ))
         ],
         backgroundColor: Colors.white,
         title:  Row(
           children: [
             CircleAvatar(
               radius: 20,
               backgroundImage:  (url!=null)?NetworkImage(url):AssetImage('assets/images/Logo.png'),
               backgroundColor: Colors.transparent,
             ),
             SizedBox(width: 15),
             Center(
               child: Text((name!=null)?name:"I Choose You",
                 style: TextStyle(
                   fontFamily: 'Rubik',
                   color: Color(0xff333343),
                   fontSize: 20,
                   fontWeight: FontWeight.w500,
                   fontStyle: FontStyle.normal,
                 )
       ),
             ),
           ],
         ),
      ),
      body: Container(
        child: Stack(
          children: [
            Container(margin: EdgeInsets.only(bottom: 70 ),child: chatMessages()),
            Container(alignment: Alignment.bottomCenter,
              margin: EdgeInsets.symmetric(horizontal: 12,vertical: 20),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Container(
                      height: 50,
                      decoration: new BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [BoxShadow(
                            color: Color(0x29000000),
                            offset: Offset(0,0),
                            blurRadius: 3,
                            spreadRadius: 0
                        ) ],
                      ),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageEditingController,
                          decoration: InputDecoration(
                              hintText: "Message ...",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w400
                              ),
                              border: InputBorder.none
                          ),
                          style: TextStyle(
                            fontSize: 20,
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400
                          ),
                        )),
                    // SizedBox(width: 16,),
                    // GestureDetector(
                    //   onTap: () {
                    //     // setState(() {
                    //     //   isShowSticker = !isShowSticker;
                    //     // });
                    //   },
                    //   child: Icon(Icons.emoji_emotions_outlined,size: 30, color: Colors.grey,),
                    //
                    // ),
                    SizedBox(width: 16,),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                        if (controller.hasClients) gotobottom();
                        messageEditingController.clear();
                      },
                      child: Icon(Icons.send,size: 30, color: Colors.grey,),

                    ),
                  ],
                ),
              ),
            ),
           // (isShowSticker ? buildSticker() : Container()),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final String dateTime;

  MessageTile({this.message,this.sendByMe, this.dateTime});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe ? 0 : 24,
          right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: sendByMe ? CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          !sendByMe?Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:  (url!=null)?NetworkImage(url):AssetImage('assets/images/Logo.png'),
                backgroundColor: Colors.transparent,
              ),
              Container(margin: EdgeInsets.only(left: 0,right: 5,top: 2),),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: sendByMe
                          ? EdgeInsets.only(left: 30)
                          : EdgeInsets.only(right: 30),
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 16, right: 16),
                      decoration: BoxDecoration(
                          borderRadius: sendByMe ? BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20)
                          ) :
                          BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20)
                          ),
                              color: const Color(0xfff1f0f0),
                      ),
                      child: Flexible(
                        child: Text(message,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w400)),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Text(dateTime,style: TextStyle(
                          fontFamily: 'Rubik',
                          color: Color(0xff707070),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        )
                        )
                    )
                  ],
                ),
              ),
            ],
          ):
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: sendByMe
                    ? EdgeInsets.only(left: 30)
                    : EdgeInsets.only(right: 30),
                padding: EdgeInsets.only(
                    top: 10, bottom: 10, left: 16, right: 16),
                decoration: BoxDecoration(
                  borderRadius: sendByMe ? BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)
                  ) :
                  BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)
                  ),
                  color: const Color(0xfff1f0f0),
                ),
                child: Text(message,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w400)),
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Text(dateTime,style: TextStyle(
                    fontFamily: 'Rubik',
                    color: Color(0xff707070),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  )
                  )
              )
            ],
          ),

        ],
      ),
    );
  }
}