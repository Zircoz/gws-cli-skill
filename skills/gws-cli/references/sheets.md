# Sheets Reference

## Helper commands (the fast path)

```bash
# Read values from a range
gws sheets +read --spreadsheet SPREADSHEET_ID --range "Sheet1!A1:D20"

# Append a row
gws sheets +append --spreadsheet SPREADSHEET_ID --values "Alice,95,A,Pass"
```

## API resource commands

### Get spreadsheet metadata
```bash
gws sheets spreadsheets get --params '{
  "spreadsheetId": "SPREADSHEET_ID",
  "includeGridData": false
}'
```

### Read a range
```bash
gws sheets spreadsheets values get --params '{
  "spreadsheetId": "SPREADSHEET_ID",
  "range": "Sheet1!A1:D10"
}'
```

### Read multiple non-contiguous ranges
```bash
gws sheets spreadsheets values get --params '{
  "spreadsheetId": "SPREADSHEET_ID",
  "range": "Sheet1!A:Z",
  "valueRenderOption": "FORMATTED_VALUE",
  "dateTimeRenderOption": "FORMATTED_STRING"
}'
```

`valueRenderOption`: `FORMATTED_VALUE` (display text), `UNFORMATTED_VALUE` (raw), `FORMULA` (formulas).

### Write / update a range
```bash
gws sheets spreadsheets values update \
  --params '{
    "spreadsheetId": "SPREADSHEET_ID",
    "range": "Sheet1!A1",
    "valueInputOption": "USER_ENTERED"
  }' \
  --json '{
    "values": [
      ["Name", "Score", "Grade"],
      ["Alice", 95, "A"],
      ["Bob", 82, "B"]
    ]
  }'
```

`valueInputOption`: `USER_ENTERED` (parses formulas and dates), `RAW` (literal text).

### Append rows
```bash
gws sheets spreadsheets values append \
  --params '{
    "spreadsheetId": "SPREADSHEET_ID",
    "range": "Sheet1!A1",
    "valueInputOption": "USER_ENTERED",
    "insertDataOption": "INSERT_ROWS"
  }' \
  --json '{
    "values": [["NewRow", "Data", "Here"]]
  }'
```

### Batch read ranges
```bash
gws sheets spreadsheets values batchGet --params '{
  "spreadsheetId": "SPREADSHEET_ID",
  "ranges": ["Sheet1!A1:C10", "Summary!A1:B5"]
}'
```

### Batch update ranges
```bash
gws sheets spreadsheets values batchUpdate \
  --params '{"spreadsheetId": "SPREADSHEET_ID"}' \
  --json '{
    "valueInputOption": "USER_ENTERED",
    "data": [
      {"range": "Sheet1!A1", "values": [["Updated"]]},
      {"range": "Sheet2!B2", "values": [["Also updated"]]}
    ]
  }'
```

### Clear values
```bash
gws sheets spreadsheets values clear \
  --params '{"spreadsheetId": "SPREADSHEET_ID", "range": "Sheet1!A2:Z100"}' \
  --json '{}'
```

### Create a spreadsheet
```bash
gws sheets spreadsheets create --json '{
  "properties": {"title": "My New Spreadsheet"},
  "sheets": [{"properties": {"title": "Sheet1"}}]
}'
```

### Apply formatting (batchUpdate)
```bash
gws sheets spreadsheets batchUpdate \
  --params '{"spreadsheetId": "SPREADSHEET_ID"}' \
  --json '{
    "requests": [{
      "repeatCell": {
        "range": {"sheetId": 0, "startRowIndex": 0, "endRowIndex": 1},
        "cell": {
          "userEnteredFormat": {
            "backgroundColor": {"red": 0.2, "green": 0.5, "blue": 0.8},
            "textFormat": {"bold": true}
          }
        },
        "fields": "userEnteredFormat(backgroundColor,textFormat)"
      }
    }]
  }'
```

## Getting spreadsheet IDs

From a Google Sheets URL like:
`https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms/edit`

The spreadsheet ID is the long string between `/d/` and `/edit`:
`1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms`

## Shell quoting note (zsh)

Ranges containing `!` must be double-quoted in zsh:
```bash
# Wrong in zsh:
gws sheets +read --range Sheet1!A1:B10
# Correct:
gws sheets +read --range "Sheet1!A1:B10"
```
