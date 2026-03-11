class LocationService {
  static const Map<String, Map<String, List<String>>> vietnamData = {
    'Hà Nội': {
      'Ba Đình': ['Phúc Xá', 'Trúc Bạch', 'Vĩnh Phúc', 'Cống Vị', 'Liễu Giai', 'Nguyễn Trung Trực', 'Quán Thánh', 'Ngọc Hà', 'Đội Cấn', 'Giảng Võ', 'Kim Mã', 'Ngọc Khánh', 'Thành Công'],
      'Hoàn Kiếm': ['Phan Chu Trinh', 'Phúc Tân', 'Đồng Xuân', 'Hàng Mã', 'Hàng Buồm', 'Hàng Đào', 'Hàng Bồ', 'Cửa Đông', 'Lý Thái Tổ', 'Hàng Bạc', 'Hàng Gai', 'Chương Dương', 'Hàng Trống', 'Cửa Nam', 'Hàng Bông', 'Tràng Tiền', 'Trần Hưng Đạo', 'Hàng Bài'],
      'Tây Hồ': ['Phú Thượng', 'Nhật Tân', 'Tứ Liên', 'Quảng An', 'Xuân La', 'Yên Phụ', 'Bưởi', 'Thụy Khuê'],
      'Long Biên': ['Thượng Thanh', 'Đức Giang', 'Giang Biên', 'Ngọc Thụy', 'Việt Hưng', 'Phúc Lợi', 'Gia Thụy', 'Ngọc Lâm', 'Bồ Đề', 'Sài Đồng', 'Long Biên', 'Thạch Bàn', 'Phúc Đồng', 'Cự Khối'],
      'Cầu Giấy': ['Nghĩa Đô', 'Nghĩa Tân', 'Mai Dịch', 'Dịch Vọng', 'Dịch Vọng Hậu', 'Quan Hoa', 'Yên Hòa', 'Trung Hòa'],
      'Đống Đa': ['Cát Linh', 'Văn Miếu', 'Quốc Tử Giám', 'Láng Thượng', 'Ô Chợ Dừa', 'Hàng Bột', 'Nam Đồng', 'Trung Liệt', 'Khâm Thiên', 'Phương Liên', 'Phương Mai', 'Khương Thượng', 'Ngã Tư Sở', 'Láng Hạ', 'Thịnh Quang', 'Trung Tự', 'Kim Liên', 'Phương Liên', 'Thổ Quan', 'Trung Phụng', 'Văn Chương'],
      'Hai Bà Trưng': ['Nguyễn Du', 'Lê Đại Hành', 'Bùi Thị Xuân', 'Phố Huế', 'Ngô Thì Nhậm', 'Đồng Nhân', 'Bạch Đằng', 'Thanh Lương', 'Bách Khoa', 'Vĩnh Tuy', 'Trương Định', 'Đồng Tâm', 'Minh Khai', 'Quỳnh Lôi', 'Quỳnh Mai', 'Thanh Nhàn'],
      'Hoàng Mai': ['Hoàng Liệt', 'Yên Sở', 'Vĩnh Hưng', 'Định Công', 'Đại Kim', 'Thịnh Liệt', 'Giáp Bát', 'Tân Mai', 'Tương Mai', 'Trần Phú', 'Lĩnh Nam', 'Mai Động', 'Thanh Trì'],
      'Thanh Xuân': ['Hạ Đình', 'Khương Đình', 'Khương Mai', 'Khương Trung', 'Kim Giang', 'Phương Liệt', 'Thanh Xuân Bắc', 'Thanh Xuân Nam', 'Thanh Xuân Trung', 'Thượng Đình', 'Nhân Chính'],
      'Hà Đông': ['Quang Trung', 'Nguyễn Trãi', 'Hà Cầu', 'Vạn Phúc', 'Phúc La', 'Yết Kiêu', 'Mộ Lao', 'Văn Quán', 'La Khê', 'Phú La', 'Kiến Hưng', 'Yên Nghĩa', 'Phú Lương', 'Phú Lãm', 'Đồng Mai', 'Biên Giang', 'Dương Nội'],
    },
    'Hải Phòng': {
      'Hồng Bàng': ['Minh Khai', 'Hoàng Văn Thụ', 'Quang Trung', 'Phan Bội Châu', 'Phạm Hồng Thái', 'Hạ Lý', 'Thượng Lý', 'Trại Chuối'],
      'Lê Chân': ['An Biên', 'Cát Dài', 'Đông Hải', 'Dư Hàng', 'Dư Hàng Kênh', 'Hàng Kênh', 'Kênh Dương', 'Lam Sơn', 'Nghĩa Xá', 'Niệm Nghĩa', 'Trại Cau', 'Trần Nguyên Hãn', 'Vĩnh Niệm'],
      'Ngô Quyền': ['Cầu Đất', 'Cầu Tre', 'Đằng Giang', 'Đông Khê', 'Đồng Quốc Bình', 'Gia Viên', 'Lạc Viên', 'Lạch Tray', 'Lê Lợi', 'Máy Chai', 'Máy Tơ', 'Vạn Mỹ'],
    },
    'Bắc Ninh': {
      'Thành phố Bắc Ninh': ['Đáp Cầu', 'Thị Cầu', 'Vũ Ninh', 'Suối Hoa', 'Tiền An', 'Đại Phúc', 'Ninh Xá', 'Quang Châu', 'Vân Dương', 'Vạn An', 'Hạp Lĩnh', 'Phong Khê', 'Khúc Xuyên'],
      'Từ Sơn': ['Đông Ngàn', 'Đồng Kỵ', 'Trang Hạ', 'Đồng Nguyên', 'Tân Hồng', 'Phù Chẩn', 'Phù Khê', 'Hương Mạc', 'Tam Sơn', 'Tương Giang'],
    },
    'Quảng Ninh': {
      'Thành phố Hạ Long': ['Bạch Đằng', 'Hồng Gai', 'Cao Thắng', 'Cao Xanh', 'Giếng Đáy', 'Hà Khánh', 'Hà Khẩu', 'Hà Lầm', 'Hà Tu', 'Hà Trung', 'Hồng Hà', 'Hồng Hải', 'Hùng Thắng', 'Bãi Cháy', 'Tuần Châu', 'Việt Hưng', 'Đại Yên'],
      'Thành phố Cẩm Phả': ['Cẩm Bình', 'Cẩm Đông', 'Cẩm Phú', 'Cẩm Sơn', 'Cẩm Tây', 'Cẩm Thạch', 'Cẩm Thành', 'Cẩm Thủy', 'Cẩm Trung', 'Mông Dương', 'Quang Hanh'],
    },
    'Thái Nguyên': {
      'Thành phố Thái Nguyên': ['Cam Giá', 'Chùa Hang', 'Đồng Bẩm', 'Đồng Quang', 'Gia Sàng', 'Hoàng Văn Thụ', 'Hương Sơn', 'Phan Đình Phùng', 'Phú Xá', 'Quan Triều', 'Quang Trung', 'Quang Vinh', 'Tân Lập', 'Tân Thành', 'Tân Thịnh', 'Thịnh Đán', 'Túc Duyên', 'Trung Thành', 'Trưng Vương'],
    },
    'Vĩnh Phúc': {
      'Thành phố Vĩnh Yên': ['Liên Bảo', 'Tích Sơn', 'Đồng Tâm', 'Hội Hợp', 'Khai Quang', 'Đống Đa', 'Ngô Quyền', 'Thanh Trù', 'Định Trung'],
      'Thành phố Phúc Yên': ['Đồng Xuân', 'Hùng Vương', 'Phúc Thắng', 'Trưng Nhị', 'Trưng Trắc', 'Xuân Hòa', 'Nam Viêm', 'Tiền Châu'],
    },
    'Hải Dương': {
      'Thành phố Hải Dương': ['Bình Hàn', 'Cẩm Thượng', 'Hải Tân', 'Lê Thanh Nghị', 'Ngọc Châu', 'Nguyễn Trãi', 'Nhị Châu', 'Phạm Ngũ Lão', 'Quang Trung', 'Thanh Bình', 'Trần Hưng Đạo', 'Trần Phú', 'Việt Hòa'],
    },
    'Phú Thọ': {
      'Thành phố Việt Trì': ['Bạch Hạc', 'Bến Gót', 'Gia Cẩm', 'Nông Trang', 'Phủ Lộ', 'Tân Dân', 'Thanh Miếu', 'Thọ Sơn', 'Tiên Cát', 'Vân Cơ', 'Vân Phú'],
    },
    'Hưng Yên': {
      'Thành phố Hưng Yên': ['Lê Lợi', 'Quang Trung', 'Hồng Châu', 'Lam Sơn', 'Hiến Nam', 'An Tảo'],
      'Mỹ Hào': ['Bần Yên Nhân', 'Phan Đình Phùng', 'Nhân Hòa', 'Dị Chế'],
    },
    'Thái Bình': {
      'Thành phố Thái Bình': ['Đề Thám', 'Lê Hồng Phong', 'Kỳ Bá', 'Quang Trung', 'Phú Xuân'],
      'Tiền Hải': ['Thị trấn Tiền Hải', 'Tây Sơn', 'Tây Giang', 'Đông Cơ'],
    },
    'Nam Định': {
      'Thành phố Nam Định': ['Vị Xuyên', 'Bà Triệu', 'Năng Tĩnh', 'Trần Tế Xương', 'Cửa Bắc'],
      'Vụ Bản': ['Thị trấn Gôi', 'Thành Lợi', 'Liên Bảo', 'Tiên Tân'],
    },
    'Ninh Bình': {
      'Thành phố Ninh Bình': ['Vân Giang', 'Thanh Bình', 'Ninh Khánh', 'Ninh Phong', 'Nam Bình'],
      'Tam Điệp': ['Bắc Sơn', 'Trung Sơn', 'Nam Sơn', 'Tân Bình'],
    },
    'Hà Nam': {
      'Thành phố Phủ Lý': ['Hai Bà Trưng', 'Minh Khai', 'Lương Khánh Thiện', 'Liêm Chính', 'Trần Hưng Đạo'],
      'Duy Tiên': ['Hòa Mạc', 'Đồng Văn', 'Bạch Thượng', 'Yên Bắc'],
    }
  };


  static List<String> getProvinces() {
    return vietnamData.keys.toList()..sort();
  }

  static List<String> getDistricts(String province) {
    if (!vietnamData.containsKey(province)) return [];
    return vietnamData[province]!.keys.toList()..sort();
  }

  static List<String> getWards(String province, String district) {
    if (!vietnamData.containsKey(province) || !vietnamData[province]!.containsKey(district)) return [];
    return vietnamData[province]![district]!..sort();
  }
}
