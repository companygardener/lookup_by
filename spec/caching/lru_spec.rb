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
      @cache[1].should eq "one"
      @cache[2].should eq "two"
    end

    it "drops oldest" do
      @cache[3] = "three"

      @cache[1].should be_nil
    end

    it "keeps gets" do
      @cache[1]
      @cache[3] = "three"

      @cache[1].should eq "one"
      @cache[2].should be_nil
      @cache[3].should eq "three"
    end

    it "keeps sets" do
      @cache[1] = "one"
      @cache[3] = "three"

      @cache[1].should eq "one"
      @cache[2].should be_nil
      @cache[3].should eq "three"
    end

    it "#clear" do
      cache = LRU.new(2)

      cache[1] = "one"
      cache.size.should eq 1
      cache.clear
      cache.size.should eq 0
    end

    specify "#merge" do
      @cache.merge(1 => "change", 3 => "three").should
        eq(1 => "change", 2 => "two", 3 => "three")
    end

    specify "#merge!" do
      cache = LRU.new(3)

      cache[1] = "one"
      cache[2] = "two"

      cache.merge!(1 => "change", 3 => "three")
      cache.should eq(1 => "change", 2 => "two", 3 => "three")
    end

    it "better include the values under test" do
      expect(subject.to_h).to eq(1 => "one", 2 => "two")
    end
  end
end
