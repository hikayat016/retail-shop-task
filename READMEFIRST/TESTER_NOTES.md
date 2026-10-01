> Part of `READMEFIRST/`. See [README.md](README.md) for the index.

# Tester Notes

## Android debug build

- APK: [ProductSimulation-DEBUG-v1.0.0-20261001.apk](builds/ProductSimulation-DEBUG-v1.0.0-20261001.apk)
- Version: `1.0.0+1`
- Package: `com.example.retail_shop_catalog`
- Build: universal Android debug APK, signed with the local Android debug key
- Size: 195,560,540 bytes

This is for personal device verification only. It is debuggable and is not a release-signed production package. Keep the device online when testing catalogue requests; product data comes from `https://dummyjson.com`.

## Install

Copy the APK to the Android device and open it to install. With USB debugging enabled and `adb` available, install from the project root with:

```powershell
adb install -r READMEFIRST/builds/ProductSimulation-DEBUG-v1.0.0-20261001.apk
```

Android may ask you to allow installation from the file manager or browser used to open the APK.

## Verify

- Product rows show an image, title, price, and rating.
- Scrolling near the end loads more products; pull-to-refresh reloads the list.
- Searching by name filters results; the search field shows at most five recent searches, newest first.
- Searching for a duplicate moves it to the top; tapping a recent search runs it again, and Clear removes the history.
- Favorites and recent searches remain saved after closing and reopening the app.
- Tapping a product opens its image gallery, description, price, rating, and stock.
- With network access disabled, the app shows an offline error and a retry action; restoring access and retrying loads products.

The build succeeded on the development machine and was installed and exercised on the device listed below.

## Device verification

The current debug build was verified on 2026-10-01 on a Samsung SM A526B running Android 14. Android displays the name “Product Simulation” with the supplied grocery-store launcher icon. Startup, catalogue loading, search, product details, recent-search restoration, favorite restoration, and pagination passed without Flutter runtime errors. On this build, tapping the saved `Essence` search reran the query, and Clear removed the recent-search preference. After force-stopping and relaunching, the search panel remained empty, confirming the clear persisted.

The five-item limit and case-insensitive duplicate promotion are covered by automated repository and ViewModel tests. All 18 Flutter tests pass.

Browser interaction and iOS device behavior have not been verified.