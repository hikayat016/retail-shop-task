class PaginationMeta {
  const PaginationMeta({
    required this.total,
    required this.skip,
    required this.limit,
  });

  final int total;
  final int skip;
  final int limit;

  bool get hasMore => skip + limit < total;
}

class ListResponse<T> {
  const ListResponse({
    required this.items,
    required this.pagination,
  });

  final List<T> items;
  final PaginationMeta pagination;
}

class SingleResponse<T> {
  const SingleResponse({required this.data});

  final T data;
}