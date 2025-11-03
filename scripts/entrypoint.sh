#!/bin/bash
set -e

echo "🚀 Starting Oracle APEX Container..."

# Run setup on first start
. /opt/scripts/setup.sh

echo "🗄️ Starting Oracle XE..."
/etc/init.d/oracle-xe-21c start

# Small delay to let DB start properly
sleep 10

echo "🌐 Starting ORDS..."
cd /opt/ords
exec /opt/ords/bin/ords serve
