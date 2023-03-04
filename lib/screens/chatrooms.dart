import 'package:chat_app2/screens/chatPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:rive/rive.dart' as rive;

class Chatrooms extends StatefulWidget {
  const Chatrooms({Key? key}) : super(key: key);

  @override
  State<Chatrooms> createState() => _ChatroomsState();
}

class _ChatroomsState extends State<Chatrooms> {
  final user = FirebaseAuth.instance.currentUser;
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
            preferredSize: Size.fromHeight(110.0),
            child: AppBar(
              toolbarHeight: 110.0,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark,
              ),
              title: Text('Speed Chat'),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 36,
              ),
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              actions: [
                IconButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  icon: Icon(Icons.logout),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chatrooms')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text('No chatrooms found'),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Something went wrong'),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(snapshot.data!.docs[index]['name']),
                            subtitle:
                                Text(snapshot.data!.docs[index]['subtitle']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    chatRoom: snapshot.data!.docs[index]
                                        ['name'],
                                    userEmail: user!.email,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
