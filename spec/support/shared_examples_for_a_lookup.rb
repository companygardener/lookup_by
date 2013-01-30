shared_examples "a lookup" do
  it { should respond_to :[] }
  it { should respond_to :lookup }
  it { should respond_to :lookup_by  }
  it { should respond_to :lookup_for }
  its(:is_a_lookup?) { should be_true }

  it "returns nil for nil" do
    subject[nil].should be_nil
  end

  it "returns nil for empty strings" do
    subject[""].should be_nil
  end

  it "returns itself" do
    first = subject.first
    subject[first].should eq first if first
  end

  it "rejects other argument types" do
    [1.00, true, false, Address.new].each do |value|
      expect { subject[value] }.to raise_error TypeError
    end
  end

  it "proxies create!" do
    expect { subject.lookup.create!(name: "add to cache") }.to change(subject, :count).by(1)
  end
end

shared_examples "a proxy" do
  it "does not cache records" do
    original = subject.create(name: "original")

    subject.lookup.reload

    subject[original.name]
    subject.update(original.id, name: "updated")
    subject[original.id].name.should_not eq original.name
  end
end

shared_examples "a cache" do
  it "caches records" do
    was_enabled = subject.lookup.enabled
    subject.lookup.enabled = true

    original = subject.create(name: "original")

    subject.lookup.reload
    subject[original.name]

    subject.update(original.id, subject.lookup.field => "updated")
    subject[original.id].name.should eq "original"

    subject.lookup.enabled = was_enabled
  end
end

shared_examples "a strict cache" do
  it "caches .count" do
    expect { subject.create(name: "new") }.to_not change(subject, :count)
  end

  it "caches .all" do
    expect { subject.create(name: "add") }.to_not change(subject, :all)
  end

  it "caches .pluck" do
    subject.create(name: "pluck this")
    subject.pluck(:name).should_not include("pluck this")
  end

  it "returns nil on miss" do
    subject["foo"].should be_nil
  end

  it "ignores new records" do
    subject.create(name: "new record")

    subject["new record"].should be_nil
  end
end

shared_examples "a read-through proxy" do
  it "reloads .count" do
    expect { subject.create(name: "new") }.to change(subject, :count)
  end

  it "reloads .all" do
    expect { subject.create(name: "add") }.to change(subject, :all)
  end

  it "reloads .pluck" do
    subject.create(name: "pluck this")
    subject.pluck(subject.lookup.field).should include("pluck this")
  end

  it "finds new records" do
    created = subject.create(name: "new record")
    subject["new record"].id.should eq created.id
  end
end

shared_examples "a read-through cache" do
  it_behaves_like "a read-through proxy"

  it "caches new records" do
    was_enabled = subject.lookup.enabled
    subject.lookup.enabled = true

    created = subject.create(name: "cached")

    subject.lookup.reload
    subject[created.name]

    subject.update(created.id, name: "changed")
    subject[created.id].name.should eq "cached"

    subject.lookup.enabled = was_enabled
  end
end

shared_examples "a write-through proxy" do
  it "creates missing records" do
    expect { subject["not found"] }.to change(subject, :count)
  end
end

shared_examples "a write-through cache" do
  it_behaves_like "a write-through proxy"

  it "does not cache new records" do
    subject.lookup.reload
    found = subject["found"]

    subject.update(found.id, name: "missing")
    subject[found.id].name.should eq "missing"
  end
end

shared_examples "a lookup for" do |field|
  it { should respond_to field }
  it { should respond_to "#{field}=" }
  it { should respond_to "raw_#{field}" }
  it { should respond_to "#{field}_before_type_cast" }

  it "accepts nil" do
    expect { subject.send "#{field}=", nil }.to_not raise_error
  end

  it "converts empty strings to nil" do
    subject.send "#{field}=",  ""
    subject.send(field).should be_nil
  end

  it "rejects other argument types" do
    [1.00, true, false, Address.new].each do |value|
      expect { subject.send "#{field}=", value  }.to raise_error TypeError
    end
  end
end
