# Retail Shop Catalogue

A small Flutter product catalogue backed by the public [DummyJSON Products API](https://dummyjson.com/docs/products). It supports product search, infinite scrolling, detail pages, favorites, and recent searches without login.

**State management:** Riverpod code generation with Freezed keeps dependencies explicit and catalogue state immutable, which makes async paging, search resets, and persistence transitions straightforward to test. This follows the attached Flutter architecture template.

| Stack | Choice |
| --- | --- |
| UI and state | Flutter, Riverpod, Freezed |
| API | Dio through `GenericApiService` |
| Local persistence | SharedPreferences |

## Run

```powershell
fvm flutter pub get
fvm dart run build_runner build
fvm flutter run
```

Platform runners are already scaffolded. Run tests with `fvm flutter test`. The app calls the live DummyJSON API; favorites and recent searches are stored locally on the device.

## Read next

- [Project status and document index](READMEFIRST/README.md)
- [Architecture and implementation notes](READMEFIRST/ARCHITECTURE_NOTES.md)