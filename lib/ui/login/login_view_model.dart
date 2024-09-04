import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/generic_response_model.dart';

class LoginViewModel {
  String userId = "";
  FirebaseAuth firebaseInstance;

  LoginViewModel(this.firebaseInstance);

  Map validateFields(String emailAddress, String password) {
    var returnMap = {};
    if (emailAddress.isEmpty) {
      returnMap['success'] = false;
      returnMap['message'] = "Email address can not be empty";
      return returnMap;
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
        .hasMatch(emailAddress)) {
      returnMap['success'] = false;
      returnMap['message'] = "Enter a valid email address";
      return returnMap;
    }

    if (password.isEmpty) {
      returnMap['success'] = false;
      returnMap['message'] = "Password can not be empty";
      return returnMap;
    }
    returnMap['success'] = true;
    returnMap['message'] = "Valid fields";
    return returnMap;
  }

  Future<GenericResponse> logInUser(
      String emailAddress, String password) async {
    GenericResponse response = GenericResponse();
    try {
      var result = await firebaseInstance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      //store user data in preferences
      if (result.user != null) {
        // String? userId = result.user?.uid;
        // String? userEmail = result.user?.email;
        response.success = true;
      } else {
        response.success = false;
        response.errorMessage = "No user info. is returned from the server";
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      response.success = false;
      response.errorMessage = e.toString();
    }
    return response;
  }

  Future<GenericResponse> forgotPassword(String emailAddress) async {
    GenericResponse genericResponse = GenericResponse();
    try {
      await firebaseInstance.sendPasswordResetEmail(email: emailAddress);
      genericResponse.success = true;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      genericResponse.success = false;
      genericResponse.errorMessage = e.toString();
    }
    return genericResponse;
  }

  Future<GenericResponse> registerUser(
      String email, String password, FirebaseAuth firebaseAuth) async {
    GenericResponse genericResponse = GenericResponse();
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        genericResponse.success = true;
      } else {
        genericResponse.success = false;
        genericResponse.errorMessage = "Response didn't contain user info";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        genericResponse.success = false;
        genericResponse.errorMessage = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        genericResponse.success = false;
        genericResponse.errorMessage =
            "The account already exists for that email.";
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      genericResponse.success = false;
      genericResponse.errorMessage = e.toString();
    }
    return genericResponse;
  }

  void storeUserUid(String uid) async {
    var pref = await SharedPreferences.getInstance();
    pref.setString('userUid', uid);
  }
}
