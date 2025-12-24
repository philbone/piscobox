# 👩🏻‍💻 Recommended Workflow

**This workflow is optimized for:**

- External Contributors
- Well-traceable Issues
- Predictable Releases

## 🔁 General Workflow

**Issue → Milestone → Branch → PR → Review → Merge → Release**

### 🧩 1. Issues as the Smallest Unit

Everything starts with an issue:

- Feature
- Bug
- Refactor
- Documentation

Recommended Issue Template:
```markdown
## 📝 Description
Clear description of the problem or improvement.

## 🎯 Objective
What you expect to achieve.

## 📦 Scope
- [ ] Task 1
- [ ] Task 2

## 🚫 Out of scope (not mandatory)
- ❌ Does not include X

## 🔗 Milestone
vX.Y.Z
```

### 🏷 2. Basic Labels for Open-Source

Use few, but clear:

|Label 					|Usage
|----					|----
|**bug**				|Error
|**feature** 			|New functionality
|**enhancement** 		|Improvement
|**breaking** 			|Incompatible change
|**good first issue**	|For new contributors
|**help wanted** 		|Open to the community

### 🌿 3. Simple Branching (recommended)

**main** → stable

**feature/** → new features

**fix/** → bugs

**Example:**
```bash
feature/interactive-installer
fix/permissions-check
```

In normal cases a new branch is generated from the main branch. 

To name a branch, use a label as a prefix, a forward slash (/), and the name in kebab-case.

Example: You need to work on a new feature, such as adding PHP 9.0 installation. From the main branch, create a working branch like this:

```bash
git branch feature/install-php90
```

Once you have finished your feature, bug fix, etc., you should push the working branch to origin as follows:
```bash
git push --set-upstream origin feature/install-php90
```

Note: The "origin" on your machine is your fork repository. Therefore, you will receive the new branch in your repository's version.

The next step is to login on your GitHub account and submit a pull request (PR) from your feature branch to the main branch of the `philbone/piscobox` repository.

> Don't worry, Philbone will likely change the branch that receives the new feature to test it before merging it with the main branch.

- Do not delete your branch in your repository until the feature integration has been confirmed.
- Do not merge the new feature into your local main branch directly.


Once the integration has been accepted in the `philbone/piscobox` repository, you should update your main branch from the `philbone/piscobox` repository. And then delete your local working branch.

Before starting to work on a new feature, you must update your local version. From the main directory, you execute the following command:
```bash
git pull
```


### 🔀 4. Pull Requests with traceability

Minimum checklist in PR:
```markdown
## 🎯 Objective
What does this PR solve?

## 🔗 Related Issue
Closes #XX

## 🧪 Testing
How it was tested.

## ⚠️ Breaking Changes
Yes / No
```

👉 `Closes #XX` automatically closes the #XX issue upon merging.

### 🚀 5. Open-Source Releases

#### Golden Rule

> **Never release a version with open issues at its milestone.**

Before releasing:
- Milestone closed
- Main stable
- Updated documentation (if applicable)

### 🔁 6. Pre-release versions (optional but recommended)

For OS:
- v0.3.0-beta.1
- v0.3.0-rc.1

Useful for:

- Early feedback
- Community testing