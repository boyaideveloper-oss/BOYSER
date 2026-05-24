# Model Benchmark

รัน inference benchmark สำหรับ AI model และสรุปผลเป็นภาษาไทย

## ขั้นตอน

1. ตรวจสอบและเริ่ม Ollama:
```bash
curl -s http://localhost:11434/ || ollama serve &
sleep 3
```

2. รัน benchmark script:
```bash
bash /storage/emulated/0/BOYSER/scripts/model_bench.sh [model-name]
```
- ถ้าไม่ระบุ model ใช้ `llama3.2` เป็น default
- model อื่นที่รองรับ: `qwen2.5:7b`, `gemma2:2b`, `phi3.5`

3. สรุปผลเป็นตาราง:
   - Prompt Processing speed (t/s)
   - Text Generation speed (t/s)
   - เปรียบเทียบกับ Ollama pre-built baseline (28 t/s prompt / 12 t/s generate)
   - บอก Grade และ rating

4. ถ้ายังไม่ได้ build custom llama.cpp ให้แนะนำ:
```bash
bash /storage/emulated/0/BOYSER/build/build_llamacpp.sh
```
แล้วรัน llama-bench เปรียบเทียบด้วย:
```bash
/root/llama.cpp/build/bin/llama-bench -m [model-path] -p 512 -n 128 -t 8 -o md
```
