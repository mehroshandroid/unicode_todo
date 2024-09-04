import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_view_model.dart';

final passwordVisibilityProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final toggleProgressLogin = StateProvider.autoDispose<bool>((ref) => false);
final toggleProgressSignup = StateProvider.autoDispose<bool>((ref) => false);
final firebaseAuth = Provider((ref) => FirebaseAuth.instance);
var loginViewModelProvider =
    Provider((ref) => LoginViewModel(ref.read(firebaseAuth)));
