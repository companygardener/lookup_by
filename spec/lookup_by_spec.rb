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
      subject.lookup.testing.should be_false
    end
  end

  context "IpAddress.lookup_by :column, cache: N, find_or_create: true" do
    subject { IpAddress }

    it_behaves_like "a lookup"
    it_behaves_like "a cache"
    it_behaves_like "a read-through cache"
    it_behaves_like "a write-through cache"

    it "sets testing when RAILS_ENV=test" do
      subject.lookup.testing.should be_true
    end
  end
end
