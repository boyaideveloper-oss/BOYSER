#!/bin/bash
# GPU Benchmark Guide — Adreno + KernelSU Next
# อธิบายสถานการณ์ปัจจุบัน และวิธีเปิด GPU offload
#
# สถานะ: CPU-only ได้ผล / GPU offload ต้องทำเพิ่มเติม

R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' B='\033[0;34m'
C='\033[0;36m' M='\033[0;35m' W='\033[1;37m' DIM='\033[2m' BOLD='\033[1m' NC='\033[0m'

section() {
  echo -e "\n${B}╔══════════════════════════════════════════════════════╗${NC}"
  printf  "${B}║${NC}  ${BOLD}${C}%-52s${NC}  ${B}║${NC}\n" "$1"
  echo -e "${B}╚══════════════════════════════════════════════════════╝${NC}"
}
ok()   { echo -e "  ${G}✔${NC} $1"; }
fail() { echo -e "  ${R}✘${NC} $1"; }
warn() { echo -e "  ${Y}⚠${NC} $1"; }
info() { echo -e "  ${C}ℹ${NC} $1"; }

clear
echo -e "${M}"
cat << 'LOGO'
   ██████╗ ██████╗ ██╗   ██╗    ██████╗ ███████╗███╗   ██╗ ██████╗██╗  ██╗
  ██╔════╝ ██╔══██╗██║   ██║    ██╔══██╗██╔════╝████╗  ██║██╔════╝██║  ██║
  ██║  ███╗██████╔╝██║   ██║    ██████╔╝█████╗  ██╔██╗ ██║██║     ███████║
  ██║   ██║██╔═══╝ ██║   ██║    ██╔══██╗██╔══╝  ██║╚██╗██║██║     ██╔══██║
  ╚██████╔╝██║     ╚██████╔╝    ██████╔╝███████╗██║ ╚████║╚██████╗██║  ██║
   ╚═════╝ ╚═╝      ╚═════╝     ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝
LOGO
echo -e "${NC}"
echo -e "  ${DIM}Adreno GPU Offload Guide  •  KernelSU Next  •  $(date '+%Y-%m-%d')${NC}"

# ─── ตรวจสอบสภาพแวดล้อม ───────────────────────────────────────────────
section "ENVIRONMENT CHECK"

[ -e /dev/kgsl-3d0 ]   && ok "Adreno GPU detected (/dev/kgsl-3d0)" || fail "ไม่พบ kgsl-3d0"
[ -e /dev/dri/renderD128 ] && ok "/dev/dri/renderD128 พร้อม"       || fail "ไม่พบ DRI render node"

KGSL_OWNER=$(ls -la /dev/kgsl-3d0 2>/dev/null | awk '{print $3}')
info "kgsl-3d0 owner: $KGSL_OWNER"

vulkaninfo --summary 2>/dev/null | grep -q "PHYSICAL_DEVICE_TYPE_DISCRETE_GPU" \
  && ok "Vulkan GPU พร้อม" || warn "Vulkan: CPU-only (llvmpipe) ยังไม่ได้ GPU จริง"

[ -f /proc/1/root/vendor/lib64/libOpenCL.so ] \
  && ok "Android OpenCL พบที่ /proc/1/root/vendor/lib64/" \
  || warn "ไม่พบ Android OpenCL library"

# ─── อธิบายปัญหา ──────────────────────────────────────────────────────
section "WHY GPU OFFLOAD IS BLOCKED (Linux chroot)"

cat << 'EXPLAIN'

  ┌─────────────────────────────────────────────────────┐
  │  Android (Host)                                     │
  │  ┌─────────────────────┐  ┌────────────────────┐   │
  │  │  Adreno GPU         │  │  Linux chroot      │   │
  │  │  Driver: kgsl       │  │  (Ubuntu 24.04)    │   │
  │  │  /dev/kgsl-3d0      │  │                    │   │
  │  │                     │  │  Mesa Turnip ──────┼──▶ ต้องการ msm_drm │
  │  │  Android Vulkan ICD │  │  (freedreno)       │   │ แต่ได้แค่ SDE  │
  │  │  vulkan.adreno.so   │  │                    │   │
  │  │  (Bionic libc)   ───┼──▶ glibc ❌ ใช้ไม่ได้ │   │
  │  └─────────────────────┘  └────────────────────┘   │
  └─────────────────────────────────────────────────────┘

EXPLAIN

fail "Mesa Turnip ต้องการ msm_drm GPU node แต่ /dev/dri/renderD128 เป็น SDE Display"
fail "Android Vulkan ICD (vulkan.adreno.so) ใช้ Bionic libc — ไม่ compatible กับ glibc"
fail "OpenCL จาก Android vendor ก็ติดปัญหาเดียวกัน"

# ─── วิธีแก้ทั้งหมด ───────────────────────────────────────────────────
section "SOLUTIONS (3 วิธี)"

echo -e "\n  ${BOLD}${G}วิธีที่ 1 — Termux + llama.cpp (ง่ายสุด ได้ผลเร็วสุด)${NC}"
echo -e "  ${DIM}รันบน Android side ตรงๆ — เข้าถึง kgsl ได้เต็มที่${NC}"
cat << 'TERMUX'

    ติดตั้งใน Termux:
    ──────────────────────────────────────────────────
    pkg update && pkg install cmake git clang
    git clone --depth=1 https://github.com/ggml-org/llama.cpp
    cd llama.cpp

    # Build พร้อม OpenCL (Adreno)
    cmake -B build \
      -DGGML_OPENCL=ON \
      -DCMAKE_C_FLAGS="-march=armv9-a+sve2+i8mm+bf16 -O3" \
      -DCMAKE_CXX_FLAGS="-march=armv9-a+sve2+i8mm+bf16 -O3"
    cmake --build build -j$(nproc)

    # คาดหวัง: 40-80 t/s (Adreno GPU offload)

TERMUX

echo -e "\n  ${BOLD}${Y}วิธีที่ 2 — libhybris bridge (ยากกว่า แต่รันใน Linux)${NC}"
echo -e "  ${DIM}Bridge ระหว่าง Bionic libc ↔ glibc ให้ Linux ใช้ Android libs ได้${NC}"
cat << 'HYBRIS'

    # ต้องการ: KernelSU Next (มีแล้ว ✔), build libhybris
    apt install libhybris libhybris-dev 2>/dev/null || \
      echo "ต้อง build จาก source: https://github.com/libhybris/libhybris"

    # หลัง libhybris พร้อม:
    # สร้าง Vulkan ICD ที่ชี้ไป Android library ผ่าน hybris wrapper
    # แล้ว build llama.cpp กับ Vulkan backend

HYBRIS

echo -e "\n  ${BOLD}${C}วิธีที่ 3 — Custom Build SVE2+i8mm (ทำแล้ว ✔)${NC}"
echo -e "  ${DIM}CPU-only แต่ใช้ ARM extensions เต็มที่ — Prompt Processing +161%${NC}"
cat << 'SVEBUILD'

    bash /storage/emulated/0/BOYSER/build/build_llamacpp.sh

    ผลที่ได้:
    - Prompt Processing : 73 t/s (Ollama: 28 t/s)  +161% ✔
    - Text Generation   : 14 t/s (Ollama: 12 t/s)  +15%  ✔

SVEBUILD

# ─── ผล benchmark ปัจจุบัน ────────────────────────────────────────────
section "CURRENT BENCHMARK RESULTS"

cat << 'RESULTS'

  ┌──────────────────────────────────────┬──────────┬──────────┐
  │ Test                                 │ Prompt   │ Generate │
  ├──────────────────────────────────────┼──────────┼──────────┤
  │ Ollama (pre-built)                   │  28 t/s  │  12 t/s  │
  │ Custom Build (SVE2+i8mm) ← ทำแล้ว   │  73 t/s  │  14 t/s  │
  │ Termux + OpenCL (Adreno)  ← เป้าหมาย│ ~150 t/s │ ~50 t/s  │
  │ GPU full (CUDA-class)     ← reference│ ~500 t/s │ ~150 t/s │
  └──────────────────────────────────────┴──────────┴──────────┘

RESULTS

echo -e "  ${G}คำแนะนำ: ลองวิธีที่ 1 (Termux) ก่อน — เร็วสุดและง่ายสุดครับ${NC}\n"
