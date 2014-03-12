begin
  config = YAML::load(File.open("#{Rails.root}/config/pusher.yml"))
rescue LoadError
  config = ENV
end

Pusher.url = "http://#{config['PUSHER_KEY']}:#{config['PUSHER_SECRET']}@api.pusherapp.com/apps/63832"
Pusher.logger = Rails.logger
