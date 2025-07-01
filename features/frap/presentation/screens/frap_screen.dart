import 'package:bg_med/core/models/clinical_history.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/models/physical_exam.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:signature/signature.dart';
import 'package:uuid/uuid.dart';

class FrapScreen extends StatefulWidget {
  const FrapScreen({super.key});

  @override
  State<FrapScreen> createState() => _FrapScreenState();
}

class _FrapScreenState extends State<FrapScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  bool _isFemale = false;
  final _gynecologicalController = TextEditingController();
  bool _refusesCare = false;
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _gynecologicalController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  void _saveFrap() async {
    if (_formKey.currentState!.validate()) {
      final patient = Patient(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        gender: _selectedGender!,
        address: '', // Will add later
      );

      final clinicalHistory = ClinicalHistory(
        allergies: '', // Will add later
        medications: '', // Will add later
        previousIllnesses: '', // Will add later
      );

      final physicalExam = PhysicalExam(
        vitalSigns: '', // Will add later
        head: '', // Will add later
        neck: '', // Will add later
        thorax: '', // Will add later
        abdomen: '', // Will add later
        extremities: '', // Will add later
      );

      final frap = Frap(
        id: const Uuid().v4(),
        patient: patient,
        clinicalHistory: clinicalHistory,
        physicalExam: physicalExam,
        createdAt: DateTime.now(),
      );

      final frapBox = Hive.box<Frap>('fraps');
      await frapBox.add(frap);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FRAP saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FRAP'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Patient Info Section
            Text('Patient Information', style: Theme.of(context).textTheme.headlineSmall),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an age';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: ['Male', 'Female'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                  _isFemale = newValue == 'Female';
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a gender';
                }
                return null;
              },
            ),

            if (_isFemale)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Gynecological-Obstetric Emergencies', style: Theme.of(context).textTheme.headlineSmall),
                  TextFormField(
                    controller: _gynecologicalController,
                    decoration: const InputDecoration(labelText: 'Details'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Text('Refusal of Care', style: Theme.of(context).textTheme.headlineSmall),
            CheckboxListTile(
              title: const Text('Patient refuses care'),
              value: _refusesCare,
              onChanged: (value) {
                setState(() {
                  _refusesCare = value!;
                });
              },
            ),
            if (_refusesCare)
              Column(
                children: [
                  Signature(
                    controller: _signatureController,
                    height: 200,
                    backgroundColor: Colors.grey[200]!,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _signatureController.clear();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  )
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveFrap,
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
} 