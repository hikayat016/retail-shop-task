import '../../../../../core/network/api_response.dart';
import '../../data/models/product_model.dart';

abstract interface class ProductRepository {
  Future<ListResponse<ProductModel>> getProducts({
    required int limit,
    required int skip,
    String query = '',
  });

  Future<ProductModel> getProduct(int id);
}