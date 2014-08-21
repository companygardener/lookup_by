require "rails_helper"
require "lookup_by"

describe ::ActiveRecord::Base do
  describe "macro methods" do
    subject { described_class }

    it { is_expected.to respond_to :lookup_by    }
    it { is_expected.to respond_to :is_a_lookup? }
  end

  describe "instance methods" do
    subject { Status.new }

    it { is_expected.to respond_to :name }
  end

end

describe LookupBy::Lookup do
  describe "cache" do
    it "seeds values" do
      City.lookup.seed 'Boston'
      City.lookup.seed 'Chicago', 'New York City'

      names = City.all.map(&:name).sort
      expect(names.sort).to eq(['Boston', 'Chicago', 'New York City'])
      City.lookup.clear
    end
  end

  context "Uncacheable.lookup_by :column, cache: true, find_or_create: true" do
    it "fails when trying to cache and write-through" do
      expect { Uncacheable }.to raise_error
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
      expect(subject.lookup.cache).not_to be_empty
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

    it "allows lookup by IPAddr" do
      ip = subject['127.0.0.1']

      expect(subject[IPAddr.new('127.0.0.1')]).to eq(ip)
      expect(subject[ip.id]).to eq(ip)
      expect(subject['127.0.0.1']).to eq(ip)
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
