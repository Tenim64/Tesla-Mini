library tesla_mini.globals;

import 'package:flutter/material.dart';

var recognitions;
// 0 = disabled
// 1 / -1 = enabled
final recognitionsNotifier = ValueNotifier<int>(0);
