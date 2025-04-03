#!/bin/bash

# Enhanced Color codes
BOLD='\033[1m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Function to export all needed variables
export_environment() {
    export BOLD RED GREEN YELLOW BLUE MAGENTA CYAN WHITE DIM NC
    export API_KEY SUCCESS_LOG ERROR_LOG
    export USER_AGENTS_STR=$(declare -p USER_AGENTS)
    export -f signup  # Explicitly export the signup function
}

# ASCII Art Header
show_header() {
	echo -e "${CYAN}${BOLD}"
	echo -e "███████╗    ███████╗██╗ ██████╗ ███╗   ██╗██╗   ██╗██████╗ "
	echo -e "██╔════╝    ██╔════╝██║██╔════╝ ████╗  ██║██║   ██║██╔══██╗"
	echo -e "█████╗█████╗███████╗██║██║  ███╗██╔██╗ ██║██║   ██║██████╔╝"
	echo -e "██╔══╝╚════╝╚════██║██║██║   ██║██║╚██╗██║██║   ██║██╔═══╝ "
	echo -e "██║         ███████║██║╚██████╔╝██║ ╚████║╚██████╔╝██║     "
	echo -e "╚═╝         ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     "
	echo -e "${NC}"
	}

# Function to prompt for API key with basic validation
get_api_key() {
    while true; do
        echo -e -n "${YELLOW}${BOLD}? ${NC}${WHITE}Enter your Firebase API key:${NC} "
        read -p "" API_KEY
        if [[ -z "$API_KEY" ]]; then
            echo -e "${RED}✖ Error: API key cannot be empty${NC}"
        elif [[ ! "$API_KEY" =~ ^[A-Za-z0-9_-]+$ ]]; then
            echo -e "${RED}✖ Error: Invalid API key format${NC}"
        else
            break
        fi
    done
}

# Prompt for number of accounts to create
get_account_count() {
    while true; do
        echo -e -n "${YELLOW}${BOLD}? ${NC}${WHITE}Enter number of accounts to create (default 1000):${NC} "
        read -p "" ACCOUNT_COUNT
        ACCOUNT_COUNT=${ACCOUNT_COUNT:-1000}
        if [[ "$ACCOUNT_COUNT" =~ ^[0-9]+$ ]] && [ "$ACCOUNT_COUNT" -gt 0 ]; then
            break
        else
            echo -e "${RED}✖ Error: Please enter a positive number${NC}"
        fi
    done
}

# Prompt for number of threads
get_thread_count() {
    while true; do
        echo -e -n "${YELLOW}${BOLD}? ${NC}${WHITE}Enter number of concurrent threads (default 10):${NC} "
        read -p "" THREADS
        THREADS=${THREADS:-10}
        if [[ "$THREADS" =~ ^[0-9]+$ ]] && [ "$THREADS" -gt 0 ] && [ "$THREADS" -le 20 ]; then
            break
        else
            echo -e "${RED}✖ Error: Please enter a number between 1-20${NC}"
        fi
    done
}

# Main configuration
SUCCESS_LOG="signup_responses.json"
ERROR_LOG="signup_errors.txt"

# Expanded User agents array
USER_AGENTS=(
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Safari/605.1.15"
    "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36 Edg/99.0.1150.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:66.0) Gecko/20100101 Firefox/66.0"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:99.0) Gecko/20100101 Firefox/99.0"
    "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36"
    "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36"
    "Mozilla/5.0 (X11; CrOS x86_64 8172.45.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.64 Safari/537.36"
    "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)"
    "Mozilla/5.0 (iPad; CPU OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D257 Safari/9537.53"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 8_4_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12H321 Safari/600.1.4"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Firefox/117.0"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/604.1"
)

# Main execution flow
main() {
    show_header
    
    # Get user input
    get_api_key
    get_account_count
    get_thread_count

    # Display configuration
    echo -e "\n${MAGENTA}${BOLD}⚙ CONFIGURATION SUMMARY${NC}"
    echo -e "${MAGENTA}──────────────────────────${NC}"
    echo -e "${CYAN}${BOLD}API Key:${NC} ${DIM}${API_KEY:0:4}****${API_KEY: -4}${NC}"
    echo -e "${CYAN}${BOLD}Accounts to create:${NC} ${GREEN}${ACCOUNT_COUNT}${NC}"
    echo -e "${CYAN}${BOLD}Concurrent threads:${NC} ${GREEN}${THREADS}${NC}"
    echo -e "${CYAN}${BOLD}Success log:${NC} ${BLUE}${SUCCESS_LOG}${NC}"
    echo -e "${CYAN}${BOLD}Error log:${NC} ${BLUE}${ERROR_LOG}${NC}"
    echo -e "${CYAN}${BOLD}Available User-Agents:${NC} ${GREEN}${#USER_AGENTS[@]}${NC}"
    echo -e "\n${GREEN}${BOLD}🚀 Starting process...${NC}\n"

    # Clear previous log files
    > "$SUCCESS_LOG"
    > "$ERROR_LOG"

    # Export environment for parallel processes
    export_environment

    # Run signup requests in parallel
    seq 1 "$ACCOUNT_COUNT" | xargs -P "$THREADS" -I {} bash -c '
        eval "$USER_AGENTS_STR"
        source /dev/stdin <<<"$(declare -f signup)"
        signup "$@"' _ {}

    # Completion message with stats
    show_completion
}

# Function to perform signup
signup() {
    local i=$1
    local email="fakeuser856335${i}@example.com"
    local password="P@ssw0rd123"
    
    # Get random user agent
    local ua_count=${#USER_AGENTS[@]}
    local user_agent_index=$((RANDOM % ua_count))
    local user_agent="${USER_AGENTS[$user_agent_index]}"

    # Shortened UA for display
    local display_ua=$(echo "$user_agent" | awk -F'[()]' '{print $2}' | head -n 1 | cut -c 1-30)
    
    response=$(curl -s -w "\n%{http_code}" -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}" \
        -H "Content-Type: application/json" \
        -H "User-Agent: ${user_agent}" \
        -d "{\"email\":\"${email}\",\"password\":\"${password}\",\"returnSecureToken\":true}")

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)

    if [[ "$http_code" == "200" ]]; then
        echo "$body" >> "$SUCCESS_LOG"
        echo -e "${GREEN}✓ [SUCCESS]${NC} ${WHITE}Account:${NC} ${CYAN}${email}${NC} ${DIM}(${display_ua}...)${NC}"
    else
        echo "[ERROR] Failed to create ${email} - HTTP ${http_code} - Response: ${body}" >> "$ERROR_LOG"
        echo -e "${RED}✗ [ERROR]${NC} ${WHITE}Account:${NC} ${CYAN}${email}${NC} ${DIM}(${display_ua}...)${NC}"
    fi

    sleep $((RANDOM % 3 + 1))
}

# Function to show completion message
show_completion() {

    echo -e "\n${MAGENTA}${BOLD}🏁 PROCESS COMPLETED${NC}"
    echo -e "${MAGENTA}──────────────────────${NC}"
    echo -e "${CYAN}${BOLD}Results saved to:${NC}"
    echo -e "  ${BLUE}• ${SUCCESS_LOG}${NC}"
    echo -e "  ${BLUE}• ${ERROR_LOG}${NC}"
}

# Start main execution
main
