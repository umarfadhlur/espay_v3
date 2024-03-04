import 'package:espay_v3/cubit/espay/espay_cubit.dart';
import 'package:espay_v3/repository/espay/espay_repository_impl.dart';
import 'package:espay_v3/ui/api_access_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EspayCubit(EspayRepositoryImpl()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Espay Integration',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ApiAccessPage(),
      ),
    );
  }
}
