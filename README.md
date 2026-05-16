# Missile Guidance Simulator

A real-time 2D missile intercept simulator built in base MATLAB. Models proportional navigation, pure pursuit, and lead pursuit guidance laws against manoeuvring targets.

No toolboxes required.

![sim screenshot](screenshot.png)

## Run


## Guidance laws

| Law | Description |
|-----|-------------|
| Proportional Navigation | Commands acceleration proportional to LOS rate — `a = N * Vc * λ̇` |
| Pure Pursuit | Missile always steers directly toward current target position |
| Lead Pursuit | Missile steers toward a predicted future target position |

## Target motion modes
| Mode | Behaviour |
|------|-----------|
| Straight | Constant velocity, baseline case |
| Weave | Sinusoidal lateral oscillation |
| Constant Turn | Steady circular arc at fixed turn rate |
| Evasive | Compound sinusoidal heading changes |

## Controls
- **Nav Const N** — proportional navigation gain (2 to 8)
- **MSL Speed** — missile speed in m/s, up to 2700 m/s (Mach 8)
- **TGT Speed** — target speed in m/s, up to 1100 m/s (Mach 3.3)
- **START / PAUSE / RESET** — simulation flow control
- **Camera** — Follow, Global view, or Missile chase

## HUD metrics
Live telemetry includes closing velocity, LOS angle and rate, commanded acceleration in g, range, and time-to-go.

## Requirements
- MATLAB R2018b or later
- No toolboxes
