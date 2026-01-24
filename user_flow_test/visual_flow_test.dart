import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stimmapp/core/data/di/service_locator.dart';
import 'package:stimmapp/core/data/firebase/firebase_options.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    locator.init();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const MaterialApp(home: FlowTestVisualizer()));
}

class FlowStep {
  final String name;
  final Future<void> Function() action;
  StepStatus status;

  FlowStep({
    required this.name,
    required this.action,
    this.status = StepStatus.pending,
  });
}

enum StepStatus { pending, running, success, failure }

class FlowTestVisualizer extends StatefulWidget {
  const FlowTestVisualizer({super.key});

  @override
  State<FlowTestVisualizer> createState() => _FlowTestVisualizerState();
}

class _FlowTestVisualizerState extends State<FlowTestVisualizer> {
  late List<FlowStep> steps;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _setupSteps();
  }

  void _setupSteps() {
    final email = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
    const password = 'Password123!';

    steps = [
      FlowStep(
        name: 'Register',
        action: () =>
            authService.createAccount(email: email, password: password),
      ),
      FlowStep(name: 'Logout', action: () => authService.signOut()),
      FlowStep(
        name: 'Login',
        action: () => authService.signIn(email: email, password: password),
      ),
      FlowStep(
        name: 'Delete Account',
        action: () =>
            authService.deleteAccount(email: email, password: password),
      ),
      FlowStep(
        name: 'Login (Has to fail)',
        action: () async {
          try {
            await authService.signIn(email: email, password: password);
            throw Exception('Login should have failed but succeeded');
          } catch (e) {
            // Expected failure
            debugPrint('Caught expected login failure: $e');
          }
        },
      ),
    ];
  }

  Future<void> _runTests() async {
    setState(() {
      isRunning = true;
      for (var step in steps) {
        step.status = StepStatus.pending;
      }
    });

    for (var step in steps) {
      setState(() {
        step.status = StepStatus.running;
      });

      try {
        await step.action();
        setState(() {
          step.status = StepStatus.success;
        });
      } catch (e) {
        setState(() {
          step.status = StepStatus.failure;
        });
        debugPrint('Step ${step.name} failed: $e');
        break;
      }
      // Small delay for visual effect
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Flow Test Visualizer')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: steps.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Row(
                    children: [
                      _buildStatusBlock(step.status),
                      const SizedBox(width: 15),
                      Text(
                        step.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: step.status == StepStatus.running
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (step.status == StepStatus.running)
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: isRunning ? null : _runTests,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(isRunning ? 'Running Tests...' : 'Start Flow Test'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBlock(StepStatus status) {
    Color color;
    switch (status) {
      case StepStatus.pending:
        color = Colors.grey.shade300;
        break;
      case StepStatus.running:
        color = Colors.orange;
        break;
      case StepStatus.success:
        color = Colors.green;
        break;
      case StepStatus.failure:
        color = Colors.red;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black26),
      ),
    );
  }
}
