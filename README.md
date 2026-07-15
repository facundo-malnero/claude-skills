# claude-skills

Shared Claude Code skills for the Light-it team.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/facundomalnero/claude-skills/main/install.sh | bash
```

A TUI will let you pick which skills to install. Requires `gum` or `fzf` for the interactive selector — falls back to a plain `[Y/n]` prompt if neither is available.

## Update

After install, an alias is added to your `~/.zshrc`:

```bash
claude-skills-update
```

Re-run whenever new skills are added to this repo.

## Personal overrides

If you already have a skill with the same name in `~/.claude/skills/<skill>/`, the installer will skip it and leave yours intact. Your version always wins.

To switch to the managed version:

```bash
rm -rf ~/.claude/skills/<skill-name>
claude-skills-update
```

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`
2. Add `<skill-name>` to `manifest.txt`
3. Commit and push — teammates get it on their next `claude-skills-update`

## Available skills

| Skill | Description |
|---|---|
| `mentoring-daily` | Creates daily mentoring session notes in Obsidian from PRs and mentor context |
| `mentoring-report` | Generates a structured mentoring report to share with the mentee's manager |
| `end-of-mentorship-feedback` | Answers the 10 Light-it end-of-mentorship questions from Obsidian session notes |
