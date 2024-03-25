# Initialize the new Redis instance with the new Redis namespace and store it in a global variable, $redis.
$redis = Redis::Namespace.new("redis_caching", redis: Redis.new)
