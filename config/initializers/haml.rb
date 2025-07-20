# config/initializers/haml.rb

# Set HAML as the default template engine
Rails.application.config.generators do |g|
  g.template_engine :haml
end
