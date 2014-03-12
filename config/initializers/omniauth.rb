begin
  CONF = YAML::load(File.open("#{Rails.root}/config/stripe.yml"))
rescue LoadError
  CONF = ENV
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :stripe_connect, CONF['STRIPE_CONNECT_CLIENT_ID'], CONF['STRIPE_SECRET'], scope: 'read_write'
end

OmniAuth.config.on_failure = Proc.new do |env|
  OrganizationsController.action(:omniauth_failure).call(env)
end