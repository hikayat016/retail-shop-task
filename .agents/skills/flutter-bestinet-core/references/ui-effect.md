# UiEffect — full contract

Open this when wiring effects into a ViewModel or View. `SKILL.md` §5 is the summary; this file is
the complete rule set. Models live in `lib/core/utils/side_effects/ui_effect/`, the runner and
listeners in `lib/app/ui/ui_effect/`.

## 1. Laws
- An effect is **never derived from state, never mutates state, and runs exactly once.**
- A `UiEffect` is the only legal mechanism for **any** ViewModel-driven, non-persistent UI reaction —
  navigation, dialog, snackbar, toast, pop — not only navigation.
- The VM emits; `UiEffectRunner` interprets. Views never hand-write a `switch` over effects, never
  re-emit an effect, and never persist its outcome.
- Use the typed taxonomy below; never raw strings for feedback or actions.
- For one error, pick **persistent** (`state.errorMessage`, rendered inline with Retry) **or**
  **transient** (`UiEffect` + `UiFeedback`) — not both, unless the screen explicitly requires it.
- The UI must not show a dialog/snackbar driven by `state.errorMessage`, and must not use rebuilds to
  re-trigger a transient effect.
- **Confirmation belongs to the UI**: the view shows the confirm dialog and calls the VM method only
  after the user confirms. The VM never asks for confirmation.

## 2. Model API
```dart
UiEffect.create({required Object scenario, UiFeedback? feedback, UiAction? action})
// id is generated per emission (microsecondsSinceEpoch). Never pass `id` yourself — the unique id
// is what stops a repeated user action from being deduped as a stale duplicate.

UiFeedback.dialog({required UiFeedbackStyle style, required String title, required String message,
                   required DismissPolicy dismissPolicy, UiAction? afterDismiss})   // blocking
UiFeedback.snackBar({required UiFeedbackStyle style, required String message,
                     Duration? duration, UiAction? afterDismiss})
UiFeedback.toast({required UiFeedbackStyle style, required String message, Duration? duration})
enum UiFeedbackStyle { success, error, warning, info }
DismissPolicy.ok({String label = 'OK'}) | DismissPolicy.auto({Duration? duration})

UiAction.none() | UiAction.navigate(command: NavCommand) | UiAction.pop({Object? result})
  | UiAction.doublePop({Object? result}) | UiAction.custom(token: Object)

NavCommand.pushNamed({required String route, Object? arguments})
NavCommand.pushReplacementNamed({required String route, Object? arguments})
NavCommand.pushNamedAndRemoveUntil({required String route, Object? arguments, bool clearStack = true})
```
- **The call-site API above is the contract, not the implementation.** The models may be Freezed
  unions or Dart 3 `sealed` classes with factory constructors — a project without Freezed uses sealed
  classes rather than adding a code generator just for effects. Consumers `switch` over the subtypes
  exhaustively either way.
- After a dialog, prefer `UiAction.pop` as its `afterDismiss` — the runner's OK button already pops
  the dialog. Keep `doublePop` for one action that must unwind two routes.
- `route` is `AppRoute.x.path`, so a `NavCommand` carrying it cannot be `const`.

## 3. Scenarios
- `scenario` is typed `Object`: an enum value **or** a `static const String`.
- String scenarios live in the module's `domain/<m>_ui_scenario.dart`, namespaced
  `'<module>.<event>'`.
- Scenarios are stable over time and **never encode presentation or navigation rules** — they exist
  for logging, analytics, debugging and test assertions. Never branch UI on them.

## 4. Custom actions
- The token is a module-scoped union (`@freezed`, or a `sealed` class) in `domain/<m>_ui_action.dart` (no Presentation
  imports — if it needs one, it doesn't belong in `domain/`), sent as `UiAction.custom(token: …)`.
- Handled by a typed runner: `UiEffectRunner<MyUiAction>(onCustomAction: (context, ref, token) =>
  token.when(...))`.
- A custom action **MUST NOT navigate**, is never reused across modules, and stays UI-only.
- Views with no custom actions use `UiEffectRunner<NoCustomAction>()` (`typedef NoCustomAction = Never`).

## 5. ViewModel side
```dart
@riverpod
class ContactsViewModel extends _$ContactsViewModel {
  late StreamController<UiEffect> _effects; // not `final`: build() reruns on invalidate
  // A one-shot stream cannot live in `state`; UiEffect exposes it by design.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  Stream<UiEffect> get effects => _effects.stream;

  @override
  ContactsState build() {
    _effects = StreamController<UiEffect>.broadcast();
    ref.onDispose(_effects.close);
    return const ContactsState();
  }

  void _emit(UiEffect effect) => _effects.add(effect);

  Future<void> save() async {
    // … on success, after state has stabilised (isLoading:false first):
    _emit(UiEffect.create(
      scenario: ContactsUiScenario.saved,
      feedback: const UiFeedback.snackBar(style: UiFeedbackStyle.success, message: '…'),
      action: UiAction.navigate(command: NavCommand.pushNamed(route: AppRoute.contactList.path)),
    ));
  }
}

@riverpod
Stream<UiEffect> contactsUiEffect(Ref ref) =>
    ref.watch(contactsViewModelProvider.notifier).effects; // watch: follow a rebuilt notifier
```

## 6. View side — listener lifecycle
```dart
class _ContactsViewState extends ConsumerState<ContactsView> {
  final _runner = UiEffectRunner<NoCustomAction>();
  ProviderSubscription<AsyncValue<UiEffect>>? _effectSub;

  @override
  void initState() {
    super.initState();
    _effectSub = listenUiEffects(
      ref: ref, context: context, provider: contactsUiEffectProvider, runner: _runner);
  }

  @override
  void dispose() {
    _effectSub?.close();
    _effectSub = null;
    super.dispose();
  }
}
```
- `listenUiEffects` (ConsumerStatefulWidget): call in `initState`; the returned subscription **must**
  be closed and nulled in `dispose()`.
- `bindUiEffects` (ConsumerWidget): call in `build()`; it wraps `ref.listen`. A fresh runner per build
  is safe because dedup is global.
- Hand-rolling `listenManual`? Skip null `asData` values and return early when `!context.mounted`.

## 7. Why dedup is global (static)
A `keepAlive` ViewModel can be observed by two live screens at once — the origin and the pushed
detail screen. A broadcast stream delivers each effect to both. Both screens attach a listener to the
same effect provider (don't invent a per-flow stream); the runner's static last-handled id suppresses
the second delivery. Ids are unique per emission, so only genuine duplicates are dropped.

The runner navigates on the **context tier** with the view's context and pops via
`Navigator.of(context)`; only dialog/snackbar surfaces, which own no context, use `popGlobal`.
