import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class CalorieItem {
  String name;
  int calories;

  CalorieItem(this.name, this.calories);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calories Tracker',
      theme: ThemeData(
        fontFamily: 'Times New Roman',
      ),
      home: TargetCaloriesScreen(), // Start with the screen to set target calories
    );
  }
}

class TargetCaloriesScreen extends StatefulWidget {
  @override
  _TargetCaloriesScreenState createState() => _TargetCaloriesScreenState();
}

class _TargetCaloriesScreenState extends State<TargetCaloriesScreen> {
  final TextEditingController targetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Target Calories'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter Target Calories'),
              style: TextStyle(fontFamily: 'Times New Roman'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (targetController.text.isNotEmpty) {
                  int targetCalories = int.tryParse(targetController.text) ?? 0;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(targetCalories: targetCalories),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter target calories.'),
                    ),
                  );
                }
              },
              child: Text('Set Target'),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final int targetCalories;

  const HomeScreen({required this.targetCalories});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CalorieItem> calorieItems = []; // Your existing list of calorie items

  int getTotalCalories() {
    int total = calorieItems.fold(0, (previousValue, element) => previousValue + element.calories);
    return total;
  }

  bool isOverTarget() {
    return getTotalCalories() > widget.targetCalories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calories'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2023, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              // Implement logic to filter calorie items by selected day if needed
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: calorieItems.isEmpty
                ? Center(
              child: Text(
                'No Entered Calories.',
                style: TextStyle(fontFamily: 'Times New Roman'),
              ),
            )
                : ListView.builder(
              itemCount: calorieItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${calorieItems[index].name}: ${calorieItems[index].calories} calories',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditCalorieScreen(
                                    calorieItem: calorieItems[index],
                                    onUpdate: (updatedCalorieItem) {
                                      setState(() {
                                        calorieItems[index] = updatedCalorieItem;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                calorieItems.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewCalorieScreen()),
          ).then((newCalorie) {
            if (newCalorie != null) {
              setState(() {
                calorieItems.add(newCalorie);
              });
            }
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Calories: ${getTotalCalories()} | Target Calories: ${widget.targetCalories}',
            style: TextStyle(
              fontFamily: 'Times New Roman',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isOverTarget() ? Colors.red : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}



class NewCalorieScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController calorieController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Calorie'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
              style: TextStyle(fontFamily: 'Times New Roman'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: calorieController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Calories'),
              style: TextStyle(fontFamily: 'Times New Roman'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && calorieController.text.isNotEmpty) {
                  String enteredName = nameController.text;
                  int enteredCalories = int.tryParse(calorieController.text) ?? 0;
                  CalorieItem newCalorie = CalorieItem(enteredName, enteredCalories);
                  Navigator.pop(context, newCalorie);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter both name and calories.'),
                    ),
                  );
                }
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
            ),
            SizedBox(height: 16.0),
            // Buttons for specific food items and their calories
            _buildFoodButton(context, 'Apple', 59),
            _buildFoodButton(context, 'Banana', 120),
            _buildFoodButton(context, 'Cookies', 250),
            _buildFoodButton(context, 'Carrots', 52),
            _buildFoodButton(context, 'Chicken Breast', 142),
            _buildFoodButton(context, 'Bagel', 289),
            _buildFoodButton(context, 'Coffee', 2),
            _buildFoodButton(context, 'Egg', 102),
            _buildFoodButton(context, 'Granola Bar', 193),
            _buildFoodButton(context, 'Hot Dog', 137),
            _buildFoodButton(context, 'Jelly Doughnut', 290),
            _buildFoodButton(context, 'Pizza', 300),
            _buildFoodButton(context, 'Potato', 160),
            _buildFoodButton(context, 'Burger', 275),
            _buildFoodButton(context, 'Shrimp', 84),
            _buildFoodButton(context, 'Cheddar Cheese', 113),
            _buildFoodButton(context, 'Orange', 60),
            _buildFoodButton(context, 'Popcorn', 300),
            _buildFoodButton(context, 'Pasta', 500),
            _buildFoodButton(context, 'smoothie', 180),
          ],
        ),
      ),
    ),
    );
  }

  // Helper function to create food buttons
  Widget _buildFoodButton(BuildContext context, String name, int calories) {
    return SizedBox(
      height: 56.0,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          CalorieItem foodItem = CalorieItem(name, calories);
          Navigator.pop(context, foodItem);
        },
        child: Text('Add $name ($calories calories)'),
        style: ElevatedButton.styleFrom(
          primary: Colors.orange,
        ),
      ),
    );
  }
}



class EditCalorieScreen extends StatelessWidget {
  final CalorieItem calorieItem;
  final Function(CalorieItem) onUpdate;

  const EditCalorieScreen({
    required this.calorieItem,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController calorieController =
    TextEditingController(text: calorieItem.calories.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Calorie'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Editing ${calorieItem.name}',
              style: TextStyle(fontFamily: 'Times New Roman', fontSize: 20),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: calorieController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Calories'),
              style: TextStyle(fontFamily: 'Times New Roman'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (calorieController.text.isNotEmpty) {
                  int updatedCalories =
                      int.tryParse(calorieController.text) ?? calorieItem.calories;
                  CalorieItem updatedItem = CalorieItem(
                    calorieItem.name,
                    updatedCalories,
                  );
                  onUpdate(updatedItem);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter calories.'),
                    ),
                  );
                }
              },
              child: Text('Update'),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
