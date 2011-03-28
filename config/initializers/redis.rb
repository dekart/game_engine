REDIS_CONFIG = YAML.load(
    ERB.new(File.read(Rails.root.join("config", "redis.yml"))).result
)[Rails.env].symbolize_keys

$redis = Redis.new(REDIS_CONFIG)