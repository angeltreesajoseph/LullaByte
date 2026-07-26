# Family Sharing — Application Layer

The ViewModel layer (MVVM, SAD Section 7.3) for the Family Sharing feature,
implemented as Riverpod `Notifier`/`AsyncNotifier` classes. Translates user
actions from `presentation/` into `domain/` use-case invocations and exposes
loading/success/error state back to the UI.
