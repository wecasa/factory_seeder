# FactorySeeder Template
# This template shows common patterns for seeding your database

FactorySeeder.generate do |seeder|
  # ========================================
  # BASIC SEEDING
  # ========================================
  
  # Create users with different traits
  seeder.create(:user, count: 10, traits: [:admin])
  seeder.create(:user, count: 50, traits: [:vip])
  seeder.create(:user, count: 100) # regular users
  
  # Create posts with associations
  seeder.create_with_associations(:post, count: 25, associations: {
    author: { factory: :user, count: 1 }
  })
  
  # ========================================
  # COMPLEX ASSOCIATIONS
  # ========================================
  
  # Create orders with multiple associations
  seeder.create_with_associations(:order, count: 10, associations: {
    customer: { factory: :user, traits: [:vip] },
    items: { factory: :product, count: 3 }
  })
  
  # Create blog posts with comments
  seeder.create_with_associations(:blog_post, count: 15, associations: {
    author: { factory: :user, traits: [:admin] },
    comments: { factory: :comment, count: 5 }
  })
  
  # ========================================
  # CUSTOM ATTRIBUTES
  # ========================================
  
  # Override default attributes
  seeder.create(:user, count: 5, attributes: {
    email: "custom@example.com",
    role: "moderator"
  })
  
  # ========================================
  # DIFFERENT STRATEGIES
  # ========================================
  
  # Build records without saving (useful for testing)
  seeder.create(:user, count: 3, strategy: :build, traits: [:admin])
  
  # ========================================
  # ENVIRONMENT-SPECIFIC SEEDING
  # ========================================
  
  if Rails.env.development?
    # Development-specific seeds
    seeder.create(:user, count: 100, traits: [:admin])
    seeder.create(:post, count: 500)
  elsif Rails.env.test?
    # Test-specific seeds (minimal data)
    seeder.create(:user, count: 5)
    seeder.create(:post, count: 10)
  end
end

# ========================================
# ALTERNATIVE APPROACHES
# ========================================

# You can also use the direct API
generator = FactorySeeder::SeedGenerator.new

# Create records one by one
generator.create(:user, count: 1, traits: [:admin])
generator.create(:post, count: 5, traits: [:published])

# Preview data before creating
generator.preview(:user, [:admin, :vip])

# Get a summary of what was created
generator.summary
