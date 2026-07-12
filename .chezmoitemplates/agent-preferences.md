{{- /* Shared coding-agent preferences. Rendered into ~/.claude/CLAUDE.md,
       ~/.codex/AGENTS.md, and ~/.config/opencode/AGENTS.md, each of which
       appends its own tool-specific section. Keep everything here portable
       across agents; anything naming a single tool's features belongs in that
       tool's file instead. */ -}}
# User Preferences

## Tools

- Use `gh` CLI for GitHub interactions and `glab` CLI for GitLab interactions
- Always use GNU syntax in scripts (e.g. `sed -i 'pattern'` not `sed -i '' 'pattern'`); my macOS machines have GNU coreutils installed, so GNU-syntax scripts run there too
- Prefer individual or bulk operations through CLIs, MCP servers, or built-in tools over writing Bash/Python scripts. Scripts require explicit approval on each run and are harder to review.

### Search & Documentation

- **Context7 MCP** (`resolve-library-id`, `get-library-docs`) - Current library/framework/SDK/API docs. Use for any library question, even ones you think you know; prefer over web search and don't rely on stale training data for API details
- **Your own web search tools** - Find things on the web, current events, quick facts
- **`defuddle` CLI** - Read or grab a web page's main content as Markdown: `defuddle parse <url> --md`. Use whenever you need to fetch or read content from a URL. For JS-heavy or authenticated pages, use `agent-browser` instead.
- **Perplexity MCP** - Deep research on complex topics requiring synthesis from multiple sources

### Web Testing

Use the `agent-browser` CLI directly.

## Repository Paths

Always clone repos under `~/Developer/<host>/<owner>/<repo>`, e.g.
`~/Developer/github.com/joaodrp/omarchy`.

## Code

- Follow existing patterns in the codebase
- Comment only where a skilled reader couldn't infer intent from the code; then make every word earn its place
- Write comments and commit/PR descriptions in terms of the current state, not the change that produced it; leave out what it replaced, since git history holds that
- Verify claims about the codebase by reading or searching it, not assuming; flag uncertainty and how to check
- Verify before finishing: re-check each requirement, run tests and lint, then state what changed, what was verified, and what couldn't be

### Bug Fixes

Write a failing test *before* fixing the bug. Use the lowest test level that captures it (unit > integration > e2e). After the fix, the test must pass. If a test is not feasible (environment-specific, transient), say why and ask me how to proceed; never skip it on your own judgement.

## Writing

Applies to all prose: chat replies, code comments, commit and PR bodies, docs.

- Three literal dots `...`, never the `…` character
- No symbols a keyboard can't type: `->` not `→`, `!=` not `≠`, `x` not `×`, "section" not
  `§`. Emoji as GitHub shortcodes (`:warning:`), never raw unicode.
- Em dashes are the exception, but not the default connector. En dashes never: use a hyphen.
- No wall-of-text paragraphs — restructure as bullets when a paragraph packs several
  independent facts
- No decorative name-drops: mention a tool only when it is the actual justification
- Benchmark-style claims need a linked source, or get softened
- Long-lived docs never pin dependency versions — manifests pin; docs record the choice
  and the why

## Communication

- Be direct and concise
- Ask when there are genuine trade-offs or ambiguity
- In chat and review annotations alike, a question gets an answer or a plan, never an
  implementation; only clear directives get acted on. Judge by intent, not grammatical form
- When it's unclear whether something is a question or a directive, ask before acting
- Never post comments on issues or PRs without explicit consent

## Plans

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any
- Never ask what the codebase can answer: look it up. Ask only about decisions that are mine
- Give your recommended answer with each question

## Commits & PRs

- Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages and PR titles
- One logical change per commit. Never batch unrelated fixes into a single commit.
- Never amend pushed commits. Verify push status before amending.
- Use markdown in commit bodies and PR descriptions; use backticks for inline code and identifiers
- Never mention your own tooling (plugins, skills, subagents, models)
- After merging a PR, switch to the default branch and pull
- Before making changes on the default branch, create a new feature branch

## Memory

- Never edit this preferences file on your own initiative. When something reads like a
  general preference or working pattern rather than a project fact, raise it and get my
  explicit confirmation before it goes in here.
- Everything else stays in project-scoped memory.
