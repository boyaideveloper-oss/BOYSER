#!/bin/bash

# ─────────────────────────────────────────────
#  COLORS
# ─────────────────────────────────────────────
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
C='\033[0;36m'
M='\033[0;35m'
W='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ─────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────
bar() {
  local val=$(( 10#${1:-0} )) max=$(( 10#${2:-1} )) width=${3:-30}
  local filled=$(( val * width / max ))
  [ $filled -gt $width ] && filled=$width
  [ $filled -lt 0 ] && filled=0
  local empty=$(( width - filled ))
  local color=$4
  printf "${color}"
  printf '█%.0s' $(seq 1 $filled) 2>/dev/null
  printf "${DIM}"
  printf '░%.0s' $(seq 1 $empty) 2>/dev/null
  printf "${NC}"
}

rating() {
  local val=$1 t1=$2 t2=$3 t3=$4
  if   [ "$val" -ge "$t3" ] 2>/dev/null; then echo -e "${G}EXCELLENT${NC}"
  elif [ "$val" -ge "$t2" ] 2>/dev/null; then echo -e "${Y}GOOD${NC}"
  elif [ "$val" -ge "$t1" ] 2>/dev/null; then echo -e "${C}AVERAGE${NC}"
  else echo -e "${R}WEAK${NC}"; fi
}

section() {
  echo -e "\n${B}╔══════════════════════════════════════════════════════╗${NC}"
  printf  "${B}║${NC}  ${BOLD}${C}%-52s${NC}  ${B}║${NC}\n" "$1"
  echo -e "${B}╚══════════════════════════════════════════════════════╝${NC}"
}

divider() {
  echo -e "${DIM}  ──────────────────────────────────────────────────────${NC}"
}

# ─────────────────────────────────────────────
#  HEADER
# ─────────────────────────────────────────────
clear
echo -e "${M}"
cat << 'EOF'
  ██████╗ ███████╗███╗   ██╗ ██████╗██╗  ██╗
  ██╔══██╗██╔════╝████╗  ██║██╔════╝██║  ██║
  ██████╔╝█████╗  ██╔██╗ ██║██║     ███████║
  ██╔══██╗██╔══╝  ██║╚██╗██║██║     ██╔══██║
  ██████╔╝███████╗██║ ╚████║╚██████╗██║  ██║
  ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝
EOF
echo -e "${NC}"
echo -e "  ${DIM}System Performance Benchmark  •  $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "  ${DIM}────────────────────────────────────────────────────${NC}"

# ─────────────────────────────────────────────
#  DEVICE INFO
# ─────────────────────────────────────────────
section "DEVICE INFO"
BRAND=$(getprop ro.product.brand 2>/dev/null)
MODEL=$(getprop ro.product.model 2>/dev/null)
CODENAME=$(getprop ro.product.device 2>/dev/null)
ANDROID=$(getprop ro.build.version.release 2>/dev/null)
CORES=$(nproc)
TOTAL_RAM=$(free -m | awk '/Mem:/{print $2}')
TOTAL_DISK=$(df -h / | awk 'NR==2{print $2}')
KERNEL=$(uname -r)

printf "  ${W}%-18s${NC} ${Y}%s %s${NC} ${DIM}(%s)${NC}\n" "Device"    "$BRAND" "$MODEL" "$CODENAME"
printf "  ${W}%-18s${NC} ${C}Android %s${NC}\n"             "Android"   "$ANDROID"
printf "  ${W}%-18s${NC} ${C}%s${NC}\n"                     "Kernel"    "$KERNEL"
printf "  ${W}%-18s${NC} ${C}%s cores${NC}\n"               "CPU Cores" "$CORES"
printf "  ${W}%-18s${NC} ${C}%s MB${NC}\n"                  "Total RAM" "$TOTAL_RAM"
printf "  ${W}%-18s${NC} ${C}%s${NC}\n"                     "Storage"   "$TOTAL_DISK"

# ─────────────────────────────────────────────
#  CPU SINGLE THREAD
# ─────────────────────────────────────────────
section "CPU BENCHMARK"
echo -e "  ${DIM}Running Single-thread test...${NC}"
ST_RAW=$(sysbench cpu --cpu-max-prime=20000 --threads=1 --time=10 run 2>&1)
ST_EPS=$(echo "$ST_RAW" | grep "events per second" | awk '{printf "%.0f", $NF}')
ST_AVG=$(echo "$ST_RAW" | grep "avg:" | awk '{print $2}')

echo -e "\n  ${W}Single-Thread${NC}"
printf  "  Score : ${Y}%s${NC} events/sec\n" "$ST_EPS"
printf  "  Avg   : ${C}%s ms${NC}\n" "$ST_AVG"
printf  "  Load  : "
bar $ST_EPS 5000 35 "${Y}"
echo -e "  $(rating $ST_EPS 2000 3000 4000)"

divider

echo -e "  ${DIM}Running Multi-thread test (${CORES} cores)...${NC}"
MT_RAW=$(sysbench cpu --cpu-max-prime=20000 --threads=$CORES --time=10 run 2>&1)
MT_EPS=$(echo "$MT_RAW" | grep "events per second" | awk '{printf "%.0f", $NF}')
MT_AVG=$(echo "$MT_RAW" | grep "avg:" | awk '{print $2}')
EFFICIENCY=$(echo "$ST_EPS $MT_EPS $CORES" | awk '{printf "%.0f", ($2/$1/$3)*100}')

echo -e "\n  ${W}Multi-Thread (${CORES} cores)${NC}"
printf  "  Score : ${Y}%s${NC} events/sec\n" "$MT_EPS"
printf  "  Avg   : ${C}%s ms${NC}\n" "$MT_AVG"
printf  "  Load  : "
bar $MT_EPS 40000 35 "${G}"
echo -e "  $(rating $MT_EPS 10000 18000 25000)"
printf  "  ${DIM}Multi-core efficiency: %s%%${NC}\n" "$EFFICIENCY"

# ─────────────────────────────────────────────
#  RAM
# ─────────────────────────────────────────────
section "MEMORY BENCHMARK"
echo -e "  ${DIM}Running RAM Read test...${NC}"
MR_RAW=$(sysbench memory --memory-block-size=1M --memory-total-size=10G --memory-oper=read --threads=1 run 2>&1)
MR_MBS=$(echo "$MR_RAW" | grep "transferred" | grep -oP '\([0-9.]+' | tr -d '(' | head -1)

echo -e "  ${DIM}Running RAM Write test...${NC}"
MW_RAW=$(sysbench memory --memory-block-size=1M --memory-total-size=10G --memory-oper=write --threads=1 run 2>&1)
MW_MBS=$(echo "$MW_RAW" | grep "transferred" | grep -oP '\([0-9.]+' | tr -d '(' | head -1)

MR_GBS=$(echo "$MR_MBS" | awk '{printf "%.1f", $1/1024}')
MW_GBS=$(echo "$MW_MBS" | awk '{printf "%.1f", $1/1024}')
MR_INT=$(echo "$MR_GBS" | awk '{printf "%.0f", $1}')
MW_INT=$(echo "$MW_GBS" | awk '{printf "%.0f", $1}')

printf "\n  ${W}%-20s${NC} ${Y}%s GB/s${NC}\n" "Sequential Read" "$MR_GBS"
printf  "  Load  : "
bar $MR_INT 35 35 "${Y}"
echo -e "  $(rating $MR_INT 10 20 28)"

printf "\n  ${W}%-20s${NC} ${Y}%s GB/s${NC}\n" "Sequential Write" "$MW_GBS"
printf  "  Load  : "
bar $MW_INT 35 35 "${C}"
echo -e "  $(rating $MW_INT 8 15 18)"

# ─────────────────────────────────────────────
#  DISK
# ─────────────────────────────────────────────
section "STORAGE BENCHMARK"
echo -e "  ${DIM}Running Disk Write test (2GB)...${NC}"
DW_RAW=$(dd if=/dev/zero of=/tmp/_bench_disk bs=1M count=2048 conv=fdatasync 2>&1)
DW_SPEED=$(echo "$DW_RAW" | grep -oP '[0-9.]+ [GM]B/s' | tail -1)
DW_VAL=$(echo "$DW_SPEED" | awk '{if ($2=="GB/s") printf "%.2f", $1; else printf "%.2f", $1/1000}')
DW_INT=$(echo "$DW_VAL" | awk '{printf "%.0f", $1*10}')

echo -e "  ${DIM}Running Disk Read test (2GB)...${NC}"
DR_RAW=$(dd if=/tmp/_bench_disk of=/dev/null bs=1M 2>&1)
DR_SPEED=$(echo "$DR_RAW" | grep -oP '[0-9.]+ [GM]B/s' | tail -1)
DR_VAL=$(echo "$DR_SPEED" | awk '{if ($2=="GB/s") printf "%.2f", $1; else printf "%.2f", $1/1000}')
DR_INT=$(echo "$DR_VAL" | awk '{printf "%.0f", $1*10}')
rm -f /tmp/_bench_disk

printf "\n  ${W}%-20s${NC} ${Y}%s${NC}\n" "Write Speed" "$DW_SPEED"
printf  "  Load  : "
bar ${DW_INT:-1} 60 35 "${Y}"
echo -e "  $(rating ${DW_INT:-1} 10 20 30)"

printf "\n  ${W}%-20s${NC} ${Y}%s${NC}\n" "Read Speed" "$DR_SPEED"
printf  "  Load  : "
bar ${DR_INT:-1} 60 35 "${G}"
echo -e "  $(rating ${DR_INT:-1} 10 30 50)"

# ─────────────────────────────────────────────
#  CRYPTO
# ─────────────────────────────────────────────
section "CRYPTO BENCHMARK"
echo -e "  ${DIM}Running AES-256-CBC test...${NC}"
AES_RAW=$(openssl speed -elapsed aes-256-cbc 2>&1)
AES_8K=$(echo "$AES_RAW" | grep "^aes-256-cbc" | awk '{v=$NF; gsub(/k/,"",v); printf "%d", v/1024}')

printf "\n  ${W}%-20s${NC} ${Y}%s MB/s${NC}\n" "AES-256-CBC (8KB)" "$AES_8K"
printf  "  Load  : "
bar $AES_8K 1200 35 "${M}"
echo -e "  $(rating $AES_8K 400 600 800)"

# ─────────────────────────────────────────────
#  SUMMARY SCORE
# ─────────────────────────────────────────────
section "OVERALL SCORE"

CPU_SCORE=$(echo "$MT_EPS" | awk '{printf "%.0f", $1/23175*1000}')
RAM_SCORE=$(echo "$MR_INT" | awk '{printf "%.0f", $1/29*1000}')
DISK_SCORE=$(echo "${DW_VAL:-0.1}" | awk '{printf "%.0f", $1/6*1000}')
CRYPTO_SCORE=$(echo "$AES_8K" | awk '{printf "%.0f", $1/836*1000}')
TOTAL=$(echo "$CPU_SCORE $RAM_SCORE $DISK_SCORE $CRYPTO_SCORE" | awk '{printf "%.0f", ($1+$2+$3+$4)/4}')

printf "\n  ${W}%-18s${NC} " "CPU"
bar $CPU_SCORE 1000 30 "${G}"
printf " ${Y}%s/1000${NC}\n" "$CPU_SCORE"

printf "  ${W}%-18s${NC} " "RAM"
bar $RAM_SCORE 1000 30 "${C}"
printf " ${Y}%s/1000${NC}\n" "$RAM_SCORE"

printf "  ${W}%-18s${NC} " "DISK"
bar $DISK_SCORE 1000 30 "${M}"
printf " ${Y}%s/1000${NC}\n" "$DISK_SCORE"

printf "  ${W}%-18s${NC} " "CRYPTO"
bar $CRYPTO_SCORE 1000 30 "${B}"
printf " ${Y}%s/1000${NC}\n" "$CRYPTO_SCORE"

divider

printf "\n  ${BOLD}${W}%-18s${NC} " "TOTAL SCORE"
if   [ "$TOTAL" -ge 900 ]; then COLOR="${G}"
elif [ "$TOTAL" -ge 700 ]; then COLOR="${Y}"
elif [ "$TOTAL" -ge 500 ]; then COLOR="${C}"
else COLOR="${R}"; fi
bar $TOTAL 1000 30 "$COLOR"
printf " ${BOLD}${COLOR}%s / 1000${NC}\n" "$TOTAL"

if   [ "$TOTAL" -ge 900 ]; then GRADE="S"  ; LABEL="FLAGSHIP TIER"
elif [ "$TOTAL" -ge 750 ]; then GRADE="A+" ; LABEL="HIGH-END"
elif [ "$TOTAL" -ge 600 ]; then GRADE="A"  ; LABEL="ABOVE AVERAGE"
elif [ "$TOTAL" -ge 450 ]; then GRADE="B"  ; LABEL="AVERAGE"
else                             GRADE="C"  ; LABEL="BELOW AVERAGE"; fi

echo -e "\n  ${BOLD}${COLOR}  ★  Grade: ${GRADE}  —  ${LABEL}  ★${NC}\n"
echo -e "  ${DIM}Baseline: Xiaomi (nezha) reference run — 2026-05-24${NC}"
echo -e "${DIM}  ──────────────────────────────────────────────────────${NC}\n"

# ─────────────────────────────────────────────
#  SAVE RESULT
# ─────────────────────────────────────────────
SAVE_DIR="/storage/emulated/0/BOYSER/benchmark_results"
mkdir -p "$SAVE_DIR"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
OUTFILE="$SAVE_DIR/result_${TIMESTAMP}.txt"

cat > "$OUTFILE" << RESULT
═══════════════════════════════════════════════════
  BENCHMARK RESULT — ${TIMESTAMP}
═══════════════════════════════════════════════════

  Device  : ${BRAND} ${MODEL} (${CODENAME})
  Android : ${ANDROID}
  Kernel  : ${KERNEL}
  Cores   : ${CORES} cores
  RAM     : ${TOTAL_RAM} MB
  Storage : ${TOTAL_DISK}

───────────────────────────────────────────────────
  CPU
───────────────────────────────────────────────────
  Single-Thread   : ${ST_EPS} events/sec  (avg ${ST_AVG} ms)
  Multi-Thread    : ${MT_EPS} events/sec  (avg ${MT_AVG} ms)
  Efficiency      : ${EFFICIENCY}%

───────────────────────────────────────────────────
  MEMORY
───────────────────────────────────────────────────
  Read            : ${MR_GBS} GB/s
  Write           : ${MW_GBS} GB/s

───────────────────────────────────────────────────
  STORAGE
───────────────────────────────────────────────────
  Write           : ${DW_SPEED}
  Read            : ${DR_SPEED}

───────────────────────────────────────────────────
  CRYPTO
───────────────────────────────────────────────────
  AES-256-CBC     : ${AES_8K} MB/s

───────────────────────────────────────────────────
  SCORE
───────────────────────────────────────────────────
  CPU             : ${CPU_SCORE} / 1000
  RAM             : ${RAM_SCORE} / 1000
  DISK            : ${DISK_SCORE} / 1000
  CRYPTO          : ${CRYPTO_SCORE} / 1000

  TOTAL           : ${TOTAL} / 1000
  GRADE           : ${GRADE}  —  ${LABEL}

═══════════════════════════════════════════════════
RESULT

echo -e "  ${G}✔ บันทึกผลแล้วที่:${NC}"
echo -e "  ${W}${OUTFILE}${NC}\n"
