# Config Redis

begin
  file = YAML.load_file("#{Rails.root}/config/sidekiq_pro_path.yml")
  path = file['path']
  $LOAD_PATH.unshift(path)

  require 'sidekiq-pro'
  require 'sidekiq/pro/reliable_push'
rescue Exception
end

if Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://10.0.2.181:6379', namespace: 'fairnopoly' }
    begin
      require 'sidekiq/pro/reliable_fetch'
    rescue LoadError
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://10.0.2.181:6379', namespace: 'fairnopoly' }
  end
end

Redis.current = SidekiqRedisConnectionWrapper.new
