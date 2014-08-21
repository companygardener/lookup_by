require "rails_helper"
require "lookup_by/caching/lru"

include LookupBy::Caching

describe LookupBy::Caching::LRU do
  let(:cache) do
    cache = LRU.new(2)

    cache[1] = "one"
    cache[2] = "two"
    cache
  end

  describe "#[]" do
    it "caches" do
      expect(cache[1]).to eq "one"
      expect(cache[2]).to eq "two"
    end

    it "promotes gets" do
      cache[1]
      cache[3] = "three"

      expect(cache[2]).to be_nil
    end
  end

  describe "#[]=" do
    it "promotes sets" do
      cache[3] = "three"

      expect(cache[1]).to be_nil
    end

    it "deletes least-recently accessed value" do
      cache[3] = "three"

      expect(cache[1]).to be_nil
    end
  end

  describe "#clear" do
    specify { expect(cache.clear.size).to eq 0 }
  end

  describe "#size" do
    specify { expect(cache.size).to eq 2 }
  end

  describe "#values" do
    specify { expect(cache.values).to eq ["one", "two"] }
  end

  describe "#to_h" do
    specify { expect(cache.to_h).to eq(1 => "one", 2 => "two") }
  end
end
