# frozen_string_literal: true

# FactorySeeder seed template
# Drop files like this one under db/factory_seeds/ -- they are loaded
# automatically by the CLI and by the Rails engine.

# A seed without parameters.
FactorySeeder.define_seed(:sample_users) do
  FactoryBot.create_list(:user, 10)
end

# A seed with typed, validated parameters. They show up as a form in the web UI
# and can be passed on the command line:
#
#   factory_seeder seeds sample_posts --params count:5 published:true
FactorySeeder.define_seed(:sample_posts, lambda { |builder|
  builder
    .description('Create posts for an existing author')
    .integer_param(:count, required: true, min: 1, max: 100, description: 'How many posts')
    .boolean_param(:published, required: false, default: false, description: 'Publish them')
    .symbol_param(:locale, required: false, default: :fr,
                  allowed_values: %i[fr en es], description: 'Post locale')
    .array_param(:tags, required: false, default: %w[ruby rails], description: 'Tags to apply')
}) do |count:, published: false, locale: :fr, tags: %w[ruby rails]|
  author = FactoryBot.create(:user)

  count.times do
    FactoryBot.create(:post, author: author, published: published, locale: locale, tags: tags)
  end
end

# Every record FactoryBot persists inside a seed -- associations included -- is
# reported back by the CLI, the web UI and the execution log. Nothing to declare.
