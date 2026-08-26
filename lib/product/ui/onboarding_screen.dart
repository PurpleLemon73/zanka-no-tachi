import 'package:flutter/material.dart';

import '../../app/app_identity.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.reopened = false,
  });
  final Future<void> Function() onComplete;
  final bool reopened;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  static const pages = [
    (
      Icons.auto_stories_outlined,
      'Your library, independent of sources',
      'Zanka keeps one canonical manga or anime while interchangeable adapters contribute availability and public metadata.',
    ),
    (
      Icons.extension_outlined,
      'Capabilities stay honest',
      'Some adapters provide metadata only. Reading and playback appear only for lawful, capable sources such as your local CBZ and video files.',
    ),
    (
      Icons.shield_outlined,
      'Local-first and portable',
      'Library state and progress stay on this device. Data-only backup is available in Settings, and diagnostics are never transmitted automatically.',
    ),
    (Icons.info_outline, 'Independent and unofficial', AppIdentity.disclaimer),
  ];

  Future<void> _finish() async {
    await widget.onComplete();
    if (widget.reopened && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: widget.reopened,
      actions: [
        TextButton(
          key: const Key('skip-onboarding'),
          onPressed: _finish,
          child: Text(widget.reopened ? 'Close' : 'Skip'),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: pages.length,
              onPageChanged: (value) => setState(() => page = value),
              itemBuilder: (context, index) {
                final item = pages[index];
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        children: [
                          Icon(item.$1, size: 72, semanticLabel: item.$2),
                          const SizedBox(height: 24),
                          Text(
                            item.$2,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item.$3,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Semantics(
            label: 'Onboarding page ${page + 1} of ${pages.length}',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < pages.length; index++)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      index == page ? Icons.circle : Icons.circle_outlined,
                      size: 12,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('onboarding-next'),
                onPressed: page == pages.length - 1
                    ? _finish
                    : () => controller.nextPage(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                      ),
                child: Text(
                  page == pages.length - 1 ? 'Start using Zanka' : 'Next',
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
