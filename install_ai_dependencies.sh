#!/bin/bash

# Bwana Cloud - AI Dependencies Installation Script
# This script installs all necessary AI/agent tools for multi-agent workflows

echo "=== Bwana Cloud AI Dependencies Installation ==="
echo "Installing AI libraries, agent frameworks, and development tools..."

# Update system packages
echo "Updating system packages..."
sudo apt update

# Install system dependencies
echo "Installing system dependencies..."
sudo apt install -y redis-server memcached rabbitmq-server
sudo apt install -y php8.3-pgsql php8.3-redis php8.3-memcached
sudo apt install -y php8.3-curl php8.3-xml php8.3-soap
sudo apt install -y php8.3-intl php8.3-gd php8.3-imagick
sudo apt install -y python3-dev build-essential
sudo apt install -y nodejs-dev npm
sudo apt install -y docker-compose-plugin

# Start services
echo "Starting Redis, Memcached, and RabbitMQ..."
sudo systemctl start redis-server
sudo systemctl enable redis-server
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

# Install Python AI libraries
echo "Installing Python AI libraries..."
pip3 install --user autogen-agent langchain openai anthropic
pip3 install --user transformers torch torchvision
pip3 install --user numpy pandas scikit-learn
pip3 install --user sqlalchemy psycopg2-binary
pip3 install --user redis celery aiohttp websockets
pip3 install --user selenium beautifulsoup4 scrapy
pip3 install --user jupyter streamlit gradio
pip3 install --user huggingface-hub diffusers
pip3 install --user accelerate bitsandbytes peft

# Install agent orchestration frameworks
echo "Installing agent orchestration frameworks..."
pip3 install --user crewai pyautogen swarm-agents
pip3 install --user multi-agent-orchestrator
pip3 install --user agent-memory persistent-agents

# Install Node.js AI libraries
echo "Installing Node.js AI libraries..."
npm install -g @langchain/langchain-js
npm install -g openai anthropic
npm install -g @tensorflow/tfjs-node
npm install -g socket.io redis
npm install -g bull queue
npm install -g puppeteer playwright
npm install -g express fastify
npm install -g prisma @prisma/client

# Create agent system directory
echo "Creating agent system directory..."
mkdir -p ~/bwana-agents
cd ~/bwana-agents

# Download agent system files
echo "Downloading agent system files..."
curl -sSL https://bwana.cloud/agent-system.tar.gz | tar -xz

# Create configuration file
echo "Creating agent configuration..."
cat > config.json << 'EOF'
{
  "system": {
    "name": "Bwana Cloud Multi-Agent System",
    "version": "1.0.0",
    "environment": "production"
  },
  "database": {
    "redis_url": "redis://localhost:6379/0",
    "postgres_url": "postgres://postgres:EthrAuth$$!!@38.45.71.83:5432/bwanacloud"
  },
  "agents": {
    "max_concurrent": 10,
    "memory_retention_days": 30,
    "workflow_timeout_minutes": 60
  },
  "services": {
    "anythingllm_url": "https://chat.bwana.cloud",
    "coder_url": "https://coder.bwana.cloud",
    "plane_url": "https://plane.bwana.cloud",
    "keycloak_url": "https://sso.bwana.cloud"
  }
}
EOF

# Create systemd service for agent system
echo "Creating systemd service..."
sudo tee /etc/systemd/system/bwana-agents.service > /dev/null << 'EOL'
[Unit]
Description=Bwana Cloud Multi-Agent System
After=network.target

[Service]
Type=simple
User=ap
WorkingDirectory=/home/ap/bwana-agents
ExecStart=/usr/bin/python3 /home/ap/bwana-agents/agent_orchestrator.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL

# Enable and start agent service
echo "Enabling and starting agent service..."
sudo systemctl daemon-reload
sudo systemctl enable bwana-agents
sudo systemctl start bwana-agents

# Create IDE integration
echo "Creating IDE integration..."
mkdir -p ~/.vscode/extensions
cat > ~/.vscode/extensions/bwana-agent-integration.json << 'EOF'
{
  "name": "Bwana Agent Integration",
  "version": "1.0.0",
  "description": "Multi-agent workflow integration for Bwana Cloud",
  "agent_endpoint": "ws://localhost:8080/agents",
  "persistent_memory": true,
  "workflow_support": true
}
EOF

# Create desktop shortcut for agent management
echo "Creating desktop shortcut..."
cat > ~/Desktop/Bwana-Agents.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Bwana Cloud Agents
Comment=Multi-Agent Workflow Management
Exec=firefox http://localhost:8080/agent-dashboard
Icon=~/.local/share/icons/bwana-agents.png
Terminal=false
Categories=Development;
EOF

chmod +x ~/Desktop/Bwana-Agents.desktop

# Test installation
echo "Testing installation..."
python3 -c "
import redis
import json
try:
    r = redis.Redis(host='localhost', port=6379, db=0)
    r.set('test', 'success')
    result = r.get('test')
    print(f'Redis test: {result.decode()}')
except Exception as e:
    print(f'Redis error: {e}')
"

echo ""
echo "=== Installation Complete ==="
echo "✅ Redis server: $(systemctl is-active redis-server && echo 'Running' || echo 'Stopped')"
echo "✅ Memcached server: $(systemctl is-active memcached && echo 'Running' || echo 'Stopped')"
echo "✅ RabbitMQ server: $(systemctl is-active rabbitmq-server && echo 'Running' || echo 'Stopped')"
echo "✅ Agent service: $(systemctl is-active bwana-agents && echo 'Running' || echo 'Stopped')"
echo ""
echo "=== Next Steps ==="
echo "1. Open Firefox: http://localhost:8080/agent-dashboard"
echo "2. Configure your first agent workflow"
echo "3. Test multi-agent collaboration"
echo "4. Start generating revenue with AI automation"
echo ""
echo "=== Service Status ==="
echo "Agent Dashboard: http://localhost:8080/agent-dashboard"
echo "Agent API: http://localhost:8080/api/agents"
echo "WebSocket: ws://localhost:8080/agents"
echo "Logs: journalctl -u bwana-agents -f"
echo ""
echo "=== Revenue Ready ==="
echo "Your Bwana Cloud now has multi-agent AI capabilities!"
echo "Start offering AI Agent Platform as Service: $999/month"
echo ""