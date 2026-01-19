# Contributing to XAI

Thank you for contributing to XAI! This guide covers our development workflow and standards.

## Code of Conduct

By participating, you agree to maintain a respectful and inclusive environment. See `CODE_OF_CONDUCT.md` for details.

## Reporting Bugs

- Search existing issues to avoid duplicates
- Include steps to reproduce and system information (OS, Python version)
- For security vulnerabilities, see `SECURITY.md` for private disclosure

## Submitting Pull Requests

1. Fork and create a feature branch: `git checkout -b feature/your-feature`
2. Make changes following code style guidelines
3. Run tests: `pytest && make lint`
4. Commit with conventional format (see below)
5. Push and create PR, address review feedback

## Development Setup

```bash
git clone https://github.com/YOUR_USERNAME/xai.git && cd xai
python3 -m venv venv
source venv/bin/activate
pip install -e ".[dev]"
```

### Pre-commit Hooks (Recommended)

```bash
pip install pre-commit
pre-commit install
```

## Code Style

### Python
- Follow [PEP 8](https://peps.python.org/pep-0008/) style guide
- Use type hints for all function signatures
- Use `black` for formatting, `isort` for imports, `flake8` for linting
- Use `mypy` for static type checking
- Prefer explicit over implicit; avoid magic

### Cryptography
- Use established libraries (e.g., `cryptography`, `hashlib`)
- Never implement custom crypto primitives
- Document all cryptographic assumptions

### Networking
- Use async/await for I/O-bound operations
- Handle connection failures gracefully
- Implement proper timeout handling

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `security`

**Scopes** (XAI-specific):
- `core` - Core blockchain logic
- `consensus` - Proof-of-work consensus
- `p2p` - Peer-to-peer networking
- `pool` - AI compute task pooling
- `trading` - Task trading functionality
- `api` - RPC/API endpoints
- `cli` - Command-line interface

**Examples**:
- `feat(pool): add GPU task scheduling`
- `fix(consensus): correct difficulty adjustment`
- `perf(p2p): optimize peer discovery`
- `security(api): add rate limiting to RPC`

## Testing Requirements

### Required for All PRs
- Unit tests for new functions
- Integration tests for P2P and consensus changes
- Property-based tests where appropriate (using `hypothesis`)

### Running Tests

```bash
# Unit tests
pytest

# With coverage
pytest --cov=xai --cov-report=html

# P2P integration tests
make ci-p2p

# Full CI suite
make ci
```

### Coverage Standards
- Minimum 80% for new code
- 100% for consensus and cryptographic functions

## Branch Strategy

```
main              - Production-ready, protected
develop           - Integration branch
feature/xyz       - Individual features
hotfix/xyz        - Emergency fixes
release/v1.0.0    - Release candidates
```

### Protected Branch Rules
- `main` requires PR with 1-2 approvals
- All CI checks must pass
- No force pushes

## Pull Request Process

1. Ensure tests pass and linters are clean
2. Update documentation for user-facing changes
3. Add changelog entry if applicable
4. Request review from CODEOWNERS where applicable
5. Address feedback; prefer squash-merge or rebase-merge

### PR Categories Requiring Extra Review

| Category | Required Reviewers |
|----------|-------------------|
| Consensus changes | 2+ senior devs |
| Cryptographic code | Security reviewer |
| P2P protocol | Network specialist |
| Task pooling | Core team |

## Security

- Never commit secrets or credentials
- Run `bandit -r xai/` before submitting
- Use `safety check` for dependency vulnerabilities
- Report vulnerabilities privately (see `SECURITY.md`)

### Security-Critical Areas
- `xai/core/consensus.py` - PoW implementation
- `xai/core/crypto.py` - Cryptographic functions
- `xai/p2p/` - Network protocol
- `xai/pool/verification.py` - Task verification

## DCO Sign-off

All commits must be signed off to certify you have the right to submit the work:

```bash
git commit -s -m "feat(pool): your feature description"
```

This adds a `Signed-off-by:` line certifying agreement with the [Developer Certificate of Origin](https://developercertificate.org/).

### Configuring Git for Sign-off

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Amending Unsigned Commits

```bash
git commit --amend -s
```

## Project Structure

```
xai/
├── core/           # Blockchain core (blocks, transactions, consensus)
├── p2p/            # Peer-to-peer networking
├── pool/           # AI compute task pooling
├── trading/        # Task trading and marketplace
├── api/            # RPC and REST API
├── cli/            # Command-line interface
└── utils/          # Shared utilities
```

## Questions?

- GitHub Discussions for general questions
- Documentation in `docs/`
- `SECURITY.md` for security-related questions

## License

Contributions are licensed under the Apache License 2.0 (see LICENSE file).
