#!/usr/bin/env ruby

require 'fileutils'
require 'rubygems'

gem 'activerecord', '~>2.3.2'
gem 'addressable',  '~>2.0'
gem 'faker',        '~>0.3.1'
gem 'rbench',       '~>0.2.3'

require 'addressable/uri'
require 'faker'
require 'rbench'
require 'dm-core'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'mongo_adapter'))

TIMES = ENV.key?('x') ? ENV['x'].to_i : 10_000

configuration = { :hostname => 'localhost', :database => 'dm_core_test', :username => 'root', :password => '' }

DataMapper.setup(:default, configuration.merge(:adapter => "mongo").except(:username, :password))
DataMapper.setup(:mysql, configuration.merge(:adapter => "mysql"))

class User
  include DataMapper::Resource

  def self.default_repository_name; :mysql; end

  property :id,         Serial
  property :name,       String
  property :email,      String
  property :about,      Text,   :lazy => false
  property :created_on, Time
end

class Exhibit
  include DataMapper::Resource

  def self.default_repository_name; :mysql; end

  property :id,         Serial
  property :name,       String
  property :user_id,    Integer
  property :notes,      Text,    :lazy => false
  property :created_on, Time
end

User.has User.n, :exhibits
Exhibit.belongs_to :user

module Mongo
  class User
    include DataMapper::Mongo::Resource

    def self.default_storage_name; 'user'; end

    property :id,         DataMapper::Mongo::Types::ObjectID
    property :name,       String
    property :email,      String
    property :about,      Text,   :lazy => false
    property :created_on, Time
  end

  class Exhibit
    include DataMapper::Mongo::Resource

    def self.default_storage_name; 'exhibit'; end

    property :id,         DataMapper::Mongo::Types::ObjectID
    property :name,       String
    property :user_id,    Integer
    property :notes,      Text,    :lazy => false
    property :created_on, Time

    belongs_to :user
  end

  User.has User.n, :exhibits
  Exhibit.belongs_to :user
end

def touch_attributes(*exhibits)
  exhibits.flatten.each do |exhibit|
    exhibit.id
    exhibit.name
    exhibit.created_on
  end
end

def touch_relationships(*exhibits)
  exhibits.flatten.each do |exhibit|
    exhibit.id
    exhibit.name
    exhibit.created_on
    exhibit.user
  end
end

root = File.dirname(__FILE__)

dump_dir = root / 'dumps'

dump_dir_mysql = dump_dir / 'mysql'
dump_dir_mongo = dump_dir / 'mongo'

FileUtils.mkdir_p(dump_dir_mysql) unless File.exist?(dump_dir_mysql)
FileUtils.mkdir_p(dump_dir_mongo) unless File.exist?(dump_dir_mongo)

dump_sql = dump_dir / 'mysql' / 'dump.sql'
dump_mongo_users = dump_dir_mongo / configuration[:database] / 'users.bson'
dump_mongo_exhibits = dump_dir_mongo / configuration[:database] / 'exhibits.bson'

mongo_user_ids    = []
mongo_exhibit_ids = []

mysql_user_ids    = []
mysql_exhibit_ids = []

puts 'Clearing databases...'

User.auto_migrate!
Exhibit.auto_migrate!

Mongo::User.auto_migrate!
Mongo::Exhibit.auto_migrate!

# pre-compute the insert statements and fake data compilation,
# so the benchmmysqlks below show the actual runtime for the execute
# method, minus the setup steps

# Using the same paragraphs for all exhibits because it is very slow
# to generate unique paragraphs for all exhibits.
notes = Faker::Lorem.paragraphs.join($/)
today = Time.now

puts 'Generating data for benchmarking...'

c = configuration

if File.exist?(dump_sql) && File.exist?(dump_mongo_users) && File.exist?(dump_mongo_exhibits)
  puts "Found db dumps, importing..."
  
  `mysql -u #{c[:username]} #{"-p#{ c[:password]}" unless c[:password].blank?} --database #{c[:database]} < #{dump_sql}`
  `mongorestore -d #{c[:database]} -c users --dir #{dump_mongo_users}`
  `mongorestore -d #{c[:database]} -c exhibits --dir #{dump_mongo_exhibits}`

  mysql_user_ids    = User.all.map(&:id)
  mysql_exhibit_ids = Exhibit.all.map(&:id)

  mongo_user_ids   = Mongo::User.all.map(&:id)
  mongo_exhibit_ids = Mongo::Exhibit.all.map(&:id)
else
  FileUtils.rm(dump_sql) if File.exist?(dump_sql)
  FileUtils.rm_r(dump_mongo_users) if File.exist?(dump_mongo_users)
  FileUtils.rm_r(dump_mongo_exhibits) if File.exist?(dump_mongo_exhibits)

  puts 'Inserting 10,000 users and exhibits...'
  10_000.times do
    user_properties = {
      :created_on => today,
      :name       => Faker::Name.name,
      :email      => Faker::Internet.email }

    exhibit_properties = {
      :created_on => today,
      :name       => Faker::Company.name,
      :notes      => notes
    }

    mongo_user    = Mongo::User.create(user_properties)
    mongo_exhibit = Mongo::Exhibit.create(exhibit_properties.merge(:user_id => mongo_user.id))

    mongo_user_ids    << mongo_user.id.to_s
    mongo_exhibit_ids << mongo_exhibit.id.to_s

    mysql_user = User.new(user_properties)
    mysql_user.save!
    mysql_exhibit = Exhibit.new(exhibit_properties.merge(:user_id => mysql_user.id))
    mysql_exhibit.save!

    mysql_user_ids    << mysql_user.id
    mysql_exhibit_ids << mysql_exhibit.id
  end

  # mysql dump
  `mysqldump -u #{c[:username]} #{"-p#{c[:password]}" unless c[:password].blank?} #{c[:database]} exhibits users > #{dump_sql}`
  # mongo dump
  `mongodump -d #{c[:database]} -c users -o #{dump_dir_mongo}`
  `mongodump -d #{c[:database]} -c exhibits -o #{dump_dir_mongo}`
end

RBench.run(TIMES) do
  column :times
  column :mysql, :title => 'MySQL Adapter'
  column :mongo, :title => "Mongo Adapter"
  column :diff, :compare => [:mysql, :mongo]

  report 'Model#id', (TIMES * 100).ceil do
    mysql_obj = Exhibit.get(mysql_exhibit_ids.first)
    mongo_obj = Mongo::Exhibit.get(mongo_exhibit_ids.first)

    mysql { mysql_obj.id }
    mongo { mongo_obj.id }
  end

  report 'Model.get specific (not cached)' do
    mysql { touch_attributes(Exhibit.get(mysql_exhibit_ids.first)) }
    mongo { touch_attributes(Mongo::Exhibit.get(mongo_exhibit_ids.first)) }
  end

  report 'Model.get specific (cached)' do
    Exhibit.repository(:mysql) { mysql { touch_attributes(Exhibit.get(mysql_exhibit_ids.first)) } }
    Mongo::Exhibit.repository(:default) { mongo { touch_attributes(Mongo::Exhibit.get(mongo_exhibit_ids.first)) } }
  end

  report 'Model.first' do
    mysql { touch_attributes(Exhibit.first) }
    mongo { touch_attributes(Mongo::Exhibit.first) }
  end

  report 'Model.all limit(100)', (TIMES / 100).ceil do
    mysql { touch_attributes(Exhibit.all(:limit => 100)) }
    mongo { touch_attributes(Mongo::Exhibit.all(:limit => 100)) }
  end

  report 'Model.all limit(10,000)', (TIMES / 1000).ceil do
    mysql { touch_attributes(Exhibit.all(:limit => 10_000)) }
    mongo { touch_attributes(Mongo::Exhibit.all(:limit => 10_000)) }
  end

  exhibit = {
    :name       => Faker::Company.name,
    :notes      => Faker::Lorem.paragraphs.join($/),
    :created_on => today
  }

  report 'Model.create' do
    mysql { Exhibit.create(exhibit) }
    mongo { Mongo::Exhibit.create(exhibit) }
  end

  report 'Resource#attributes=' do
    attrs_first  = { :name => 'sam', :notes => 'foo bar' }
    attrs_second = { :name => 'tom', :notes => 'foo bar' }
    mysql { exhibit = Exhibit.new(attrs_first); exhibit.attributes = attrs_second }
    mongo { exhibit = Mongo::Exhibit.new(attrs_first);   exhibit.attributes = attrs_second }
  end

  report 'Resource#update' do
    mysql { Exhibit.get(mysql_user_ids.first).update(:name => 'bob') }
    mongo { Mongo::Exhibit.get(mongo_exhibit_ids.first).update(:name => 'bob') }
  end

  report 'Resource#destroy' do
    mysql { Exhibit.first.destroy }
    mongo { Mongo::Exhibit.first.destroy }
  end

  summary 'Total'
end
