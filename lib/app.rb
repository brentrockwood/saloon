require 'rubygems'
require 'sinatra'

require File.dirname(__FILE__) + '/store'

mime :atom_service,   'application/atomsvc+xml'
mime :atom_feed,      'application/atom+xml'
mime :atom_entry,     'application/atom+xml;type=entry'

configure do
  DatabaseName = 'saloonrb'
end

helpers do
  def store
    @store ||= Store.new(DatabaseName)
  end

  def location(uri)
    header['Location'] = uri.to_s
  end
end

error CollectionNotFound do
  status 404
end

error EntryNotFound do
  status 404
end

get '/' do
  content_type :atom_service
  store.service_document.to_s
end

get '/:collection' do
  content_type :atom_feed
  store.find_collection(params[:collection]).to_s
end

post '/:collection' do
  entry = store.create_entry(params[:collection], request.body.read)
  status 201
  content_type :atom_entry
  location entry.edit_url
  entry.to_s
end

get '/:collection/:entry' do
  content_type :atom_entry
  store.find_entry(params[:collection], params[:entry]).to_s
end

put '/:collection/:entry' do
  entry = store.update_entry(params[:collection], params[:entry], request.body.read)
  content_type :atom_entry
  location entry.edit_url
  entry.to_s
end

delete '/:collection/:entry' do
  store.delete_entry(params[:collection], params[:entry])
  ''
end
