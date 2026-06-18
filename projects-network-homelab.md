---
layout: default
title: HomeLab Network Projects | Fritz Gerald Reyes
---

[← Back to Portfolio](./)

# 🌐 HomeLab Network Projects

Detailed documentation of my home infrastructure, focusing on network segmentation, L3 routing, and secure laboratory environments.

---

<details markdown="1" open>
<summary><h3 style="display:inline">🏆 🌐 HomeLab Network Architecture</h3></summary>

*Enterprise-grade Network Segmentation / Zero Trust Design for SRE & Cybersecurity Labs.*

### 🚀 Project Overview
The goal of this project is to build a robust homelab network that separates trusted personal devices, isolated testing environments, and quarantined threat analysis zones.

* **Network Segmentation:** Multiple subnets configured for trusted traffic, IoT/BYOD, and isolated labs.
* **Layer 3 Gateway Routing:** Uses a dedicated System/Management VLAN as a transit network between the core router and switch, relying on hardware-level routing to securely handle multi-subnet traffic.
* **Security & Quarantine:** Dedicated zones for malware experimentation and secure file analysis using hardware ACLs.

### 📐 Architectural Blueprint
![Home Network Detailed Diagram](./images/projects/network/homelab/home_network_diagram.png)

### 🔗 Logical Infrastructure (Source)
The following Mermaid.js source defines the dynamic network topology, demonstrating a "Documentation as Code" approach to infrastructure management.

```mermaid
graph TD
    %% Define Color Styles matching your subnets
    classDef mainNet fill:#f8f9fa,stroke:#333,stroke-width:2px;
    classDef byod fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef lab fill:#d1e7dd,stroke:#198754,stroke-width:2px;
    classDef malware fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef guest fill:#ffe8cc,stroke:#fd7e14,stroke-width:2px;
    classDef hardware fill:#e2e3e5,stroke:#6c757d,stroke-width:2px;

    %% ==========================================
    %% 1. CORE HARDWARE & ROUTING LAYER DEFINITIONS
    %% ==========================================
    ISP[🌐 ISP Router / Modem]:::hardware
    RB5009[🎛️ Mikrotik RB5009<br/><sub>Bridge Interface Disabled</sub>]:::hardware

    %% ==========================================
    %% 2. SWITCH MATRIX SUBGRAPH & PORTS
    %% ==========================================
    subgraph Core_Switch [🔌 Switch: TP-Link TL-SG2218]
        VLAN1[VLAN 1: System-VLAN<br/>10.230.0.2/16<br/>Ports 1-0-1 to 1-0-18]
        VLAN4_Port[VLAN 4: BYOD<br/>Port 1-0-15]
        VLAN231_Port[VLAN 231: LAB<br/>Ports 1-0-10, 1-0-12, 1-0-14]
        VLAN777_Port[VLAN 777: MALWARE<br/>Port 1-0-16]
        VLAN778_Port[VLAN 778: GUEST<br/>Port 1-0-13]
    end
    class Core_Switch mainNet;

    %% ==========================================
    %% 3. VLAN SUBGRAPHS & CONTAINED ENDPOINTS
    %% ==========================================
    
    %% Core Network Nodes (VLAN 1 Systems)
    subgraph Sys_Devices [Main Network Devices]
        NAS[💾 NAS Synology DS224+]:::hardware
        PC[🖥️ Desktop PC]:::hardware
        PS5[🎮 PS5]:::hardware
    end

    %% VLAN 231 - LAB Compute
    subgraph Lab_Network [🟢 VLAN 231: LAB - 10.231.0.0/16]
        ESXi[⚙️ VMware ESXi Servers]:::hardware
        Optiplex3050[🖥️ Dell Optiplex 3050/Proxmox]:::hardware
    end
    class Lab_Network lab;

    %% VLAN 4 - BYOD Workstation
    subgraph BYOD_Network [🟡 VLAN 4: BYOD - 192.168.4.0/24]
        Deco[📡 TP-Link Deco M4R]:::hardware
        SSID_Eidos((( )))
        SSID_Lucis((( )))
        TapoC210[📷 TP-Link Tapo C210]:::hardware
        TapoC500_1[📷 TP-Link Tapo C500 #1]:::hardware    
        TapoC500_2[📷 TP-Link Tapo C500 #2]:::hardware    
        OtherWireless[📱 Other Wireless Devices]:::hardware
    end
    class BYOD_Network byod;

    %% VLAN 777 - MALWARE Isolated Sandbox
    subgraph Malware_Network [🔴 VLAN 777: MALWARE - 10.250.77.0/24]
        Optiplex3060[🖥️ Dell Optiplex 3060/VMware Workstation]:::hardware
    end
    class Malware_Network malware;

    %% VLAN 778 - GUEST
    subgraph Guest_Network [🟠 VLAN 778: GUEST - 10.250.78.0/24]
        PC_AYR[🖥️ Desktop PC - AYR]:::hardware
    end
    class Guest_Network guest;


    %% ==========================================
    %% 4. RELATIONSHIP LINKS & INTERFACES (BOTTOM)
    %% ==========================================
    
    %% WAN to Router
    ISP ---|"LAN1 to Ether1 (192.168.1.10/24)"| RB5009
    
    %% Uplink Trunk from Router to Switch
    RB5009 ---|"Ether3 (10.230.0.1/16) to Int 1-0-1"| VLAN1

    %% VLAN 1 Connections
    VLAN1 ---|Port 1-0-2| NAS
    VLAN1 ---|Port 1-0-3| PC
    VLAN1 ---|Port 1-0-4| PS5

    %% VLAN 231 Connections
    VLAN231_Port ---|Ports 1-0-10,12,14| ESXi
    VLAN231_Port ---|Port 1-0-11| Optiplex3050

    %% VLAN 4 Connections & Wireless Layout
    VLAN4_Port ---|Port 1-0-15| Deco
    
    %% SSID 1 Layout
    Deco -.->|SSID: Eidos| SSID_Eidos
    SSID_Eidos -.-> TapoC210
    SSID_Eidos -.-> TapoC500_1
    SSID_Eidos -.-> TapoC500_2

    %% SSID 2 Layout
    Deco -.->|"SSID: Lucis (Guest)"| SSID_Lucis
    SSID_Lucis -.-> OtherWireless

    %% VLAN 777 Connections
    VLAN777_Port ---|Port 1-0-16| Optiplex3060

    %% VLAN 778 Connections
    VLAN778_Port ---|Port 1-0-13| PC_AYR
```

### ⚙️ Network Summary
High-level segmentation strategy.

| VLAN | Name | CIDR Block | Gateway | Target Role |
| :---: | :--- | :--- | :--- | :--- |
| **1** | **System** | `10.230.0.0/16` | `10.230.0.1` | Transit Backbone & Management |
| **4** | **BYOD** | `192.168.4.0/24` | `192.168.4.1` | Mobile Devices & Smart IoT |
| **231** | **LAB** | `10.231.0.0/16` | `10.231.0.1` | Hypervisors & Testing Sandboxes |
| **777** | **MALWARE** | `10.250.77.0/24` | `10.250.77.1` | Quarantined Threat Analysis |
| **778** | **GUEST** | `10.250.78.0/24` | `10.250.78.1` | Isolated Guest Compute |

### 🖥️ Hardware Inventory

| Device | Role | OS / Hypervisor |
| :--- | :--- | :--- |
| **Mikrotik RB5009** | Core Router & Firewall | RouterOS v7.19.6 |
| **TP-Link TL-SG2218** | L3 Distribution Switch | JetStream Managed |
| **Synology DS224+** | Centralized Storage (NAS) | DSM 7.2.2 |
| **Dell Optiplex 3050** | Virtualization Node | Proxmox VE 9.2.2 |
| **Dell Optiplex 3060** | Malware Sandbox | Win 11 Pro + Workstation |
| **ESXi Cluster (3 Nodes)** | Virtualization Nodes | VMware ESXi |
| **TP-Link Deco M4R** | Wireless Access Point | Mesh Mode |

### 🛠️ Service Catalog
*   **Core Infrastructure:** Centralized DHCP (Mikrotik), L3 Hardware Routing (TP-Link), DNS.
*   **Virtualization:** VMware ESXi, Proxmox VE, VMware Workstation.
*   **Security Lab:** Isolated Malware Sandbox, Static/Dynamic Analysis zones.
*   **Storage:** Synology File Services.

### 📸 Lab Gallery

| Rack Overview | Network Gateway/Firewall |
| :---: | :---: |
| ![Rack Front View](./images/projects/network/homelab/0010_Rack_Front_View.jpg) | ![Mikrotik RB5009](./images/projects/network/homelab/0001_Mikrotik_RB5009.jpg) |

| Distribution Layer | Virtualization Servers |
| :---: | :---: |
| ![TP-Link Switch](./images/projects/network/homelab/0002_TP-Link_TL-SG2218.jpg) | ![ESXi Servers](./images/projects/network/homelab/0004_ESXi_Servers.jpg) |

| Additional Compute Nodes | Side Profile |
| :---: | :---: |
| ![Dell Optiplex Nodes](./images/projects/network/homelab/0005_Dell_Optiplex_3060_3050.jpg) | ![Rack Side View](./images/projects/network/homelab/0011_Rack_Side_View_Right.jpg) |

---

> 🔒 **Note on Source Code:** The full repository containing RouterOS configurations, switch ACL scripts, and detailed documentation is currently private.

</details>

---

[← Back to Portfolio](./)
