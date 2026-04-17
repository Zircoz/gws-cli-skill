# Chat Reference

## Helper commands (the fast path)

```bash
# Send a message to a space
gws chat +send --space SPACE_NAME_OR_ID --text "Hello team!"
```

## API resource commands

### List spaces you're in
```bash
gws chat spaces list --params '{"pageSize": 20}'
```

### Get a specific space
```bash
gws chat spaces get --params '{"name": "spaces/SPACE_ID"}'
```

### Find a direct message with someone
```bash
gws chat spaces findDirectMessage --params '{"name": "users/USER_EMAIL_OR_ID"}'
```

### Create a new space
```bash
# Named space (team channel)
gws chat spaces create --body '{
  "displayName": "Project Phoenix",
  "spaceType": "SPACE"
}'

# Group DM with multiple people
gws chat spaces create --body '{
  "spaceType": "GROUP_CHAT",
  "members": [
    {"member": {"name": "users/alice@example.com", "type": "HUMAN"}},
    {"member": {"name": "users/bob@example.com", "type": "HUMAN"}}
  ]
}'
```

### Send a message to a space
```bash
gws chat spaces.messages create \
  --params '{"parent": "spaces/SPACE_ID"}' \
  --body '{
    "text": "Hello from the CLI! 👋"
  }'
```

**With formatted cards (rich messages):**
```bash
gws chat spaces.messages create \
  --params '{"parent": "spaces/SPACE_ID"}' \
  --body '{
    "cardsV2": [{
      "cardId": "info-card",
      "card": {
        "header": {"title": "Deployment Complete"},
        "sections": [{
          "widgets": [{
            "textParagraph": {"text": "Service <b>api-gateway</b> deployed successfully to prod."}
          }]
        }]
      }
    }]
  }'
```

### List messages in a space
```bash
gws chat spaces.messages list \
  --params '{"parent": "spaces/SPACE_ID", "pageSize": 25}'
```

### Reply to a thread
```bash
gws chat spaces.messages create \
  --params '{"parent": "spaces/SPACE_ID", "messageReplyOption": "REPLY_MESSAGE_FALLBACK_TO_NEW_THREAD"}' \
  --body '{
    "text": "Following up on this...",
    "thread": {"name": "spaces/SPACE_ID/threads/THREAD_ID"}
  }'
```

### Update a message
```bash
gws chat spaces.messages patch \
  --params '{"name": "spaces/SPACE_ID/messages/MESSAGE_ID", "updateMask": "text"}' \
  --body '{"text": "Updated message text"}'
```

### Delete a message
```bash
# Confirm with user before deleting
gws chat spaces.messages delete --params '{"name": "spaces/SPACE_ID/messages/MESSAGE_ID"}'
```

### Manage members
```bash
# List members of a space
gws chat spaces.members list --params '{"parent": "spaces/SPACE_ID"}'

# Add a member
gws chat spaces.members create \
  --params '{"parent": "spaces/SPACE_ID"}' \
  --body '{"member": {"name": "users/alice@example.com", "type": "HUMAN"}}'
```

### Upload an attachment (media)
```bash
gws chat media upload \
  --params '{"parent": "spaces/SPACE_ID"}' \
  --upload ./document.pdf
```

## Getting space IDs

Space names look like `spaces/AAABBBCCC`. From a Chat URL:
`https://mail.google.com/chat/u/0/#chat/space/AAABBBCCC`
→ Space ID: `AAABBBCCC`, space name: `spaces/AAABBBCCC`

## Note on admin-only features

Searching spaces across the entire organization requires admin privileges:
```bash
gws chat spaces search --params '{"query": "label:project", "pageSize": 10}'
```

If this returns a 403, the user doesn't have Chat admin rights.
