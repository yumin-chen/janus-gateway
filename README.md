# janus-gateway

janus-gateway is a lightweight, macOS-native network egress controller designed for multi-uplink home environments.
It provides secure SSH-based tunneling, optional WireGuard overlay, traffic shaping, multipath failover, and a clean separation of ingress/egress policies.

Janus — the Roman god of duality and portals — symbolizes the gateway’s role as a bidirectional traffic orchestrator between multiple ISPs, tunnels, and internal clients.

## Features

- macOS-native gateway mode (no containers required)
- SSH tunnel endpoint (local-only or LAN-exposed)
- Optional WireGuard overlay ("Hybrid Mode")
- PF-based routing, NAT, and denylist firewall
- Dual-uplink failover (Wi-Fi + Ethernet or dual routers)
- Traffic shaping and prioritization
- DNS leak protection for tunnel-based clients
- Clean separation of configuration, scripts, and policies
- Lightweight footprint suitable for M2 Mac Mini (8GB RAM)

## Target Hardware

- macOS (Apple Silicon)
- Designed for Mac Mini M2 (8GB RAM)
- Works with dual-router setups or multi-ISP homes

## Quick Start

```
make init
make enable-gateway
make start-tunnel
```

## Repository Layout

```
.
├── ci/
├── config/
│   ├── pf.conf
│   ├── routing.conf
│   ├── sshd_config
│   └── wireguard/
│       └── wg0.conf.example
├── content/
├── docs/
│   ├── architecture/
│   │   └── design/
│   │       └── adr-001-naming-and-scope.md
│   ├── guidelines/
│   │   └── decisions/
│   └── technical/
│       └── specs/
├── modules/
├── scripts/
│   ├── gateway-disable.sh
│   ├── gateway-enable.sh
│   ├── failover-monitor.sh
│   ├── start-tunnel.sh
│   ├── stop-tunnel.sh
│   └── traffic-shape.sh
├── src/
├── Makefile
└── README.md
```

## License

MIT
