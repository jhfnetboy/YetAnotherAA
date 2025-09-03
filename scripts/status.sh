#!/bin/bash

# YetAnotherAA 状态检查脚本
# 检查所有服务的运行状态

echo "📊 YetAnotherAA Application Status"
echo "================================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查端口状态
check_service() {
    local service_name=$1
    local port=$2
    local url=$3
    
    PID=$(lsof -ti:$port 2>/dev/null)
    if [ ! -z "$PID" ]; then
        echo -e "${GREEN}✅ $service_name${NC} - Running on port $port (PID: $PID)"
        if [ ! -z "$url" ]; then
            echo -e "   🔗 $url"
        fi
        return 0
    else
        echo -e "${RED}❌ $service_name${NC} - Not running on port $port"
        return 1
    fi
}

# 检查HTTP服务响应
check_http_response() {
    local service_name=$1
    local url=$2
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        echo -e "   ${GREEN}🌐 HTTP Response: OK${NC}"
    else
        echo -e "   ${YELLOW}🌐 HTTP Response: Not responding${NC}"
    fi
}

echo "Services Status:"
echo ""

# 检查前端
check_service "Frontend" 8080 "http://localhost:8080"
if [ $? -eq 0 ]; then
    check_http_response "Frontend" "http://localhost:8080"
fi
echo ""

# 检查后端API
check_service "Backend API" 3000 "http://localhost:3000/api/v1"
if [ $? -eq 0 ]; then
    check_http_response "Backend API" "http://localhost:3000/api/v1/health"
fi
echo ""

# 检查Signer节点
for i in 1 2 3; do
    port=$((3000 + i))
    gossip_port=$((8000 + i))
    check_service "Signer Node $i" $port "http://localhost:$port"
    if [ $? -eq 0 ]; then
        check_http_response "Signer Node $i" "http://localhost:$port/node/info"
        # 检查Gossip端口
        GOSSIP_PID=$(lsof -ti:$gossip_port 2>/dev/null)
        if [ ! -z "$GOSSIP_PID" ]; then
            echo -e "   ${GREEN}🗣️  Gossip: Active on port $gossip_port${NC}"
        else
            echo -e "   ${YELLOW}🗣️  Gossip: Not active on port $gossip_port${NC}"
        fi
    fi
    echo ""
done

echo "================================================"

# 统计运行中的服务
RUNNING_COUNT=0
TOTAL_COUNT=5

for port in 8080 3000 3001 3002 3003; do
    PID=$(lsof -ti:$port 2>/dev/null)
    if [ ! -z "$PID" ]; then
        RUNNING_COUNT=$((RUNNING_COUNT + 1))
    fi
done

echo -e "Summary: ${GREEN}$RUNNING_COUNT${NC}/$TOTAL_COUNT services running"

if [ $RUNNING_COUNT -eq $TOTAL_COUNT ]; then
    echo -e "${GREEN}🎉 All services are healthy!${NC}"
elif [ $RUNNING_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some services are not running${NC}"
else
    echo -e "${RED}🚫 No services are running${NC}"
fi

echo ""
echo "💡 Commands:"
echo "  - Start all:  ./scripts/start-all.sh"
echo "  - Stop all:   ./scripts/stop-all.sh"
echo "  - View logs:  tail -f logs/*.log"