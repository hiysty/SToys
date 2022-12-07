import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const List<String> statusList = <String>[
  'Oldukça Eski',
  'Eski',
  'Ortalama',
  'Yeni',
  'Kutusu Açılmamış'
];

class ProductGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.purple);
  }
}

class CreateProduct extends StatefulWidget {
  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  final ImagePicker imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String dropdownValue = statusList[2];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: const Text("Ürün Ekle"),
          centerTitle: true,
        ),
        body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ürün Adı',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 3,
                    controller: descriptionController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ürün Açıklaması (İsteğe Bağlı)')),
                SizedBox(height: 10),
                DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Ürün Durumu',
                    ),
                    value: dropdownValue,
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: statusList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()),
                SizedBox(height: 10),
                MaterialButton(
                    color: Colors.blue,
                    child: const Text("Resim Ekle",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () {})
              ],
            )));
  }
}

class Product {
  Product(String title, String status, List<Image> image,
      {String? description});
}
