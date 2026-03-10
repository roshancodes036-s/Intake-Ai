import 'package:flutter/material.dart';

// यह फाइल पूरे ऐप में रियल-टाइम डेटा सिंक करेगी
final ValueNotifier<int> globalCalorieGoal = ValueNotifier(2500);
final ValueNotifier<int> globalProteinGoal = ValueNotifier(150);
final ValueNotifier<int> globalCarbsGoal = ValueNotifier(275);
final ValueNotifier<int> globalFatGoal = ValueNotifier(70);