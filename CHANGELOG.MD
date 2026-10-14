## 0.0.3

- Standardize native Manifest, Build and Publish modes, retain the RunMode alias and add CI checks for source tests and packaged behavior on PowerShell 5.1 and 7.

- Retrieve every SCIM user page, including a final user after a full 1,000-user page.
- Advance by the returned page size and preserve filters, sorting, native output, and result limits.
- Propagate HTTP, malformed response, and pagination failures for callers using `-ErrorAction Stop`; preserve warning and partial output behavior for other callers.
- Correct the display-name search and sort attribute mapping.
- Add a native build entrypoint with matching ZIP and unpacked packages.

### 0.0.2 - 2023.03.08
- Added support for the following parameters:
  - `Formatted`

### 0.0.1 - 2023.02.26
- Initial release
