import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jeas/models/custom_user.dart';
import 'package:jeas/resources/auth_methods.dart';
import 'package:jeas/screens/request_service_screen.dart';
import 'package:jeas/screens/service_details_screen.dart';
import 'package:provider/provider.dart';

class RequestsScreen extends StatelessWidget {
  final CollectionReference serviceRequests =
      FirebaseFirestore.instance.collection('requests');
  final AuthMethods _auth = AuthMethods();

  RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Requested Services'),
        actions: <Widget>[
          TextButton.icon(
              onPressed: () async {
                await _auth.logout();
              },
              icon: const Icon(Icons.person),
              label: const Text('logout')),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: serviceRequests
                .where('requesterUID',
                    isEqualTo:
                        Provider.of<CustomUser?>(context, listen: false)!.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return snapshot.data!.docs.isEmpty
                  ? const Center(
                      child: Text('No requests'),
                    )
                  : ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        data['requestId'] = document.id;
                        return ListTile(
                          title: Text(data['title']),
                          subtitle: Text(data['description']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ServiceDetailsScreen(data: data)),
                            );
                          },
                        );
                      }).toList(),
                    );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const ServiceRequestScreen()), // Navigate to the request page
                );
              },
              icon: const Icon(Icons.add), // Use any icon you want
              iconSize: 50, // Adjust the size as needed
            ),
          )
        ],
      ),
    );
  }
}
