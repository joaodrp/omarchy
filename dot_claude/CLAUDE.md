# User Preferences

## Tools

- Use `gh` CLI for GitHub interactions and `glab` CLI for GitLab interactions
- Always use GNU syntax in scripts (e.g. `sed -i 'pattern'` not `sed -i '' 'pattern'`) so they remain portable to macOS where GNU coreutils aren't the default
- Prefer individual or bulk operations through CLIs, MCP servers, or built-in tools over writing Bash/Python scripts. Scripts require explicit approval on each run and are harder to review.
- Never wrap CLI calls in for loops or scripted iterations. Use individual parallel tool calls instead (e.g., multiple `gh api` Bash calls, not a for loop over repos).

### Search & Documentation

- **`ctx7` CLI** - Library/framework docs, API specs, usage samples, setup instructions
- **Your own web search tools** - Find things on the web, current events, quick facts
- **Firecrawl CLI** - Read online pages, scrape JS-heavy pages, crawl sites, extract structured data. Use this whenever you need to fetch or read content from a URL
- **Perplexity MCP** - Deep research on complex topics requiring synthesis from multiple sources

### Web Testing

Prefer `agent-browser` CLI to interacting directly with Playwright.

## Repository Paths

Always clone repos under `~/Developer/<host>/<owner>/<repo>`:
- GitHub: `~/Developer/github.com/<owner>/<repo>`
- GitLab: `~/Developer/gitlab.com/<owner>/<repo>`

## Code

- Follow existing patterns in the codebase

### Bug Fixes

Write a failing test *before* fixing the bug. Use the lowest test level that captures it (unit > integration > e2e). After the fix, the test must pass. If a test is not feasible (environment-specific, transient), document why.

## Communication

- Be direct and concise
- Ask when there are genuine trade-offs or ambiguity
- Never post comments on issues or PRs without explicit consent
- Never use em-dashes (—, ---, or --)

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
