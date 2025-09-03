#!/bin/bash

# YetAnotherAA 分步启动脚本
# 一步步启动，每步等待用户确认

echo "🚀 YetAnotherAA Step-by-Step Startup Guide"
echo "================================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 用户确认函数
wait_for_user() {
    local message=$1
    echo ""
    echo -e "${YELLOW}$message${NC}"
    echo -e "${BLUE}Press Enter to continue, or 'q' to quit...${NC}"
    read -r response
    if [ "$response" = "q" ] || [ "$response" = "quit" ]; then
        echo "Exiting..."
        exit 0
    fi
}

# 创建必要的目录
mkdir -p logs .pids

echo "This script will start all YetAnotherAA services step by step."
echo "You will be able to see the output and confirm each step."
echo ""
echo "Services to start:"
echo "  1. Signer Node 1 (Port 3001, Gossip 8001)"
echo "  2. Signer Node 2 (Port 3002, Gossip 8002)"
echo "  3. Signer Node 3 (Port 3003, Gossip 8003)"
echo "  4. Backend API (Port 3000)"
echo "  5. Frontend (Port 8080)"

wait_for_user "Ready to start? Make sure you have stopped any existing services first."

# 步骤1: 启动 Signer Node 1
echo ""
echo "================================================"
echo -e "${BLUE}Step 1: Starting Signer Node 1${NC}"
echo "================================================"
echo "Command to run:"
echo "cd signer && NODE_STATE_FILE=./node_dev_001.json PORT=3001 GOSSIP_PORT=8001 npm run start:dev"

wait_for_user "Ready to start Signer Node 1?"

echo -e "${GREEN}Starting Signer Node 1...${NC}"
echo "You can open a new terminal and run:"
echo "cd /Users/jason/Downloads/YetAnotherAA/signer"
echo "NODE_STATE_FILE=./node_dev_001.json PORT=3001 GOSSIP_PORT=8001 GOSSIP_BOOTSTRAP_PEERS=\"\" npm run start:dev"
echo ""
echo "Watch for the message: '🚀 BLS Signer Service is running on port 3001'"

wait_for_user "Signer Node 1 started successfully? (Check that it shows 'running on port 3001')"

# 步骤2: 启动 Signer Node 2
echo ""
echo "================================================"
echo -e "${BLUE}Step 2: Starting Signer Node 2${NC}"
echo "================================================"
echo "Command to run in a NEW terminal:"
echo "cd /Users/jason/Downloads/YetAnotherAA/signer"
echo "NODE_STATE_FILE=./node_dev_002.json PORT=3002 GOSSIP_PORT=8002 GOSSIP_BOOTSTRAP_PEERS=\"ws://localhost:8001\" npm run start:dev"
echo ""
echo "This node will connect to Node 1 via gossip protocol."

wait_for_user "Ready to start Signer Node 2?"

echo -e "${GREEN}Start Signer Node 2 now...${NC}"
echo "Watch for:"
echo "- '🚀 BLS Signer Service is running on port 3002'"
echo "- '👋 Peer joined' messages in Node 1's output"

wait_for_user "Signer Node 2 started and connected to Node 1?"

# 步骤3: 启动 Signer Node 3
echo ""
echo "================================================"
echo -e "${BLUE}Step 3: Starting Signer Node 3${NC}"
echo "================================================"
echo "Command to run in a NEW terminal:"
echo "cd /Users/jason/Downloads/YetAnotherAA/signer"
echo "NODE_STATE_FILE=./node_dev_003.json PORT=3003 GOSSIP_PORT=8003 GOSSIP_BOOTSTRAP_PEERS=\"ws://localhost:8001\" npm run start:dev"

wait_for_user "Ready to start Signer Node 3?"

echo -e "${GREEN}Start Signer Node 3 now...${NC}"
echo "Watch for:"
echo "- '🚀 BLS Signer Service is running on port 3003'"
echo "- Gossip connections in all node outputs"

wait_for_user "All 3 Signer Nodes are running and connected?"

# 步骤4: 启动 Backend API
echo ""
echo "================================================"
echo -e "${BLUE}Step 4: Starting Backend API${NC}"
echo "================================================"
echo "Command to run in a NEW terminal:"
echo "cd /Users/jason/Downloads/YetAnotherAA/aastar"
echo "PORT=3000 NODE_ENV=development JWT_SECRET=your-development-jwt-secret-key BLS_SIGNER_URL=http://localhost:3001 npm run start:dev"

wait_for_user "Ready to start Backend API?"

echo -e "${GREEN}Start Backend API now...${NC}"
echo "Watch for:"
echo "- '🚀 Application is running on: http://localhost:3000/api/v1'"
echo "- '📚 API Documentation: http://localhost:3000/api-docs'"

wait_for_user "Backend API started successfully?"

# 步骤5: 启动 Frontend
echo ""
echo "================================================"
echo -e "${BLUE}Step 5: Starting Frontend${NC}"
echo "================================================"
echo "Command to run in a NEW terminal:"
echo "cd /Users/jason/Downloads/YetAnotherAA/aastar-frontend"
echo "PORT=8080 npm run dev"

wait_for_user "Ready to start Frontend?"

echo -e "${GREEN}Start Frontend now...${NC}"
echo "Watch for:"
echo "- '✓ Ready in X.Xs'"
echo "- 'Local: http://localhost:8080'"

wait_for_user "Frontend started successfully?"

# 完成
echo ""
echo "================================================"
echo -e "${GREEN}🎉 All Services Started Successfully!${NC}"
echo "================================================"
echo ""
echo "📍 Your services should now be running on:"
echo "  - Frontend:        http://localhost:8080"
echo "  - Backend API:     http://localhost:3000/api/v1"
echo "  - API Docs:        http://localhost:3000/api-docs"
echo "  - Signer Node 1:   http://localhost:3001/api"
echo "  - Signer Node 2:   http://localhost:3002/api"
echo "  - Signer Node 3:   http://localhost:3003/api"
echo ""
echo "✨ You can now visit http://localhost:8080 to use the application!"
echo ""
echo "💡 To stop all services later, use: ./scripts/stop-all.sh"
echo "💡 To check status, use: ./scripts/status.sh"