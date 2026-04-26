# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Create roles
puts "Creating roles..."
admin_role = Role.find_or_create_by!(name: 'admin') do |role|
  role.description = '管理者'
end

user_role = Role.find_or_create_by!(name: 'user') do |role|
  role.description = '一般ユーザー'
end

puts "✅ Roles created"

# Create admin user
puts "Creating admin user..."
admin = User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'Admin123!@#'
  user.password_confirmation = 'Admin123!@#'
  user.confirmed_at = Time.current
end

admin.roles << admin_role unless admin.roles.include?(admin_role)
admin.profile.update!(
  display_name: '管理者',
  bio: 'システム管理者アカウント'
)

puts "✅ Admin user created (email: admin@example.com, password: Admin123!@#)"

# Create sample users
puts "Creating sample users..."
5.times do |i|
  user = User.find_or_create_by!(email: "user#{i + 1}@example.com") do |u|
    u.password = 'User123!@#'
    u.password_confirmation = 'User123!@#'
    u.confirmed_at = Time.current
  end

  user.profile.update!(
    display_name: "ユーザー#{i + 1}",
    bio: "サンプルユーザー#{i + 1}のプロフィールです",
    interests: ['Ruby', 'Rails', 'JavaScript', 'React'].sample(2),
    skills: ['プログラミング', 'デザイン', 'マーケティング'].sample(2)
  )
end

puts "✅ Sample users created"

# Create sample posts
puts "Creating sample posts..."
User.limit(3).each do |user|
  3.times do |i|
    Post.create!(
      user: user,
      content: "#{user.profile.display_name}のサンプル投稿 ##{i + 1}\n\nこれはテスト投稿です。"
    )
  end
end

puts "✅ Sample posts created"

# Create sample contents
puts "Creating sample contents..."
admin.authored_contents.create!(
  title: 'プラットフォームへようこそ',
  body: 'ビジネス効率化プラットフォームへようこそ。このプラットフォームでは、ユーザー管理、データ分析、コンテンツ管理、SNS、マッチング機能を提供しています。',
  status: :published,
  published_at: Time.current
)

puts "✅ Sample contents created"

puts "🎉 Seeding completed!"
puts ""
puts "📝 Login credentials:"
puts "   Admin: admin@example.com / Admin123!@#"
puts "   User1: user1@example.com / User123!@#"
puts "   User2: user2@example.com / User123!@#"
