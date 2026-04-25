import 'package:flutter/material.dart';

/// For SnackBars from [ApiService] (cold-start retries) when no Scaffold context exists.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
