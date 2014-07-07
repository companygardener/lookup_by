require "spec_helper"
require "lookup_by"
require "pry"

describe ::ActiveRecord::Base do
  describe "macro methods" do
    subject { described_class }

    it { should respond_to :lookup_by    }
    it { should respond_to :is_a_lookup? }
  end

  describe "instance methods" do
    subject { Status.new }

    it { should respond_to :name }
  end

end

describe LookupBy::Lookup do
  describe "cache" do
    it "seeds values" do
      City.lookup.seed 'Boston'
      City.lookup.seed 'Chicago', 'New York City'

      City.all.map(&:name).sort.should eq(['Boston', 'Chicago', 'New York City'])
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
      subject["foo"].should be_nil
    end
  end

  context "Status.lookup_by :column, normalize: true" do
    subject { Status }

    it_behaves_like "a lookup"
    it_behaves_like "a proxy"
    it_behaves_like "a read-through proxy"

    it "normalizes the lookup field" do
      status = subject.create(subject.lookup.field => "paid")

      subject["  paid "].id.should == status.id
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
      subject.lookup.cache.should_not be_empty
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
      subject.lookup.testing.should be false
    end
  end

  context "UserAgent.lookup_by :column, cache: N, find_or_create: true" do
    subject { UserAgent }

    it_behaves_like "a lookup"
    it_behaves_like "a cache"
    it_behaves_like "a read-through cache"
    it_behaves_like "a write-through cache"

    it "sets testing when RAILS_ENV=test" do
      subject.lookup.testing.should be true
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

      subject[IPAddr.new('127.0.0.1')].should == ip
      subject[ip.id].should == ip
      subject['127.0.0.1'].should == ip
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
      path.id.should match(LookupBy::UUID_REGEX)
      subject[path.id].should == path
    end
  end
end
