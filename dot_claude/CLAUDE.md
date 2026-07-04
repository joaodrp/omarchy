# User Preferences

## Tools

- Use `gh` CLI for GitHub interactions and `glab` CLI for GitLab interactions
- Always use GNU syntax in scripts (e.g. `sed -i 'pattern'` not `sed -i '' 'pattern'`); my macOS machines have GNU coreutils installed, so GNU-syntax scripts run there too
- Prefer individual or bulk operations through CLIs, MCP servers, or built-in tools over writing Bash/Python scripts. Scripts require explicit approval on each run and are harder to review.
- Never wrap CLI calls in for loops or scripted iterations. Use individual parallel tool calls instead (e.g., multiple `gh api` Bash calls, not a for loop over repos).

### Search & Documentation

- **`ctx7` CLI** - Library/framework docs, API specs, usage samples, setup instructions
- **Your own web search tools** - Find things on the web, current events, quick facts
- **`defuddle` CLI** - Read or grab a web page's main content as Markdown: `defuddle parse <url> --md`. Use whenever you need to fetch or read content from a URL. For JS-heavy or authenticated pages, use `agent-browser` instead.
- **Perplexity MCP** - Deep research on complex topics requiring synthesis from multiple sources

### Web Testing

Use the `agent-browser` CLI directly.

## Repository Paths

Always clone repos under `~/Developer/<host>/<owner>/<repo>`:
- GitHub: `~/Developer/github.com/<owner>/<repo>`
- GitLab: `~/Developer/gitlab.com/<owner>/<repo>`

## Code

- Follow existing patterns in the codebase
- Verify claims about the codebase by reading or searching it, not assuming; flag uncertainty and how to check
- Verify before finishing: re-check each requirement, run tests and lint, then state what changed, what was verified, and what couldn't be

### Bug Fixes

Write a failing test *before* fixing the bug. Use the lowest test level that captures it (unit > integration > e2e). After the fix, the test must pass. If a test is not feasible (environment-specific, transient), document why.

## Communication

- Be direct and concise
- Ask when there are genuine trade-offs or ambiguity
- Treat a question ("how would...", "can we...") as a question: answer it or propose a plan, don't implement until given an explicit go-ahead
- Never post comments on issues or PRs without explicit consent
- Use em dashes sparingly in prose; don't lean on them as the default connector

## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.

## Commits & PRs

- Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages and PR titles
- One logical change per commit. Never batch unrelated fixes into a single
  commit.
- Never amend pushed commits. Verify push status before amending.
- Keep descriptions concise and direct
- Use markdown in commit bodies and PR descriptions; use backticks for inline code and identifiers
- Never mention your plugins or skills
- After merging a PR, switch to the default branch and pull
- Before making changes on the default branch, create a new feature branch
