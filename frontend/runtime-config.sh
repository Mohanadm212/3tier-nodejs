#!/bin/sh
echo "Injecting runtime config..."

cat <<EOF > /usr/share/nginx/html/env.js
window.REACT_APP_API_URL="${REACT_APP_API_URL}";
EOF
