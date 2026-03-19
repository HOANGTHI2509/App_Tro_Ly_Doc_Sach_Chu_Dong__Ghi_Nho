import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() {
    return 0;
  }

  void setIndex(int index) {
    state = AsyncData(index);
  }
}

final navProvider = AsyncNotifierProvider<NavNotifier, int>(NavNotifier.new);
