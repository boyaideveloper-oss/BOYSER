# GPU Setup Guide

แสดงสถานะ GPU offload และแนะนำวิธีเปิดใช้ GPU สำหรับ AI inference

## ขั้นตอน

1. รัน GPU guide script:
```bash
bash /storage/emulated/0/BOYSER/scripts/gpu_bench_guide.sh
```

2. ตรวจสอบสถานะ GPU environment:
```bash
# ตรวจ Adreno GPU
ls -la /dev/kgsl-3d0 /dev/dri/renderD128

# ตรวจ Vulkan
vulkaninfo --summary 2>&1 | grep -E "deviceName|deviceType"

# ตรวจ Android libs
ls /proc/1/root/vendor/lib64/ | grep -iE "vulkan|openCL|adreno"
```

3. แนะนำวิธีที่เหมาะสมตามสถานการณ์:

### ถ้าอยู่ใน Linux chroot (สถานการณ์ปัจจุบัน)
- **วิธีแนะนำ**: ใช้ custom build SVE2+i8mm แทน GPU
- Prompt Processing เร็วขึ้น 161% (73 t/s vs 28 t/s)
```bash
bash /storage/emulated/0/BOYSER/build/build_llamacpp.sh
```

### ถ้าต้องการ GPU จริง — ย้ายไป Termux
```bash
# ใน Termux (Android side)
pkg install cmake git clang libopencl
git clone --depth=1 https://github.com/ggml-org/llama.cpp
cd llama.cpp
cmake -B build \
  -DGGML_OPENCL=ON \
  -DCMAKE_C_FLAGS="-march=armv9-a+sve2+i8mm+bf16 -O3" \
  -DCMAKE_CXX_FLAGS="-march=armv9-a+sve2+i8mm+bf16 -O3"
cmake --build build -j$(nproc)
# คาดหวัง: 40-80 t/s บน Adreno GPU
```

### ถ้าต้องการทำใน Linux chroot — libhybris
สร้าง bridge ระหว่าง Bionic libc ↔ glibc  
อ้างอิง: https://github.com/libhybris/libhybris

4. สรุปผลเป็นตาราง แสดงว่าแต่ละวิธีได้ผลลัพธ์อย่างไร และแนะนำวิธีที่เหมาะกับความต้องการของผู้ใช้
