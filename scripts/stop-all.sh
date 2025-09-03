#!/bin/bash

# YetAnotherAA 停止脚本
# 停止所有运行中的服务

echo "🛑 Stopping YetAnotherAA Application Stack..."
echo "================================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查PID文件是否存在
if [ -d ".pids" ]; then
    # 从PID文件读取并停止服务
    if [ -f ".pids/frontend.pid" ]; then
        PID=$(cat .pids/frontend.pid)
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            echo -e "${GREEN}✅ Frontend stopped (PID: $PID)${NC}"
        fi
        rm .pids/frontend.pid
    fi

    if [ -f ".pids/backend.pid" ]; then
        PID=$(cat .pids/backend.pid)
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            echo -e "${GREEN}✅ Backend API stopped (PID: $PID)${NC}"
        fi
        rm .pids/backend.pid
    fi

    for i in 1 2 3; do
        if [ -f ".pids/signer$i.pid" ]; then
            PID=$(cat .pids/signer$i.pid)
            if kill -0 $PID 2>/dev/null; then
                kill $PID
                echo -e "${GREEN}✅ Signer Node $i stopped (PID: $PID)${NC}"
            fi
            rm .pids/signer$i.pid
        fi
    done
else
    echo -e "${YELLOW}No PID files found. Attempting to stop services by port...${NC}"
fi

# 备用方案：通过端口停止服务
echo ""
echo "Checking for services on known ports..."

# 停止前端 (8080)
PID=$(lsof -ti:8080)
if [ ! -z "$PID" ]; then
    kill $PID
    echo -e "${GREEN}✅ Stopped service on port 8080${NC}"
fi

# 停止后端 (3000)
PID=$(lsof -ti:3000)
if [ ! -z "$PID" ]; then
    kill $PID
    echo -e "${GREEN}✅ Stopped service on port 3000${NC}"
fi

# 停止Signer节点 (3001-3003)
for port in 3001 3002 3003; do
    PID=$(lsof -ti:$port)
    if [ ! -z "$PID" ]; then
        kill $PID
        echo -e "${GREEN}✅ Stopped service on port $port${NC}"
    fi
done

# 停止Gossip端口 (8001-8003)
for port in 8001 8002 8003; do
    PID=$(lsof -ti:$port)
    if [ ! -z "$PID" ]; then
        kill $PID
        echo -e "${GREEN}✅ Stopped gossip service on port $port${NC}"
    fi
done

echo ""
echo "================================================"
echo -e "${GREEN}All services stopped${NC}"
echo "================================================"