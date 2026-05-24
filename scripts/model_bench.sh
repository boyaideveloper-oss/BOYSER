#!/bin/bash
# Model Inference Benchmark — llama.cpp / Ollama
# ใช้กับ Ollama API ที่ localhost:11434

R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' B='\033[0;34m'
C='\033[0;36m' M='\033[0;35m' W='\033[1;37m' DIM='\033[2m' BOLD='\033[1m' NC='\033[0m'

MODEL="${1:-llama3.2}"
API="http://localhost:11434/api/generate"
THREADS=$(nproc)

section() {
  echo -e "\n${B}╔══════════════════════════════════════════════════════╗${NC}"
  printf  "${B}║${NC}  ${BOLD}${C}%-52s${NC}  ${B}║${NC}\n" "$1"
  echo -e "${B}╚══════════════════════════════════════════════════════╝${NC}"
}
divider() { echo -e "${DIM}  ──────────────────────────────────────────────────────${NC}"; }

run_test() {
  local label="$1" prompt="$2"
  printf "\n  ${W}%s${NC}\n" "$label"
  local START=$(date +%s%N)
  local RESP=$(curl -s -X POST "$API" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"$prompt\",\"stream\":false}" 2>&1)
  local END=$(date +%s%N)
  local ELAPSED_MS=$(( (END - START) / 1000000 ))
  local ELAPSED_S=$(echo "$ELAPSED_MS" | awk '{printf "%.2f", $1/1000}')
  local EVAL_COUNT=$(echo "$RESP"  | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('eval_count',0))" 2>/dev/null)
  local PROMPT_EVAL=$(echo "$RESP" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('prompt_eval_count',0))" 2>/dev/null)
  local EVAL_DUR=$(echo "$RESP"    | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('eval_duration',1))" 2>/dev/null)
  local PROMPT_DUR=$(echo "$RESP"  | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('prompt_eval_duration',1))" 2>/dev/null)
  local LOAD_DUR=$(echo "$RESP"    | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('load_duration',0))" 2>/dev/null)
  local TPS=$(echo "$EVAL_COUNT $EVAL_DUR"      | awk '{if($2>0) printf "%.1f",$1/($2/1e9); else print "0"}')
  local PPS=$(echo "$PROMPT_EVAL $PROMPT_DUR"   | awk '{if($2>0) printf "%.1f",$1/($2/1e9); else print "0"}')
  local LOAD_MS=$(echo "$LOAD_DUR" | awk '{printf "%.0f",$1/1e6}')
  printf  "  ${DIM}Prompt / Output : ${NC}${C}%s${NC} / ${C}%s${NC} tokens\n" "$PROMPT_EVAL" "$EVAL_COUNT"
  printf  "  ${DIM}Prompt speed    : ${NC}${Y}%s t/s${NC}\n" "$PPS"
  printf  "  ${DIM}Generate speed  : ${NC}${Y}%s t/s${NC}\n" "$TPS"
  printf  "  ${DIM}Load time       : ${NC}${C}%s ms${NC}   Total: ${Y}%s s${NC}\n" "$LOAD_MS" "$ELAPSED_S"
  echo "$TPS"
}

clear
echo -e "${M}"
cat << 'LOGO'
  ███╗   ███╗ ██████╗ ██████╗ ███████╗██╗
  ████╗ ████║██╔═══██╗██╔══██╗██╔════╝██║
  ██╔████╔██║██║   ██║██║  ██║█████╗  ██║
  ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  ██║
  ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗███████╗
  ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
  BENCHMARK
LOGO
echo -e "${NC}"
echo -e "  ${DIM}Model: ${W}${MODEL}${NC}  •  Threads: ${W}${THREADS}${NC}  •  $(date '+%Y-%m-%d %H:%M:%S')${NC}"
divider

# ตรวจสอบ Ollama
if ! curl -s --max-time 3 "$API" > /dev/null 2>&1; then
  echo -e "\n  ${R}✘ Ollama ไม่ได้รัน — เริ่มด้วย: ollama serve${NC}\n"
  exit 1
fi

# ตรวจสอบ model
if ! ollama list 2>/dev/null | grep -q "$MODEL"; then
  echo -e "\n  ${Y}⚠ ไม่พบ model '$MODEL' — กำลัง pull...${NC}"
  ollama pull "$MODEL"
fi

section "TEST 1 — SHORT PROMPT"
T1=$(run_test "ถามสั้น" "What is 2+2? Answer in one word.")
divider

section "TEST 2 — MEDIUM PROMPT"
T2=$(run_test "ถามกลาง" "Explain what is RAM memory in 3 sentences.")
divider

section "TEST 3 — LONG GENERATION"
T3=$(run_test "สร้าง Long text" "Write a short story about a robot in 100 words.")
divider

section "TEST 4 — THAI LANGUAGE"
T4=$(run_test "ภาษาไทย" "อธิบายว่า RAM คืออะไร ใน 2 ประโยค")
divider

section "SUMMARY"
AVG=$(echo "$T1 $T2 $T3 $T4" | awk '{s=0;n=0;for(i=1;i<=NF;i++){if($i+0>0){s+=$i;n++}};if(n>0)printf "%.1f",s/n;else print "0"}')

printf "\n  ${W}%-22s${NC} ${Y}%s t/s${NC}\n" "Test 1 (short)"   "$T1"
printf  "  ${W}%-22s${NC} ${Y}%s t/s${NC}\n" "Test 2 (medium)"  "$T2"
printf  "  ${W}%-22s${NC} ${Y}%s t/s${NC}\n" "Test 3 (long)"    "$T3"
printf  "  ${W}%-22s${NC} ${Y}%s t/s${NC}\n" "Test 4 (thai)"    "$T4"
divider
printf  "\n  ${BOLD}${W}Average Speed   : ${G}%s tokens/sec${NC}\n" "$AVG"

AVG_INT=$(echo "$AVG" | awk '{printf "%d", $1}')
if   [ "$AVG_INT" -ge 30 ]; then GRADE="S";  LABEL="BLAZING FAST"
elif [ "$AVG_INT" -ge 20 ]; then GRADE="A+"; LABEL="FAST"
elif [ "$AVG_INT" -ge 12 ]; then GRADE="A";  LABEL="GOOD"
elif [ "$AVG_INT" -ge 7  ]; then GRADE="B";  LABEL="AVERAGE"
else                              GRADE="C";  LABEL="SLOW"; fi

echo -e "\n  ${BOLD}${G}  ★  Grade: ${GRADE}  —  ${LABEL}  ★${NC}\n"
echo -e "${DIM}  ──────────────────────────────────────────────────────${NC}\n"
