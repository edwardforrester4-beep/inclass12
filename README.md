Inventory App (inclass12)

This Flutter application is an inventory management system that uses Firebase Firestore for real-time data storage and updates. Users can add, edit, delete, and view inventory items, with changes reflected instantly in the UI.

Features
Core Features
Add new inventory items
Edit existing items
Delete items
Real-time updates using Firestore
Form validation for:
Empty fields
Invalid numbers
Negative values
Displays loading, empty, and error states
Uses StreamBuilder with ListView.builder for dynamic UI
Enhanced Features
Search by Item Name
Users can filter items in real time using a search bar.
Total Inventory Value
The app calculates and displays the total value of all visible items (quantity × price).
Technologies Used
Flutter
Firebase Core
Cloud Firestore
Project Structure
lib/
  main.dart
  firebase_options.dart
  models/
    item.dart
  services/
    firestore_service.dart
  screens/
    inventory_page.dart
How to Run
Clone the repository

Install dependencies:

flutter pub get

Run the app:

flutter run -d chrome
Notes
Firestore must be enabled in Firebase Console
Collection name used: items
Each item contains:
name (String)
quantity (int)
price (double)
