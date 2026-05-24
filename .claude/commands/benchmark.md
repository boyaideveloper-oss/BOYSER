# System Benchmark

รัน system benchmark สำหรับเครื่องนี้ แล้วสรุปผลเป็นภาษาไทย

## ขั้นตอน

1. รันสคริปต์:
```bash
bash /storage/emulated/0/BOYSER/benchmark.sh
```

2. อ่านผลที่ได้ แล้วสรุปเป็นตารางภาษาไทย ประกอบด้วย:
   - คะแนนแต่ละหมวด (CPU / RAM / Disk / Crypto)
   - คะแนนรวมและ Grade
   - เปรียบเทียบกับผลรันครั้งก่อนถ้ามีใน `benchmark_results/`
   - บอกจุดเด่นและจุดด้อยของเครื่อง

3. ถ้า sysbench ยังไม่ได้ติดตั้ง ให้ติดตั้งก่อน:
```bash
apt-get install -y sysbench
```
