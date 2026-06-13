# Docs Reference

## Helper commands (the fast path)

```bash
# Append text to an existing document
gws docs +write --document DOC_ID --text "New paragraph text to append"
```

## API resource commands

### Get a document
```bash
gws docs documents get --params '{"documentId": "DOC_ID"}'

# With specific fields
gws docs documents get --params '{
  "documentId": "DOC_ID",
  "fields": "title,body"
}'
```

The response includes the full document structure: title, body content, sections, tables, inline objects, etc.

### Create a new document
```bash
gws docs documents create --json '{"title": "My New Document"}'
```

### Batch update (insert/format/delete content)

The Docs API uses `batchUpdate` with a list of request objects. Common request types:

**Insert text at the end:**
```bash
gws docs documents batchUpdate \
  --params '{"documentId": "DOC_ID"}' \
  --json '{
    "requests": [{
      "insertText": {
        "location": {"index": 1},
        "text": "Hello, this is new content.\n"
      }
    }]
  }'
```

> Note: index 1 is the start of the document body. To append to the end, you need to know the
> document's endIndex (from a `get` call). The `+write` helper handles this automatically.

**Insert a paragraph with heading style:**
```bash
gws docs documents batchUpdate \
  --params '{"documentId": "DOC_ID"}' \
  --json '{
    "requests": [
      {
        "insertText": {
          "location": {"index": 1},
          "text": "Section Title\n"
        }
      },
      {
        "updateParagraphStyle": {
          "range": {"startIndex": 1, "endIndex": 14},
          "paragraphStyle": {"namedStyleType": "HEADING_1"},
          "fields": "namedStyleType"
        }
      }
    ]
  }'
```

**Delete a range of content:**
```bash
gws docs documents batchUpdate \
  --params '{"documentId": "DOC_ID"}' \
  --json '{
    "requests": [{
      "deleteContentRange": {
        "range": {"startIndex": 10, "endIndex": 50}
      }
    }]
  }'
```

**Replace text throughout the document:**
```bash
gws docs documents batchUpdate \
  --params '{"documentId": "DOC_ID"}' \
  --json '{
    "requests": [{
      "replaceAllText": {
        "containsText": {"text": "{{COMPANY_NAME}}", "matchCase": false},
        "replaceText": "Acme Corp"
      }
    }]
  }'
```

## Getting document IDs

From a Google Docs URL like:
`https://docs.google.com/document/d/1ABCdef123GHIjkl456MNOpqr/edit`

The document ID is the string between `/d/` and `/edit`:
`1ABCdef123GHIjkl456MNOpqr`

## Reading document content (extracting text)

The document JSON is deeply nested. To extract just the text:
```bash
gws docs documents get --params '{"documentId": "DOC_ID"}' | \
  python3 -c "
import json, sys
doc = json.load(sys.stdin)
for elem in doc['body']['content']:
  if 'paragraph' in elem:
    for pe in elem['paragraph'].get('elements', []):
      print(pe.get('textRun', {}).get('content', ''), end='')
"
```

## Practical tip: use `+write` for simple appends

For most "add content to a doc" tasks, `+write` is far easier than crafting a `batchUpdate`:
```bash
gws docs +write --document DOC_ID --text "$(cat my_content.txt)"
```
