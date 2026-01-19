# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| main branch | Yes |
| testnet releases | Yes |
| < v1.0 | No |

## Reporting a Vulnerability

**DO NOT** create public GitHub issues for security vulnerabilities.

### Contact
- **Email**: security@xai-blockchain.org
- **Response Time**: 48 hours for initial acknowledgment
- **Disclosure Policy**: 90-day coordinated disclosure

### What to Include
- Affected file paths and versions
- Step-by-step reproduction instructions
- Proof of concept (if available)
- Impact assessment
- Suggested fix (optional)

## Scope

### In Scope
- Core node implementation (`src/xai/core/`)
- Blockchain logic (`src/xai/core/blockchain*.py`)
- P2P networking (`src/xai/core/p2p/`)
- API endpoints (`src/xai/core/api_routes/`)
- Wallet CLI (`src/xai/wallet/`)
- Cryptographic implementations

### Out of Scope
- Third-party dependencies (report upstream)
- Documentation and website
- Denial-of-service against public testnet
- Social engineering attacks
- Issues already reported or known

## Security Model

### Trust Assumptions
1. **AI Compute Verification**: Results verified via consensus
2. **Cryptographic Primitives**: Standard Python cryptography libraries
3. **P2P Network**: Peer verification and rate limiting
4. **Python Runtime**: Relies on Python's memory management

### Core Security Features
- **Rate Limiting**: Token bucket per address
- **API Authentication**: Optional write-auth for sensitive endpoints
- **Proxy Awareness**: X-Forwarded-For header handling for Cloudflare
- **IP Allow/Deny Lists**: Configurable access control

## Testnet Hardening

Operators should enable these environment variables:

```bash
XAI_TRUST_PROXY_HEADERS=1
XAI_TRUSTED_PROXY_IPS=<cloudflare-ips>
XAI_PUBLIC_TESTNET_HARDENED=1
XAI_WRITE_AUTH_REQUIRED=1
```

## Bug Bounty Program

**Status**: Not yet established

Future bounty program planned for mainnet with token-based rewards.

| Severity | Planned Reward |
|----------|----------------|
| Critical | Up to $15,000 |
| High | Up to $5,000 |
| Medium | Up to $1,500 |
| Low | Up to $300 |

### Severity Guidelines
- **Critical**: Remote code execution, fund theft, consensus failure
- **High**: State corruption, significant resource drain
- **Medium**: Limited impact bugs, DoS vectors
- **Low**: Minor issues, edge cases

## Audit History

| Date | Auditor | Scope | Status |
|------|---------|-------|--------|
| TBD | TBD | Full Protocol | Pending |

## Security Checklist

- [x] Apache 2.0 license
- [x] Security contact established
- [x] Code of conduct in place
- [x] Signed commits required
- [ ] External security audit
- [ ] Bug bounty program launched
- [ ] Incident response plan documented

## Contact

For security inquiries: security@xai-blockchain.org
