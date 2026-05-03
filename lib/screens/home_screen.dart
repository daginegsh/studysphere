import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';




import 'task_screen.dart';
import 'timer_screen.dart';
import 'resource_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🎨 COLORS
  static const Color mainBg = Color(0xFF1ECB9B);
  static const Color innerBg = Color(0xFFE0F7F1);
  static const Color cardBg = Colors.white;
  static const Color primary = Color(0xFF1ECB9B);
  static const Color textDark = Color(0xFF1B3A3A);

  int index = 0;
  bool isDarkMode = false;

  int totalTasks = 10;
  int completedTasks = 4;

  final List<Widget> pages = [
  TaskScreen(),
  TimerScreen(),
  ResourceScreen(),
  ChatScreen(),
];

  Color get backgroundColor => isDarkMode ? Colors.black : mainBg;
  Color get innerBackgroundColor => isDarkMode ? Colors.grey.shade900 : innerBg;
  Color get cardColor => isDarkMode ? Colors.grey.shade800 : cardBg;
  Color get textColor => isDarkMode ? Colors.white : textDark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [

            // 🔷 HEADER
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900 : mainBg,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [
                      Image.asset("assets/images/icon.jpg", height: 35),
                      const SizedBox(width: 8),
                      const Text(
                        "StudySphere",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // ⭐ 3 DOT MENU (RESTORED)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),

                    onSelected: (value) {
                      switch (value) {
                        case "refresh":
                          setState(() {});
                          break;

                        case "dark":
                          setState(() {
                            isDarkMode = !isDarkMode;
                          });
                          break;

                        case "settings":
                          Navigator.pushNamed(context, "/settings");
                          break;

                        case "help":
                          showDialog(
                            context: context,
                            builder: (_) => const AlertDialog(
                              title: Text("Help ❓"),
                              content: Text(
                                "Tasks: manage work\n"
                                "Focus: timer\n"
                                "Resources: PDFs & links\n"
                                "Chat: group discussion",
                              ),
                            ),
                          );
                          break;

                        case "logout":
                          Navigator.pushReplacementNamed(context, "/login");
                          break;
                      }
                    },

                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "refresh",
                        child: ListTile(
                          leading: Icon(Icons.refresh),
                          title: Text("Refresh"),
                        ),
                      ),

                      PopupMenuItem(
                        value: "dark",
                        child: ListTile(
                          leading: const Icon(Icons.dark_mode),
                          title: const Text("Dark Mode"),
                          trailing: Switch(
                            value: isDarkMode,
                            onChanged: (v) {
                              Navigator.pop(context);
                              setState(() => isDarkMode = v);
                            },
                          ),
                        ),
                      ),

                      const PopupMenuItem(
                        value: "settings",
                        child: ListTile(
                          leading: Icon(Icons.settings),
                          title: Text("Settings"),
                        ),
                      ),

                      const PopupMenuItem(
                        value: "help",
                        child: ListTile(
                          leading: Icon(Icons.help_outline),
                          title: Text("Help"),
                        ),
                      ),

                      const PopupMenuDivider(),

                      const PopupMenuItem(
                        value: "logout",
                        child: ListTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 📱 BODY
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: innerBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: index == 0
                    ? _buildDashboard()
                    : pages[index - 1],
              ),
            ),
          ],
        ),
      ),

      // 🔻 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Focus"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Resources"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Groups"),
        ],
      ),
    );
  }

  // 🏠 DASHBOARD
  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15),

          buildChart(totalTasks, completedTasks),

          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildCard(Icons.task_alt, "Tasks", () => setState(() => index = 1)),
                _buildCard(Icons.timer, "Focus", () => setState(() => index = 2)),
                _buildCard(Icons.menu_book, "Resources", () => setState(() => index = 3)),
                _buildCard(Icons.chat, "Groups", () => setState(() => index = 4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChart(int total, int done) {
    double percent = total == 0 ? 0 : done / total;

    return Column(
      children: [
        const Text("Task Progress",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: done.toDouble(),
                  color: primary,
                  title: "Done",
                ),
                PieChartSectionData(
                  value: (total - done).toDouble(),
                  color: Colors.grey.shade300,
                  title: "Left",
                ),
              ],
            ),
          ),
        ),
        Text("${(percent * 100).toInt()}% Completed"),
      ],
    );
  }
  

  Widget _buildCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: primary),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ],
        ),
      ),
    );
  }
}