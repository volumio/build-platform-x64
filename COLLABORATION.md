# Collaboration Guidelines

This project — originally developed by Gé Koerkamp (2022–2024) — is now maintained under a **collaborative stewardship model** as of **May 2025**.

These guidelines define how contributions are handled, how maintainers collaborate, and how engineering consistency is preserved in future development.

## 1. Guiding Principles

- **Respect the original work**: The project is technically mature and thoughtfully designed. Changes should uphold its clarity, stability, and performance goals.
- **Minimize regressions**: Platform builds impact end-user systems. Avoid introducing changes that may destabilize boot, firmware loading, or kernel compatibility.
- **Document every change**: All non-trivial changes must be accompanied by clear commit messages and README or script-level documentation updates where appropriate.
- **Collaborate transparently**: Discuss significant decisions in issues or pull requests before merging.

## 2. Contribution Process

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**, including:
   - Patch or script modifications
   - Updates to documentation where relevant
   - Verification against at least one known supported build host (Debian 10, Ubuntu 22.04+)

4. **Open a Pull Request (PR)**:
   - Describe the purpose and scope of the change
   - Mention whether it impacts kernel sources, firmware management, or user-facing scripts

5. **Code review**:
   - PRs will be reviewed for consistency, safety, and maintainability
   - Minor cleanups (e.g., comment style, shell quoting) may be requested

6. **Approval and Merge**:
   - After one or more approvals and a successful test report, the PR may be merged

## 3. Patch and Kernel Management

- Patches must reside in the `patches/<kernelbranch>/` directory
- Sequence numbers (`NNN-name.patch`) determine application order — do not renumber existing patches
- Patch filenames must be descriptive and follow existing naming conventions
- `mkplatform.sh` must correctly apply all new patches and produce a bootable kernel
- Use `PATCH_KERNEL=yes` for pre-merge testing of patch application logic

## 4. Configuration Files

- Kernel configs must be named:  
  `amd64-volumio-min-<kernelbranch>_defconfig`
- These files should be updated only when hardware support or required kernel options change

## 5. Firmware Management

- All firmware additions must go through `mergefirmware.sh`
- Changes to `LINUX_FW_REL` must include clear identification of new firmware dates and contents
- Avoid wholesale firmware repo replacements unless necessary

## 6. Versioning and Tags

- Major kernel branch updates should be tagged (e.g. `v6.6-init`, `v6.12-stable`)
- Internal milestones (e.g. firmware refresh, script refactor) may also be tagged at maintainer discretion

## 7. Communication and Issue Tracking

- Use GitHub Issues to report bugs, request support for new kernel versions, or suggest enhancements
- Use Discussions or Issues to reach consensus on large architectural changes
- Always link relevant issues in PRs and commits when applicable

## 8. Maintainers

The project is currently maintained by a group of independent contributors. No single entity claims ownership.

New maintainers may be added through consensus based on regular, high-quality contributions.

## 9. License

This repository is governed by the [MIT License](./LICENSE). Contributors retain copyright
on their submitted code but grant permissive use under the project’s license terms.

We welcome your contributions — thank you for helping continue the work.
