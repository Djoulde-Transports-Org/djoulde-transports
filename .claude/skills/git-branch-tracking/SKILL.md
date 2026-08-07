---
name: git-branch-tracking
description: Use whenever creating a new git branch — especially ticket/feature branches "based off master". Prevents a branch from silently tracking origin/master instead of its own name, which causes commits, pushes, and VS Code "Sync Changes" to land directly on master with no PR.
---

# Git branch tracking safety

## The bug this prevents

`git checkout -b <name> origin/master` looks safe but sets the new branch's upstream to `origin/master` itself (`branch.autoSetupMerge` default behavior), not to a same-named remote branch. Any later bare `git push`, VS Code "Sync Changes", or `git pull` on that branch then operates against `master` directly. Commits land on `master` with no PR, and every branch created this way looks "linked" because they all silently point at the same upstream.

Symptom in `.git/config`:

```
branch.<name>.merge=refs/heads/master   # WRONG — should be refs/heads/<name>
```

## Rule: create branches with `--no-track`

When branching off a remote ref (almost always `origin/master`), always pass `--no-track`:

```bash
git fetch origin master
git checkout -b <branch-name> --no-track origin/master
```

This leaves the upstream unset instead of defaulting to `origin/master`.

## Rule: the first push always sets the upstream explicitly

```bash
git push -u origin HEAD
```

`-u` publishes the branch and records the upstream as `origin/<branch-name>` — matching the local name. Never rely on a bare `git push` for a brand-new branch.

## Rule: verify immediately after creating the branch

Right after `git checkout -b`, confirm the upstream is unset (or already correct) before doing any work:

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>&1
```

Expect either an error (`no upstream configured`, from `--no-track`) or `origin/<branch-name>`. If it prints `origin/master` while you're on anything other than `master`, stop before pushing and fix it:

```bash
git push -u origin HEAD   # publishes under its own name, corrects the upstream, does not touch master
```

## Retroactive fix (if a branch already tracks master)

Safe and additive — does not rewrite `master` history:

```bash
git push origin <branch-name>:refs/heads/<branch-name>
git branch --set-upstream-to=origin/<branch-name> <branch-name>
```

If `master` already received commits directly from the mistracked branch, that's a separate, higher-stakes decision (whether to unwind shared history) — surface it to the user rather than resolving it unilaterally.
