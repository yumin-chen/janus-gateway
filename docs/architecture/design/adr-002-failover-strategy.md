# ADR-002: Failover and Load Balancing Strategy

## Status

Proposed

## Context

The `janus-gateway` system requires a robust strategy for handling dual-WAN connections. The primary goal is to ensure uninterrupted service for critical applications like SSH and VPN tunnels, while also considering the potential for maximizing bandwidth. Two primary modes of operation were considered:

*   **Mode B: Soft Failover (Hysteresis):** A simple, highly stable approach where a secondary WAN is used only when the primary WAN fails. It avoids "path flapping" by requiring a sustained number of failures (N) to switch and a sustained number of successes (M) to switch back.
*   **Mode C: Load Balancing + Failover:** A more complex approach that utilizes both WAN connections simultaneously to increase aggregate throughput. It distributes traffic based on weights or policies and automatically removes a failed ISP from the pool.

## Decision

The initial implementation of `janus-gateway` will be **Mode B: Soft Failover (Hysteresis)**.

This decision is based on the following rationale:

*   **Reliability Over Throughput:** For the primary use case of providing a secure and stable remote access gateway, the reliability of long-lived connections (SSH, VPNs) is paramount. Soft failover guarantees this by preventing path changes unless a hard failure occurs.
*   **Simplicity and Debuggability:** A simple, predictable failover mechanism is easier to implement, maintain, and debug. This is critical for foundational network infrastructure.
*   **Architectural Progression:** Starting with a solid failover foundation (Mode B) allows for the future addition of load balancing (Mode C) as a separate, more advanced profile. This aligns with standard industry practice for deploying multi-WAN solutions.

The following table summarizes the trade-offs that informed this decision:

| Priority                     | Best Mode |
| ---------------------------- | --------- |
| **Reliability**              | **B**     |
| Both ISPs used all the time  | C         |
| **Simplest possible setup**  | **B**     |
| Maximum aggregate throughput | C         |
| **Avoid breaking SSH/tunnels** | **B**     |
| You want per-service routing | C         |
| ISP_A is much better         | **B**     |
| ISP_A ≈ ISP_B                | C         |

## Consequences

### Positive

*   The system will be highly stable and predictable.
*   Critical SSH and VPN sessions will not be interrupted by transient network fluctuations.
*   The implementation of PF rules and routing logic will be significantly simpler for the initial release.

### Negative

*   The total available bandwidth will be limited to that of the single active ISP.
*   The secondary ISP connection will remain idle unless a failover event occurs.

### Future Work

*   Once the core soft failover mechanism is proven stable, Mode C (Policy Load-Balancing) can be developed as an advanced, optional profile for users whose primary need is aggregate throughput.
