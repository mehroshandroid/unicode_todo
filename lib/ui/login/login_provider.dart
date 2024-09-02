import 'package:flutter_riverpod/flutter_riverpod.dart';

final passwordVisibilityProvider =
    StateProvider.autoDispose<bool>((ref) => false);
