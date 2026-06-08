class VoucherModel {
  final String code;
  final String title;
  final String description;
  final String condition;
  final String expireDate;
  final double discount;
  final IconDataData iconType;

  VoucherModel({
    required this.code,
    required this.title,
    required this.description,
    required this.condition,
    required this.expireDate,
    required this.discount,
    required this.iconType,
  });
}

enum IconDataData {
  gift,
  delivery,
  combo,
}


