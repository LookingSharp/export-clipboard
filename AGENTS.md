# AGENTS.md

This is the canonical repository policy for coding agents working in this
repository.

## Authority

- `specs/Export-Clipboard-Spec.md` is the authoritative behavioral
  specification.
- Implementations and tests must conform to it.
- Implementation-specific documentation must not silently redefine the
  project-wide behavioral contract.
- Ambiguous requirements must be surfaced rather than silently interpreted.

## Standards

Agents MUST adhere to:

- Keep a Changelog 1.1.0: https://keepachangelog.com/en/1.1.0/
- Semantic Versioning 2.0.0: https://semver.org/spec/v2.0.0.html

The referenced standards are authoritative and must not be redefined
locally.

## Specification lifecycle

- The main spec is the single authoritative current specification.
- Normal accepted changes update that specification in place.
- Git history preserves previous revisions.
- Do not create an archive directory merely to retain old specifications.
- `specs/speclets/` contains focused proposed or in-progress specification
  changes.
- Once a speclet is accepted and fully incorporated into the authoritative
  specification, normally delete the speclet.
- Git history preserves the deleted speclet and its evolution.
- Release tags preserve important complete historical states.
- Introduce parallel version-specific specifications only if the project
  genuinely needs to maintain multiple behavioral contracts simultaneously.

## Behavioral change workflow

Before making a change, determine whether it affects externally observable
or documented behavior.

If it does:

1. Update the authoritative specification, or create/update a speclet while
   the design is still being developed.
2. Once accepted, ensure the authoritative specification contains the final
   behavior.
3. Update affected implementations.
4. Update tests.
5. Add any notable change required by Keep a Changelog to the `Unreleased`
   section of `CHANGELOG.md`.
6. Assess the change according to Semantic Versioning.

Do not bump a released version simply because development work occurred.
Version assignment is part of the release process.

## Mandatory completion check

Every coding-agent completion report must contain:

```text
Change compliance:
- Spec: <updated | no change required - reason>
- Changelog: <updated | no entry required - reason>
- SemVer impact: <major | minor | patch | none>
- Tests: <updated/run/not run/etc.>
```

Perform these checks even when the task request does not explicitly mention
the specification, changelog, SemVer, or tests.

## Repository principles

1. The project is implementation-language-neutral.
2. The specification defines externally observable behavior.
3. Implementations conform to the specification.
4. Implementation details may differ freely when they do not change the
   specified behavioral contract.
5. Use established standards rather than inventing project-specific
   conventions.
6. Extend a standard only when a concrete project requirement is not
   addressed by that standard.
7. Keep the repository structure minimal until additional structure has a
   concrete purpose.
8. Use Git history and release tags as the detailed historical record
   rather than maintaining duplicate archive files.
