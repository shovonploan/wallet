class Ticker {
  const Ticker();

  Stream<int> tick({required int tickDuration}) {
    return Stream.periodic(Duration(seconds: tickDuration), (x) => x + 1);
  }
}
