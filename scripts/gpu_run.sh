#!/data/data/com.termux/files/usr/bin/bash
# รัน llama.cpp ด้วย Adreno GPU (OpenCL)
# รันสคริปต์นี้ใน Termux
#
# วิธีใช้:
#   bash ~/gpu_run.sh bench              — benchmark
#   bash ~/gpu_run.sh chat model.gguf   — interactive chat
#   bash ~/gpu_run.sh server model.gguf — HTTP server port 8080

LLAMA="$HOME/llama.cpp/build/bin"
OCL_LIB="/vendor/lib64/libOpenCL_adreno.so"
DEFAULT_MODEL="$HOME/models/llama3.2.gguf"
MODEL="${2:-$DEFAULT_MODEL}"
THREADS=$(nproc)
NGL=99   # layers to offload to GPU (99 = ทุก layer)

R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' W='\033[1;37m' NC='\033[0m' BOLD='\033[1m'

# ── ตรวจสอบ ───────────────────────────────────────────────────────────
[ -f "$OCL_LIB" ]         || { echo -e "${R}✘ ไม่พบ $OCL_LIB${NC}"; exit 1; }
[ -f "$LLAMA/llama-bench" ] || { echo -e "${R}✘ ยังไม่ได้ build — รัน build_llamacpp.sh ก่อน${NC}"; exit 1; }

GPU_CHECK=$(LD_PRELOAD="$OCL_LIB" "$LLAMA/llama-bench" --list-devices 2>&1 | grep "Adreno")
if [ -n "$GPU_CHECK" ]; then
  echo -e "${G}✔ GPU: $GPU_CHECK${NC}"
else
  echo -e "${Y}⚠ ไม่พบ Adreno GPU — รันแบบ CPU แทน${NC}"
  OCL_LIB=""
fi

# ── คำสั่ง ────────────────────────────────────────────────────────────
case "${1:-bench}" in

  bench)
    echo -e "\n${BOLD}${W}GPU Benchmark — Adreno 840 OpenCL${NC}\n"
    LD_PRELOAD="$OCL_LIB" "$LLAMA/llama-bench" \
      -m "$MODEL" \
      -p 512 -n 128 \
      -t "$THREADS" \
      -ngl "$NGL" \
      -o md 2>&1
    ;;

  chat)
    [ -f "$MODEL" ] || { echo -e "${R}✘ ไม่พบ model: $MODEL${NC}"; exit 1; }
    echo -e "\n${BOLD}${G}แชทกับ $(basename $MODEL) — GPU offload${NC}"
    echo -e "${Y}พิมพ์ /bye เพื่อออก${NC}\n"
    LD_PRELOAD="$OCL_LIB" "$LLAMA/llama-cli" \
      -m "$MODEL" \
      -t "$THREADS" \
      -ngl "$NGL" \
      -cnv 2>&1
    ;;

  server)
    [ -f "$MODEL" ] || { echo -e "${R}✘ ไม่พบ model: $MODEL${NC}"; exit 1; }
    echo -e "\n${BOLD}${G}llama-server — http://localhost:8080${NC}"
    echo -e "${Y}Ctrl+C เพื่อหยุด${NC}\n"
    LD_PRELOAD="$OCL_LIB" "$LLAMA/llama-server" \
      -m "$MODEL" \
      -t "$THREADS" \
      -ngl "$NGL" \
      --host 0.0.0.0 \
      --port 8080 2>&1
    ;;

  *)
    echo "วิธีใช้: $0 [bench|chat|server] [model.gguf]"
    exit 1
    ;;
esac
