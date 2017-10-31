require "rails_helper"
require "lookup_by"

describe LookupBy do
  describe ".register" do
    it "adds its argument to .lookups" do
      LookupBy.register(Array)
      expect(LookupBy.classes).to include(Array)
      LookupBy.classes.delete(Array)
    end

    it "doesn't register classes twice" do
      LookupBy.register(Array)
      LookupBy.register(Array)

      expect(LookupBy.classes.select { |l| l == Array }.size).to eq(1)

      LookupBy.classes.delete(Array)
    end
  end

  describe ".clear" do
    it "clears all lookup caches" do
      Path.lookup.cache[1] = "remove-this"
      Path.lookup.reverse["remove-this"] = "remove-this"

      expect { LookupBy.clear }.to change { Path.lookup.cache.size }.
        and change { Path.lookup.reverse.size }
    end
  end

  describe ".disable and .enable" do
    it "affects all lookups" do
      expect(City.lookup.enabled?).to eq(true)
      LookupBy.disable
      expect(City.lookup.enabled?).to eq(false)
      LookupBy.enable
      expect(City.lookup.enabled?).to eq(true)
    end
  end
end

describe ::ActiveRecord::Base do
  describe "macro methods" do
    subject { described_class }

    it { is_expected.to respond_to :lookup_by    }
    it { is_expected.to respond_to :is_a_lookup? }
  end

  describe ".lookup_by" do
    class CityTest < ActiveRecord::Base
      self.table_name = "cities"
      lookup_by :city
    end

    it "registers lookup models" do
      expect(LookupBy.classes).to include(CityTest)
    end
  end

  describe "instance methods" do
    subject { Status.new }

    it { is_expected.to respond_to :name }
  end
end

describe LookupBy::Lookup::ClassMethods do
  describe "#seed" do
    it "accepts multiple values" do
      City.seed 'Boston'
      City.seed 'Chicago', 'New York City'

      expect(City.pluck(:city).sort).to eq(['Boston', 'Chicago', 'New York City'])
    end

    it "accepts duplicates" do
      expect { City.seed 'Chicago', 'Chicago' }.not_to raise_error

      expect(City.pluck(:city)).to eq(['Chicago'])
    end
  end
end

describe LookupBy::Lookup do
  describe "#clear" do
    it "clears the cache" do
      expect(State.lookup.cache).to be_present
      State.lookup.clear
      expect(State.lookup.cache).to be_empty
    end
  end

  describe "#load" do
    it "populates the cache" do
      State.lookup.clear
      expect(State.lookup.cache).to be_empty
      State.lookup.load
      expect(State.lookup.cache).to be_present
    end
  end

  context "Uncacheable.lookup_by :column, cache: true, find_or_create: true" do
    it "fails when trying to cache and write-through" do
      expect { Uncacheable }.to raise_error(ArgumentError)
    end
  end

  context "City.lookup_by :column" do
    subject { City }

    it_behaves_like "a lookup"
    it_behaves_like "a proxy"
    it_behaves_like "a read-through proxy"

    it "returns nil on db miss" do
      expect(subject["foo"]).to be_nil
    end
  end

  context "Status.lookup_by :column, normalize: true" do
    subject { Status }

    it_behaves_like "a lookup"
    it_behaves_like "a proxy"
    it_behaves_like "a read-through proxy"

    it "normalizes the lookup field" do
      status = subject.create(subject.lookup.field => "paid")

      expect(subject["  paid "].id).to eq(status.id)
    end

    it "has a small primary key" do
      sql_type = Status.columns_hash['status_id'].sql_type
      expect(sql_type).to eq('smallint')
    end
  end

  context "EmailAddress.lookup_by :column, find_or_create: true" do
    subject { EmailAddress }

    it_behaves_like "a lookup"
    it_behaves_like "a proxy"
    it_behaves_like "a read-through proxy"
    it_behaves_like "a write-through proxy"
  end

  context "State.lookup_by :column, cache: true" do
    subject { State }

    it_behaves_like "a lookup"
    it_behaves_like "a cache"
    it_behaves_like "a strict cache"

    it "preloads the cache" do
      class StateTest < ActiveRecord::Base
        self.table_name = "states"
        lookup_by :state, cache: true
      end

      expect(StateTest.lookup.cache).not_to be_empty
    end
  end

  context "Account.lookup_by :column, cache: true, strict: false" do
    subject { Account }

    it_behaves_like "a lookup"
    it_behaves_like "a cache"
    it_behaves_like "a read-through cache"
  end

  context "PostalCode.lookup_by :column, cache: N" do
    subject { PostalCode }

    it_behaves_like "a lookup"
    it_behaves_like "a cache"
    it_behaves_like "a read-through cache"

    it "is not testing when not writing through the LRU" do
      expect(subject.lookup.testing).to be false
    end
  end

  context "UserAgent.lookup_by :column, cache: N, find_or_create: true" do
    subject { UserAgent }

    it_behaves_like "a lookup"
    it_behaves_like "a cache"
    it_behaves_like "a read-through cache"
    it_behaves_like "a write-through cache"

    it "sets testing when RAILS_ENV=test" do
      expect(subject.lookup.testing).to be true
    end

    it "does not write primary keys" do
      expect { UserAgent[1] }.to_not raise_error
    end

    # Has begin..ensure to prevent monkey patch from leaking.
    it "handles the race condition on write-throughs" do
      begin
        class ::LookupBy::Cache
          alias fetch_old fetch

          def fetch(value)
            db_write(value)
            db_write(value)
          end
        end

        expect { UserAgent.transaction { UserAgent["Mozilla"].destroy } }.to_not raise_error
      ensure
        class ::LookupBy::Cache
          alias fetch fetch_old
          undef fetch_old
        end
      end
    end
  end

  context "IpAddress.lookup_by :column, cache: N, find_or_create: true" do
    subject { IpAddress }

    let(:value) { '127.0.0.1' }
    let(:ip)    { subject[value] }

    it "allows lookup by IPAddr" do
      expect(subject[IPAddr.new(value)]).to eq(ip)
      expect(subject[ip]).to eq(ip)
      expect(subject[ip.id]).to eq(ip)
      expect(subject[value]).to eq(ip)
    end

    it 'caches values' do
      subject.lookup.testing = false

      subject[value]

      id1 = subject[IPAddr.new(value)].object_id
      id2 = subject[ip.id].object_id
      id3 = subject[value].object_id
      id4 = subject[ip].object_id

      expect([id1, id2, id3, id4].uniq.size).to eq(1)

      subject.lookup.testing = true
      subject.lookup.clear
    end
  end

  context "Path.lookup_by :column, cache: N, find_or_create: true (UUID primary key)" do
    subject { Path }

    it_behaves_like "a lookup"
    it_behaves_like "a cache"
    it_behaves_like "a read-through cache"
    it_behaves_like "a write-through cache"

    it 'treats UUIDs as the primary key' do
      path = subject['/']
      expect(path.id).to match(LookupBy::UUID_REGEX)
      expect(subject[path.id]).to eq(path)
    end
  end

  context "Raisin.lookup_by :column, cache: true, raise: true" do
    subject { Raisin }

    it_behaves_like "a lookup"
    it_behaves_like "a cache"

    it "raises LookupBy::RecordNotFound on cache miss" do
      expect {
        subject[:not_disgusting]
      }.to raise_error(LookupBy::RecordNotFound, /Raisin.*not_disgusting/)
    end
  end

  context "ReadThroughRaisin.lookup_by :column, cache: true, find: true, raise: true" do
    subject { ReadThroughRaisin }

    it_behaves_like "a lookup"
    it_behaves_like "a cache"
    it_behaves_like "a read-through cache"

    it "raises LookupBy::RecordNotFound on cache and DB miss" do
      expect {
        subject[:tasty]
      }.to raise_error(LookupBy::RecordNotFound, /Raisin.*tasty/)
    end
  end

  context "Raisin.lookup_by :column, find_or_create: true, raise: true" do
    it "raises ArgumentError, as `raise` and `find_or_create` can not exist" do
      expect {
        class WriteThroughRaisin < ActiveRecord::Base
          self.table_name = 'raisins'
          lookup_by :raisin, find_or_create: true, raise: true
        end
      }.to raise_error(ArgumentError)
    end
  end

  context "Unsynchronizable.lookup_by :column, cache: 1, find_or_create: true, safe: true" do
    subject { Unsynchronizable }

    it_behaves_like "a lookup"
    it_behaves_like "a cache"
    it_behaves_like "a read-through cache"
    it_behaves_like "a write-through cache"

    it "does not deadlock when synchronizing access" do
      expect {
        Unsynchronizable['foo']
        Unsynchronizable['foo']
        Unsynchronizable['bar']
      }.to_not raise_error
    end
  end
end
