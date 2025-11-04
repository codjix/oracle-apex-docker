#!/bin/bash
set -e

echo "🚀 Starting Oracle APEX Container..."

# Run setup on first start
. /opt/scripts/setup.sh

echo "🗄️ Starting Oracle XE..."
/etc/init.d/oracle-xe-21c start

echo "🌐 Starting ORDS..."
cd /opt/ords
exec ords --config $ORACLE_BASE/oradata/ords-config serve
