#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/eww"
ENV_FILE="$CONFIG_DIR/spotify.env"
REDIRECT_URI="http://127.0.0.1:8888/callback"
SCOPE="user-read-playback-state"

echo "=== Spotify API Authentication Setup ==="
echo ""
echo "Before starting, you need to:"
echo "1. Go to https://developer.spotify.com/dashboard"
echo "2. Create an app (or use an existing one)"
echo "3. Add 'http://127.0.0.1:8888/callback' to your app's Redirect URIs"
echo "   (Note: Use 127.0.0.1, NOT localhost - Spotify requires explicit loopback IP)"
echo "4. Note your Client ID and Client Secret"
echo ""

read -p "Enter your Spotify Client ID: " CLIENT_ID
read -p "Enter your Spotify Client Secret: " CLIENT_SECRET

if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" ]]; then
  echo "Error: Client ID and Secret are required"
  exit 1
fi

AUTH_URL="https://accounts.spotify.com/authorize?client_id=$CLIENT_ID&response_type=code&redirect_uri=$REDIRECT_URI&scope=$SCOPE"

echo ""
echo "Opening browser for authorization..."
echo "If browser doesn't open, visit this URL:"
echo "$AUTH_URL"
echo ""

xdg-open "$AUTH_URL" 2>/dev/null || open "$AUTH_URL" 2>/dev/null || echo "Please open the URL manually"

echo ""
echo "After authorizing, you'll be redirected to 127.0.0.1:8888/callback?code=..."
echo "The page won't load (that's normal), but copy the 'code' parameter from the URL"
echo ""
read -p "Paste the authorization code here: " AUTH_CODE

if [[ -z "$AUTH_CODE" ]]; then
  echo "Error: Authorization code is required"
  exit 1
fi

echo ""
echo "Exchanging authorization code for refresh token..."

RESPONSE=$(curl -s -X POST "https://accounts.spotify.com/api/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "code=$AUTH_CODE" \
  -d "redirect_uri=$REDIRECT_URI" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET")

REFRESH_TOKEN=$(echo "$RESPONSE" | grep -o '"refresh_token":"[^"]*' | cut -d'"' -f4)

if [[ -z "$REFRESH_TOKEN" ]]; then
  echo "Error: Failed to get refresh token"
  echo "Response: $RESPONSE"
  exit 1
fi

cat > "$ENV_FILE" <<EOF
# Spotify API Credentials
SPOTIFY_CLIENT_ID="$CLIENT_ID"
SPOTIFY_CLIENT_SECRET="$CLIENT_SECRET"
SPOTIFY_REFRESH_TOKEN="$REFRESH_TOKEN"
EOF

chmod 600 "$ENV_FILE"

echo ""
echo "✓ Success! Credentials saved to $ENV_FILE"
echo "You can now use the spotify_unified.sh script"
