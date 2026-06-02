import 'package:flutter/widgets.dart';

import 'app_coordinator.dart';

class AppLudiprof extends StatefulWidget {
  const AppLudiprof({super.key});

  @override
  State<AppLudiprof> createState() => _AppLudiprofState();
}

class _AppLudiprofState extends State<AppLudiprof> {
  late final AppCoordinator coordinator;

  @override
  void initState() {
    super.initState();
    coordinator = AppCoordinator();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // placeholder
  }
}
