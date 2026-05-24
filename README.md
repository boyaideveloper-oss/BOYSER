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

[![Android](https://img.shields.io/badge/Android-KernelSU_Next-3DDC84?logo=android&logoColor=white)](https://github.com/rifsxd/KernelSU-Next)
[![GPU](https://img.shields.io/badge/GPU-Adreno_840_OpenCL-FF6B35?logo=qualcomm&logoColor=white)](#gpu-benchmark)
[![llama.cpp](https://img.shields.io/badge/llama.cpp-SVE2+i8mm-4B8BBE?logo=cplusplus&logoColor=white)](#build)
[![Model](https://img.shields.io/badge/Model-Llama_3.2_3B-7C3AED?logo=meta&logoColor=white)](#model-benchmark)
[![License](https://img.shields.io/badge/License-MIT-green)](#)

*ชุดสคริปต์ benchmark CPU · RAM · Disk · AI Model สำหรับ Android + Linux*

</div>

---

## 📊 ผลการทดสอบ

### System Benchmark

<div align="center">

| หมวด | ผล | Rating | คะแนน |
|:-----|:--:|:------:|------:|
| CPU Multi-Thread (8 cores) | 22,564 ev/s | 🟡 GOOD | 974 |
| RAM Read | 29.1 GB/s | 🟢 EXCELLENT | 966 |
| RAM Write | 18.9 GB/s | 🟢 EXCELLENT | — |
| Disk Read | 6.6 GB/s | 🟢 EXCELLENT | — |
| Disk Write | 2.6 GB/s | 🟡 GOOD | 433 |
| AES-256-CBC | 873 MB/s | 🟢 EXCELLENT | 1023 |
| **รวม** | | | **852 / 1000** |

**Grade: `A+` HIGH-END**

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

---

## 📱 อุปกรณ์ที่ทดสอบ

<div align="center">

### Xiaomi 17 Ultra — 16GB / 512GB

</div>

| รายการ | ข้อมูล |
|:-------|:-------|
| **Device** | Xiaomi 17 Ultra (16GB / 512GB) |
| **SoC** | Qualcomm Snapdragon (ARM64 aarch64) |
| **CPU** | 8 cores · SVE2 · SME · i8mm · bf16 |
| **GPU** | Adreno 840 — OpenCL 3.0 · 7,500 MB VRAM |
| **RAM** | 16 GB (available ~15 GB) |
| **Storage** | 512 GB (476 GB usable) |
| **OS** | Ubuntu 24.04 LTS (Linux chroot) |
| **Kernel** | Android 6.12.23 · KernelSU Next |

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
# 1. ใช้ libOpenCL_adreno.so จาก Android vendor
LD_PRELOAD=/vendor/lib64/libOpenCL_adreno.so

# 2. รันใน Termux (Android side) ที่เข้าถึง kgsl ได้
# 3. Build พร้อม -DGGML_OPENCL_USE_ADRENO_KERNELS=ON
```

```
Detection:
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

*Tested on 2026-05-24 · Xiaomi 17 Ultra · Snapdragon · KernelSU Next · Ubuntu 24.04*

</div>
