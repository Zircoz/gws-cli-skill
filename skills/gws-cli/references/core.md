# Core: Shared Patterns, Flags & Security

Always read this file before any service-specific reference.

## Command structure

```
gws <service> <resource> [sub-resource] <method> [flags]
```

Examples:
```bash
gws gmail users messages list --params '{"maxResults": 10}'
gws drive files list --params '{"pageSize": 5, "q": "mimeType=\"application/pdf\""}'
gws calendar events insert --json '{"summary": "Team sync", "start": {...}}'
```

## Exploring the API (when you're unsure of params)

```bash
gws <service> --help                         # list available resources/methods
gws schema <service>.<resource>.<method>     # show exact params, types, and defaults
```

Use `gws schema` liberally before constructing complex requests. It's fast, local, and saves you from guessing.

## Global flags

| Flag | Purpose |
|------|---------|
| `--params '{"key": "val"}'` | Query parameters (GET requests) |
| `--json '{"key": "val"}'` | Request body (POST/PUT/PATCH) |
| `--format json\|table\|yaml\|csv` | Output format (default: json) |
| `--dry-run` | Validate the request locally without hitting the API |
| `--sanitize <template>` | Screen response through Model Armor for sensitive data |
| `--page-all` | Auto-paginate and return all results |

## Security rules (never skip these)

1. **Confirm before write/delete** — Always tell the user what you're about to do and get confirmation before `insert`, `update`, `patch`, `delete`, or `send` operations.
2. **Never output secrets** — Don't print API keys, access tokens, or OAuth credentials to the conversation.
3. **Use `--dry-run` when uncertain** — Especially for bulk operations or when testing new parameter combinations.
4. **`--sanitize` for sensitive data** — Use when processing personal information, financial data, or content that might be confidential.

## Shell quoting gotchas

- **zsh**: Wrap sheet ranges containing `!` in double quotes (e.g., `"Sheet1!A1:B10"`) to avoid history expansion.
- **JSON params**: Use single quotes around the JSON string: `--params '{"key": "val"}'`
- **Nested quotes**: When you need double quotes inside JSON inside a shell command, use `$'...'` syntax or a heredoc.

## Pagination

Many list commands return paginated results. Use `--page-all` to fetch everything automatically:
```bash
gws drive files list --params '{"q": "trashed=false"}' --page-all
```

Or handle manually with `nextPageToken`:
```bash
gws gmail users messages list --params '{"maxResults": 100, "pageToken": "TOKEN_HERE"}'
```

## Adding new scopes later

If the user needs a service that wasn't authorized:
```bash
gws auth login --services gmail,calendar,drive,sheets,docs,chat
```

This re-runs OAuth and lets them select additional scopes. They may need to re-authenticate fully if changing the scope set significantly.
