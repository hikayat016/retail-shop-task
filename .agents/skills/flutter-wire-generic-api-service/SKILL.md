---
name: flutter-wire-generic-api-service
description: >-
  Wires repositories to GenericApiService in the BESTINET Flutter architecture. Use when adding API
  calls, DTO decoders, repository methods, object/list/empty responses, ApiException handling, or
  choosing between user-authenticated and system API services.
---

# Flutter Wire Generic API Service

## Use When

- Adding a repository method that calls an HTTP API.
- Mapping JSON DTOs into typed domain or UI models.
- Handling list, object, or empty success responses.
- Choosing between authenticated and pre-login API clients.

## Required Flow

```text
Widget -> ViewModel -> Repository -> GenericApiService -> ApiTransport -> backend
```

The UI and ViewModel never import Dio, parse raw JSON, or handle transport exceptions.

## Repository Rules

- Repository interfaces live in `domain/repositories/` when a repository exists.
- Implementations live in `data/repositories/`.
- Repository implementations depend on `GenericApiService`, not directly on Dio.
- Every call provides an explicit decoder or list decoder for DTO parsing.
- Repositories return typed DTOs or mapped domain models, never `dynamic` or raw maps.
- Repositories never check raw HTTP status codes (`if (response.statusCode == 200)`) and never assume
  whether the backend wraps its payload — the transport accepts wrapped (`{httpStatus, data}`) and raw
  JSON and normalizes both. The only allowed branch is on `ApiException.status`, for enrichment.
- DTOs implement both `fromJson` and `toJson`, with an explicit type on every field.

## Response Categories

- Object response: `get/post/put/delete<T>` with `decoder`; return `SingleResponse.data`.
- List response: `getList/postList/putList/deleteList<T>` with `listDecoder`; return
  `ListResponse.items` (paging in `ListResponse.pagination`).
- Per-request differences (alternate base URL, gateway choice, endpoint toggles) go through an
  explicit `ApiRequestConfig`, never feature booleans; repositories don't branch on auth mode.
- Empty response: return a typed success result or `void`, matching nearby code.

## Provider Selection

- Use the normal user API service when a valid user bearer token is required.
- Use the system API service for pre-login, client-credentials, reference bootstrap, or public setup
  flows.
- Keep the provider choice visible in `lib/app/providers/providers.dart`.

## Error Handling

- Let `ApiTransport` normalize network and backend failures into `ApiException`:
  - low-level failures (timeout, DNS, socket) → a generic localized "Connection error" `userMessage`,
    technical detail in `developerMessage`;
  - backend failures (non-2xx, **or HTTP 200 whose wrapper status says failure**) → the server's own
    message as `userMessage`. A wrapped failure is thrown, never returned as a `ServerResponse`.
- `GenericApiService` is a transparent conduit — it neither catches nor rethrows differently.
- Enrichment: a repository may catch `ApiException` and throw a more specific one (e.g. 409 →
  "Username taken"); what it throws is still `ApiException` or a subtype.
- Repository methods may swallow an error or default to an empty result only when the feature
  explicitly requires it — and that exception is documented at the call site.
- `ApiException.toString()` shows only `status` and `userMessage`, never `developerMessage`.
- ViewModels catch `ApiException` and expose `message.userMessage` to UI state.
- Log `developerMessage` only through approved logging utilities.

## Avoid

- Adding the `http` package for feature networking.
- Returning raw Dio responses.
- Parsing JSON in ViewModels.
- Displaying developer diagnostics to users.
