# unicode_todo

Todo app for unicode hiring process

## Introduction

Its a todo app which make use of local storage package hive. Firebase database is being used to store the todos whenever internet is available.

Package used:
- hive for local storage
- riverpod for state management
- firebase cloud-store for online database and data syncing
- firebase auth for managing auth of the application
- work manager for syncing of tasks in the background

Future improvements:
- time based syncing
- better design , one that is provided by professional app designer
- iOS compatibility specially firebase related configurations
- forgot password flow

Integration tests can be run be following command:
flutter test integration_test/integration_test.dart
Note: integration test are not running at the moment because of hive issue, will take it up later



![img.png](img.png)


