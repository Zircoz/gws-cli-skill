# Calendar Reference

## Helper commands (the fast path)

```bash
# Show upcoming agenda across all calendars
gws calendar +agenda

# Create an event quickly
gws calendar +insert \
  --summary "Team sync" \
  --start "2026-06-17T10:00:00-07:00" \
  --end "2026-06-17T11:00:00-07:00" \
  --attendee "alice@example.com" \
  --attendee "bob@example.com"
```

## API resource commands

### List calendars
```bash
gws calendar calendarList list --params '{"maxResults": 10}'
```

### List events
```bash
# Events in primary calendar, next 7 days
gws calendar events list --params '{
  "calendarId": "primary",
  "maxResults": 20,
  "orderBy": "startTime",
  "singleEvents": true,
  "timeMin": "2026-06-14T00:00:00Z",
  "timeMax": "2026-06-21T00:00:00Z"
}'
```

`timeMin` and `timeMax` must be RFC 3339 timestamps. Use `singleEvents: true` to expand recurring events.

### Get a specific event
```bash
gws calendar events get --params '{"calendarId": "primary", "eventId": "EVENT_ID"}'
```

### Create an event
```bash
gws calendar events insert \
  --params '{"calendarId": "primary"}' \
  --json '{
    "summary": "Quarterly review",
    "description": "Q4 performance review",
    "start": {"dateTime": "2026-06-17T14:00:00-07:00", "timeZone": "America/Los_Angeles"},
    "end":   {"dateTime": "2026-06-17T15:00:00-07:00", "timeZone": "America/Los_Angeles"},
    "attendees": [
      {"email": "alice@example.com"},
      {"email": "bob@example.com"}
    ],
    "reminders": {"useDefault": true}
  }'
```

### Update an event
```bash
gws calendar events patch \
  --params '{"calendarId": "primary", "eventId": "EVENT_ID"}' \
  --json '{"summary": "Updated title", "location": "Conference room B"}'
```

### Delete an event
```bash
# Always --dry-run first, then confirm with user before deleting
gws calendar events delete --params '{"calendarId": "primary", "eventId": "EVENT_ID"}' --dry-run
gws calendar events delete --params '{"calendarId": "primary", "eventId": "EVENT_ID"}'
```

### Check free/busy
```bash
gws calendar freebusy query --json '{
  "timeMin": "2026-06-17T00:00:00Z",
  "timeMax": "2026-06-17T23:59:59Z",
  "items": [{"id": "primary"}, {"id": "alice@example.com"}]
}'
```

### Quick add (natural language)
```bash
gws calendar events quickAdd \
  --params '{"calendarId": "primary", "text": "Lunch with Alice next Monday at noon"}'
```

## Common patterns

**Find a time slot when everyone is free:**
```bash
# Use freebusy query with all attendee emails, then find gaps in the response
gws calendar freebusy query --json '{
  "timeMin": "2026-06-15T00:00:00Z",
  "timeMax": "2026-06-19T23:59:59Z",
  "items": [
    {"id": "primary"},
    {"id": "alice@example.com"},
    {"id": "bob@example.com"}
  ]
}'
```

**List today's events:**
```bash
# Get ISO timestamps for start/end of today, then list
TODAY=$(date -u +%Y-%m-%dT00:00:00Z)
TOMORROW=$(date -u -d tomorrow +%Y-%m-%dT00:00:00Z 2>/dev/null || date -u -v+1d +%Y-%m-%dT00:00:00Z)
gws calendar events list --params "{
  \"calendarId\": \"primary\",
  \"timeMin\": \"$TODAY\",
  \"timeMax\": \"$TOMORROW\",
  \"singleEvents\": true,
  \"orderBy\": \"startTime\"
}"
```
