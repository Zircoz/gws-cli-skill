# Admin Reference

> These commands require Google Workspace Admin privileges. Only available if the user authenticated
> with admin scopes. Non-admins will receive 403 errors on most of these endpoints.

## User management

### List users in the domain
```bash
gws reports:directory_v1 users list --params '{
  "customer": "my_customer",
  "maxResults": 50,
  "orderBy": "email"
}'

# Search for a specific user
gws reports:directory_v1 users list --params '{
  "customer": "my_customer",
  "query": "email:alice*"
}'
```

### Get a specific user
```bash
gws reports:directory_v1 users get --params '{"userKey": "alice@example.com"}'
```

### Create a user
```bash
gws reports:directory_v1 users insert --json '{
  "primaryEmail": "newuser@example.com",
  "name": {"givenName": "New", "familyName": "User"},
  "password": "TEMPORARY_PASSWORD",
  "changePasswordAtNextLogin": true
}'
```

### Update a user
```bash
gws reports:directory_v1 users update \
  --params '{"userKey": "alice@example.com"}' \
  --json '{"suspended": false, "name": {"givenName": "Alice"}}'
```

### Suspend / unsuspend a user
```bash
# Suspend
gws reports:directory_v1 users update \
  --params '{"userKey": "alice@example.com"}' \
  --json '{"suspended": true}'

# Unsuspend
gws reports:directory_v1 users update \
  --params '{"userKey": "alice@example.com"}' \
  --json '{"suspended": false}'
```

### Reset a user's password
```bash
gws reports:directory_v1 users update \
  --params '{"userKey": "alice@example.com"}' \
  --json '{"password": "NEW_TEMP_PASSWORD", "changePasswordAtNextLogin": true}'
```

## Group management

### List groups
```bash
gws reports:directory_v1 groups list --params '{"customer": "my_customer", "maxResults": 50}'
```

### Get group details
```bash
gws reports:directory_v1 groups get --params '{"groupKey": "engineering@example.com"}'
```

### Create a group
```bash
gws reports:directory_v1 groups insert --json '{
  "email": "newgroup@example.com",
  "name": "New Group",
  "description": "Description of the group"
}'
```

### List group members
```bash
gws reports:directory_v1 members list --params '{"groupKey": "engineering@example.com"}'
```

### Add a member to a group
```bash
gws reports:directory_v1 members insert \
  --params '{"groupKey": "engineering@example.com"}' \
  --json '{"email": "alice@example.com", "role": "MEMBER"}'
```

## Organizational Units

### List OUs
```bash
gws reports:directory_v1 orgunits list --params '{"customerId": "my_customer", "type": "all"}'
```

### Get a specific OU
```bash
gws reports:directory_v1 orgunits get \
  --params '{"customerId": "my_customer", "orgUnitPath": "/Engineering"}'
```

## Reports & audit logs

### Get login activity for the last 7 days
```bash
gws reports activities list --params '{
  "userKey": "all",
  "applicationName": "login",
  "maxResults": 100
}'
```

### Admin activity audit
```bash
gws reports activities list --params '{
  "userKey": "all",
  "applicationName": "admin",
  "maxResults": 50
}'
```

### Usage reports
```bash
# Domain-wide usage stats
gws reports usageReports get --params '{
  "date": "2026-06-01",
  "parameters": "gmail:num_emails_sent,drive:num_items_created"
}'
```

## Chrome device management (if applicable)

```bash
# List managed Chrome devices
gws reports:directory_v1 chromeosdevices list \
  --params '{"customerId": "my_customer", "maxResults": 20}'
```

## Important security reminders

- Always use `--dry-run` before bulk user operations
- Password resets and account suspensions take effect immediately — double-check the `userKey`
- Audit log access may itself be logged in your domain's admin activity
