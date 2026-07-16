---
name: conventions
description: "Query Light-it coding conventions across sources: ai-workspace-template → Slite → laravel boilerplate. Stops at the first source that answers."
trigger: /conventions
---

# /conventions

Answer any question about Light-it coding conventions by searching sources in order. Stop and return as soon as a source gives a complete answer — never continue to the next source unnecessarily.

## Usage

```
/conventions <query>
/conventions how should I structure a FormRequest?
/conventions where does authorization live?
/conventions what's the convention for enums?
```

## Search Order

### 1. ai-workspace-template (primary source)

Repo: `Light-it-labs/ai-workspace-template`
Base path: `bundles/laravel/skills/laravel-backend`

**Step 1 — map the query to reference files.** Based on the query topic, identify which reference files are relevant:

| Topic keywords | Reference file |
|---|---|
| controller, invoke, response, HTTP status | `references/controllers.md` |
| action, business logic, execute | `references/actions.md` |
| form request, validation, authorization, DTO, field constants | `references/form-requests.md` |
| migration, schema, index, foreign key | `references/migrations.md` |
| model, eloquent, cast, guarded | `references/models.md` |
| notification, mail | `references/notifications.md` |
| policy, permission, gate | `references/policies.md` |
| query, list, filter, N+1, eager load | `references/query-patterns.md` |
| resource, response, camelCase, JSON | `references/resources.md` |
| saloon, HTTP client, external API | `references/saloon.md` |
| enum, type, exception, strict_types | `references/types-and-enums.md` |

**Step 2 — fetch and read.** Read only the relevant reference file(s) using:

```bash
gh api repos/Light-it-labs/ai-workspace-template/contents/bundles/laravel/skills/laravel-backend/references/<file> \
  | python3 -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d['content']).decode())"
```

If unsure which file applies, read the overview first:

```bash
gh api repos/Light-it-labs/ai-workspace-template/contents/bundles/laravel/skills/laravel-backend/SKILL.md \
  | python3 -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d['content']).decode())"
```

**If the fetched content answers the query → return the answer immediately. Do not proceed to step 2 or 3.**

---

### 2. Slite

Use `ask-slite` with the original user query. Target the Backend Standards and Tech Decisions documentation.

**If Slite returns a relevant answer → return it. Do not proceed to step 3.**

---

### 3. laravel boilerplate (last resort)

Repo: `Light-it-labs/laravel`

Read the main guidelines file:

```bash
gh api repos/Light-it-labs/laravel/contents/.ai/laravel-php-ai-guidelines.md \
  | python3 -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d['content']).decode())"
```

For specific topics, also check:

| Topic | File |
|---|---|
| Model factories | `.ai/factories.md` |
| HTTP requests / FormRequest | `.ai/request.md` |
| Testing | `.ai/testing.md` |

---

## Output Format

- Answer directly and concisely — no need to explain the search process.
- Cite the source at the end: `> Source: ai-workspace-template / references/actions.md`
- If the answer was found but is incomplete across sources, say so explicitly and note where the gap is.
- If no source has an answer, say so clearly — do not invent conventions.
