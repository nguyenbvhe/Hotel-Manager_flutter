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
      'Bắc Từ Liêm': ['Thượng Cát', 'Liên Mạc', 'Thụy Phương', 'Đông Ngạc', 'Đức Thắng', 'Xuân Đỉnh', 'Xuân Tảo', 'Cổ Nhuế 1', 'Cổ Nhuế 2', 'Phúc Diễn', 'Phú Diễn', 'Minh Khai', 'Tây Tựu'],
      'Nam Từ Liêm': ['Cầu Diễn', 'Xuân Phương', 'Phương Canh', 'Mỹ Đình 1', 'Mỹ Đình 2', 'Cầu Diễn', 'Mễ Trì', 'Phú Đô', 'Đại Mỗ', 'Trung Văn', 'Tây Mỗ'],
      'Thanh Trì': ['Thị trấn Văn Điển', 'Tân Triều', 'Thanh Liệt', 'Tả Thanh Oai', 'Hữu Hòa', 'Tam Hiệp', 'Tứ Hiệp', 'Ngũ Hiệp', 'Ngọc Hồi', 'Vĩnh Quỳnh'],
      'Gia Lâm': ['Thị trấn Trâu Quỳ', 'Thị trấn Yên Viên', 'Yên Thường', 'Ninh Hiệp', 'Phù Đổng', 'Trung Mầu', 'Lệ Chi', 'Cổ Bi', 'Đặng Xá', 'Phú Thị'],
      'Đông Anh': ['Thị trấn Đông Anh', 'Xuân Nộn', 'Thụy Lâm', 'Bắc Hồng', 'Nguyên Khê', 'Nam Hồng', 'Tiên Dương', 'Vân Hà', 'Uy Nỗ', 'Vân Nội'],
      'Sóc Sơn': ['Thị trấn Sóc Sơn', 'Tân Minh', 'Tiên Dược', 'Phù Linh', 'Bắc Sơn', 'Hồng Kỳ', 'Nam Sơn', 'Phù Lỗ', 'Trung Giã'],
      'Sơn Tây': ['Lê Lợi', 'Ngô Quyền', 'Quang Trung', 'Sơn Lộc', 'Xuân Khanh', 'Trung Hưng', 'Viên Sơn', 'Trung Sơn Trầm', 'Đường Lâm'],
    },
    'Hải Phòng': {
      'Hồng Bàng': ['Minh Khai', 'Hoàng Văn Thụ', 'Quang Trung', 'Phan Bội Châu', 'Phạm Hồng Thái', 'Hạ Lý', 'Thượng Lý', 'Trại Chuối'],
      'Lê Chân': ['An Biên', 'Cát Dài', 'Đông Hải', 'Dư Hàng', 'Dư Hàng Kênh', 'Hàng Kênh', 'Kênh Dương', 'Lam Sơn', 'Nghĩa Xá', 'Niệm Nghĩa', 'Trại Cau', 'Trần Nguyên Hãn', 'Vĩnh Niệm'],
      'Ngô Quyền': ['Cầu Đất', 'Cầu Tre', 'Đằng Giang', 'Đông Khê', 'Đồng Quốc Bình', 'Gia Viên', 'Lạc Viên', 'Lạch Tray', 'Lê Lợi', 'Máy Chai', 'Máy Tơ', 'Vạn Mỹ'],
      'Kiến An': ['Quán Trữ', 'Lãm Hà', 'Đồng Hòa', 'Bắc Sơn', 'Nam Sơn', 'Ngọc Sơn', 'Trần Thành Ngọ', 'Phù Liễn', 'Tràng Minh'],
      'Hải An': ['Đông Hải 1', 'Đông Hải 2', 'Đằng Lâm', 'Thành Tô', 'Đằng Hải', 'Nam Hải', 'Cát Bi', 'Tràng Cát'],
      'Đồ Sơn': ['Ngọc Xuyên', 'Vạn Hương', 'Hợp Đức', 'Bàng La', 'Minh Đức'],
      'Dương Kinh': ['Anh Dũng', 'Hưng Đạo', 'Đa Phúc', 'Hòa Nghĩa', 'Tân Thành', 'Hải Thành'],
      'Thủy Nguyên': ['Thị trấn Núi Đèo', 'Thị trấn Minh Đức', 'Lại Xuân', 'An Sơn', 'Kỳ Sơn', 'Liên Khê', 'Gia Đức', 'Gia Minh'],
      'An Dương': ['Thị trấn An Dương', 'An Hồng', 'An Hòa', 'Bắc Sơn', 'Nam Sơn', 'Lê Lợi', 'Hồng Phong'],
    },
    'Bắc Ninh': {
      'Thành phố Bắc Ninh': ['Đáp Cầu', 'Thị Cầu', 'Vũ Ninh', 'Suối Hoa', 'Tiền An', 'Đại Phúc', 'Ninh Xá', 'Quang Châu', 'Vân Dương', 'Vạn An', 'Hạp Lĩnh', 'Phong Khê', 'Khúc Xuyên', 'Võ Cường', 'Hòa Long'],
      'Từ Sơn': ['Đông Ngàn', 'Đồng Kỵ', 'Trang Hạ', 'Đồng Nguyên', 'Tân Hồng', 'Phù Chẩn', 'Phù Khê', 'Hương Mạc', 'Tam Sơn', 'Tương Giang'],
      'Quế Võ': ['Thị trấn Phố Mới', 'Việt Hùng', 'Bằng An', 'Cách Bi', 'Chi Lăng', 'Đại Xuân', 'Đào Viên'],
      'Tiên Du': ['Thị trấn Lim', 'Nội Duệ', 'Liên Bão', 'Cảnh Hưng', 'Hiên Vân', 'Hoàn Sơn', 'Lạc Vệ', 'Phật Tích'],
      'Yên Phong': ['Thị trấn Chờ', 'Dũng Liệt', 'Đông Phong', 'Đông Thọ', 'Đông Tiến', 'Hòa Tiến', 'Long Châu', 'Tam Đa', 'Yên Trung'],
      'Thuận Thành': ['Thị trấn Hồ', 'An Bình', 'Đại Đồng Thành', 'Đình Tổ', 'Gia Đông', 'Hà Mãn', 'Hoài Thượng'],
    },
    'Hải Dương': {
      'Thành phố Hải Dương': ['Bình Hàn', 'Cẩm Thượng', 'Hải Tân', 'Lê Thanh Nghị', 'Ngọc Châu', 'Nguyễn Trãi', 'Nhị Châu', 'Phạm Ngũ Lão', 'Quang Trung', 'Thanh Bình', 'Trần Hưng Đạo', 'Trần Phú', 'Việt Hòa', 'Nam Đồng', 'Tứ Minh'],
      'Chí Linh': ['Phả Lại', 'Sao Đỏ', 'Bến Tắm', 'Cộng Hòa', 'Đồng Lạc', 'Hoàng Tân', 'Thái Học', 'Văn An', 'Văn Đức'],
      'Kinh Môn': ['An Lưu', 'Hiệp An', 'Hiệp Sơn', 'Long Xuyên', 'Minh Tân', 'Phú Thứ', 'Thái Thịnh', 'Thất Hùng'],
      'Cẩm Giàng': ['Thị trấn Cẩm Giang', 'Thị trấn Lai Cách', 'Cẩm Điền', 'Cẩm Đoài', 'Cẩm Phúc', 'Cẩm Vũ', 'Đức Chính', 'Lương Điền'],
      'Bình Giang': ['Thị trấn Kẻ Sặt', 'Bình Minh', 'Bình Xuyên', 'Hồng Khê', 'Hùng Thắng', 'Nhân Quyền', 'Thúc Kháng'],
      'Nam Sách': ['Thị trấn Nam Sách', 'An Bình', 'An Lâm', 'An Sơn', 'Cộng Hòa', 'Đồng Lạc'],
    },
    'Hưng Yên': {
      'Thành phố Hưng Yên': ['Lê Lợi', 'Quang Trung', 'Hồng Châu', 'Lam Sơn', 'Hiến Nam', 'An Tảo', 'Minh Khai', 'Hồng Nam'],
      'Mỹ Hào': ['Bần Yên Nhân', 'Phan Đình Phùng', 'Nhân Hòa', 'Dị Chế', 'Phùng Chí Kiên', 'Bạch Quang'],
      'Văn Lâm': ['Thị trấn Như Quỳnh', 'Chỉ Đạo', 'Đại Đồng', 'Đình Dù', 'Lạc Đạo', 'Lạc Hồng', 'Tân Quang', 'Trưng Trắc'],
      'Văn Giang': ['Thị trấn Văn Giang', 'Cửu Cao', 'Liên Nghĩa', 'Long Hưng', 'Mễ Sở', 'Phụng Công', 'Thắng Lợi', 'Xuân Quan'],
      'Yên Mỹ': ['Thị trấn Yên Mỹ', 'Đồng Than', 'Giai Phạm', 'Hoàn Long', 'Liêu Xá', 'Lý Thường Kiệt', 'Tân Lập', 'Trung Hòa'],
      'Khoái Châu': ['Thị trấn Khoái Châu', 'Bình Minh', 'Dạ Trạch', 'Đông Kết', 'Đông Ninh', 'Hàm Tử', 'Ông Đình', 'Tứ Dân'],
    },
    'Thái Bình': {
      'Thành phố Thái Bình': ['Đề Thám', 'Lê Hồng Phong', 'Kỳ Bá', 'Quang Trung', 'Phú Xuân', 'Trần Hưng Đạo', 'Tiền Phong', 'Bồ Xuyên'],
      'Tiền Hải': ['Thị trấn Tiền Hải', 'Tây Sơn', 'Tây Giang', 'Đông Cơ', 'Đông Lâm', 'Đông Minh', 'Đông Phong', 'Nam Chính'],
      'Hưng Hà': ['Thị trấn Hưng Hà', 'Thị trấn Hưng Nhân', 'Canh Tân', 'Cấp Tiến', 'Chí Hòa', 'Độc Lập', 'Tiến Đức', 'Thái Phương'],
      'Đông Hưng': ['Thị trấn Đông Hưng', 'Trọng Quan', 'Đông Hợp', 'Đông Các', 'Đông Khê', 'An Châu', 'Đông La'],
      'Quỳnh Phụ': ['Thị trấn Quỳnh Côi', 'Thị trấn An Bài', 'Quỳnh Hồng', 'Quỳnh Thọ', 'Quỳnh Hải', 'Quỳnh Hoa', 'Quỳnh Mỹ'],
      'Thái Thụy': ['Thị trấn Diêm Điền', 'Thụy Hải', 'Thụy Xuân', 'Thụy Liên', 'Thái Nguyên', 'Thái Thượng'],
    },
    'Nam Định': {
      'Thành phố Nam Định': ['Vị Xuyên', 'Bà Triệu', 'Năng Tĩnh', 'Trần Tế Xương', 'Cửa Bắc', 'Quang Trung', 'Hạ Long', 'Lộc Vượng', 'Mỹ Xá'],
      'Vụ Bản': ['Thị trấn Gôi', 'Thành Lợi', 'Liên Bảo', 'Tiên Tân', 'Quang Trung', 'Trung Thành', 'Kim Thái'],
      'Hải Hậu': ['Thị trấn Yên Định', 'Thị trấn Cồn', 'Thị trấn Thịnh Long', 'Hải Chính', 'Hải Lý', 'Hải Đông', 'Hải Tây', 'Hải Quang'],
      'Giao Thủy': ['Thị trấn Ngô Đồng', 'Thị trấn Quất Lâm', 'Giao Phong', 'Giao Yến', 'Giao Hải', 'Giao Nhân', 'Giao Thiện'],
      'Nghĩa Hưng': ['Thị trấn Liễu Đề', 'Thị trấn Rạng Đông', 'Nghĩa Lạc', 'Nghĩa Hồng', 'Nghĩa Lâm', 'Nghĩa Thịnh'],
    },
    'Ninh Bình': {
      'Thành phố Ninh Bình': ['Vân Giang', 'Thanh Bình', 'Ninh Khánh', 'Ninh Phong', 'Nam Bình', 'Phúc Thành', 'Bích Đào', 'Ninh Sơn'],
      'Tam Điệp': ['Bắc Sơn', 'Trung Sơn', 'Nam Sơn', 'Tân Bình', 'Yên Bình', 'Quang Sơn', 'Tây Sơn'],
      'Hoa Lư': ['Thị trấn Thiên Tôn', 'Ninh Hải', 'Ninh Hòa', 'Trường Yên', 'Ninh An', 'Ninh Giang', 'Ninh Mỹ'],
      'Gia Viễn': ['Thị trấn Me', 'Gia Sinh', 'Gia Thắng', 'Gia Tiến', 'Gia Xuân', 'Gia Trấn', 'Gia Vân'],
      'Kim Sơn': ['Thị trấn Phát Diệm', 'Thị trấn Bình Minh', 'Kim Chính', 'Đồng Hướng', 'Hùng Tiến', 'Như Hòa', 'Quang Thiện'],
      'Nho Quan': ['Thị trấn Nho Quan', 'Cúc Phương', 'Sơn Hà', 'Quỳnh Lưu', 'Đồng Phong', 'Đức Long', 'Gia Lâm'],
    },
    'Vĩnh Phúc': {
      'Thành phố Vĩnh Yên': ['Liên Bảo', 'Tích Sơn', 'Đồng Tâm', 'Hội Hợp', 'Khai Quang', 'Đống Đa', 'Ngô Quyền', 'Thanh Trù', 'Định Trung'],
      'Thành phố Phúc Yên': ['Đồng Xuân', 'Hùng Vương', 'Phúc Thắng', 'Trưng Nhị', 'Trưng Trắc', 'Xuân Hòa', 'Nam Viêm', 'Tiền Châu'],
      'Bình Xuyên': ['Thị trấn Hương Canh', 'Thị trấn Gia Khánh', 'Thị trấn Bá Hiến', 'Thị trấn Đạo Đức', 'Quất Lưu', 'Tam Hợp'],
      'Lập Thạch': ['Thị trấn Lập Thạch', 'Thị trấn Hoa Sơn', 'Bàn Giản', 'Đình Chu', 'Tiên Lữ', 'Tử Du', 'Xuân Lôi'],
      'Vĩnh Tường': ['Thị trấn Vĩnh Tường', 'Thị trấn Thổ Tang', 'Bình Dương', 'Đại Đồng', 'Nghĩa Hưng', 'Thượng Trưng'],
    },
    'Hà Nam': {
      'Thành phố Phủ Lý': ['Hai Bà Trưng', 'Minh Khai', 'Lương Khánh Thiện', 'Liêm Chính', 'Trần Hưng Đạo', 'Lam Hạ', 'Thanh Tuyền', 'Châu Sơn'],
      'Duy Tiên': ['Hòa Mạc', 'Đồng Văn', 'Bạch Thượng', 'Yên Bắc', 'Duy Hải', 'Duy Minh', 'Tiên Nội'],
      'Kim Bảng': ['Thị trấn Quế', 'Thị trấn Ba Sao', 'Nhật Tựu', 'Liên Sơn', 'Khả Phong', 'Thi Sơn', 'Tượng Lĩnh'],
      'Lý Nhân': ['Thị trấn Vĩnh Trụ', 'Nhân Chính', 'Nhân Hậu', 'Nhân Mỹ', 'Chính Lý', 'Đạo Lý'],
      'Thanh Liêm': ['Thị trấn Tân Thanh', 'Thanh Hà', 'Thanh Nguyên', 'Thanh Thủy', 'Liêm Cần', 'Liêm Phong'],
    },
    'Phú Thọ': {
      'Thành phố Việt Trì': ['Bạch Hạc', 'Bến Gót', 'Gia Cẩm', 'Nông Trang', 'Phủ Lộ', 'Tân Dân', 'Thanh Miếu', 'Thọ Sơn', 'Tiên Cát', 'Vân Cơ', 'Vân Phú', 'Dữu Lâu', 'Minh Nông', 'Minh Phương'],
      'Thị xã Phú Thọ': ['Âu Cơ', 'Hùng Vương', 'Phong Châu', 'Thanh Vinh', 'Hà Lộc', 'Hà Thạch', 'Phú Hộ'],
      'Phù Ninh': ['Thị trấn Phong Châu', 'Phù Ninh', 'Tây Cốc', 'Trạm Thản', 'Liên Hoa', 'Phú Lộc', 'Tiên Du'],
      'Lâm Thao': ['Thị trấn Lâm Thao', 'Thị trấn Hùng Sơn', 'Cao Xá', 'Tiên Kiên', 'Vĩnh Lại', 'Sơn Vi', 'Tứ Xã'],
      'Thanh Ba': ['Thị trấn Thanh Ba', 'Chí Tiên', 'Đông Thành', 'Khải Xuân', 'Ninh Dân', 'Vân Lĩnh'],
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
    return List<String>.from(vietnamData[province]![district]!)..sort();
  }
}
