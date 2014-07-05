require "spec_helper"
require "lookup_by/caching/lru"

include LookupBy::Caching

module LookupBy::Caching
  describe LRU do
    before(:each) do
      @cache = LRU.new(2)

      @cache[1] = "one"
      @cache[2] = "two"
    end

    subject { @cache }

    it "stores entries" do
      expect(@cache[1]).to eq "one"
      expect(@cache[2]).to eq "two"
    end

    it "drops oldest" do
      @cache[3] = "three"

      expect(@cache[1]).to be_nil
    end

    it "keeps gets" do
      @cache[1]
      @cache[3] = "three"

      expect(@cache[1]).to eq "one"
      expect(@cache[2]).to be_nil
      expect(@cache[3]).to eq "three"
    end

    it "keeps sets" do
      @cache[1] = "one"
      @cache[3] = "three"

      expect(@cache[1]).to eq "one"
      expect(@cache[2]).to be_nil
      expect(@cache[3]).to eq "three"
    end

    it "#clear" do
      cache = LRU.new(2)

      cache[1] = "one"
      expect(cache.size).to eq 1
      cache.clear
      expect(cache.size).to eq 0
    end

    specify "#merge" do
      merged = @cache.merge(1 => "change", 3 => "three")
      expect(merged).to eq(1 => "change", 2 => "two", 3 => "three")
    end

    specify "#merge!" do
      cache = LRU.new(3)

      cache[1] = "one"
      cache[2] = "two"

      cache.merge!(1 => "change", 3 => "three")
      expect(cache).to eq(1 => "change", 2 => "two", 3 => "three")
    end

    it "better include the values under test" do
      expect(subject.to_h).to eq(1 => "one", 2 => "two")
    end
  end
end
