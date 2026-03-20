# Project-Lobster-TPU
A 4x4 Systolic Array TPU core co-created with Generative AI, featuring RTL to GDSII implementation on Sky130 process.
## 🚀 Technical Deep Dive

### Systolic Array Architecture
The core utilizes a **Weight-Stationary** systolic array. Each PE (Processing Element) contains an 8-bit multiplier and a 32-bit accumulator. This architecture minimizes data movement, significantly reducing power consumption during large-scale matrix multiplications.

### Physical Sign-off (OpenLane)
The design was synthesized and routed using the **SkyWater 130nm PDK**. 
- **DRC/LVS**: 100% Clean.
- **Timing**: Meets 100MHz target frequency with positive slack.
- **Power**: Optimized power grid for stable IR drop across the 4x4 array.

### Verification
Simulation was performed using **Iverilog**. The testbench feeds real-world image data transformed into hexadecimal vectors. The output matches our Python-based AI emulator, confirming the mathematical integrity of the hardware implementation.
