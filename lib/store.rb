$:.unshift File.dirname(__FILE__) + '/../vendor/couchrest/lib'

require 'rubygems'
require 'couch_rest'
require 'atom/entry'
require 'atom/collection'

class CollectionNotFound < RuntimeError; end
class EntryNotFound < RuntimeError; end

class Store
  attr_reader :db_name

  def initialize(db_name)
    @db_name = db_name
  end

  def find_collection(collection)
    rows = database.view('collection/all', :key => collection, :count => 1)['rows']
    raise CollectionNotFound if rows.empty?
    rows.first.to_atom_feed
  end

  def find_entry(collection, entry)
    rows = database.view('entry/by_collection', :key => [collection, entry], :count => 1)['rows']
    raise EntryNotFound if rows.empty?
    rows.first.to_atom_entry
  end

  private
    def server
      @server ||= CouchRest.new
    end

    def database
      @database ||= server.database(db_name)
    end
end
