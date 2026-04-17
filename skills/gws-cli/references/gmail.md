# Gmail Reference

## Helper commands (the fast path)

```bash
# Send an email
gws gmail +send --to "alice@example.com" --subject "Hello" --body "Message text here"

# Triage inbox — shows unread messages with sender, subject, date
gws gmail +triage

# Reply to a message (by message ID)
gws gmail +reply --message-id MESSAGE_ID --body "Thanks!"

# Reply-all
gws gmail +reply-all --message-id MESSAGE_ID --body "Thanks everyone!"

# Forward a message
gws gmail +forward --message-id MESSAGE_ID --to "bob@example.com"

# Read a message body/headers
gws gmail +read --message-id MESSAGE_ID

# Watch inbox — streams new messages as NDJSON (useful for monitoring)
gws gmail +watch
```

## API resource commands

### List messages
```bash
gws gmail users.messages list --params '{
  "userId": "me",
  "maxResults": 20,
  "q": "is:unread",
  "labelIds": ["INBOX"]
}'
```

Gmail search syntax works in `q`: `from:alice`, `subject:meeting`, `has:attachment`, `after:2024/01/01`, `is:starred`, etc.

### Get a specific message
```bash
gws gmail users.messages get --params '{
  "userId": "me",
  "id": "MESSAGE_ID",
  "format": "full"
}'
```

`format` options: `full` (entire message), `metadata` (headers only), `minimal` (IDs + labels), `raw` (RFC 2822).

### Search for messages
```bash
# Find emails from a specific sender
gws gmail users.messages list --params '{"userId": "me", "q": "from:boss@company.com is:unread"}'

# Find emails with attachments in last 7 days
gws gmail users.messages list --params '{"userId": "me", "q": "has:attachment newer_than:7d"}'
```

### Labels
```bash
# List all labels
gws gmail users.labels list --params '{"userId": "me"}'

# Get label info (includes unread count)
gws gmail users.labels get --params '{"userId": "me", "id": "INBOX"}'
```

### Threads
```bash
# List threads
gws gmail users.threads list --params '{"userId": "me", "maxResults": 10}'

# Get full thread
gws gmail users.threads get --params '{"userId": "me", "id": "THREAD_ID"}'
```

### Drafts
```bash
# List drafts
gws gmail users.drafts list --params '{"userId": "me"}'

# Create a draft (body is an RFC 2822 message, base64url encoded — use +send instead for simplicity)
gws gmail users.drafts create --body '{"message": {"raw": "BASE64_ENCODED_EMAIL"}}'
```

### Profile
```bash
# Get user's email address and quota info
gws gmail users.getProfile --params '{"userId": "me"}'
```

## Common patterns

**Find and read the most recent email from someone:**
```bash
# 1. Find the message ID
gws gmail users.messages list --params '{"userId": "me", "q": "from:alice@example.com", "maxResults": 1}'
# 2. Read it (use the id from step 1)
gws gmail +read --message-id MESSAGE_ID
```

**Send with CC:**
Use `+send` — check `gws gmail +send --help` for all flags including `--cc` and `--bcc`.

**Mark as read:**
```bash
gws gmail users.messages modify \
  --params '{"userId": "me", "id": "MESSAGE_ID"}' \
  --body '{"removeLabelIds": ["UNREAD"]}'
```
