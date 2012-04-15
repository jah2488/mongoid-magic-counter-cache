require "rubygems"
require "mongoid"
require "bundler/setup"
require "rspec"
require File.expand_path("../../lib/mongoid_magic_counter_cache", __FILE__)

Mongoid.configure do |config|
    name = "mongoid_magic_counter_cache_test"
    config.master = Mongo::Connection.new.db(name)
end

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |f| require f }

RSpec.configure do |c|
    c.mock_with :rspec
    c.before(:each) do
          Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    end
end
