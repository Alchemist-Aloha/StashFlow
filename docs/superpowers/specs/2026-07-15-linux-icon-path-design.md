# Linux Icon Path Resolution Design

## Problem

The Linux runner loads `data/app_icon.png` relative to the process working
directory. The build correctly installs the icon beside the executable under
`data/`, but launching the executable from another directory makes the lookup
fail.

## Design

Resolve the running executable through `/proc/self/exe`, take its parent
directory, and append `data/app_icon.png`. Keep the existing CMake bundle
layout and GTK icon-loading behavior unchanged.

If the executable path cannot be resolved or the PNG cannot be decoded, emit a
warning and continue starting the application without a custom window icon.
The icon is cosmetic and must not make startup fatal.

Alternatives considered were embedding the PNG as a GResource and probing
paths relative to the working directory. GResource embedding adds unnecessary
build machinery for one existing asset, while working-directory probes retain
the ambiguity that caused the defect.

## Verification

Add a focused native path-resolution test that supplies an executable path and
expects its sibling `data/app_icon.png` path. Observe the test fail before the
helper exists, then pass after implementation. Build the release Linux bundle
and launch it from the repository root to confirm the previous missing-icon
warning is absent.
