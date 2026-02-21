# Agent Relay - AI Agent Relay Development Framework

Solving the context loss problem in long AI Agent conversations. Enables continuous cross-session development through structured requirements documents and feature lists.

## Core Features

- **Cross-session Continuous Development**: Built on SPEC.md, feature-list.json, and claude-progress.txt
- **Requirements Confirmation Flow**: AI generates requirements document → User confirms → Generate feature list
- **Automated Workflow**: Auto-select feature → Implement → Test → Commit → Update progress
- **One-click Installation**: Auto-detect git root, write to CLAUDE.md

## Installation

```bash
# Install to any git project
bash /path/to/agent-relay/install.sh /path/to/your-project

# Or remote installation
curl -sL https://raw.githubusercontent.com/your-repo/agent-relay/main/install.sh | bash -s /path/to/your-project
```

## Uninstall

```bash
bash /path/to/agent-relay/install.sh --uninstall /path/to/your-project
```

## Check Status

```bash
bash /path/to/agent-relay/install.sh --check /path/to/your-project
```

## Usage

### First Initialization

```bash
cd /path/to/your-project
claude
```

Tell Claude:
> Initialize relay project, I want to build a xxx

**Flow:**
1. AI generates `SPEC.md` requirements document → Show to user for confirmation
2. After user confirms, generate feature list
3. Claude automatically generates:
   - `SPEC.md` - Requirements document
   - `feature-list.json` - Feature list
   - `claude-progress.txt` - Progress tracking

### Subsequent Relay Development

Each new session just say:
> Continue development

Claude automatically: Read progress → Select feature → Implement → Test → Commit → Update progress

## File Description

| File | Description |
|------|-------------|
| `install.sh` | Install/uninstall/check script |
| `relay-instructions.md` | CLAUDE.md template with complete relay workflow |
| `SPEC.md` | Requirements document (generated during init, needs user confirmation) |
| `feature-list.json` | Feature list (generated after requirements confirmed) |
| `claude-progress.txt` | Progress tracking file |

## How It Works

1. **Initialization**: User briefly describes requirements → AI generates SPEC.md → User confirms
2. **Generate List**: After confirmation, generate feature-list.json
3. **Select Feature**: Auto-select next implementable feature by priority and dependencies
4. **Implement**: Implement step by step according to steps list, verify test criteria
5. **Commit**: Git commit, update feature status to completed

## Core Rules

- Implement only one feature at a time
- Don't delete or modify test_criteria
- Don't mark unimplemented features as complete
- Update progress file before each session ends

## Edge Cases

| Scenario | Handling |
|----------|----------|
| feature-list.json exists | Ask user to overwrite or continue |
| SPEC.md exists | Ask user to use existing or regenerate |
| User adjusts requirements | Update SPEC.md, regenerate feature list |
