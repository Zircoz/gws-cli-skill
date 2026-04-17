# gws-cli skill

A Claude skill for the [Google Workspace CLI (`gws`)](https://github.com/googleworkspace/cli) — lets Claude interact with Gmail, Calendar, Drive, Sheets, Docs, and Chat on your behalf.

## What it does

When you ask Claude to check your email, schedule a meeting, append rows to a spreadsheet, or find a file in Drive, this skill kicks in and:

1. **Detects your authorized scopes** — runs a scope detection script that reads your local OAuth token to figure out which Google Workspace services you've authenticated. Only authorized services get loaded.
2. **Loads relevant reference docs** — seven service-specific reference files (Gmail, Calendar, Drive, Sheets, Docs, Chat, Admin), loaded lazily so Claude only reads what it actually needs.
3. **Executes via `gws`** — constructs the correct CLI commands with proper JSON bodies, confirms with you before any write/delete operation, and presents output in a readable format.

## Prerequisites

1. Install the `gws` CLI:
   ```bash
   # macOS
   brew install googleworkspace/tap/gws

   # Or download from GitHub releases
   # https://github.com/googleworkspace/cli/releases
   ```

2. Authenticate and choose your scopes:
   ```bash
   gws auth login
   # Select which services to authorize (gmail, calendar, drive, sheets, docs, chat)
   ```

## Install the skill

```bash
npx skills add setu-dixit/gws-cli-skill
```

Or install the `.skill` file directly in the Claude desktop app.

## Example prompts

Once installed, just talk to Claude naturally:

- *"Check my inbox for unread emails from the last 24 hours"*
- *"Schedule a 30-min 1:1 with sarah@company.com tomorrow at 2pm, title it 'Weekly sync'"*
- *"Append three rows to my spreadsheet [ID]: Alice,95,A | Bob,82,B | Carol,77,C"*
- *"Find my most recently modified PDF in Drive and create a calendar event to review it on Friday"*
- *"Send a message to the #engineering space in Google Chat saying the build passed"*

Claude will detect which services you've authorized and only use those — if you ask for something that needs a scope you haven't set up, it'll tell you exactly how to add it.

## What's inside

```
skills/gws-cli/
├── SKILL.md                  # Main skill instructions (scope detection + phase workflow)
├── scripts/
│   └── detect_scopes.sh      # OAuth token reader + live probe fallback
└── references/
    ├── core.md               # Global flags, security rules, shell quoting
    ├── gmail.md              # Gmail helper commands + API resource commands
    ├── calendar.md           # Calendar events, freebusy, quick-add
    ├── drive.md              # Files, folders, permissions, export
    ├── sheets.md             # Values read/write/append, batch ops
    ├── docs.md               # Documents get/create/batchUpdate
    ├── chat.md               # Spaces, messages, members
    └── admin.md              # Users, groups, OUs, audit logs (admin only)
```

## Supported services

| Service | Scope name | What Claude can do |
|---------|-----------|-------------------|
| Gmail | `gmail` | Read, send, reply, forward, triage, label, search |
| Calendar | `calendar` | List events, create/update/delete, freebusy, quick-add |
| Drive | `drive` | List, upload, download, export, share, move, trash |
| Sheets | `sheets` | Read ranges, append/update rows, batch ops, create |
| Docs | `docs` | Get content, create, append text, batch updates |
| Chat | `chat` | List spaces, send messages, reply to threads, manage members |
| Admin | `admin` | Users, groups, OUs, audit logs (requires admin privileges) |

## How scope detection works

The `detect_scopes.sh` script first looks for your OAuth token file in common locations (`~/.config/gws/token.json`, `~/.gws/token.json`, `$XDG_CONFIG_HOME/gws/token.json`). It parses the stored scope strings to determine what's authorized — no API calls needed, and your token is never logged or stored.

If the token file isn't found or is opaque, it falls back to lightweight live probes (one read call per service with a 5-second timeout) to determine authorization.

## Security

- Claude always asks for confirmation before write, update, delete, or send operations
- Token contents are never printed or stored
- `--dry-run` is used for uncertain or destructive operations
- `--sanitize` flag available for sensitive data screening

## Adding scopes later

```bash
gws auth login --scopes gmail,calendar,drive,sheets,docs,chat
```

## Contributing

PRs welcome — especially for additional workflow examples, edge cases in scope detection, or new service references (Forms, Meet, Classroom, Tasks, Keep).

## License

MIT
