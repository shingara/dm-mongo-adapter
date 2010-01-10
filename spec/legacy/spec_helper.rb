require File.join(File.dirname(__FILE__), '..', 'spec_helper')
$db = Mongo::Connection.new.db('dm-mongo-test')
include DataMapper::Mongo
