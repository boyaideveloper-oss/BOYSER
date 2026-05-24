<div align="center">

```
  ██████╗  ██████╗ ██╗   ██╗███████╗███████╗██████╗
  ██╔══██╗██╔═══██╗╚██╗ ██╔╝██╔════╝██╔════╝██╔══██╗
  ██████╔╝██║   ██║ ╚████╔╝ ███████╗█████╗  ██████╔╝
  ██╔══██╗██║   ██║  ╚██╔╝  ╚════██║██╔══╝  ██╔══██╗
  ██████╔╝╚██████╔╝   ██║   ███████║███████╗██║  ██║
  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝
```

**Android AI Benchmark Suite**

[![Device](https://img.shields.io/badge/Xiaomi_17_Ultra-16GB/512GB-FF6900?logo=xiaomi&logoColor=white)](#-device-specs)
[![SoC](https://img.shields.io/badge/Snapdragon_8_Elite-SM8850-3253DC?logo=qualcomm&logoColor=white)](#-device-specs)
[![GPU](https://img.shields.io/badge/Adreno_840-OpenCL_3.0-FF6B35?logo=qualcomm&logoColor=white)](#-gpu-benchmark)
[![llama.cpp](https://img.shields.io/badge/llama.cpp-SVE2+i8mm-4B8BBE?logo=cplusplus&logoColor=white)](#-build)
[![ROM](https://img.shields.io/badge/Xiaomi_EU-HyperOS-FF6900?logo=xiaomi&logoColor=white)](#-device-specs)
[![Root](https://img.shields.io/badge/KernelSU_Next-Rooted-00C853?logo=android&logoColor=white)](https://github.com/rifsxd/KernelSU-Next)

*ชุดสคริปต์ benchmark CPU · RAM · Disk · AI Model สำหรับ Android + Linux*

</div>

---

## 📱 Device Specs

<div align="center">

### Xiaomi 17 Ultra — codename `nezha`

</div>

### ⚡ SoC — Qualcomm Snapdragon 8 Elite (SM8850)

| รายการ | ข้อมูล |
|:-------|:-------|
| **SoC** | Qualcomm **SM8850** Snapdragon 8 Elite |
| **Fab Process** | TSMC **3nm** |
| **CPU Architecture** | Qualcomm **Oryon V2** (custom — ไม่ใช่ ARM Cortex มาตรฐาน) |
| **CPU หมายเหตุ** | core เดียวกับ **Snapdragon X Elite** ที่ใช้ใน PC/Laptop |

### 🔷 CPU Clusters

| Cluster | Cores | Min | Max | ISA |
|:--------|:-----:|:---:|:---:|:----|
| Performance | cpu0–5 **(6 cores)** | 0.38 GHz | **3.63 GHz** | Oryon V2 |
| Prime | cpu6–7 **(2 cores)** | 0.77 GHz | **4.40 GHz** | Oryon V2 |

**ARM Extensions ที่รองรับ:**
`SVE2` · `SME` · `SME2` · `i8mm` · `bf16` · `DOTPROD` · `AES` · `SHA3` · `PMULL`

> 💡 **Oryon V2** มี **SME (Scalable Matrix Extension)** — ARM extension ที่ออกแบบมาสำหรับ AI/ML โดยเฉพาะ พบได้ในมือถือน้อยมาก

### 🎮 GPU

| รายการ | ข้อมูล |
|:-------|:-------|
| **GPU** | Qualcomm **Adreno 840** |
| **Max Clock** | **902 MHz** |
| **Idle Clock** | 191 MHz |
| **OpenCL** | **3.0** (Adreno-specific kernels) |
| **VRAM (shared)** | **7,500 MB** (free ~6,476 MB) |
| **Vulkan** | 1.4 |

### 💾 Memory & Storage

| รายการ | ข้อมูล |
|:-------|:-------|
| **RAM** | **16 GB LPDDR5X** |
| **RAM available** | ~15 GB (7.8 GB free) |
| **Swap** | 16 GB |
| **Storage** | **512 GB UFS 4.0** |
| **Storage chip** | SK Hynix HN8T271EJKX152 |
| **Usable** | ~476 GB |

### 🖥️ Display

| รายการ | ข้อมูล |
|:-------|:-------|
| **Resolution** | **1200 × 2608 px** |
| **Refresh Rate** | **120Hz LTPO** (adaptive) |
| **Density** | **480 DPI** |
| **Panel** | AMOLED |

### 🤖 AI / Compute Units

| Unit | Device | หน้าที่ |
|:-----|:------:|:--------|
| **Hexagon NSP** | fastrpc-nsp1000 | Neural Signal Processor (AI inference) |
| **ADSP** | fastrpc-adsp | Audio DSP |
| **CDSP** | fastrpc-cdsp | Compute DSP |
| **SVE2 + SME** | CPU | AI matrix multiply acceleration |

### 🔋 Battery & Charging

| รายการ | ข้อมูล |
|:-------|:-------|
| **ความจุ** | **6,000 mAh** |
| **เคมี** | Li-poly |

### 📡 Software & Connectivity

| รายการ | ข้อมูล |
|:-------|:-------|
| **Android** | **16** (API 36) |
| **ROM** | **Xiaomi EU HyperOS** |
| **Build** | `OS3.0.306.0.WPACNXM` |
| **Build Date** | April 23, 2026 |
| **Codename** | `nezha` |
| **Root** | **KernelSU Next** |
| **Linux** | Ubuntu 24.04.4 LTS (chroot) |
| **Kernel** | Android 6.12.23 |

---

## 📊 Benchmark Results

### System Benchmark

<div align="center">

| หมวด | ผล | Rating | คะแนน |
|:-----|:--:|:------:|------:|
| CPU Single-Thread | 3,303 ev/s | 🟡 GOOD | — |
| CPU Multi-Thread (8 cores) | 22,564 ev/s | 🟡 GOOD | 974 |
| CPU Efficiency | 94% | — | — |
| RAM Read | 29.1 GB/s | 🟢 EXCELLENT | 966 |
| RAM Write | 18.9 GB/s | 🟢 EXCELLENT | — |
| Disk Read | 6.6 GB/s | 🟢 EXCELLENT | — |
| Disk Write | 2.6 GB/s | 🟡 GOOD | 433 |
| AES-256-CBC | 873 MB/s | 🟢 EXCELLENT | 1023 |
| **รวม** | | | **852 / 1000** |

**🏆 Grade: `A+` HIGH-END**

</div>

### 🤖 AI Model Benchmark — Llama 3.2 3B (Q4\_K\_M)

<div align="center">

| Engine | Backend | Prompt (pp512) | Generate (tg128) | เพิ่มขึ้น |
|:-------|:-------:|:--------------:|:----------------:|:--------:|
| Ollama pre-built | CPU | 28 t/s | 12 t/s | baseline |
| llama.cpp SVE2+i8mm | CPU | 73 t/s | 14 t/s | +161% |
| **Adreno 840 OpenCL** | **GPU** | **196 t/s** | **12 t/s** | **+600%** |

> GPU: QUALCOMM Adreno™ 840 · OpenCL 3.0 · 7,500 MB VRAM

</div>

### ⚡ CPU+GPU Hybrid Benchmark — `-ngl` Layer Split

<div align="center">

> ทดสอบ offload transformer layers จาก 0% → 100% GPU (Llama 3.2 3B มี 28 layers)

| ngl | GPU Layers | Prompt (pp512) | Generate (tg128) | แนะนำสำหรับ |
|:---:|:----------:|:--------------:|:----------------:|:-----------|
| 0   | 0% CPU only | 84 t/s | **12.4 t/s** | Chat / Generation |
| 7   | 25% GPU | 64 t/s | 7.2 t/s | — |
| 14  | 50% GPU | 82 t/s | 7.8 t/s | — |
| 21  | 75% GPU | 110 t/s | 8.5 t/s | Balance |
| **28** | **100% GPU** | **154 t/s** | 9.4 t/s | **RAG / Batch** |

**Key Insight:**
- **Prompt Processing** — ยิ่ง GPU เยอะ ยิ่งเร็ว (batch matrix multiply) → ใช้ `-ngl 28`
- **Generation** — CPU ชนะ (sequential latency ต่ำกว่า) → ใช้ `-ngl 0`
- ngl=7–14 ช้ากว่าทั้งคู่ เพราะ CPU↔GPU transfer overhead สูงกว่า compute ที่ได้

</div>

---

## 📁 โครงสร้างโปรเจกต์

```
BOYSER/
├── 📄 benchmark.sh                    ← System benchmark (CPU/RAM/Disk/Crypto)
├── 📁 scripts/
│   ├── model_bench.sh                 ← AI inference benchmark (Ollama API)
│   ├── gpu_run.sh                     ← รัน GPU mode (bench/chat/server)
│   ├── gpu_bench_guide.sh             ← คู่มือ GPU offload + status check
│   └── termux_llama_opencl.sh         ← Build llama.cpp + Adreno OpenCL
├── 📁 build/
│   └── build_llamacpp.sh              ← Build llama.cpp ARM optimized (Linux)
├── 📁 .claude/commands/               ← Claude Code slash commands
│   ├── benchmark.md                   ← /benchmark
│   ├── model-bench.md                 ← /model-bench
│   └── gpu-setup.md                   ← /gpu-setup
└── 📄 README.md
```

---

## 🚀 วิธีใช้งาน

### 1. System Benchmark

```bash
bash /storage/emulated/0/BOYSER/benchmark.sh
```

### 2. Build llama.cpp (Linux — SVE2+i8mm)

```bash
bash /storage/emulated/0/BOYSER/build/build_llamacpp.sh
# ผล: Prompt Processing 73 t/s (+161% vs Ollama)
```

### 3. GPU Benchmark & Chat (Termux)

```bash
# ติดตั้งและ build ครั้งแรก
bash /storage/emulated/0/BOYSER/scripts/termux_llama_opencl.sh

# รัน benchmark GPU
bash /storage/emulated/0/BOYSER/scripts/gpu_run.sh bench

# แชทกับ model ด้วย GPU
bash /storage/emulated/0/BOYSER/scripts/gpu_run.sh chat ~/models/llama3.2.gguf

# HTTP server (OpenAI-compatible API)
bash /storage/emulated/0/BOYSER/scripts/gpu_run.sh server ~/models/llama3.2.gguf
```

### 4. คำสั่งตรง (GPU)

```bash
LD_PRELOAD=/vendor/lib64/libOpenCL_adreno.so \
  ~/llama.cpp/build/bin/llama-cli \
  -m model.gguf -ngl 99 -cnv
```

---

## 🔧 GPU Offload — วิธีที่ทำสำเร็จ

สภาพแวดล้อมนี้รัน Ubuntu บน Android kernel (KernelSU Next)
Adreno GPU ใช้ `kgsl` driver ซึ่ง Linux เข้าถึงตรงไม่ได้

**Key ที่ทำให้ GPU ทำงาน:**

```bash
# 1. ใช้ libOpenCL_adreno.so จาก Android vendor โดยตรง
LD_PRELOAD=/vendor/lib64/libOpenCL_adreno.so

# 2. รันใน Termux (Android side) ที่เข้าถึง kgsl ได้
# 3. Build พร้อม Adreno-specific OpenCL kernels
cmake ... -DGGML_OPENCL_USE_ADRENO_KERNELS=ON \
          -DOpenCL_LIBRARY=/vendor/lib64/libOpenCL.so
```

```
GPU Detection:
  ggml_opencl: selected platform: 'QUALCOMM Snapdragon(TM)'
  ggml_opencl: device: 'QUALCOMM Adreno(TM) 840 (OpenCL 3.0)'
  Available: 7,500 MiB · Free: 6,476 MiB
```

---

## ⚡ Claude Code Skills

เปิด Claude Code ในโฟลเดอร์นี้แล้วใช้ slash commands:

| Command | หน้าที่ |
|:--------|:--------|
| `/benchmark` | รัน system benchmark + สรุปผล |
| `/model-bench` | รัน AI inference benchmark |
| `/gpu-setup` | ดูสถานะ GPU + คู่มือ setup |

---

## 📚 อ้างอิง

- [llama.cpp](https://github.com/ggml-org/llama.cpp) — LLM inference engine
- [Ollama](https://ollama.com) — Local LLM runner
- [KernelSU Next](https://github.com/rifsxd/KernelSU-Next) — Android root solution
- [Termux](https://termux.dev) — Android terminal emulator

---

<div align="center">

*Tested on 2026-05-24 · Xiaomi 17 Ultra (nezha) · Snapdragon 8 Elite · KernelSU Next · Ubuntu 24.04*

</div>
