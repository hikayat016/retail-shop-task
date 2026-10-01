import '../../../../../core/network/api_response.dart';
import '../../../../../core/network/generic_api_service.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._apiService);

  final GenericApiService _apiService;

  @override
  Future<ListResponse<ProductModel>> getProducts({
    required int limit,
    required int skip,
    String query = '',
  }) {
    final searchPath = query.isEmpty ? '/products' : '/products/search';
    return _apiService.getList<ProductModel>(
      path: searchPath,
      query: {
        'limit': limit,
        'skip': skip,
        if (query.isNotEmpty) 'q': query,
      },
      listDecoder: (json) => json
          .map(
            (item) => ProductModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    final response = await _apiService.get<ProductModel>(
      path: '/products/$id',
      decoder: (json) => ProductModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return response.data;
  }
}