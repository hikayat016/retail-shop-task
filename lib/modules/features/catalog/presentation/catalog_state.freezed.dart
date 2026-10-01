// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogState {

 bool get isInitialLoading; bool get isRefreshing; bool get isLoadingMore; bool get hasReachedEnd; String get searchQuery; List<ProductModel> get products; Set<int> get favoriteIds; List<String> get recentSearches; String get errorMessage; bool get isNetworkError; bool get isRefreshError;
/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogStateCopyWith<CatalogState> get copyWith => _$CatalogStateCopyWithImpl<CatalogState>(this as CatalogState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CatalogState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogState&&(identical(other.isInitialLoading, _this.isInitialLoading) || other.isInitialLoading == _this.isInitialLoading)&&(identical(other.isRefreshing, _this.isRefreshing) || other.isRefreshing == _this.isRefreshing)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.hasReachedEnd, _this.hasReachedEnd) || other.hasReachedEnd == _this.hasReachedEnd)&&(identical(other.searchQuery, _this.searchQuery) || other.searchQuery == _this.searchQuery)&&const DeepCollectionEquality().equals(other.products, _this.products)&&const DeepCollectionEquality().equals(other.favoriteIds, _this.favoriteIds)&&const DeepCollectionEquality().equals(other.recentSearches, _this.recentSearches)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.isNetworkError, _this.isNetworkError) || other.isNetworkError == _this.isNetworkError)&&(identical(other.isRefreshError, _this.isRefreshError) || other.isRefreshError == _this.isRefreshError));
}


@override
int get hashCode {
  final _this = this as CatalogState;
  return Object.hash(runtimeType,_this.isInitialLoading,_this.isRefreshing,_this.isLoadingMore,_this.hasReachedEnd,_this.searchQuery,const DeepCollectionEquality().hash(_this.products),const DeepCollectionEquality().hash(_this.favoriteIds),const DeepCollectionEquality().hash(_this.recentSearches),_this.errorMessage,_this.isNetworkError,_this.isRefreshError);
}

@override
String toString() {
  final _this = this as CatalogState;
  return 'CatalogState(isInitialLoading: ${_this.isInitialLoading}, isRefreshing: ${_this.isRefreshing}, isLoadingMore: ${_this.isLoadingMore}, hasReachedEnd: ${_this.hasReachedEnd}, searchQuery: ${_this.searchQuery}, products: ${_this.products}, favoriteIds: ${_this.favoriteIds}, recentSearches: ${_this.recentSearches}, errorMessage: ${_this.errorMessage}, isNetworkError: ${_this.isNetworkError}, isRefreshError: ${_this.isRefreshError})';
}


}

/// @nodoc
abstract mixin class $CatalogStateCopyWith<$Res>  {
  factory $CatalogStateCopyWith(CatalogState value, $Res Function(CatalogState) _then) = _$CatalogStateCopyWithImpl;
@useResult
$Res call({
 bool isInitialLoading, bool isRefreshing, bool isLoadingMore, bool hasReachedEnd, String searchQuery, List<ProductModel> products, Set<int> favoriteIds, List<String> recentSearches, String errorMessage, bool isNetworkError, bool isRefreshError
});




}
/// @nodoc
class _$CatalogStateCopyWithImpl<$Res>
    implements $CatalogStateCopyWith<$Res> {
  _$CatalogStateCopyWithImpl(this._self, this._then);

  final CatalogState _self;
  final $Res Function(CatalogState) _then;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isInitialLoading = null,Object? isRefreshing = null,Object? isLoadingMore = null,Object? hasReachedEnd = null,Object? searchQuery = null,Object? products = null,Object? favoriteIds = null,Object? recentSearches = null,Object? errorMessage = null,Object? isNetworkError = null,Object? isRefreshError = null,}) {
  return _then(CatalogState(
isInitialLoading: null == isInitialLoading ? _self.isInitialLoading : isInitialLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasReachedEnd: null == hasReachedEnd ? _self.hasReachedEnd : hasReachedEnd // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<ProductModel>,favoriteIds: null == favoriteIds ? _self.favoriteIds : favoriteIds // ignore: cast_nullable_to_non_nullable
as Set<int>,recentSearches: null == recentSearches ? _self.recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<String>,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,isNetworkError: null == isNetworkError ? _self.isNetworkError : isNetworkError // ignore: cast_nullable_to_non_nullable
as bool,isRefreshError: null == isRefreshError ? _self.isRefreshError : isRefreshError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogState].
extension CatalogStatePatterns on CatalogState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogState value)  $default,){
final _that = this;
switch (_that) {
case _CatalogState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogState value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isInitialLoading,  bool isRefreshing,  bool isLoadingMore,  bool hasReachedEnd,  String searchQuery,  List<ProductModel> products,  Set<int> favoriteIds,  List<String> recentSearches,  String errorMessage,  bool isNetworkError,  bool isRefreshError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that.isInitialLoading,_that.isRefreshing,_that.isLoadingMore,_that.hasReachedEnd,_that.searchQuery,_that.products,_that.favoriteIds,_that.recentSearches,_that.errorMessage,_that.isNetworkError,_that.isRefreshError);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isInitialLoading,  bool isRefreshing,  bool isLoadingMore,  bool hasReachedEnd,  String searchQuery,  List<ProductModel> products,  Set<int> favoriteIds,  List<String> recentSearches,  String errorMessage,  bool isNetworkError,  bool isRefreshError)  $default,) {final _that = this;
switch (_that) {
case _CatalogState():
return $default(_that.isInitialLoading,_that.isRefreshing,_that.isLoadingMore,_that.hasReachedEnd,_that.searchQuery,_that.products,_that.favoriteIds,_that.recentSearches,_that.errorMessage,_that.isNetworkError,_that.isRefreshError);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isInitialLoading,  bool isRefreshing,  bool isLoadingMore,  bool hasReachedEnd,  String searchQuery,  List<ProductModel> products,  Set<int> favoriteIds,  List<String> recentSearches,  String errorMessage,  bool isNetworkError,  bool isRefreshError)?  $default,) {final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that.isInitialLoading,_that.isRefreshing,_that.isLoadingMore,_that.hasReachedEnd,_that.searchQuery,_that.products,_that.favoriteIds,_that.recentSearches,_that.errorMessage,_that.isNetworkError,_that.isRefreshError);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogState implements CatalogState {
  const _CatalogState({this.isInitialLoading = false, this.isRefreshing = false, this.isLoadingMore = false, this.hasReachedEnd = false, this.searchQuery = '',  List<ProductModel> products = const [],  Set<int> favoriteIds = const <int>{},  List<String> recentSearches = const [], this.errorMessage = '', this.isNetworkError = false, this.isRefreshError = false}): _products = products,_favoriteIds = favoriteIds,_recentSearches = recentSearches;
  

@override@JsonKey() final  bool isInitialLoading;
@override@JsonKey() final  bool isRefreshing;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  bool hasReachedEnd;
@override@JsonKey() final  String searchQuery;
 final  List<ProductModel> _products;
@override@JsonKey() List<ProductModel> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

 final  Set<int> _favoriteIds;
@override@JsonKey() Set<int> get favoriteIds {
  if (_favoriteIds is EqualUnmodifiableSetView) return _favoriteIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_favoriteIds);
}

 final  List<String> _recentSearches;
@override@JsonKey() List<String> get recentSearches {
  if (_recentSearches is EqualUnmodifiableListView) return _recentSearches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentSearches);
}

@override@JsonKey() final  String errorMessage;
@override@JsonKey() final  bool isNetworkError;
@override@JsonKey() final  bool isRefreshError;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogStateCopyWith<_CatalogState> get copyWith => __$CatalogStateCopyWithImpl<_CatalogState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogState&&(identical(other.isInitialLoading, isInitialLoading) || other.isInitialLoading == isInitialLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasReachedEnd, hasReachedEnd) || other.hasReachedEnd == hasReachedEnd)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other.products, _products)&&const DeepCollectionEquality().equals(other.favoriteIds, _favoriteIds)&&const DeepCollectionEquality().equals(other.recentSearches, _recentSearches)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isNetworkError, isNetworkError) || other.isNetworkError == isNetworkError)&&(identical(other.isRefreshError, isRefreshError) || other.isRefreshError == isRefreshError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isInitialLoading,isRefreshing,isLoadingMore,hasReachedEnd,searchQuery,const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_favoriteIds),const DeepCollectionEquality().hash(_recentSearches),errorMessage,isNetworkError,isRefreshError);
}

@override
String toString() {
    return 'CatalogState(isInitialLoading: $isInitialLoading, isRefreshing: $isRefreshing, isLoadingMore: $isLoadingMore, hasReachedEnd: $hasReachedEnd, searchQuery: $searchQuery, products: $products, favoriteIds: $favoriteIds, recentSearches: $recentSearches, errorMessage: $errorMessage, isNetworkError: $isNetworkError, isRefreshError: $isRefreshError)';
}


}

/// @nodoc
abstract mixin class _$CatalogStateCopyWith<$Res> implements $CatalogStateCopyWith<$Res> {
  factory _$CatalogStateCopyWith(_CatalogState value, $Res Function(_CatalogState) _then) = __$CatalogStateCopyWithImpl;
@override @useResult
$Res call({
 bool isInitialLoading, bool isRefreshing, bool isLoadingMore, bool hasReachedEnd, String searchQuery, List<ProductModel> products, Set<int> favoriteIds, List<String> recentSearches, String errorMessage, bool isNetworkError, bool isRefreshError
});




}
/// @nodoc
class __$CatalogStateCopyWithImpl<$Res>
    implements _$CatalogStateCopyWith<$Res> {
  __$CatalogStateCopyWithImpl(this._self, this._then);

  final _CatalogState _self;
  final $Res Function(_CatalogState) _then;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isInitialLoading = null,Object? isRefreshing = null,Object? isLoadingMore = null,Object? hasReachedEnd = null,Object? searchQuery = null,Object? products = null,Object? favoriteIds = null,Object? recentSearches = null,Object? errorMessage = null,Object? isNetworkError = null,Object? isRefreshError = null,}) {
  return _then(_CatalogState(
isInitialLoading: null == isInitialLoading ? _self.isInitialLoading : isInitialLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasReachedEnd: null == hasReachedEnd ? _self.hasReachedEnd : hasReachedEnd // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<ProductModel>,favoriteIds: null == favoriteIds ? _self._favoriteIds : favoriteIds // ignore: cast_nullable_to_non_nullable
as Set<int>,recentSearches: null == recentSearches ? _self._recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<String>,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,isNetworkError: null == isNetworkError ? _self.isNetworkError : isNetworkError // ignore: cast_nullable_to_non_nullable
as bool,isRefreshError: null == isRefreshError ? _self.isRefreshError : isRefreshError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
