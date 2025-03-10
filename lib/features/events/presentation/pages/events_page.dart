import 'package:eventure/core/utils/constants/dummy_data.dart';
import 'package:eventure/core/utils/helper/ui.dart';
import 'package:eventure/core/utils/size/size_config.dart';
import 'package:eventure/core/utils/theme/colors.dart';
import 'package:eventure/features/events/presentation/widgets/event_card.dart';
import 'package:eventure/features/events/presentation/blocs/event/event_bloc.dart';
import 'package:eventure/features/events/presentation/widgets/events_page/main_app_bar.dart';
import 'package:eventure/injection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestNotificationPermissions();
    });

    getDeviceToken();

    return Scaffold(
      backgroundColor: kMainLight,
      appBar: MainAppBar(),
      body: BlocProvider(
        create: (context) => getIt<EventBloc>()..add(FetchEvents()),
        child: BlocConsumer<EventBloc, EventState>(
          listener: (context, state) {
            if (state is EventError) {
              UI.errorSnack(context, state.msg);
            }
          },
          builder: (context, state) {
            if (state is EventLoading) {
              final events = List.filled(3, kDummyEvent);
              return Skeletonizer(
                child: ListView.builder(
                  scrollDirection:
                      SizeConfig.isPortrait() ? Axis.vertical : Axis.horizontal,
                  padding: EdgeInsets.all(12),
                  itemCount: events.length,
                  itemBuilder: (context, index) => EventCard(
                    event: events[index],
                  ),
                ),
              );
            } else if (state is EventLoaded) {
              return ListView.builder(
                scrollDirection:
                    SizeConfig.isPortrait() ? Axis.vertical : Axis.horizontal,
                padding: EdgeInsets.all(12),
                itemCount: state.events.length,
                itemBuilder: (context, index) => EventCard(
                  event: state.events[index],
                ),
              );
            }
            return Center(
              child: Text('No Events'),
            );
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => registerUser(),
      // ),
    );
  }

  registerUser() {
    // getIt<FirebaseAuth>().createUserWithEmailAndPassword(
    //   email: 'test1@gmail.com',
    //   password: '12345678',
    // );
    getIt<FirebaseAuth>().signInWithEmailAndPassword(
      email: 'test@gmail.com',
      password: '12345678',
    );
  }

  void requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  void getDeviceToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM Token: $token");
  }

// 👉 Call this method when the app starts or when the user logs in.

//   Future<void> updateFcmToken(String userId) async {
//   final String? fcmToken = await FirebaseMessaging.instance.getToken();
//   if (fcmToken != null) {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .update({'fcmToken': fcmToken});
//   }
// }
}
