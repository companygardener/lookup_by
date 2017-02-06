require "rails_helper"
require "lookup_by"

describe LookupBy::Cache do
  subject { State.lookup }

  describe "#clear" do
    it "clears the cache" do
      expect { subject.clear }.to     change(subject.cache, :size).from(1).to(0)
      expect { subject.clear }.not_to change(subject.cache, :size)
    end
  end

  describe "#reload" do
    before(:each) { subject.clear }

    it "loads the cache" do
      expect { subject.reload }.to     change(subject.cache, :size).from(0).to(1)
      expect { subject.reload }.not_to change(subject.cache, :size)
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

  # @todo Add tests
  # #initialize
  # #create
  # #create!
  # #seed
  # #fetch
  # #has_cache?
  # #read_through?
  # #allow_blank?
end
