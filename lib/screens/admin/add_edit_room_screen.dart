import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  late TextEditingController _amenitiesController;
  late TextEditingController _sizeController;
  late TextEditingController _maxGuestsController;
  late TextEditingController _bedTypeController;
  Duration _selectedDuration = const Duration(minutes: 30);
  late RoomType _selectedType;
  late RoomStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.room?.roomNumber ?? '');
    _priceController = TextEditingController(text: widget.room?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.room?.description ?? '');
    _imageController = TextEditingController(text: widget.room?.images.isNotEmpty == true ? widget.room!.images[0] : '');
    _amenitiesController = TextEditingController(text: widget.room?.amenities.join(', ') ?? '');
    _sizeController = TextEditingController(text: widget.room?.size.toString() ?? '25');
    _maxGuestsController = TextEditingController(text: widget.room?.maxGuests.toString() ?? '2');
    _bedTypeController = TextEditingController(text: widget.room?.bedType ?? 'King Size');
    
    // Update duration if editing
    if (widget.room?.statusUntil != null) {
      final diff = widget.room!.statusUntil!.difference(DateTime.now());
      if (!diff.isNegative) {
        _selectedDuration = diff;
      }
    }
    
    _selectedType = widget.room?.roomType ?? RoomType.standard;
    _selectedStatus = widget.room?.status ?? RoomStatus.available;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _amenitiesController.dispose();
    _sizeController.dispose();
    _maxGuestsController.dispose();
    _bedTypeController.dispose();
    super.dispose();
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chọn thời gian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('XONG', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: _selectedDuration,
                  onTimerDurationChanged: (Duration newDuration) {
                    setState(() {
                      _selectedDuration = newDuration;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      DateTime? statusUntil;
      DateTime? statusStartedAt;

      if (_selectedStatus == RoomStatus.cleaning || _selectedStatus == RoomStatus.maintenance) {
        statusStartedAt = DateTime.now();
        statusUntil = statusStartedAt.add(_selectedDuration);
      }

      final roomData = Room(
        id: widget.room?.id ?? const Uuid().v4(),
        roomNumber: _numberController.text,
        roomType: _selectedType,
        price: double.parse(_priceController.text),
        status: _selectedStatus,
        description: _descriptionController.text,
        images: [_imageController.text.isNotEmpty ? _imageController.text : 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600&q=80'],
        amenities: _amenitiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        size: double.tryParse(_sizeController.text) ?? 25,
        maxGuests: int.tryParse(_maxGuestsController.text) ?? 2,
        bedType: _bedTypeController.text,
        statusUntil: statusUntil,
        statusStartedAt: statusStartedAt,
      );

      final isEditing = widget.room != null;
      if (isEditing) {
        await context.read<HotelProvider>().updateRoom(roomData);
      } else {
        await context.read<HotelProvider>().addRoom(roomData);
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
    bool showDurationField = _selectedStatus == RoomStatus.cleaning || _selectedStatus == RoomStatus.maintenance;

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
              if (showDurationField) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: _showDurationPicker,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedStatus == RoomStatus.cleaning ? 'Thời gian dọn dẹp' : 'Thời gian bảo trì',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedDuration.inHours} giờ ${_selectedDuration.inMinutes % 60} phút',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12),
                  child: Text(
                    'Hệ thống sẽ tự động chuyển về trạng thái Trống sau thời gian này.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _amenitiesController,
                decoration: const InputDecoration(
                  labelText: 'Tiện nghi (Cách nhau bởi dấu phẩy)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.list),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sizeController,
                      decoration: const InputDecoration(
                        labelText: 'Diện tích (m2)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxGuestsController,
                      decoration: const InputDecoration(
                        labelText: 'Khách tối đa',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bedTypeController,
                decoration: const InputDecoration(
                  labelText: 'Loại giường',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.bed),
                ),
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
