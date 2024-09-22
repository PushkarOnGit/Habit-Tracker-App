import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/heat_map.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:provider/provider.dart';
import '../utils/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  void initState() {
    //read the existing habits on the app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

  //controllers
  final TextEditingController textController = TextEditingController();

  //create new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: "Create a new habit",
          ),
        ),
        actions: [
          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: Text("Cancel"),
          ),

          //save button
          MaterialButton(
            onPressed: () {
              //get a new habit name
              String newHabitName = textController.text;

              //save to db
              context.read<HabitDatabase>().addHabit(newHabitName);

              // pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  //check habit on and off
  void checkHabitOnOff(bool? value, Habit habit) {
    //update the habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  //edit habit box
  void editHabitBox(Habit habit) {
    textController.text = habit.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: Text("Cancel"),
          ),

          //save button
          MaterialButton(
            onPressed: () {
              //get a new habit name
              String newHabitName = textController.text;

              //save to db
              context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);

              // pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  //delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure you want to delete?", style: TextStyle(fontSize: 17),),
        actions: [
          //cancel button
          MaterialButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

            },
            child: Text("Cancel"),
          ),

          //save button
          MaterialButton(
            onPressed: () {
              //get a new habit name
              String newHabitName = textController.text;

              //save to db
              context.read<HabitDatabase>().deleteHabit(habit.id);

              // pop box
              Navigator.pop(context);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(
        children: [
          //heatmap
          _buildHeatMap(),

          //habit list
          _buildHabitList(),

        ],
      ),
    );
  }

  Widget _buildHeatMap() {
    // habit database
    final habitDataBase = context.watch<HabitDatabase>();

    // current habit
    List<Habit> currentHabits =  habitDataBase.currentHabits;

    // return heatmap UI
    return FutureBuilder<DateTime?>(
      future: habitDataBase.getFirstLaunchDate(),
      builder: (context, snapshot){
        //once date is available
        if (snapshot.hasData) {
          return MyHeatMap(
              startDate: snapshot.data!,
              datasets: prepHeatMmapDataSet(currentHabits),
          );
        }

        else {
          return Container();
        }
      },
    );
  }

  Widget _buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: currentHabits.length,
      itemBuilder: (context, index) {
        final habit = currentHabits[index];
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);
        return MyHabitTile(
          isCompleted: isCompletedToday,
          text: habit.name,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) =>editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }

}
