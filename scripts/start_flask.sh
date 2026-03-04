#!/usr/bin/env bash
set -euo pipefail

cd /app
source /app/.venv/bin/activate
export DATABASE_URL="mysql+pymysql://root:${DB_PASSWORD}@db:3306/${DB_NAME}"

echo "DATABASE_URL=$DATABASE_URL"

# 1) Wait for db (max 20s)
python - <<'PY'
import socket, time, sys
host, port = "db", 3306
deadline = time.time() + 20
last_err = None
while time.time() < deadline:
    try:
        s = socket.socket()
        s.settimeout(2)
        s.connect((host, port))
        s.close()
        print("db:3306 reachable")
        sys.exit(0)
    except Exception as e:
        last_err = e
        time.sleep(1)
print(f"ERROR: db not reachable after 20s: {last_err}")
sys.exit(1)
PY

# 2) If Flask is already listening, stop here (but do NOT trigger set -e)
python - <<'PY'
import socket
s=socket.socket()
s.settimeout(0.3)
try:
    s.connect(("127.0.0.1", 4000))
    print("Flask already running on 4000")
except Exception:
    pass
finally:
    s.close()
PY

# If it printed "already running", exit 0 by detecting port open again
if python - <<'PY'
import socket, sys
s=socket.socket()
s.settimeout(0.3)
try:
    s.connect(("127.0.0.1", 4000))
    sys.exit(0)
except Exception:
    sys.exit(1)
finally:
    s.close()
PY
then
  exit 0
fi

# 3) Start Flask detached (no reloader)
setsid flask run --no-reload --host=0.0.0.0 --port=4000 >/tmp/flask.log 2>&1 < /dev/null &
echo $! >/tmp/flask.pid

# 4) Wait for Flask to accept connections (max 10s)
python - <<'PY'
import socket, time, sys
deadline = time.time() + 10
last_err = None
while time.time() < deadline:
    try:
        s=socket.socket()
        s.settimeout(0.5)
        s.connect(("127.0.0.1", 4000))
        s.close()
        print("Flask is accepting connections on 4000")
        sys.exit(0)
    except Exception as e:
        last_err = e
        time.sleep(0.5)
print(f"ERROR: Flask did not come up: {last_err}")
sys.exit(1)
PY

echo "Started Flask PID $(cat /tmp/flask.pid). Log: /tmp/flask.log"
