require File.dirname(__FILE__) + '/test_helper'

class RedisSessionStoreTest < Test::Unit::TestCase

  def setup
    @redis = Redis.new(RedisSessionStore::DEFAULT_OPTIONS.merge(:port => 9736, :key_prefix => 'test_session'))
    @redis.flushall # reset everything in the db
    @redis_session_store = RedisSessionStore.new(Object.new, :port => 9736, :key_prefix => 'test_session')
    @env = {'rack.session.options' => {}}
    @env_with_expiry = {'rack.session.options' => {:expire_after => 600}}
    @sid = "abc123"
    @key = "test_session#{@sid}"
  end

  def test_get_and_set
    assert_equal 0, @redis.keys('*').length
    assert @redis_session_store.send(:set_session, @env, @sid, "This was a triumph")
    assert_equal 1, @redis.keys('*').length
    assert @redis.get(@key)

    assert_equal -1, @redis.ttl(@key)

    response = @redis_session_store.send(:get_session, @env, @sid)
    assert_equal @sid, response[0]
    assert_equal "This was a triumph", response[1]
  end

  def test_get_and_set_with_expiry
    assert_equal 0, @redis.keys('*').length
    assert @redis_session_store.send(:set_session, @env_with_expiry, @sid, "Where's the cake?")
    assert_equal 1, @redis.keys('*').length

    # Assume no more than 5 seconds will pass between the set and these asserts
    assert @redis.ttl(@key) <= 600
    assert @redis.ttl(@key) >= 555

    response = @redis_session_store.send(:get_session, @env_with_expiry, @sid)
    assert_equal @sid, response[0]
    assert_equal "Where's the cake?", response[1]
  end

  def test_get_with_no_sid
    response = @redis_session_store.send(:get_session, @env, nil)
    assert response[0] # should have created a sid
    assert_equal({}, response[1])
  end

end