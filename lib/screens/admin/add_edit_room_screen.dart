import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import '../../providers/hotel_provider.dart';
import 'package:uuid/uuid.dart';

class AddEditRoomScreen extends StatefulWidget {
  final Room? room;

  const AddEditRoomScreen({super.key, this.room});

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late RoomType _selectedType;
  late RoomStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.room?.roomNumber ?? '');
    _priceController = TextEditingController(text: widget.room?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.room?.description ?? '');
    _imageController = TextEditingController(text: widget.room?.images.isNotEmpty == true ? widget.room!.images[0] : '');
    _selectedType = widget.room?.roomType ?? RoomType.standard;
    _selectedStatus = widget.room?.status ?? RoomStatus.available;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final roomData = Room(
        id: widget.room?.id ?? const Uuid().v4(),
        roomNumber: _numberController.text,
        roomType: _selectedType,
        price: double.parse(_priceController.text),
        status: _selectedStatus,
        description: _descriptionController.text,
        images: [_imageController.text.isNotEmpty ? _imageController.text : 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600&q=80'],
      );

      final isEditing = widget.room != null;
      if (isEditing) {
        context.read<HotelProvider>().updateRoom(roomData);
      } else {
        context.read<HotelProvider>().addRoom(roomData);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Cập nhật phòng thành công!' : 'Thêm phòng mới thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room == null ? 'Thêm phòng mới' : 'Sửa thông tin phòng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Số phòng (VD: 101)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập số phòng' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RoomType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Loại phòng',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: RoomType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá phòng (VNĐ)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập giá';
                  if (double.tryParse(value) == null) return 'Giá phải là số';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RoomStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: RoomStatus.values.map((status) {
                  String label = '';
                  switch (status) {
                    case RoomStatus.available: label = 'Sẵn sàng (Available)'; break;
                    case RoomStatus.booked: label = 'Đã đặt (Booked)'; break;
                    case RoomStatus.cleaning: label = 'Đang dọn (Cleaning)'; break;
                    case RoomStatus.maintenance: label = 'Bảo trì (Maintenance)'; break;
                  }
                  return DropdownMenuItem(value: status, child: Text(label));
                }).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả chi tiết',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Link ảnh (Unsplash URL)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập link ảnh' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('LƯU THÔNG TIN', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
