require "rails_helper"
require "lookup_by"

describe LookupBy::Cache do
  subject { State.lookup }

  describe "#clear" do
    it "clears the cache" do
      expect { subject.clear }.to     change(subject.cache, :size).from(1).to(0)
      expect { subject.clear }.not_to change(subject.cache, :size)
    end

    it "clears the reverse cache" do
      expect { subject.clear }.to     change(subject.reverse, :size).from(1).to(0)
      expect { subject.clear }.not_to change(subject.reverse, :size)
    end
  end

  describe "#reload" do
    before(:each) { subject.clear }

    it "loads the cache" do
      expect { subject.reload }.to     change(subject.cache, :size).from(0).to(1)
      expect { subject.reload }.not_to change(subject.cache, :size)
    end

    it "loads the reverse cache" do
      expect { subject.reload }.to     change(subject.reverse, :size).from(0).to(1)
      expect { subject.reload }.not_to change(subject.reverse, :size)
    end
  end

  describe "#disable!" do
    it "disables the cache" do
      subject.disable!

      expect(subject).to be_disabled
    end

    it "clears the cache once" do
      expect(subject).to receive(:clear).once

      subject.disable!
      subject.disable!
    end
  end

  describe "#disabled?" do
    it "toggles correctly" do
      expect(subject).not_to be_disabled

      subject.disable!

      expect(subject).to be_disabled
    end
  end

  describe "#enable!" do
    before(:each) { subject.disable! }

    it "enables the cache" do
      expect(subject).not_to be_enabled

      subject.enable!

      expect(subject).to be_enabled
    end

    it "does not reload if already enabled" do
      expect(subject).to receive(:reload).once

      subject.enable!
      subject.enable!
    end
  end

  describe "#while_disabled" do
    it "raises without a block" do
      expect { subject.while_disabled }.to raise_error(ArgumentError)
    end

    it "disables the cache while running the block" do
      expect(subject).to be_enabled

      subject.while_disabled do
        expect(subject).to be_disabled
        expect(subject.cache.size).to eq(0)
      end

      expect(subject).to be_enabled
    end
  end

  describe "#initialize" do
    let(:klass) do
      Class.new(ActiveRecord::Base) do
        self.table_name = "states"
      end
    end

    it "raises ArgumentError for unknown field" do
      expect {
        LookupBy::Cache.new(klass, field: :nonexistent)
      }.to raise_error(ArgumentError, /unknown attribute/)
    end

    it "sets @type to :all for cache: true" do
      cache = LookupBy::Cache.new(klass, field: :state, cache: true)
      expect(cache.instance_variable_get(:@type)).to eq(:all)
    end

    it "sets @type to :lru for cache: N" do
      cache = LookupBy::Cache.new(klass, field: :state, cache: 10)
      expect(cache.instance_variable_get(:@type)).to eq(:lru)
    end

    it "raises when find_or_create used with cache: true" do
      expect {
        LookupBy::Cache.new(klass, field: :state, cache: true, find_or_create: true)
      }.to raise_error(ArgumentError, /cache: true/)
    end

    it "raises when raise used with find_or_create" do
      expect {
        LookupBy::Cache.new(klass, field: :state, find_or_create: true, raise: true)
      }.to raise_error(ArgumentError, /raise.*find_or_create/)
    end
  end

  describe "#create" do
    it "creates and caches a record" do
      record = State.lookup.create(state: "ZZ")
      expect(record).to be_persisted
      expect(State.lookup.cache[record.id]).to eq(record)
    end
  end

  describe "#create!" do
    it "raises on invalid input" do
      expect { State.lookup.create!(state: nil) }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end

  describe "#seed" do
    it "seeds new values" do
      subject.seed("AA", "BB")
      expect(State.where(state: "AA")).to exist
      expect(State.where(state: "BB")).to exist
    end

    it "skips existing values" do
      expect { subject.seed("AL") }.not_to raise_error
    end
  end

  describe "#fetch" do
    it "returns cached record for known value" do
      result = State.lookup.fetch("AL")
      expect(result).to be_a(State)
      expect(result.state).to eq("AL")
    end

    it "returns nil for unknown value when not read-through" do
      expect(State.lookup.fetch("NONEXISTENT")).to be_nil
    end

    it "reads through to DB on cache miss" do
      PostalCode.create!(postal_code: "99999")
      result = PostalCode.lookup.fetch("99999")
      expect(result).to be_a(PostalCode)
      expect(result.postal_code).to eq("99999")
    end

    it "raises LookupBy::RecordNotFound when raise: true and value missing" do
      expect {
        Raisin.lookup.fetch("NONEXISTENT")
      }.to raise_error(LookupBy::RecordNotFound)
    end
  end

  describe "#has_cache?" do
    it "returns true for cached models" do
      expect(State.lookup.has_cache?).to be true
    end

    it "returns falsey for uncached models" do
      expect(City.lookup.has_cache?).to be_falsey
    end
  end

  describe "#read_through?" do
    it "returns false for cache: true" do
      expect(State.lookup.read_through?).to be false
    end

    it "returns true for cache: N" do
      expect(PostalCode.lookup.read_through?).to be true
    end
  end

  describe "#allow_blank?" do
    it "returns false by default" do
      expect(State.lookup.allow_blank?).to be false
    end
  end
end
