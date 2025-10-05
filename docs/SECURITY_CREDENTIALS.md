# Security: CI Credentials Handling

## Overview

This document explains how Garmin credentials are handled securely in the CI/CD pipeline.

## Current Implementation

### Secure Approach (Current)

```yaml
- name: Setup Connect IQ SDK
  env:
    # Credentials scoped to this step only
    GARMIN_USERNAME: ${{ secrets.GARMIN_USERNAME }}
    GARMIN_PASSWORD: ${{ secrets.GARMIN_PASSWORD }}
  run: |
    ./scripts/setup_sdk.sh
```

**Security Properties:**
- ✅ **Step-scoped** - Credentials only available to this specific step
- ✅ **Automatically masked** - GitHub masks secret values in logs
- ✅ **No persistence** - Not written to GITHUB_ENV or files
- ✅ **Isolated** - Other steps can't access these values

### Previous Approach (Less Secure)

```yaml
# ❌ Less secure - don't use
- name: Setup Garmin Credentials
  run: |
    echo "GARMIN_USERNAME=${{ secrets.GARMIN_USERNAME }}" >> $GITHUB_ENV
    echo "GARMIN_PASSWORD=${{ secrets.GARMIN_PASSWORD }}" >> $GITHUB_ENV
```

**Issues:**
- ⚠️ **Job-scoped** - Available to ALL subsequent steps
- ⚠️ **Wider exposure** - Any malicious code in later steps could access them
- ⚠️ **Less isolation** - Increases attack surface

## Security Best Practices

### 1. Use Step-Level Environment Variables

**Always prefer:**
```yaml
- name: My Step
  env:
    SECRET_VAR: ${{ secrets.MY_SECRET }}
  run: |
    # SECRET_VAR only available here
```

**Over:**
```yaml
- name: Expose Secret
  run: echo "SECRET_VAR=${{ secrets.MY_SECRET }}" >> $GITHUB_ENV
  
- name: Use Secret
  run: |
    # SECRET_VAR available here (wider scope = more risk)
```

### 2. Principle of Least Privilege

Credentials should have the **minimum scope** necessary:
- ✅ Step-scoped (best)
- ⚠️ Job-scoped (acceptable if necessary)
- ❌ Workflow-scoped (avoid)
- ❌ Repository-scoped (never)

### 3. Secret Masking

GitHub automatically masks secrets in logs:

```yaml
- name: Test
  env:
    PASSWORD: ${{ secrets.PASSWORD }}
  run: |
    echo "Password is: $PASSWORD"  # Output: "Password is: ***"
```

**However:**
- Base64/hex encoding **might** bypass masking in edge cases
- Binary data from decoded secrets might not be fully masked
- Don't manipulate secrets in ways that might expose them

**Example of potential issue:**
```yaml
# Less safe - decoded output might leak
- run: echo "${{ secrets.KEY_B64 }}" | base64 -d | xxd
```

**Better approach:**
```yaml
# Safer - use env var, direct to file
- env:
    KEY_B64: ${{ secrets.KEY_B64 }}
  run: echo "$KEY_B64" | base64 -d > key.der
```

### 4. Limit Secret Access

**Fork Pull Requests:**
- ✅ Forks **cannot** access secrets (security feature)
- ✅ Prevents credential leakage via malicious PRs
- ⚠️ CI will fail on fork PRs (expected behavior)

**Repository Settings:**
```
Settings → Secrets and variables → Actions → Repository secrets
```

Only repository maintainers can add/modify secrets.

## Threat Model

### What We're Protected Against

1. **Accidental Logging**
   - ✅ GitHub automatically masks secret values
   - ✅ Secrets won't appear in console output

2. **Malicious Fork PRs**
   - ✅ Forks can't access secrets
   - ✅ Attackers can't exfiltrate credentials via PR

3. **Credential Reuse**
   - ✅ Step-scoped env vars limit exposure window
   - ✅ Only SDK setup step can access credentials

### What We're NOT Protected Against

1. **Compromised Repository**
   - ⚠️ If attacker gains write access to repo
   - ⚠️ They could modify workflow to exfiltrate secrets
   - **Mitigation**: Use branch protection, code review

2. **Compromised GitHub Account**
   - ⚠️ If maintainer account is compromised
   - ⚠️ Attacker could access secrets directly
   - **Mitigation**: Use 2FA, strong passwords, PATs with limited scope

3. **Supply Chain Attacks**
   - ⚠️ If a GitHub Action we use is compromised
   - ⚠️ Malicious action could access env vars
   - **Mitigation**: Pin actions to specific commits, audit dependencies

## Recommendations

### For This Project

✅ **Current setup is secure** for our threat model:
- We control the repository
- We trust the code we write
- Credentials are step-scoped
- We use official GitHub Actions only

### For Enhanced Security (Optional)

If working with highly sensitive credentials, consider:

1. **Use OIDC Authentication** (eliminates long-lived secrets)
   ```yaml
   permissions:
     id-token: write
   
   - name: Configure credentials
     uses: aws-actions/configure-aws-credentials@v4
     with:
       role-to-assume: arn:aws:iam::ACCOUNT:role/ROLE
       aws-region: us-east-1
   ```
   
   **Note**: Garmin doesn't support OIDC (as of 2025)

2. **Use Environment Protection Rules**
   ```
   Settings → Environments → Production
   → Required reviewers
   → Deployment branches
   ```

3. **Rotate Credentials Regularly**
   - Change Garmin password periodically
   - Update GitHub secret

4. **Use Service Accounts**
   - Create dedicated Garmin account for CI
   - Limit permissions/access
   - Easier to audit and revoke

5. **Monitor Access**
   - Review workflow runs regularly
   - Check for suspicious activity
   - Enable audit logging

## Common Pitfalls to Avoid

### ❌ Don't Write Secrets to Files

```yaml
# BAD - secrets persist on disk
- run: echo "${{ secrets.PASSWORD }}" > password.txt
- run: ./script.sh password.txt
```

```yaml
# GOOD - use environment variables
- env:
    PASSWORD: ${{ secrets.PASSWORD }}
  run: ./script.sh  # Script reads from env
```

### ❌ Don't Echo Secrets Directly

```yaml
# BAD - might bypass masking
- run: echo "${{ secrets.PASSWORD }}" | base64
```

```yaml
# GOOD - let GitHub handle masking
- env:
    PASSWORD: ${{ secrets.PASSWORD }}
  run: |
    # Use PASSWORD in commands, don't echo it
    ./authenticate.sh
```

### ❌ Don't Use Secrets in Conditionals

```yaml
# BAD - secret might leak in logs
- if: secrets.PASSWORD == 'admin123'
  run: echo "Admin access"
```

```yaml
# GOOD - use environment-based logic
- env:
    PASSWORD: ${{ secrets.PASSWORD }}
  run: |
    # Logic inside script, not in workflow
    ./check_access.sh
```

### ❌ Don't Expose Secrets to Artifacts

```yaml
# BAD - secret in uploaded artifact
- run: echo "${{ secrets.API_KEY }}" > config.json
- uses: actions/upload-artifact@v4
  with:
    path: config.json
```

```yaml
# GOOD - generate config without secrets
- run: ./generate_config.sh  # Uses env vars internally
- uses: actions/upload-artifact@v4
  with:
    path: config.json  # Doesn't contain secrets
```

## Auditing

### Check Secret Usage

1. **Review workflow files:**
   ```bash
   grep -r "secrets\." .github/workflows/
   ```

2. **Check for exposed credentials:**
   ```bash
   # Search for hardcoded credentials (should be none!)
   grep -ri "password\|secret\|token" .github/
   ```

3. **Review workflow runs:**
   - Go to Actions tab
   - Check logs for `***` (masked secrets)
   - Verify no unmasked credentials appear

### Verify Step Scoping

```yaml
# Run this test workflow
- name: Test - Can't Access Creds
  run: |
    if [ -n "$GARMIN_USERNAME" ]; then
      echo "ERROR: Credentials leaked!"
      exit 1
    fi
    echo "OK: Credentials not accessible"
```

## Further Reading

- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [OIDC in GitHub Actions](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)

---

**Last Updated**: January 2025  
**Status**: Current implementation is secure for our use case  
**Next Review**: When adding new secrets or changing workflow
