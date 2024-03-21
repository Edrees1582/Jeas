// ignore_for_file: constant_identifier_names, library_private_types_in_public_api, unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:jeas/models/custom_user.dart';
import 'package:jeas/resources/auth_methods.dart';
import 'package:jeas/resources/database.dart';
import 'package:provider/provider.dart';

enum ServiceType {
  Repairs,
  Delivery,
  Cleaning,
  Other,
}

enum ServiceCategory {
  Electricity,
  Woodwork,
  Plumbing,
  Gardening,
  Other,
}

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  _ServiceRequestScreenState createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  // Variables to hold the selected service type and category
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  ServiceType _selectedServiceTypeController = ServiceType.Repairs;
  ServiceCategory _selectedServiceCategoryController =
      ServiceCategory.Electricity;
  String _otherServiceTypeDescriptionController = '';
  String _otherServiceCategoryDescriptionController = '';
  final AuthMethods _auth = AuthMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Service'),
        actions: <Widget>[
          TextButton.icon(
              onPressed: () async {
                await _auth.logout();
              },
              icon: const Icon(Icons.person),
              label: const Text('logout')),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Request a Service',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              _buildLocationInput(),
              const SizedBox(height: 20),
              _buildServiceDetailsInput(),
              const SizedBox(height: 20),
              _buildServiceTypeDropdown(),
              _buildOtherServiceTypeDescriptionInput(),
              const SizedBox(height: 20),
              _buildServiceCategoryDropdown(),
              _buildOtherServiceCategoryDescriptionInput(),
              // const SizedBox(height: 20),
              // _buildMediaUploadButton(),
              // SizedBox(height: 20),
              // _buildAddedMediaPlaceholder(),
              const SizedBox(height: 20),
              _buildRequestButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _locationController,
        decoration: const InputDecoration(
          hintText: 'Enter your location',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildServiceDetailsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Description',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<ServiceType>(
        value: _selectedServiceTypeController,
        onChanged: (value) {
          setState(() {
            _selectedServiceTypeController = value!;
          });
        },
        items: ServiceType.values.map((type) {
          return DropdownMenuItem<ServiceType>(
            value: type,
            child: Text(type.toString().split('.').last),
          );
        }).toList(),
        decoration: const InputDecoration(
          labelText: 'Service Type',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildServiceCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<ServiceCategory>(
        value: _selectedServiceCategoryController,
        onChanged: (value) {
          setState(() {
            _selectedServiceCategoryController = value!;
          });
        },
        items: ServiceCategory.values.map((category) {
          return DropdownMenuItem<ServiceCategory>(
            value: category,
            child: Text(category.toString().split('.').last),
          );
        }).toList(),
        decoration: const InputDecoration(
          labelText: 'Service Category',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildOtherServiceTypeDescriptionInput() {
    return Visibility(
      visible: _selectedServiceTypeController == ServiceType.Other,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          onChanged: (value) {
            _otherServiceTypeDescriptionController = value;
          },
          decoration: const InputDecoration(
            hintText: 'Other Service Type Description',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherServiceCategoryDescriptionInput() {
    return Visibility(
      visible: _selectedServiceCategoryController == ServiceCategory.Other,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          onChanged: (value) {
            _otherServiceCategoryDescriptionController = value;
          },
          decoration: const InputDecoration(
            hintText: 'Other Service Category Description',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaUploadButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement media upload functionality
      },
      icon: const Icon(Icons.attach_file),
      label: const Text('Upload Media Files'),
    );
  }

  Widget _buildAddedMediaPlaceholder() {
    // Placeholder widget to show added media
    return const Placeholder(
      color: Colors.grey,
      fallbackWidth: double.infinity,
      fallbackHeight: 100,
    );
  }

  Widget _buildRequestButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        DatabaseService(
                uid: Provider.of<CustomUser?>(context, listen: false)!.uid)
            .requestService(
          _locationController.text,
          _titleController.text,
          _descriptionController.text,
          _selectedServiceTypeController == ServiceType.Other
              ? _otherServiceTypeDescriptionController
              : _selectedServiceTypeController.name,
          _selectedServiceCategoryController == ServiceCategory.Other
              ? _otherServiceCategoryDescriptionController
              : _selectedServiceCategoryController.name,
        );
        Navigator.pop(context);
      },
      child: const Text(
        'Request Service',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
