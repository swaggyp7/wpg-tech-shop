stripe_config_path = Rails.root.join("config/stripe.yml")
stripe_file_config =
  if File.exist?(stripe_config_path)
    YAML.safe_load_file(stripe_config_path)&.with_indifferent_access || {}
  else
    {}
  end

Rails.application.config.x.stripe = ActiveSupport::OrderedOptions.new
Rails.application.config.x.stripe.publishable_key = stripe_file_config["STRIPE_PUBLISHABLE_KEY"].presence || ENV.fetch("STRIPE_PUBLISHABLE_KEY", "")
Rails.application.config.x.stripe.secret_key = stripe_file_config["STRIPE_SECRET_KEY"].presence || ENV.fetch("STRIPE_SECRET_KEY", "")
Rails.application.config.x.stripe.webhook_secret = stripe_file_config["STRIPE_WEBHOOK_SECRET"].presence || ENV.fetch("STRIPE_WEBHOOK_SECRET", "")
Rails.application.config.x.stripe.currency = stripe_file_config["STRIPE_CURRENCY"].presence || ENV.fetch("STRIPE_CURRENCY", "cad")

Stripe.api_key = Rails.configuration.x.stripe.secret_key if defined?(Stripe) && Rails.configuration.x.stripe.secret_key.present?
