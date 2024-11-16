mixin PaginationMixin<T> {
  bool _isLoading = false;
  bool _hasReachedMax = false;
  int _currentPage = 1;
  List<T> _items = [];

  bool get isLoading => _isLoading;
  bool get hasReachedMax => _hasReachedMax;
  int get currentPage => _currentPage;
  List<T> get items => _items;

  void resetPagination() {
    _isLoading = false;
    _hasReachedMax = false;
    _currentPage = 1;
    _items = [];
  }

  void updatePaginationState({
    required List<T> newItems,
    required bool hasReachedMax,
  }) {
    _items = newItems;
    _hasReachedMax = hasReachedMax;
    _currentPage++;
    _isLoading = false;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void initializePagination({int initialPage = 1}) {
    _currentPage = initialPage;
    _items = [];
    _hasReachedMax = false;
    _isLoading = false;
  }
} 