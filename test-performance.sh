#!/usr/bin/env bash
#
# Performance Test Suite for Dotfiles
# Measures shell startup time, command response times, and resource usage
#
set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}Performance Test Suite${NC}"
echo "======================"
echo "Testing shell and tool performance..."

# Helper function to measure command time
measure_time() {
    local cmd="$1"
    local iterations="${2:-5}"
    local total=0
    
    for i in $(seq 1 "$iterations"); do
        local start=$(date +%s.%N)
        eval "$cmd" >/dev/null 2>&1
        local end=$(date +%s.%N)
        local time=$(echo "$end - $start" | bc)
        total=$(echo "$total + $time" | bc)
    done
    
    echo "scale=3; $total / $iterations" | bc
}

# Test 1: Shell Startup Time
echo -e "\n${YELLOW}Shell Startup Performance:${NC}"

# Measure zsh startup
if command -v zsh >/dev/null 2>&1; then
    echo "Measuring zsh startup time (5 iterations)..."
    ZSH_TIME=$(measure_time "zsh -i -c exit" 5)
    
    if (( $(echo "$ZSH_TIME < 0.3" | bc -l) )); then
        echo -e "${GREEN}✓${NC} Zsh startup: ${ZSH_TIME}s (excellent)"
    elif (( $(echo "$ZSH_TIME < 0.5" | bc -l) )); then
        echo -e "${GREEN}✓${NC} Zsh startup: ${ZSH_TIME}s (good)"
    elif (( $(echo "$ZSH_TIME < 1.0" | bc -l) )); then
        echo -e "${YELLOW}⚠${NC} Zsh startup: ${ZSH_TIME}s (could be improved)"
    else
        echo -e "${RED}✗${NC} Zsh startup: ${ZSH_TIME}s (too slow)"
    fi
    
    # Test minimal startup (no config)
    echo "Testing minimal zsh startup..."
    MINIMAL_TIME=$(measure_time "zsh -f -c exit" 5)
    echo -e "${CYAN}ℹ${NC} Minimal zsh: ${MINIMAL_TIME}s"
    
    # Calculate overhead
    OVERHEAD=$(echo "$ZSH_TIME - $MINIMAL_TIME" | bc)
    echo -e "${CYAN}ℹ${NC} Config overhead: ${OVERHEAD}s"
else
    echo -e "${RED}✗${NC} zsh not found"
fi

# Test 2: Command Response Times
echo -e "\n${YELLOW}Command Response Times:${NC}"

# Test common commands
COMMANDS=(
    "ls -la"
    "git status"
    "which zsh"
    "echo test"
)

for cmd in "${COMMANDS[@]}"; do
    if command -v "${cmd%% *}" >/dev/null 2>&1; then
        TIME=$(measure_time "$cmd" 3)
        if (( $(echo "$TIME < 0.1" | bc -l) )); then
            echo -e "${GREEN}✓${NC} '$cmd': ${TIME}s"
        else
            echo -e "${YELLOW}⚠${NC} '$cmd': ${TIME}s"
        fi
    else
        echo -e "  Skipping '$cmd' (command not found)"
    fi
done

# Test 3: Modern Tool Performance
echo -e "\n${YELLOW}Modern Tool Performance:${NC}"

# Test ripgrep vs grep
if command -v rg >/dev/null 2>&1 && command -v grep >/dev/null 2>&1; then
    echo "Comparing ripgrep vs grep performance..."
    
    # Create test file if it doesn't exist
    TEST_FILE="/tmp/perf_test_file.txt"
    if [[ ! -f "$TEST_FILE" ]]; then
        for i in {1..1000}; do
            echo "This is line $i of the test file for performance testing" >> "$TEST_FILE"
        done
    fi
    
    RG_TIME=$(measure_time "rg 'test' '$TEST_FILE'" 3)
    GREP_TIME=$(measure_time "grep 'test' '$TEST_FILE'" 3)
    
    echo -e "${CYAN}ℹ${NC} ripgrep: ${RG_TIME}s"
    echo -e "${CYAN}ℹ${NC} grep: ${GREP_TIME}s"
    
    # Calculate speedup
    if (( $(echo "$GREP_TIME > 0" | bc -l) )); then
        SPEEDUP=$(echo "scale=2; $GREP_TIME / $RG_TIME" | bc)
        echo -e "${GREEN}✓${NC} ripgrep is ${SPEEDUP}x faster"
    fi
    
    rm -f "$TEST_FILE"
fi

# Test fd vs find
if command -v fd >/dev/null 2>&1 && command -v find >/dev/null 2>&1; then
    echo -e "\nComparing fd vs find performance..."
    
    FD_TIME=$(measure_time "fd . /tmp --max-depth 2" 3)
    FIND_TIME=$(measure_time "find /tmp -maxdepth 2" 3)
    
    echo -e "${CYAN}ℹ${NC} fd: ${FD_TIME}s"
    echo -e "${CYAN}ℹ${NC} find: ${FIND_TIME}s"
fi

# Test 4: Cache Performance
echo -e "\n${YELLOW}Cache Performance:${NC}"

# Test zsh completion cache
if [[ -d "$HOME/.zcompdump" ]] || [[ -f "$HOME/.zcompdump"* ]]; then
    CACHE_SIZE=$(du -sh "$HOME/.zcompdump"* 2>/dev/null | cut -f1 | head -1)
    echo -e "${GREEN}✓${NC} Zsh completion cache exists: $CACHE_SIZE"
else
    echo -e "${YELLOW}⚠${NC} No zsh completion cache found"
fi

# Test sccache if available
if command -v sccache >/dev/null 2>&1; then
    echo -e "\nTesting sccache performance..."
    if sccache --show-stats >/dev/null 2>&1; then
        STATS=$(sccache --show-stats 2>/dev/null | grep -E "Hits|Misses" | head -2)
        if [[ -n "$STATS" ]]; then
            echo -e "${GREEN}✓${NC} sccache is active"
            echo "$STATS" | sed 's/^/  /'
        else
            echo -e "${YELLOW}⚠${NC} sccache installed but no stats available"
        fi
    else
        echo -e "${YELLOW}⚠${NC} sccache not running"
    fi
fi

# Test 5: Resource Usage
echo -e "\n${YELLOW}Resource Usage:${NC}"

# Check shell memory usage
if command -v ps >/dev/null 2>&1; then
    # Start a new shell and check its memory
    zsh -c "sleep 0.5" &
    ZSH_PID=$!
    sleep 0.6
    
    if ps -p $ZSH_PID >/dev/null 2>&1; then
        MEM_INFO=$(ps -o pid,vsz,rss,comm -p $ZSH_PID | tail -1)
        VSZ=$(echo "$MEM_INFO" | awk '{print $2}')
        RSS=$(echo "$MEM_INFO" | awk '{print $3}')
        
        # Convert to MB
        VSZ_MB=$((VSZ / 1024))
        RSS_MB=$((RSS / 1024))
        
        echo -e "${CYAN}ℹ${NC} Zsh memory usage:"
        echo "  Virtual: ${VSZ_MB}MB"
        echo "  Resident: ${RSS_MB}MB"
        
        if [[ $RSS_MB -lt 50 ]]; then
            echo -e "${GREEN}✓${NC} Memory usage is reasonable"
        else
            echo -e "${YELLOW}⚠${NC} High memory usage detected"
        fi
        
        kill $ZSH_PID 2>/dev/null || true
    fi
fi

# Test 6: Plugin Performance
echo -e "\n${YELLOW}Plugin Performance:${NC}"

# Check Oh My Zsh plugins
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    PLUGIN_COUNT=$(grep -c "^plugins=" "$HOME/.zshrc" 2>/dev/null || echo "0")
    if [[ -f "$HOME/.zshrc" ]]; then
        PLUGINS=$(grep "^plugins=" "$HOME/.zshrc" | sed 's/plugins=(//' | sed 's/)//' | tr ' ' '\n' | wc -l)
        echo -e "${CYAN}ℹ${NC} Oh My Zsh plugins loaded: $PLUGINS"
        
        if [[ $PLUGINS -lt 10 ]]; then
            echo -e "${GREEN}✓${NC} Reasonable number of plugins"
        elif [[ $PLUGINS -lt 20 ]]; then
            echo -e "${YELLOW}⚠${NC} Many plugins loaded (may affect startup time)"
        else
            echo -e "${RED}✗${NC} Too many plugins (will slow startup)"
        fi
    fi
fi

# Summary
echo -e "\n${BLUE}Performance Test Summary:${NC}"
echo "========================"

# Calculate overall performance score
SCORE=0
TOTAL=0

# Shell startup score
if [[ -n "${ZSH_TIME:-}" ]]; then
    TOTAL=$((TOTAL + 1))
    if (( $(echo "$ZSH_TIME < 0.5" | bc -l) )); then
        SCORE=$((SCORE + 1))
        echo -e "${GREEN}✓${NC} Shell startup: Passed"
    else
        echo -e "${YELLOW}⚠${NC} Shell startup: Needs improvement"
    fi
fi

# Tool performance
if command -v rg >/dev/null 2>&1; then
    TOTAL=$((TOTAL + 1))
    SCORE=$((SCORE + 1))
    echo -e "${GREEN}✓${NC} Modern tools: Installed and fast"
fi

# Memory usage
if [[ -n "${RSS_MB:-}" ]] && [[ $RSS_MB -lt 50 ]]; then
    TOTAL=$((TOTAL + 1))
    SCORE=$((SCORE + 1))
    echo -e "${GREEN}✓${NC} Memory usage: Efficient"
fi

if [[ $TOTAL -gt 0 ]]; then
    PERCENTAGE=$((SCORE * 100 / TOTAL))
    echo -e "\nOverall Performance Score: ${PERCENTAGE}%"
    
    if [[ $PERCENTAGE -ge 80 ]]; then
        echo -e "${GREEN}✨ Excellent performance!${NC}"
    elif [[ $PERCENTAGE -ge 60 ]]; then
        echo -e "${YELLOW}⚠ Good performance with room for improvement${NC}"
    else
        echo -e "${RED}✗ Performance needs attention${NC}"
    fi
fi

# Optimization suggestions
if [[ -n "${ZSH_TIME:-}" ]] && (( $(echo "$ZSH_TIME > 0.5" | bc -l) )); then
    echo -e "\n${YELLOW}Optimization Suggestions:${NC}"
    echo "• Review and reduce Oh My Zsh plugins"
    echo "• Check for slow custom scripts in .zshrc"
    echo "• Consider using zsh-defer for non-critical plugins"
    echo "• Run 'zprof' to profile startup time"
fi