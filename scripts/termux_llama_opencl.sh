#!/data/data/com.termux/files/usr/bin/bash
# ติดตั้ง llama.cpp + OpenCL บน Termux (Adreno GPU)
# รันสคริปต์นี้ใน Termux app ตรงๆ (ไม่ใช่ root)
#
# วิธีใช้:
#   bash /storage/emulated/0/BOYSER/scripts/termux_llama_opencl.sh

set -e

R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' W='\033[1;37m'
BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

log()  { echo -e "  ${G}▶${NC} $1"; }
warn() { echo -e "  ${Y}⚠${NC} $1"; }
err()  { echo -e "  ${R}✘${NC} $1"; exit 1; }
ok()   { echo -e "  ${G}✔${NC} $1"; }

echo -e "\n${BOLD}${W}  llama.cpp + Adreno OpenCL — Termux Build${NC}"
echo -e "${DIM}  ────────────────────────────────────────────────────${NC}\n"

# ตรวจสอบว่ารันใน Termux
[ -d "$PREFIX" ] || err "สคริปต์นี้ต้องรันใน Termux เท่านั้น"
echo -e "  ${G}✔${NC} Termux environment: $PREFIX"

# ─── 1. ติดตั้ง dependencies ────────────────────────────────────────────
log "อัพเดต package list..."
pkg update -y 2>&1 | tail -3

log "ติดตั้ง build tools..."
pkg install -y cmake git clang ninja opencl-headers 2>&1 | tail -10
ok "Build tools พร้อม"

# ตรวจหา OpenCL library จาก Android vendor
log "ค้นหา OpenCL library..."
OPENCL_LIB=""
for path in \
  /vendor/lib64/libOpenCL.so \
  /system/lib64/libOpenCL.so \
  /vendor/lib64/egl/libOpenCL.so \
  /system/vendor/lib64/libOpenCL.so; do
  if [ -f "$path" ]; then
    OPENCL_LIB="$path"
    ok "พบ OpenCL: $path"
    break
  fi
done

if [ -z "$OPENCL_LIB" ]; then
  warn "ไม่พบ OpenCL library — ลอง CLBlast fallback"
  pkg install -y clblast 2>/dev/null || true
fi

# ─── 2. Clone llama.cpp ─────────────────────────────────────────────────
LLAMA_DIR="$HOME/llama.cpp"
if [ -d "$LLAMA_DIR/.git" ]; then
  log "Update llama.cpp..."
  git -C "$LLAMA_DIR" pull --depth=1 2>&1 | tail -3
else
  log "Clone llama.cpp..."
  git clone --depth=1 https://github.com/ggml-org/llama.cpp "$LLAMA_DIR"
fi
ok "llama.cpp พร้อม"

# ─── 3. Build ────────────────────────────────────────────────────────────
log "Configure cmake (OpenCL + SVE2 + i8mm)..."

CMAKE_EXTRA=""
if [ -n "$OPENCL_LIB" ]; then
  OPENCL_DIR=$(dirname "$OPENCL_LIB")
  CMAKE_EXTRA="-DGGML_OPENCL=ON -DOpenCL_LIBRARY=$OPENCL_LIB -DOpenCL_INCLUDE_DIR=$PREFIX/include"
  log "ใช้ OpenCL: $OPENCL_LIB"
else
  warn "Build CPU-only พร้อม ARM optimizations"
fi

cmake -B "$LLAMA_DIR/build" -S "$LLAMA_DIR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="-march=armv9-a+sve2+sve2-aes+i8mm+bf16 -O3 -funroll-loops" \
  -DCMAKE_CXX_FLAGS="-march=armv9-a+sve2+sve2-aes+i8mm+bf16 -O3 -funroll-loops" \
  -DGGML_NATIVE=ON \
  -DGGML_OPENMP=ON \
  -DGGML_SVE=ON \
  -DLLAMA_BUILD_TESTS=OFF \
  -DLLAMA_BUILD_EXAMPLES=ON \
  $CMAKE_EXTRA \
  -GNinja 2>&1 | grep -E "HAVE_|OPENCL|error|done"

log "Building ($(nproc) threads)... ~10 นาที"
ninja -C "$LLAMA_DIR/build" -j$(nproc) 2>&1 | grep -E "^\[.*%\]" | tail -5

ok "Build สำเร็จ!"

# ─── 4. ดาวน์โหลด model ─────────────────────────────────────────────────
MODEL_DIR="$HOME/models"
mkdir -p "$MODEL_DIR"

# เช็คว่ามี model จาก Ollama แล้วไหม
OLLAMA_MODEL="/storage/emulated/0/.ollama/models/blobs"
EXISTING_MODEL=$(find $OLLAMA_MODEL 2>/dev/null -size +500M | head -1)

if [ -n "$EXISTING_MODEL" ]; then
  ok "พบ model จาก Ollama: $EXISTING_MODEL"
  MODEL_PATH="$EXISTING_MODEL"
elif [ -f "/storage/emulated/0/BOYSER/models/llama3.2.gguf" ]; then
  MODEL_PATH="/storage/emulated/0/BOYSER/models/llama3.2.gguf"
  ok "พบ model: $MODEL_PATH"
else
  warn "ไม่พบ model — ดาวน์โหลด Llama 3.2 3B..."
  mkdir -p "$MODEL_DIR"
  # ใช้ huggingface hub ถ้ามี
  if command -v huggingface-cli &>/dev/null; then
    huggingface-cli download \
      bartowski/Llama-3.2-3B-Instruct-GGUF \
      Llama-3.2-3B-Instruct-Q4_K_M.gguf \
      --local-dir "$MODEL_DIR"
    MODEL_PATH="$MODEL_DIR/Llama-3.2-3B-Instruct-Q4_K_M.gguf"
  else
    warn "ดาวน์โหลดเองด้วย:"
    echo ""
    echo "  curl -L -o $MODEL_DIR/llama3.2.gguf \\"
    echo "    https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf"
    echo ""
    MODEL_PATH="$MODEL_DIR/llama3.2.gguf"
  fi
fi

# ─── 5. Benchmark ────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${W}  ════ BENCHMARK RESULTS ════${NC}"
echo ""

if [ -f "$MODEL_PATH" ]; then
  log "รัน llama-bench..."
  LD_PRELOAD=/vendor/lib64/libOpenCL_adreno.so \
  "$LLAMA_DIR/build/bin/llama-bench" \
    -m "$MODEL_PATH" \
    -p 512 -n 128 \
    -ngl 99 \
    -t $(nproc) \
    -o md 2>&1
else
  warn "ยังไม่มี model — ใช้ path: $MODEL_PATH"
  echo ""
  echo -e "  รัน benchmark ด้วยตัวเอง:"
  echo -e "  ${Y}LD_PRELOAD=/vendor/lib64/libOpenCL_adreno.so $LLAMA_DIR/build/bin/llama-bench -m [model.gguf] -p 512 -n 128 -ngl 99 -t \$(nproc) -o md${NC}"
fi

echo ""
echo -e "${BOLD}${G}  ════ DONE ════${NC}"
echo ""
echo -e "  Binaries:"
echo -e "  ${Y}$LLAMA_DIR/build/bin/llama-bench${NC}"
echo -e "  ${Y}$LLAMA_DIR/build/bin/llama-cli${NC}"
echo -e "  ${Y}$LLAMA_DIR/build/bin/llama-server${NC}"
echo ""
echo -e "  วิธีแชทกับ model:"
echo -e "  ${Y}$LLAMA_DIR/build/bin/llama-cli -m [model.gguf] -cnv${NC}"
echo ""
