---
layout: default
title: Network Security Projects | Fritz Gerald Reyes
---

[← Back to Portfolio](./)

# 🛡️ Zero Trust Home Lab

A NIST CSF 2.0 / SP 800-207 aligned Zero Trust blueprint — proving that enterprise-grade segmentation, detection, and incident-response automation can be built on existing prosumer home-lab gear.

---

<details markdown="1" open>
<summary><h3 style="display:inline">🏆 🛡️ Zero Trust Architecture (NIST CSF 2.0)</h3></summary>

*A defense-in-depth, assume-breach security design layered on top of my existing multi-VLAN home lab.*

### 🚀 Project Overview
This project turns a segmented home network into a working **Zero Trust** reference environment — not by buying enterprise firewalls, but by **maximizing the hardware I already own**: a MikroTik **RB5009** router and a TP-Link **SG2218** L3 switch. The result is deny-by-default east-west enforcement, MITRE ATT&CK-mapped detection, and safety-guarded response automation, all governed against the NIST Cybersecurity Framework 2.0.

**What this demonstrates:**
* **Network micro-segmentation** — deny-by-default inter-VLAN policy with explicit, documented carve-outs.
* **NIST CSF 2.0 alignment** — evidence mapped across all six functions (Govern → Recover).
* **Detection engineering** — use cases mapped to MITRE ATT&CK with a structured Wazuh rule-ID scheme.
* **Incident-response automation** — Python and PowerShell tooling with built-in safety guards.
* **Security as code** — idempotent, rollback-capable configuration and honest, tracked maturity.

### 🔐 Zero Trust Principles (SP 800-207)
The design is anchored to the four core tenets of NIST SP 800-207:

* **Never Trust, Always Verify** — no implicit trust from network location; every zone is treated as hostile until a flow is explicitly permitted.
* **Least Privilege** — access is scoped per host, per service, per protocol — not per subnet.
* **Assume Breach** — the high-value LAB zone is designed as if an attacker is already inside it.
* **Continuous Verification** — telemetry and detection logic watch for lateral movement and credential abuse rather than trusting a one-time authentication.

### 🧭 NIST CSF 2.0 Coverage
Evidence is mapped across all six framework functions.

| Function | Focus | Evidence |
| :---: | :--- | :--- |
| **GOVERN** | Scope, roles, policy, supply chain | Zone model, access-control & micro-segmentation policy, risk register |
| **IDENTIFY** | Asset inventory & data flows | Sanitized asset inventory, network-zone catalog, data-flow mapping |
| **PROTECT** | Segmentation, hardening, PAM | Firewall matrix, AD hardening, privileged-access broker, host firewalls |
| **DETECT** | Monitoring & analytics | Logging architecture, MITRE-mapped detection use cases, Wazuh rule catalog |
| **RESPOND** | IR & containment | Incident-response playbook, automated host quarantine (live RB5009 drop rule), contain-vs-observe detonation decision record, comms plan |
| **RECOVER** | Restoration & lessons learned | Recovery procedures, lessons-learned register |

### 🧱 Segmentation & East-West Enforcement
The core of the design is a **two-device split-enforcement model** that squeezes enterprise behavior out of prosumer hardware:

* **MikroTik RB5009 (edge / north-south):** owns WAN, DHCP, and egress policy. Static routes for every internal subnet point at the switch, so the router deliberately **does not process inter-VLAN traffic on its CPU**. The forward chain ends in an explicit `DENY ANY ANY`.
* **TP-Link SG2218 (core / east-west):** owns the per-VLAN gateways and performs **hardware-offloaded inter-VLAN routing**. Because a prosumer L3 switch routes *default-allow*, deny-by-default is **emulated with per-VLAN ingress ACLs** shaped `permit-allowed → deny-any` — the key architectural insight of the project, captured as a formal decision record (L3 ACLs vs. firewall-on-a-stick, keeping hardware offload).

**Sanitized zone model** *(lab addressing is illustrative and sanitized):*

| VLAN | Zone | CIDR Block | Trust Level |
| :---: | :--- | :--- | :--- |
| **—** | **System / Transit** | `10.XXX.0.0/16` | Highest — management plane & transit backbone |
| **4** | **BYOD** | `192.168.X.0/24` | Conditional (laptops) / Untrusted (IoT) |
| **231** | **LAB** | `10.XXX.0.0/16` | High-value — assume-breach |
| **777** | **MALWARE** | `10.XXX.XX.0/24` | Untrusted by design |
| **778** | **GUEST** | `10.XXX.XX.0/24` | Untrusted |

> The **MALWARE** detonation zone is hard-denied east-west at the switch, and its analysis VM keeps its virtual NIC **disconnected by default** — the host is offline until deliberately connected and observed. A formal *contain-vs-observe* decision record keeps the vNIC **fail-closed** until a controlled session, and **prescribes** dynamic analysis under **simulated internet (e.g. INetSim / FakeNet-NG)** — a planned control, not yet stood up — so a sample can reveal its C2 behavior with **no real egress**, with the harvested IOCs designed to feed back into Wazuh rules and MikroTik `address-list` blocks.

### 🎯 Detection Engineering [DESIGN]
Detection use cases are mapped to **MITRE ATT&CK** and organized under a structured Wazuh rule-ID numbering scheme (grouped by domain). *Presented as a design catalog.*

| ID | Detection Use Case | ATT&CK | Telemetry Source | Severity |
| :---: | :--- | :--- | :--- | :---: |
| UC-01 | SSH brute-force (composite) | T1110 | Host / auth logs | Medium |
| UC-04 | Cross-VLAN ACL drop | T1021 | Switch / firewall logs | Medium |
| UC-08 | Kerberoasting / AS-REP roast | T1558 | Windows security (4769) | High |
| UC-11 | DCSync | T1003.006 | Domain controller | Critical |
| UC-14 | Golden / Silver ticket | T1558.001 | AD / Kerberos | Critical |

Signals for **lateral movement** (SMB to non-file-servers, WinRM type-3 logons, Pass-the-Hash) are baselined and exercised with purple-team table-top tests.

### 🚨 Incident Response & Automation
*The playbook is a design reference not yet exercised against live infrastructure; the automation below is built and runnable today.*

Response follows **SP 800-61** phases with a severity matrix and per-scenario quick cards (ransomware on NAS, domain-admin compromise with double KRBTGT rotation, malware-zone escape, router takeover). Containment strategy is pre-decided rather than improvised: a formal **contain-vs-observe** decision record (NIST SP 800-61 / SANS PICERL) governs the MALWARE detonation VM — *disconnect-the-NIC vs. observe-for-IOCs* — resolving into two keyed defaults (compromised production host → contain now; detonation VM → fail-closed until a controlled session, with dynamic analysis prescribed under simulated internet rather than real egress), with evidence captured in **order of volatility**.

The flagship automation is a **host-quarantine tool** (Python) that adds/releases a host to the MikroTik RB5009 `quarantine` address-list via the RouterOS API. The enforcement is **live**: a forward-chain `drop src-address-list=quarantine` rule — ordered **above** the broad `ALL-NETWORK`/INTERNET permits — is deployed on the router, so adding an IP is **real L3 egress isolation**, not just a script action. *(Automatic invocation via Wazuh active-response is target-state — the SIEM is not yet deployed — so today it runs as a manual IR action.)* It ships with the safety patterns that matter in production:

* **`CRITICAL_DENY` guard** — refuses to quarantine the management plane, domain controller, NAS, SIEM, or PAM broker, preventing an accidental self-inflicted outage (`--force` required to override).
* **Graceful fallback** — if the API library is unavailable it prints the exact manual commands instead of failing silently.
* **Auditability** — TTL support and audit logging on every action.

Supporting automation includes an **idempotent, rollback-capable PowerShell** host-firewall project (`-WhatIf`/dry-run, export-before-change, per-role policy) and a **Guacamole-based PAM** broker for mediated, recorded RDP/SSH access.

### 📊 Maturity Self-Assessment (Honest)
Scored with CSF Implementation Tiers + a CMMI lens, capping any function that is *documented but not yet enforced/telemetered*.

| Function | Score | Tier |
| :---: | :---: | :---: |
| GOVERN | 3.0 | 3 |
| IDENTIFY | 3.0 | 3 |
| PROTECT | 2.0 | 2 |
| DETECT | 2.0 | 2 |
| RESPOND | 3.0 | 2 |
| RECOVER | 2.0 | 2 |

**Overall ≈ 2.5 / 5 → Tier 2 (Risk-Informed).** **RESPOND** rose to *Defined (3.0)* once the containment path went live end-to-end — the RB5009 `drop src-address-list=quarantine` rule now performs real L3 isolation, and the contain-vs-observe decision record gives incident analysis a framework-backed reference; it stops short of *Managed (4)* because the response is enforced but **not yet measured** (auto-trigger still awaits Wazuh, and the path is unexercised). The *design* maturity sits around Tier 3; the *enforced* maturity is honestly Tier 2 — and tracking that gap is itself a deliberate governance artifact.

### 🗺️ Gaps & Roadmap
* Deploy the **Wazuh** server to move the detection catalog from design to enforced telemetry.
* Enable **switch ACL logging** to close the east-west detection blind spot.
* Stand up the **simulated-internet detonation sandbox** (INetSim / FakeNet-NG) prescribed by the contain-vs-observe decision record — so the MALWARE zone can harvest C2 IOCs with no real egress.
* Build out **data-security (PR.DS)** controls — the one openly-uncovered CSF category.

### 🛠️ Tech Stack
* **Network Enforcement:** MikroTik RouterOS, TP-Link JetStream L3 ACLs
* **Detection:** Wazuh, MITRE ATT&CK
* **Identity:** Windows Active Directory hardening, Guacamole PAM
* **Automation:** Python, PowerShell
* **Framework:** NIST CSF 2.0, NIST SP 800-207 / 800-61

---

> 🔒 **Note on Source Code:** The full repository containing RouterOS configurations, switch ACL scripts, detection rules, and automation is currently private. Addressing shown here is illustrative and sanitized.

</details>

---

[← Back to Portfolio](./)
