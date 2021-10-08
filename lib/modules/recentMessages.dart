import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:socialapp/cubit/socialCubit.dart';
import 'package:socialapp/cubit/states.dart';
import 'package:socialapp/layouts/sociallayout.dart';
import 'package:socialapp/models/recentMessagesModel.dart';
import 'package:socialapp/models/userModel.dart';
import 'package:socialapp/modules/chatScreen.dart';
import 'package:socialapp/modules/searchScreen.dart';
import 'package:socialapp/shared/constants.dart';

class RecentMessages extends StatelessWidget {
  var refreshMessages = RefreshController();

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      SocialCubit.get(context).getMyData();
      SocialCubit.get(context).getRecentMessages();
      SocialCubit.get(context).getFriends(SocialCubit.get(context).model!.uID);
      Future<void> onRefresh() async {
        await Future.delayed(Duration(seconds: 1));
        SocialCubit.get(context).getMyData();
        SocialCubit.get(context).getRecentMessages();
        SocialCubit.get(context).getFriends(SocialCubit.get(context).model!.uID);
        refreshMessages.refreshCompleted();
      }

      return BlocConsumer<SocialCubit, SocialStates>(
        listener: (context, state) {},
        builder: (context, state) {
          List<RecentMessagesModel> recentMessages = SocialCubit.get(context).recentMessages;
          List<UserModel> friends = SocialCubit.get(context).friends;
          return WillPopScope(
            onWillPop: willPopCallback,
            child: Scaffold(
              body: SmartRefresher(
                controller: refreshMessages,
                onRefresh: onRefresh,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width -20,
                          child: TextFormField(
                            readOnly: true,
                            style: Theme.of(context).textTheme.bodyText1,
                            onTap: (){
                              navigateTo(context, SearchScreen());
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder( borderRadius: BorderRadius.circular(15),borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.grey[200],
                              disabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(15),borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(15),borderSide: BorderSide.none),
                              hintText: 'Search',
                              hintStyle: TextStyle(fontSize: 15),
                              prefixIcon: Icon(Icons.search,color: Colors.grey,),
                            ),
                          ),
                        ),
                      ),
                      if(friends.length > 0)
                        Container(
                          height: 110,
                          child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) =>
                              storyBuildItem(context,friends[index]),
                          separatorBuilder: (context, index) => SizedBox(height:0,),
                          itemCount: friends.length,
                      ),
                        ),
                      Conditional.single(
                            context: context,
                            conditionBuilder:(context) => recentMessages.length != 0 ,
                            widgetBuilder:(context) =>
                                ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) =>
                                      chatBuildItem(context,recentMessages[index]),
                                  separatorBuilder: (context, index) => SizedBox(height:0,),
                                  itemCount: recentMessages.length,
                                ),
                            fallbackBuilder: (context) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat,color: Colors.grey,size: 50,),
                                  Text('No recent messages',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Click on'),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Icon(Icons.chat,color: Colors.grey),
                                      ),
                                      Text('to start a new conversation'),
                                    ],
                                  )
                                ],
                              ),
                            )
            ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.blueAccent,
                  onPressed: () {
                    //SocialCubit.get(context).signIn();
                    //navigateAndKill(context, SocialLayout(1));
                   //print(SocialCubit.get(context).checkFriends('mi5uiCLintXWBZ6GTnDpEipOXng2'));
                  },
                  child: Icon(Icons.chat,)),
            ),
          );
        },
      );
    });
  }
}


Widget chatBuildItem(context,RecentMessagesModel recentMessages) {
  return InkWell(
    onTap: () {
      recentMessages.receiverId == SocialCubit.get(context).model!.uID?
        navigateTo(context, ChatScreen(uId: recentMessages.senderId,)) :
        navigateTo(context, ChatScreen(uId: recentMessages.receiverId,));
    },
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: recentMessages.receiverId == SocialCubit.get(context).model!.uID?
            NetworkImage('${recentMessages.senderProfilePic}'):
            NetworkImage('${recentMessages.receiverProfilePic}'),
            radius: 27,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${recentMessages.receiverId == SocialCubit.get(context).model!.uID?
                          recentMessages.senderName : recentMessages.receiverName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text('${sinceWhen(recentMessages.time.toString())}',style: TextStyle(color: Colors.grey),)
                  ],
                ),
                SizedBox(height: 5,),
                recentMessages.recentMessageImage != null && recentMessages.recentMessageText !=null ?
                recentMessages.receiverId == SocialCubit.get(context).model!.uID ?
                Row (children: [
                  Icon(Icons.image_rounded),
                  SizedBox(width: 5,),
                  Expanded(child: Text('${recentMessages.recentMessageText}',maxLines: 1,overflow: TextOverflow.ellipsis,)),
                ],): Row (
                  children: [
                  Text('You: '),
                  Icon(Icons.image_rounded,color: Colors.grey,),
                  SizedBox(width: 5,),
                  Expanded(child: Text('${recentMessages.recentMessageText}',maxLines: 1,overflow: TextOverflow.ellipsis,)),
                ],)
                    : recentMessages.recentMessageImage != null ?
                recentMessages.receiverId == SocialCubit.get(context).model!.uID ?
                Row (children: [
                  Icon(Icons.image_rounded),
                  SizedBox(width: 5,),
                  Text('Photo',style: TextStyle(fontSize: 16)),
                ],): Row (children: [
                  Text('You: '),
                  Icon(Icons.image_rounded,color: Colors.grey,),
                  SizedBox(width: 5,),
                  Text('Photo',style: TextStyle(fontSize: 16),),
                ],)
                    : recentMessages.recentMessageText !=null ?
                recentMessages.receiverId == SocialCubit.get(context).model!.uID ?
                Text('${recentMessages.recentMessageText}',
                  style: TextStyle(fontSize: 16),maxLines: 1,overflow: TextOverflow.ellipsis,):
                Text('You: ${recentMessages.recentMessageText}',
                    style: TextStyle(fontSize: 16),maxLines: 1,overflow: TextOverflow.ellipsis,)
                    : Text('ERROR 404'),
              ],

          ),
          )
        ],
      ),
    ),
  );
}
Future<bool> willPopCallback()async {
  SocialLayoutState.tabController.animateTo(0,duration: Duration(milliseconds: 30),curve: Curves.fastLinearToSlowEaseIn);
  return false;
}

Widget storyBuildItem (context,UserModel users) {
  return InkWell(
    onTap: (){navigateTo(context, ChatScreen(uId: users.uID,));},
    child: Padding(
      padding: const EdgeInsetsDirectional.only(start: 15,top: 15),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CircleAvatar(
                    backgroundImage:NetworkImage('${users.profilePic}'),
                    radius: 27,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 9,
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 2,end: 2),
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 7,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7,),
              Container(
                width: 60,
                alignment: AlignmentDirectional.center,
                child: Text(
                  '${users.name}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),

            ],
          ),
        ],
      ),
    ),
  );
}


