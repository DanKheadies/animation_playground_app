import 'package:animation_playground_app/animations_list.dart';
import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Playground'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showAboutDialog(
                context: context,
                children: [
                  const Text(
                    'This is a project created by JideGuru that showcases '
                    'animations he\'s been working on. Thanks for the '
                    'inspiration and guidance!',
                  ),
                  const SizedBox(height: 15),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '- David C.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: animationList.length,
        itemBuilder: (context, index) {
          AnimationPage page = animationList[index];
          return ListTile(
            leading: Icon(page.icon),
            title: Text(page.title),
            onTap: () {
              Navigator.pushNamed(context, page.route);
            },
          );
        },
      ),
    );
  }
}
