import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/service.dart';

class AddEditServiceScreen extends StatefulWidget {
  final HotelService? service;

  const AddEditServiceScreen({super.key, this.service});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late TextEditingController _durationController;
  String _selectedCategory = 'Dining';

  final List<String> _categories = [
    'Dining',
    'Wellness',
    'Leisure',
    'Transport',
    'Experience',
    'Special',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _priceController = TextEditingController(text: widget.service?.price?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.service?.description ?? '');
    _imageController = TextEditingController(text: widget.service?.image ?? '');
    _durationController = TextEditingController(text: widget.service?.duration ?? '');
    if (widget.service != null && _categories.contains(widget.service!.category)) {
      _selectedCategory = widget.service!.category!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<HotelProvider>(context, listen: false);
      final newService = HotelService(
        id: widget.service?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        image: _imageController.text,
        duration: _durationController.text,
        category: _selectedCategory,
      );

      if (widget.service == null) {
        await provider.addService(newService);
      } else {
        await provider.updateService(newService);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.service == null ? 'Đã thêm dịch vụ thành công!' : 'Đã cập nhật dịch vụ thành công!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service == null ? 'Thêm dịch vụ' : 'Chỉnh sửa dịch vụ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên dịch vụ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.room_service),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên dịch vụ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá tiền (VNĐ)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập giá tiền';
                  if (double.tryParse(value) == null) return 'Giá tiền không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Thời gian / Tần suất',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                  hintText: 'VD: 90 phút, 06:00 - 10:30, Theo chuyến bay...',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'URL hình ảnh',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả dịch vụ',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập mô tả' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    widget.service == null ? 'THÊM DỊCH VỤ' : 'LƯU THAY ĐỔI',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
