import 'package:flutter/material.dart';
import 'package:quest_gamification/quest_gamification.dart';

void main() {
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Ludiprof Gamification Demo',
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
			),
			home: const GamificationDemo(),
		);
	}
}

class GamificationDemo extends StatefulWidget {
	const GamificationDemo({super.key});

	@override
	State<GamificationDemo> createState() => _GamificationDemoState();
}

class _GamificationDemoState extends State<GamificationDemo> {
	late final QuestConfig config;
	late final GamificationEngine engine;

	@override
	void initState() {
		super.initState();
		config = QuestConfig.fitness();
		engine = GamificationEngine(
			config: config,
			repository: InMemoryProgressRepository(),
		);
	}

	@override
	void dispose() {
		// engine has no dispose API; let GC handle it or add adapter cleanup if needed
		super.dispose();
	}

	Future<void> _recordWorkout(BuildContext context) async {
		final result = await engine.recordEvent(QuestEvent.workoutCompleted);
		if (!mounted) return;
		final ctx = context;
		WidgetsBinding.instance.addPostFrameCallback((_) {
			if (!mounted) return;
			QuestAchievementToast.showResult(
				ctx,
				leveledUp: result.leveledUp,
				level: result.progress.level,
				newBadges: result.newBadges,
			);
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Gamification Demo'),
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
			),
			body: StreamBuilder<UserProgress?>(
				stream: engine.watch(),
				builder: (context, snapshot) {
					final progress = snapshot.data;

					return Padding(
						padding: const EdgeInsets.all(16.0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								QuestLevelCard(progress: progress, config: config),
								const SizedBox(height: 12),
								QuestXpBar(progress: progress, xpPerLevel: config.xpPerLevel),
								const SizedBox(height: 12),
								QuestStreakCard(progress: progress),
								const SizedBox(height: 12),
								const Text('Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
								const SizedBox(height: 8),
								Expanded(
									child: QuestBadgeGrid(progress: progress, allBadges: config.badges),
								),
							],
						),
					);
				},
			),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: () => _recordWorkout(context),
				label: const Text('Record Workout'),
				icon: const Icon(Icons.fitness_center),
			),
		);
	}
}
