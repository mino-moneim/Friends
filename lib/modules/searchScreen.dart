import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:socialapp/cubit/socialCubit.dart';
import 'package:socialapp/cubit/states.dart';
import 'package:socialapp/models/userModel.dart';
import 'package:socialapp/modules/friendsProfileScreen.dart';
import 'package:socialapp/shared/constants.dart';

class SearchScreen extends StatelessWidget {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        //List<UserModel> searchList = SocialCubit.get(context).searchList;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 60,
            title: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width - 20,
                child: TextFormField(
                  controller: searchController,
                  style: Theme.of(context).textTheme.bodyText1,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (value) {
                    SocialCubit.get(context).searchUser(value);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blueAccent)),
                    hintText: 'Search',
                    hintStyle: TextStyle(fontSize: 15),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: Conditional.single(
            context: context,
            conditionBuilder:(context) => SocialCubit.get(context).search != null,
              widgetBuilder:(context) => chatBuildItem(context, SocialCubit.get(context).search),
            fallbackBuilder: (context) => Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_outlined,size: 50,color: Colors.grey,),
                  SizedBox(height: 30,),
                  Text('No Search Results',style: TextStyle(fontSize: 25),)
                ],
              ),
            )
          ),
          // body: ListView.separated(
          //   physics: BouncingScrollPhysics(),
          //   itemBuilder: (context,index) =>chatBuildItem(context,SocialCubit.get(context).search![index]) ,
          //   separatorBuilder:(context,index) => myDivider(),
          //   itemCount: 1
          // )
        );
      },
    );
  }

  Widget chatBuildItem(context, Map<String, dynamic>? userModel) {
    return InkWell(
      onTap: () {
        navigateTo(context, FriendsProfileScreen(userModel!['uId']));
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('${userModel!['profilePic']}'),
              radius: 27,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              '${userModel['name']}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
