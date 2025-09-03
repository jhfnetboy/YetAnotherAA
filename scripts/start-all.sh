#!/bin/bash

# YetAnotherAA 完整启动脚本
# 启动所有服务：3个Signer节点 + Backend API + Frontend

echo "🚀 Starting YetAnotherAA Application Stack..."
echo "================================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查端口是否被占用
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${RED}❌ Port $port is already in use${NC}"
        echo "Please stop the service using port $port or change the port configuration"
        return 1
    fi
    return 0
}

# 检查所有必需的端口
echo -e "${BLUE}Checking required ports...${NC}"
PORTS=(3000 3001 3002 3003 8001 8002 8003 8080)
ALL_CLEAR=true

for port in "${PORTS[@]}"; do
    if ! check_port $port; then
        ALL_CLEAR=false
    fi
done

if [ "$ALL_CLEAR" = false ]; then
    echo -e "${RED}Please free up the required ports before starting${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All ports are available${NC}"
echo ""

# 清理前端缓存（如果需要）
if [ "$1" == "--clean" ]; then
    echo -e "${YELLOW}Cleaning frontend cache...${NC}"
    cd aastar-frontend
    rm -rf node_modules .next
    npm install
    cd ..
    echo -e "${GREEN}✅ Frontend cleaned and dependencies reinstalled${NC}"
    echo ""
fi

# 启动 Signer Node 1
echo -e "${BLUE}Starting Signer Node 1 (Port 3001, Gossip 8001)...${NC}"
cd signer
NODE_STATE_FILE=./node_dev_001.json \
PORT=3001 \
GOSSIP_PORT=8001 \
GOSSIP_BOOTSTRAP_PEERS="" \
GOSSIP_INTERVAL=5000 \
GOSSIP_FANOUT=2 \
GOSSIP_MAX_TTL=3 \
GOSSIP_HEARTBEAT_INTERVAL=10000 \
GOSSIP_SUSPICION_TIMEOUT=30000 \
GOSSIP_CLEANUP_TIMEOUT=60000 \
GOSSIP_MAX_MESSAGE_HISTORY=1000 \
npm run start:dev > ../logs/signer1.log 2>&1 &
SIGNER1_PID=$!
cd ..
echo -e "${GREEN}✅ Signer Node 1 started (PID: $SIGNER1_PID)${NC}"
sleep 3

# 启动 Signer Node 2
echo -e "${BLUE}Starting Signer Node 2 (Port 3002, Gossip 8002)...${NC}"
cd signer
NODE_STATE_FILE=./node_dev_002.json \
PORT=3002 \
GOSSIP_PORT=8002 \
GOSSIP_BOOTSTRAP_PEERS="ws://localhost:8001" \
GOSSIP_INTERVAL=5000 \
GOSSIP_FANOUT=2 \
GOSSIP_MAX_TTL=3 \
GOSSIP_HEARTBEAT_INTERVAL=10000 \
GOSSIP_SUSPICION_TIMEOUT=30000 \
GOSSIP_CLEANUP_TIMEOUT=60000 \
GOSSIP_MAX_MESSAGE_HISTORY=1000 \
npm run start:dev > ../logs/signer2.log 2>&1 &
SIGNER2_PID=$!
cd ..
echo -e "${GREEN}✅ Signer Node 2 started (PID: $SIGNER2_PID)${NC}"
sleep 2

# 启动 Signer Node 3
echo -e "${BLUE}Starting Signer Node 3 (Port 3003, Gossip 8003)...${NC}"
cd signer
NODE_STATE_FILE=./node_dev_003.json \
PORT=3003 \
GOSSIP_PORT=8003 \
GOSSIP_BOOTSTRAP_PEERS="ws://localhost:8001" \
GOSSIP_INTERVAL=5000 \
GOSSIP_FANOUT=2 \
GOSSIP_MAX_TTL=3 \
GOSSIP_HEARTBEAT_INTERVAL=10000 \
GOSSIP_SUSPICION_TIMEOUT=30000 \
GOSSIP_CLEANUP_TIMEOUT=60000 \
GOSSIP_MAX_MESSAGE_HISTORY=1000 \
npm run start:dev > ../logs/signer3.log 2>&1 &
SIGNER3_PID=$!
cd ..
echo -e "${GREEN}✅ Signer Node 3 started (PID: $SIGNER3_PID)${NC}"
sleep 2

# 启动 Backend API
echo -e "${BLUE}Starting Backend API (Port 3000)...${NC}"
cd aastar
PORT=3000 \
NODE_ENV=development \
JWT_SECRET=your-development-jwt-secret-key \
JWT_EXPIRES_IN=7d \
BLS_SIGNER_URL=http://localhost:3001 \
npm run start:dev > ../logs/backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo -e "${GREEN}✅ Backend API started (PID: $BACKEND_PID)${NC}"
sleep 3

# 启动 Frontend
echo -e "${BLUE}Starting Frontend (Port 8080)...${NC}"
cd aastar-frontend
PORT=8080 npm run dev > ../logs/frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..
echo -e "${GREEN}✅ Frontend started (PID: $FRONTEND_PID)${NC}"

# 保存PID到文件
echo $SIGNER1_PID > .pids/signer1.pid
echo $SIGNER2_PID > .pids/signer2.pid
echo $SIGNER3_PID > .pids/signer3.pid
echo $BACKEND_PID > .pids/backend.pid
echo $FRONTEND_PID > .pids/frontend.pid

echo ""
echo "================================================"
echo -e "${GREEN}🎉 All services started successfully!${NC}"
echo "================================================"
echo ""
echo "📍 Service URLs:"
echo "  - Frontend:        http://localhost:8080"
echo "  - Backend API:     http://localhost:3000/api/v1"
echo "  - API Docs:        http://localhost:3000/api-docs"
echo "  - Signer Node 1:   http://localhost:3001"
echo "  - Signer Node 2:   http://localhost:3002"
echo "  - Signer Node 3:   http://localhost:3003"
echo ""
echo "📝 Logs are available in the 'logs' directory"
echo "💡 Use './scripts/stop-all.sh' to stop all services"
echo "💡 Use './scripts/status.sh' to check service status"
echo ""
echo "Press Ctrl+C to stop monitoring (services will continue running in background)"

# 监控日志
tail -f logs/*.log