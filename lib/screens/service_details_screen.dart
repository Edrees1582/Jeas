// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jeas/models/custom_user.dart';
import 'package:jeas/resources/database.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final CollectionReference workers =
      FirebaseFirestore.instance.collection('workers');
  final CollectionReference requests =
      FirebaseFirestore.instance.collection('requests');

  ServiceDetailsScreen({super.key, required this.data});

  @override
  _ServiceDetailsScreenState createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  String status = "";

  @override
  void initState() {
    super.initState();
    status = widget.data['status'];
  }

  Future<Map<String, dynamic>> getWorkerInfo(String workerUid) async {
    DocumentSnapshot doc = await widget.workers.doc(workerUid).get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['title']),
      ),
      body: StreamBuilder(
        stream: widget.requests.doc(widget.data['requestId']).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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

          Map<String, dynamic> data = widget.data;

          if (snapshot.hasData && snapshot.data!.data() != null) {
            data = snapshot.data!.data() as Map<String, dynamic>;
          }

          // Assuming you want to display a list of documents
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${data['title']}'),
                Text('Description: ${data['description']}'),
                Text('Location: ${data['location']}'),
                Text('Service Type: ${data['serviceType']}'),
                Text('Service Category: ${data['serviceCategory']}'),
                Text('Status: ${data['status']}'),
                if (data['status'] == 'Pending')
                  ElevatedButton(
                    onPressed: () {
                      DatabaseService(
                              uid: Provider.of<CustomUser?>(context,
                                      listen: false)!
                                  .uid)
                          .deleteRequestService(widget.data['requestId']);
                      Navigator.pop(context);
                    },
                    child: const Text('Delete Request'),
                  ),
                if (data['status'] == 'Accepted' ||
                    data['status'] == 'Completed')
                  FutureBuilder(
                    future: getWorkerInfo(data['workerUID']),
                    builder: (context,
                        AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        Map<String, dynamic>? workerData = snapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Worker Name: ${workerData?['name']}'),
                            Text(
                                'Worker Phone Number: ${workerData?['phoneNumber']}'),
                            ElevatedButton(
                              onPressed: () {
                                _makePhoneCall(workerData?['phoneNumber']);
                              },
                              child: const Text('Call Worker'),
                            ),
                          ],
                        );
                      }
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
