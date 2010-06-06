dir = File.dirname(File.expand_path(__FILE__))

require 'rubygems'
require 'test/unit'
require 'mocha'
require File.join(dir, '../lib/redis-session-store')


if !system("which redis-server")
  puts '', "** can't find `redis-server` in your path"
  puts "** try running `sudo rake install`"
  abort ''
end

at_exit do
  next if $!

  exit_code = Test::Unit::AutoRunner.run

  pid = `ps -e -o pid,command | grep [r]edis-test`.split(" ")[0]
  puts "Killing test redis server..."
  `rm -f #{dir}/dump.rdb`
  Process.kill("KILL", pid.to_i)
  exit exit_code
end

puts "Starting redis for testing at localhost:9736..."
`redis-server #{dir}/redis-test.conf`

