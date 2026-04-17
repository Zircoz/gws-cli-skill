# Drive Reference

## Helper commands (the fast path)

```bash
# Upload a local file to Drive
gws drive +upload ./report.pdf --name "Q4 Report"

# Upload to a specific folder
gws drive +upload ./report.pdf --name "Q4 Report" --parent FOLDER_ID
```

## API resource commands

### List files
```bash
# Basic list
gws drive files list --params '{"pageSize": 20}'

# Search for specific files
gws drive files list --params '{
  "pageSize": 10,
  "q": "name contains \"budget\" and trashed=false",
  "fields": "files(id,name,mimeType,modifiedTime,size)"
}'

# List files in a folder
gws drive files list --params '{
  "q": "\"FOLDER_ID\" in parents and trashed=false",
  "pageSize": 50
}'

# Find recently modified files
gws drive files list --params '{
  "orderBy": "modifiedTime desc",
  "pageSize": 10
}'
```

### Get file metadata
```bash
gws drive files get --params '{
  "fileId": "FILE_ID",
  "fields": "id,name,mimeType,size,modifiedTime,owners,webViewLink"
}'
```

### Download a file
```bash
gws drive files get --params '{"fileId": "FILE_ID", "alt": "media"}' > output.pdf
```

### Export a Google Doc/Sheet/Slide as another format
```bash
# Export Google Doc as PDF
gws drive files export --params '{
  "fileId": "DOC_ID",
  "mimeType": "application/pdf"
}' > document.pdf

# Export Google Sheet as Excel
gws drive files export --params '{
  "fileId": "SHEET_ID",
  "mimeType": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
}' > spreadsheet.xlsx
```

### Create a folder
```bash
gws drive files create --body '{
  "name": "New Folder",
  "mimeType": "application/vnd.google-apps.folder"
}'

# Create inside another folder
gws drive files create --body '{
  "name": "Subfolder",
  "mimeType": "application/vnd.google-apps.folder",
  "parents": ["PARENT_FOLDER_ID"]
}'
```

### Share a file (manage permissions)
```bash
# Share with a specific person
gws drive permissions create \
  --params '{"fileId": "FILE_ID", "sendNotificationEmail": true}' \
  --body '{
    "type": "user",
    "role": "reader",
    "emailAddress": "alice@example.com"
  }'

# Make file publicly readable
gws drive permissions create \
  --params '{"fileId": "FILE_ID"}' \
  --body '{"type": "anyone", "role": "reader"}'
```

### Move a file
```bash
# Get current parents first, then update
gws drive files update \
  --params '{"fileId": "FILE_ID", "addParents": "NEW_FOLDER_ID", "removeParents": "OLD_PARENT_ID"}' \
  --body '{}'
```

### Trash / delete
```bash
# Trash (recoverable)
gws drive files update --params '{"fileId": "FILE_ID"}' --body '{"trashed": true}'

# Permanently delete — confirm with user first!
gws drive files delete --params '{"fileId": "FILE_ID"}' --dry-run
gws drive files delete --params '{"fileId": "FILE_ID"}'
```

## Common query syntax (`q` parameter)

| Goal | Query |
|------|-------|
| By name | `name = "Report"` or `name contains "budget"` |
| By type | `mimeType = "application/pdf"` |
| Google Docs only | `mimeType = "application/vnd.google-apps.document"` |
| In folder | `"FOLDER_ID" in parents` |
| Not trashed | `trashed = false` |
| Owned by me | `"me" in owners` |
| Shared with me | `sharedWithMe = true` |

Combine with `and` / `or`: `name contains "Q4" and mimeType = "application/pdf" and trashed = false`

## MIME types reference
| Type | MIME type |
|------|----------|
| Google Doc | `application/vnd.google-apps.document` |
| Google Sheet | `application/vnd.google-apps.spreadsheet` |
| Google Slides | `application/vnd.google-apps.presentation` |
| Google Form | `application/vnd.google-apps.form` |
| Folder | `application/vnd.google-apps.folder` |
| PDF | `application/pdf` |
