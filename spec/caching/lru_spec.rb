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
    specify { expect(cache.clear).to be_empty }
  end

  describe "#count" do
    specify { expect(cache.count).to eq 2 }
  end

  describe "#delete" do
    specify { expect(cache.delete(1)).to eq "one" }
    specify { expect(cache.delete(3)).to be_nil }
  end

  describe "#fetch" do
    specify { expect(cache.fetch(1)).to eq "one" }
    specify { expect(cache.fetch(3) { |key| key }).to eq 3 }
    specify { expect { cache.fetch(3) }.to raise_error }

    it "writes missing values" do
      expect(cache.fetch(3) { "missing" }).to eq "missing"
      expect(cache.fetch(3)).to eq "missing"
      expect(cache[1]).to be_nil
    end
  end

  describe "#key?" do
    specify { expect(cache.key?(1)).to eq true  }
    specify { expect(cache.key?(3)).to eq false }
  end

  describe "#max_size=" do
    specify { expect { cache.max_size = -1 }.to raise_error }
  end

  describe "#size" do
    specify { expect(cache.size).to eq 2 }
  end

  describe "#to_a" do
    specify { expect(cache.to_a).to eq [[1, "one"], [2, "two"]] }
  end

  describe "#to_h" do
    specify { expect(cache.to_h).to eq(1 => "one", 2 => "two") }
  end

  describe "#values" do
    specify { expect(cache.values).to eq ["one", "two"] }
  end
end
