# Privacy

Zanka no Tachi is local-first and has no account, cloud sync, analytics,
advertising SDK or automatic telemetry.

The app stores its canonical library, source bindings, progress, preferences,
metadata overrides, provider configuration and imported-media records in
app-owned storage. Managed imports copy media into app-owned storage; referenced
folders remain where the user selected them.

Enabled adapters make direct requests to configured providers for public
catalog/search/detail metadata. Those providers and the network operator may
observe ordinary request information such as IP address. Zanka does not send
Library state, progress, imported media, backups or diagnostics to them.

Diagnostics are local, bounded and redacted. Sensitive URLs/query values,
credentials and absolute paths are not intentionally retained. Debug logs are
suppressed in release mode. A report leaves the device only if the user copies
and shares it.

User-created backups contain app data but no imported media bytes or absolute
local paths. Treat them as private: titles, Library state and progress are
readable. Restored local assets are marked missing until repaired. Uninstalling
or clearing app data may remove app-owned state/media; export a backup first.
