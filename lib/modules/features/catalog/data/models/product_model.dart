import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required int id,
    required String title,
    @Default('') String description,
    required double price,
    @Default(0) double rating,
    @Default(0) int stock,
    @Default('') String thumbnail,
    @Default([]) List<String> images,
    @Default('') String category,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}