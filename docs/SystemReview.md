# System Review

## Architecture Weaknesses
- Server systems are currently tightly coupled to the workspace folder layout (e.g., `Workspace.Enemies` and `Workspace.NPCs`), which means level designers must preserve those paths for gameplay to function.
- Client UI depends on a single `ScreenGui` hierarchy, so any UI restructuring requires controller updates.
- There is no persistence layer for player progression yet; all player data is session-only and will reset between play sessions.

## Potential Exploit Risks
- The combat intent remote accepts client input without server-side validation of the requested skill type beyond a mode check. The server applies its own damage calculations, but rate limiting could still be spammed without further throttling.
- Upgrade requests rely on remote events and server validation, but replay protection or additional anti-spam checks are not present.

## Performance Risks
- The monster AI loop runs on a fixed tick per monster. Large enemy counts could increase server load without adaptive throttling or spatial partitioning.
- The combat remote scans active enemies linearly to find targets, which may become costly as the enemy count grows.

## Scalability Concerns
- Active enemies are stored in memory only; there is no sharding or room-based partitioning to scale across multiple rooms or server instances.
- Player data replication is performed through `NumberValue` objects under each player, which can become heavy if many stats or frequent updates are added.
