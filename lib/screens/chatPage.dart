import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:rive/rive.dart' as rive;

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.chatRoom, required this.userEmail})
      : super(key: key);
  String chatRoom = '';
  String? userEmail = '';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var messageController = TextEditingController();
  final _listViewController = ScrollController();
  bool isFABVisible = false;
  bool newMessages = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listViewController.addListener(() {
      if (_listViewController.position.pixels == 0) {
        setState(() {
          isFABVisible = false;
        });
      } else {
        setState(() {
          isFABVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        rive.RiveAnimation.asset(
          'assets/bg4.riv',
          fit: BoxFit.cover,
        ),
        GlassmorphicContainer(
          width: screenWidth,
          height: screenHeight,
          borderRadius: 0,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFffffff).withOpacity(0.1),
              Color(0xFFFFFFFF).withOpacity(0.05),
            ],
            stops: [
              0.1,
              1,
            ],
          ),
          border: 0,
          blur: 30,
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFffffff).withOpacity(0.5),
              Color((0xFFFFFFFF)).withOpacity(0.5),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(80.0),
            child: AppBar(
              toolbarHeight: 80.0,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark,
              ),
              title: Text(widget.chatRoom),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(widget.chatRoom)
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('Nothing to show'),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Something went wrong'),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 70.0),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _listViewController,
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          bool sentByMe = widget.userEmail ==
                              snapshot.data!.docs[index]['email'];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              alignment: sentByMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: sentByMe
                                    ? EdgeInsets.only(left: 30.0)
                                    : EdgeInsets.only(right: 30.0),
                                decoration: BoxDecoration(
                                  color: sentByMe
                                      ? Colors.grey.shade300
                                      : Colors.lightGreen,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                    bottomLeft: sentByMe
                                        ? Radius.circular(20.0)
                                        : Radius.circular(0.0),
                                    bottomRight: sentByMe
                                        ? Radius.circular(0.0)
                                        : Radius.circular(20.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 24.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          snapshot.data!.docs[index]['email'],
                                          style: TextStyle(
                                            color: sentByMe
                                                ? Colors.grey.shade700
                                                : Colors.green.shade900,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          snapshot.data!.docs[index]['message'],
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: screenWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        color: Colors.grey.withAlpha(100),
                        padding: EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                          right: 20.0,
                          left: 20.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: messageController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Send a message',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                if (messageController.text.isNotEmpty) {
                                  Map<String, dynamic> messageData = {
                                    'email': widget.userEmail,
                                    'message': messageController.text,
                                    'time':
                                        DateTime.now().millisecondsSinceEpoch,
                                  };
                                  FirebaseFirestore.instance
                                      .collection(widget.chatRoom)
                                      .add(messageData);
                                  messageController.clear();
                                }
                              },
                              child: Container(
                                height: 40.0,
                                width: 40.0,
                                decoration: BoxDecoration(
                                  color: Colors.cyan,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Visibility(
            visible: isFABVisible,
            child: Align(
              alignment: Alignment(1, 0.75),
              child: SizedBox(
                height: 40,
                width: 40,
                child: FloatingActionButton(
                  onPressed: () {
                    _listViewController.animateTo(
                      _listViewController.position.minScrollExtent,
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                    );
                  },
                  child: const Icon(
                    Icons.arrow_downward,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
