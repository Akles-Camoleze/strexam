import 'package:exam_app/utils/extensions.dart';

class LimitedSortedList<T> {
  final List<T> _items = [];
  final int maxSize;
  final int Function(T a, T b) _comparator;
  
  LimitedSortedList({required this.maxSize, required int Function(T a, T b) comparator})
      : _comparator = comparator;
  
  void updateOrInsert(T item, bool Function(T) predicate) {
    _items.removeWhere(predicate);
    _items.insertSorted(item, _comparator);
    
    if (_items.length > maxSize) {
      _items.removeRange(maxSize, _items.length);
    }
  }
  
  List<T> get items => List.unmodifiable(_items);
  int get length => _items.length;
  bool get isNotEmpty => _items.isNotEmpty;
  void clear() => _items.clear();
  T get first => _items.first;

  Iterable<E> map<E>(E Function(T) toElement) => _items.map(toElement);
}