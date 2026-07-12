{{- /* Shared coding-agent preferences. Rendered into ~/.claude/CLAUDE.md,
       ~/.codex/AGENTS.md, and ~/.config/opencode/AGENTS.md, each of which
       appends its own tool-specific section. Keep everything here portable
       across agents; anything naming a single tool's features belongs in that
       tool's file instead. */ -}}
# User Preferences

## Safety

- Never print, echo, or commit secrets (tokens, keys, passwords). Read them from the
  environment or a secret store.
- Never discard uncommitted work (`reset --hard`, `checkout .`, `clean -fd`) without asking.
- Never force-push or rewrite history on a shared branch without asking.

## Communication

- Never ask what the codebase can answer: look it up. Ask about genuine trade-offs and
  ambiguity; those decisions are mine.
- In chat and in review annotations, a question gets an answer or a plan, never an
  implementation; implement only once I give an explicit go-ahead. Judge by intent, not
  grammar; ask when unclear.
- Never post comments on issues or PRs without explicit consent.

## Writing

Applies to all prose: chat replies, code comments, commit and PR bodies, docs.

- Be direct and concise: every word must earn its place.
- No wall-of-text paragraphs — restructure as bullets when a paragraph packs several
  independent facts.
- Comments and docs describe the current state, not the change or what it replaced; git
  history holds that. Commit and PR text is the exception: there, the change is the point.
- No decorative name-drops: mention a tool only when it is the actual justification.
- Soften benchmark-style claims that lack a linked source.
- Long-lived docs never pin dependency versions — manifests pin; docs record the choice
  and the why.
- No symbols a keyboard can't type: `...` not `…`, `->` not `→`, `!=` not `≠`, `x` not `×`,
  "section" not `§`, hyphen not en dash. Em dashes are an exception, but never the default
  connector.
- Emoji are fine in chat. In code, docs, and commit/PR text use GitHub shortcodes
  (`:warning:`), never raw unicode.
- In chat and docs, prefer tables and diagrams to prose wherever they make something
  easier to scan.

## Plans

- Make the plan extremely concise. Sacrifice grammar for concision.
- At the end of each plan, list any unresolved questions.
- Give your recommended answer with each question.

## Code

- Follow existing patterns in the codebase.
- Comment only where a skilled reader couldn't infer intent from the code.
- Verify claims about the codebase by reading or searching it, not assuming; flag uncertainty and how to check.
- Verify before finishing: re-check each requirement, run tests and lint, then state what you changed, what you verified, and what you couldn't.

### Bug Fixes

In a codebase with a test suite:

- Write a failing test *before* fixing the bug, at the lowest level that captures it: unit
  if possible, else integration, else e2e.
- After the fix, the test must pass.
- If a test is not feasible, say why and ask me how to proceed; never skip it on your own
  judgement.

## Commits & PRs

- Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages and PR titles.
- One logical change per commit. Never batch unrelated fixes into a single commit.
- Verify push status before amending; amending a pushed commit needs my go-ahead.
- Use markdown in commit bodies and PR descriptions; use backticks for inline code and identifiers.
- Never mention your own tooling (plugins, skills, subagents, models) in commit or PR prose.
  Trailers the harness adds are exempt.
- After merging a PR, switch to the default branch and pull.
- Never commit directly to the default branch; branch first.

## Tools

- Use `gh` CLI for GitHub interactions and `glab` CLI for GitLab interactions.
- Clone repos under `~/Developer/<host>/<owner>/<repo>`, e.g. `~/Developer/github.com/basecamp/omarchy`.
- Some dotfiles under `~` are chezmoi-managed. Run `chezmoi source-path <file>` before
  editing one: a managed file must be changed at its source, since edits to the live copy
  are reverted on the next apply. Editing a source or running `chezmoi apply` needs my
  approval.
- Always use GNU syntax in scripts (e.g. `sed -i 'pattern'` not `sed -i '' 'pattern'`); my macOS machines have GNU coreutils installed, so GNU-syntax scripts run there too.

### Research & Web

- **Context7 MCP** (`resolve-library-id`, `get-library-docs`) - Current library/framework/SDK/API docs. Use for any library question, even ones you think you know: training data goes stale on API details. Prefer it over web search.
- **Your own web search tools** - Find things on the web, current events, quick facts.
- **`defuddle` CLI** - Read a web page's main content as Markdown: `defuddle parse <url> --md`. Use it for any web page; fetch raw files and JSON APIs directly instead.
- **`agent-browser` CLI** - Browser automation and web testing; prefer it over any built-in browser tools. Also the fallback for JS-heavy or authenticated pages that `defuddle` cannot read.
- **Perplexity MCP** - Deep research on complex topics requiring synthesis from multiple sources.

## Meta

- Never edit this preferences file on your own initiative. When something reads like a
  general preference or working pattern rather than a project fact, raise it and get my
  explicit confirmation before it goes in here.
- Portable rules go in the shared source,
  `~/.local/share/chezmoi/.chezmoitemplates/agent-preferences.md`. Agent-specific rules go
  in that agent's own file, which is what `chezmoi source-path` reports.
