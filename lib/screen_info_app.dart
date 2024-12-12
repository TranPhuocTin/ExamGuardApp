import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/student/exam_monitoring/cubit/app_monitoring_cubit.dart';
import 'features/student/exam_monitoring/models/cheating_detection_state.dart';
import 'services/app_lifecycle_service.dart';
import 'data/cheating_repository.dart';
import 'utils/share_preference/shared_preference.dart';
import 'utils/share_preference/token_cubit.dart';

class ScreenInfoApp extends StatelessWidget {
  const ScreenInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TokenCubit(TokenStorage()),
          ),
          BlocProvider(
            create: (context) => AppMonitoringCubit(
              examId: '674dc5ec874f97e70b0f1a2c',
              appLifecycleService: AppLifecycleService(),
              cheatingRepository: CheatingRepository(),
              tokenStorage: TokenStorage(),
              tokenCubit: context.read<TokenCubit>(),
            )..startMonitoring(),
          ),
        ],
        child: const ScreenInfoPage(),
      ),
    );
  }
}

class ScreenInfoPage extends StatefulWidget {
  const ScreenInfoPage({super.key});

  @override
  State<ScreenInfoPage> createState() => _ScreenInfoPageState();
}

class _ScreenInfoPageState extends State<ScreenInfoPage>
    with WidgetsBindingObserver {
  Size? _screenSize;
  double? _devicePixelRatio;
  AppLifecycleState? _lifecycleState;
  List<String> _violations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScreenInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateScreenInfo() {
    final mediaQuery = MediaQuery.of(context);
    setState(() {
      _screenSize = mediaQuery.size;
      _devicePixelRatio = mediaQuery.devicePixelRatio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppMonitoringCubit, AppMonitoringState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (state.currentBehavior != CheatingBehavior.normal) {
          setState(() {
            _violations.add(
              '${DateTime.now()}: ${state.currentBehavior.name} - ${state.cheatingLogs.last.message}',
            );
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Screen Information'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_screenSize != null) ...[
                Text(
                  'Screen Width: ${_screenSize!.width.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  'Screen Height: ${_screenSize!.height.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  'Aspect Ratio: ${(_screenSize!.width / _screenSize!.height).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  'Device Pixel Ratio: ${_devicePixelRatio?.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Text(
                  'App State: ${_lifecycleState?.toString() ?? "Unknown"}',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
              const SizedBox(height: 30),
              const Text(
                'Violations:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_violations.isEmpty)
                const Text('No violations detected')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _violations.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.red.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _violations[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lifecycleState = state;
    });
  }

  @override
  void didChangeMetrics() {
    _updateScreenInfo();
  }
}
