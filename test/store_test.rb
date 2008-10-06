require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/store'

describe 'Store' do
  setup do
    @database = stub('couchdb database', :view => '')
    @store = Store.new(TestDatabase)
    @store.stubs(:database).returns(@database)
  end

  it 'has a  db_name' do
    @store.db_name.should.equal TestDatabase
  end

  describe 'When finding a collection' do
    def do_find
      @store.find_collection('my_collection')
    end

    setup do
      @rows = [{'title' => 'foo', 'content' => 'bar'}]
      @database.stubs(:view).returns('rows' => @rows)
    end

    it 'finds the collection using the view collection/all' do
      @database.expects(:view).with('collection/all', :key => 'my_collection', :count => 1).
        returns('rows' => @rows)
      do_find
    end

    it 'raises CollectionNotFound if no collection were found' do
      @database.stubs(:view).returns('rows' => [])
      lambda { do_find }.should.raise CollectionNotFound
    end

    it 'converts the result to an Atom::Feed using Hash#to_atom_feed' do
      @rows.first.expects(:to_atom_feed)
      do_find
    end

    it 'returns an Atom::Feed' do
      do_find.should.be.an.instance_of(Atom::Feed)
    end
  end

  describe 'When finding an entry' do
    def do_find
      @store.find_entry('my_collection', 'my_entry')
    end

    it 'finds the entry using the view entry/by_collection' do
    end
  end
end
