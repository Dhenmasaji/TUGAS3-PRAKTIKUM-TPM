import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategoriesPage(),
    );
  }
}

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _categories = jsonData['categories'];
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            child: ListTile(
              leading: Image.network(category['strCategoryThumb']),
              title: Text(category['strCategory']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MealsPage(category['strCategory'])),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MealsPage extends StatefulWidget {
  final String category;

  MealsPage(this.category);

  @override
  _MealsPageState createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  List<dynamic> _meals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.category}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _meals = jsonData['meals'];
      });
    } else {
      throw Exception('Failed to load meals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meals'),
      ),
      body: ListView.builder(
        itemCount: _meals.length,
        itemBuilder: (context, index) {
          final meal = _meals[index];
          return Card(
            child: ListTile(
              leading: Image.network(meal['strMealThumb']),
              title: Text(meal['strMeal']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MealDetailPage(meal['idMeal'])),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MealDetailPage extends StatefulWidget {
  final String mealId;

  MealDetailPage(this.mealId);

  @override
  _MealDetailPageState createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  dynamic _meal;

  @override
  void initState() {
    super.initState();
    _loadMealDetail();
  }

  Future<void> _loadMealDetail() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.mealId}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _meal = jsonData['meals'][0];
      });
    } else {
      throw Exception('Failed to load meal detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Detail'),
      ),
      body: _meal != null
          ? Column(
        children: [
          // Resize the image to fit the screen width
          Container(
            width: MediaQuery.of(context).size.width,
            child: Image.network(
              _meal['strMealThumb'],
              fit: BoxFit.cover,
            ),
          ),
          Text(_meal['strMeal']),
          Text(_meal['strInstructions']),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}