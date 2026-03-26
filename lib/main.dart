import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/repositories/call_repository_impl.dart';
import 'data/sources/local_data_source.dart';
import 'data/sources/native_data_source.dart';
import 'presentation/bloc/call_bloc.dart';
import 'presentation/bloc/call_event.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final localDataSource = LocalDataSource(prefs);
  final nativeDataSource = NativeDataSource();
  
  final repository = CallRepositoryImpl(
    localDataSource: localDataSource,
    nativeDataSource: nativeDataSource,
  );

  runApp(CallRejecterApp(repository: repository));
}

class CallRejecterApp extends StatelessWidget {
  final CallRepositoryImpl repository;

  const CallRejecterApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CallBloc(repository: repository)..add(LoadSettingsAndLogs()),
      child: MaterialApp(
        title: 'ShieldCall',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF673AB7),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF673AB7),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
