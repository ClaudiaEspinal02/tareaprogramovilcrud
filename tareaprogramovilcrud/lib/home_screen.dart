import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD App'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nombre'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('users').add({
                  'name': _nameController.text,
                });
                _nameController.clear();
              }
            },
            child: Text('Agregar'),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['name']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(doc.id)
                              .delete();
                        },
                      ),
                      onTap: () {
                        // Código para actualizar
                        _updateUser(doc);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateUser(QueryDocumentSnapshot doc) {
    _nameController.text = doc['name'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar Nombre'),
        content: TextField(
          controller: _nameController,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(doc.id)
                  .update({'name': _nameController.text});
              Navigator.of(context).pop();
            },
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
