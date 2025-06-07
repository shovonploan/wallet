abstract class Result<T> {}

class Success<T> extends Result<T> {
  final T value;
  Success(this.value);
}

class Error<T> extends Result<T> {
  final String message;
  Error(this.message);
}

abstract class Option<T> {}

class Some<T> extends Option<T> {
  final T value;
  Some(this.value);
}

class None extends Option {}

class StringListPair {
  final String first;
  final Map<String, dynamic> second;

  const StringListPair(this.first, this.second);
}
