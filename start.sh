#!/bin/bash

echo "🚀 ビジネス効率化プラットフォーム - 起動スクリプト"
echo "================================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Dockerが起動していません。Dockerを起動してから再度実行してください。"
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Create .env.local if it doesn't exist
if [ ! -f frontend/.env.local ]; then
    echo "📝 Creating frontend/.env.local..."
    cp frontend/.env.local.example frontend/.env.local
    echo "✅ frontend/.env.local created"
fi

echo ""
echo "🐳 Starting Docker containers..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

echo ""
echo "📦 Installing backend dependencies..."
docker-compose exec -T backend bundle install

echo ""
echo "🗄️  Setting up database..."
docker-compose exec -T backend rails db:create
docker-compose exec -T backend rails db:migrate
docker-compose exec -T backend rails db:seed

echo ""
echo "✅ Setup complete!"
echo ""
echo "================================================"
echo "🌐 Access URLs:"
echo "   Frontend:  http://localhost:3001"
echo "   Backend:   http://localhost:3000"
echo "   API Docs:  http://localhost:3000/api/v1"
echo ""
echo "👤 Default Login:"
echo "   Admin:  admin@example.com / Admin123!@#"
echo "   User:   user1@example.com / User123!@#"
echo ""
echo "📝 Logs:"
echo "   docker-compose logs -f"
echo ""
echo "🛑 Stop:"
echo "   docker-compose down"
echo "================================================"
