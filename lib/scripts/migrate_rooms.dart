import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:homestay_booking/features/rooms/data/room_repository.dart';
import 'package:homestay_booking/core/utils/seed_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final roomRepo = RoomRepository(firestore);

  print('Starting room migration...');

  // 1. Delete all existing rooms
  final snapshot = await firestore.collection('rooms').get();
  print('Found ${snapshot.docs.length} existing rooms to delete.');
  
  final batch = firestore.batch();
  for (final doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();
  print('Successfully deleted old rooms.');

  // 2. Force seed new rooms using the updated SeedData utility
  print('Seeding new 6-room configuration...');
  final seeder = SeedData(roomRepo);
  await seeder.seedRoomsIfEmpty(); // It is empty now, so this will run
  
  print('Migration complete! You can now restart the app.');
}
