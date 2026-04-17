---
name: gws-cli
description: >
  Interact with Google Workspace services — Gmail, Google Calendar, Google Drive, Google Sheets,
  Google Docs, Google Chat, and Workspace Admin — using the gws CLI on the user's behalf.
  Use this skill when the user wants to: read or send emails, check or create calendar events,
  find or upload files in Drive, read or write spreadsheet rows, edit or create Docs, send Chat
  messages, or manage Workspace users and groups. Also trigger for multi-step Google Workspace
  workflows (weekly digest, email-to-task automation, cross-service pipelines). Auto-detects
  which services are OAuth-authorized and loads only relevant instructions. Do NOT use for
  non-Google platforms (Slack, Outlook, Jira). Prefer this over general knowledge whenever
  the task involves actually reading, writing, or automating data in a Google Workspace account.
---

# Google Workspace CLI (`gws`) Skill

The `gws` CLI gives you programmatic access to all Google Workspace services. The key challenge
is that users authorize different subsets of scopes during login, so we must first discover what's
available before trying to use anything. This skill is structured in three phases:

1. **Detect** — figure out which services are authorized
2. **Load** — read reference docs for only those services
3. **Execute** — carry out the user's task using the CLI

---

## Phase 1: Detect authorized scopes

Run the detection script before anything else. This prevents confusing 403 errors and tells you
exactly what you can help with.

```bash
bash ~/.claude/skills/gws-cli/scripts/detect_scopes.sh
```

The script outputs a JSON object, e.g.:

```json
{
  "gmail": true,
  "calendar": true,
  "drive": false,
  "sheets": true,
  "docs": false,
  "chat": false,
  "admin": false
}
```

> **If `gws` isn't installed or not authenticated**: tell the user clearly — they need to install
> the CLI (`brew install googleworkspace/tap/gws` or from the GitHub releases page) and run
> `gws auth login` to authenticate. Don't proceed further.

---

## Phase 2: Load the right references

Based on the scope detection output, read **only** the reference files for authorized services.
Always read `references/core.md` first (shared patterns, global flags, security rules). Then read
one file per authorized service:

| Authorized service | Read this file |
|--------------------|---------------|
| `gmail: true` | `references/gmail.md` |
| `calendar: true` | `references/calendar.md` |
| `drive: true` | `references/drive.md` |
| `sheets: true` | `references/sheets.md` |
| `docs: true` | `references/docs.md` |
| `chat: true` | `references/chat.md` |
| `admin: true` | `references/admin.md` |

This lazy-loading matters — each reference adds context overhead. Only load what you'll actually use.

---

## Phase 3: Execute the task

With the reference docs loaded, execute the user's request using the `gws` command.

### Mapping user intent → service

If the user's request touches a service they haven't authorized, tell them kindly:
> "You haven't authorized [service] yet. You can add it by running:
> `gws auth login --scopes [service]`"

Use the `--dry-run` flag when you're unsure about destructive operations — it validates locally
without hitting the API. Always confirm with the user before `delete`, `update`, or `send` actions.

### Discovery commands (always available)

When you're unsure of exact parameters or need to explore:
```bash
gws <service> --help                        # list resources and methods
gws schema <service>.<resource>.<method>    # inspect a specific method's params
```

### Output handling

All `gws` responses are JSON by default. If you need to display results to the user, parse and
format them cleanly. Use `--format table` for human-readable output when appropriate.

---

## Scope detection internals (for reference)

The detection script (`scripts/detect_scopes.sh`) works by:
1. First checking `~/.config/gws/token.json` (or equivalent) for stored scope strings
2. As a fallback, making a lightweight probe call (e.g., `users.getProfile` for Gmail) with a
   1-second timeout — if it returns 401/403, the scope isn't authorized
3. Never storing or logging auth tokens; it only reads the token file to parse scope metadata

If the token file doesn't exist at the expected path, the script tries common alternatives
(`~/.gws/`, `$XDG_CONFIG_HOME/gws/`) before falling back to live probes.
