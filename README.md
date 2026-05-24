# BOYSER Benchmark Suite

ชุดสคริปต์ benchmark สำหรับ Android + Linux (KernelSU Next)  
ทดสอบ CPU, RAM, Disk, Crypto และ AI Model inference

---

## อุปกรณ์ที่ทดสอบ

| รายการ | ข้อมูล |
|--------|--------|
| OS | Ubuntu 24.04.4 LTS (Linux chroot บน Android) |
| Kernel | Android 6.12.23 (KernelSU Next) |
| CPU | ARM64 aarch64 — 8 cores (SVE2, SME, i8mm, bf16) |
| RAM | 15 GB |
| Storage | 476 GB |
| Root | KernelSU Next |

---

## โครงสร้างโปรเจกต์

```
BOYSER/
├── benchmark.sh              ← System benchmark (CPU/RAM/Disk/Crypto)
├── scripts/
│   ├── model_bench.sh        ← AI Model inference benchmark
│   └── gpu_bench_guide.sh    ← คู่มือ GPU offload + benchmark guide
├── build/
│   └── build_llamacpp.sh     ← Build llama.cpp พร้อม ARM optimizations
├── .claude/commands/
│   ├── benchmark.md          ← Claude Code skill: system benchmark
│   ├── model-bench.md        ← Claude Code skill: model benchmark
│   └── gpu-setup.md          ← Claude Code skill: GPU setup guide
└── README.md
```

---

## วิธีใช้งาน

### 1. System Benchmark
```bash
bash /storage/emulated/0/BOYSER/benchmark.sh
```

### 2. Model Benchmark (ต้องรัน Ollama ก่อน)
```bash
ollama serve &
bash /storage/emulated/0/BOYSER/scripts/model_bench.sh
# หรือระบุ model อื่น
bash /storage/emulated/0/BOYSER/scripts/model_bench.sh qwen2.5:7b
```

### 3. GPU Setup Guide
```bash
bash /storage/emulated/0/BOYSER/scripts/gpu_bench_guide.sh
```

### 4. Build llama.cpp (SVE2+i8mm optimized)
```bash
bash /storage/emulated/0/BOYSER/build/build_llamacpp.sh
```

---

## ผลการทดสอบ (2026-05-24)

### System Benchmark

| หมวด | ผล | Rating | คะแนน |
|------|-----|--------|-------|
| CPU Single-Thread | 3,303 events/sec | GOOD | — |
| CPU Multi-Thread (8 cores) | 22,564 events/sec | GOOD | 974/1000 |
| CPU Efficiency | 85-94% | — | — |
| RAM Read | 28-29 GB/s | EXCELLENT | 966/1000 |
| RAM Write | 18-19 GB/s | EXCELLENT | — |
| Disk Write | 2.3-2.6 GB/s | GOOD | 433/1000 |
| Disk Read | 5.1-6.6 GB/s | EXCELLENT | — |
| AES-256-CBC | 855-873 MB/s | EXCELLENT | 1023/1000 |
| **คะแนนรวม** | — | — | **849-852 / 1000** |
| **Grade** | — | — | **A+ HIGH-END** |

### Model Benchmark — Llama 3.2 3B (Q4_K_M)

| Engine | Backend | Prompt (pp512) | Generate (tg128) |
|--------|---------|---------------|-----------------|
| Ollama (pre-built) | CPU | 28 t/s | 12 t/s |
| Linux Custom Build (SVE2+i8mm) | CPU | 73 t/s | 14 t/s |
| **Termux + Adreno 840 OpenCL** | **GPU** | **196 t/s** | **12 t/s** |

GPU: QUALCOMM Adreno(TM) 840 — OpenCL 3.0 — 7,500 MB VRAM

---

## GPU Offload — สถานะและแผน

### ปัญหาปัจจุบัน

เครื่องรัน Ubuntu บน Android kernel ผ่าน Linux chroot  
GPU Adreno ใช้ driver `kgsl` ซึ่งเป็น Android-specific:

```
Linux chroot
├── Mesa Turnip (freedreno)  ──▶ ต้องการ msm_drm GPU node ❌
│                                แต่ได้แค่ SDE Display node
└── Android Vulkan ICD       ──▶ ใช้ Bionic libc ❌
    (vulkan.adreno.so)           ไม่ compatible กับ glibc
```

### วิธีแก้ (เรียงจากง่ายไปยาก)

#### วิธีที่ 1 — Termux + Adreno OpenCL (ทำสำเร็จแล้ว ✔)
รัน llama.cpp บน Android side ใน Termux ด้วย Adreno 840 GPU

```bash
# ติดตั้งและ build อัตโนมัติ
bash /storage/emulated/0/BOYSER/scripts/termux_llama_opencl.sh

# รัน benchmark GPU
bash /storage/emulated/0/BOYSER/scripts/gpu_run.sh bench

# แชทด้วย GPU
bash /storage/emulated/0/BOYSER/scripts/gpu_run.sh chat ~/models/llama3.2.gguf

# คำสั่งตรง (ต้อง LD_PRELOAD เสมอ)
LD_PRELOAD=/vendor/lib64/libOpenCL_adreno.so \
  ~/llama.cpp/build/bin/llama-cli -m model.gguf -ngl 99 -cnv
```

**ผลจริง: 196 t/s Prompt / 12 t/s Generate**

#### วิธีที่ 2 — libhybris (ใน Linux chroot)
Bridge ระหว่าง Bionic ↔ glibc เพื่อให้ Linux ใช้ Android OpenCL ได้  
ซับซ้อนกว่า แต่ไม่ต้องออกจาก Linux environment

```bash
# ต้อง build libhybris จาก source
# https://github.com/libhybris/libhybris
```

#### วิธีที่ 3 — SVE2+i8mm Custom Build (ทำแล้ว ✔)
CPU-only แต่ใช้ ARM extensions เต็มที่

```bash
bash /storage/emulated/0/BOYSER/build/build_llamacpp.sh
```

---

## Claude Code Skills

### วิธีใช้ skill ใน Claude Code
เปิด Claude Code ในโฟลเดอร์ BOYSER แล้วใช้คำสั่ง:

```
/benchmark      ← รัน system benchmark
/model-bench    ← รัน model benchmark
/gpu-setup      ← ดู GPU setup guide
```

---

## อ้างอิง

- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [Ollama](https://ollama.com)
- [KernelSU Next](https://github.com/rifsxd/KernelSU-Next)
- [libhybris](https://github.com/libhybris/libhybris)
- Baseline: Snapdragon 8 Gen 2/3 community benchmarks
