# Specifications

`Export-Clipboard-Spec.md` is the single authoritative behavioral
specification for this project. All implementations must conform to it.

`speclets/` holds focused, in-progress proposals for changes to the
behavioral contract. A speclet describes one coherent change, not an
alternative full specification. Once a speclet is accepted and folded into
the authoritative spec, it is normally deleted - Git history preserves its
evolution.

Git history provides the detailed historical record. Release tags identify
complete historical states of the specification alongside the
implementations, tests, and changelog at that point in time.
`CHANGELOG.md` provides the curated, human-readable history of notable
changes.

The specification and the software release share one version lifecycle;
there is no independent specification version.
