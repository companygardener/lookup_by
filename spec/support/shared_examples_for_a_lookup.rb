shared_examples "a lookup" do
  it { is_expected.to respond_to :[] }
  it { is_expected.to respond_to :lookup }
  it { is_expected.to respond_to :lookup_by  }
  it { is_expected.to respond_to :lookup_for }

  it "better be a lookup" do
    expect(subject.is_a_lookup?).to be true
  end

  it "raises with no args" do
    expect { subject[] }.to raise_error ArgumentError
  end

  it "returns nil for nil" do
    expect(subject[nil]).to be_nil
    expect(subject[nil, nil]).to eq([nil, nil])
  end

  it "returns nil for empty strings" do
    expect(subject[""]).to be_nil
    expect(subject["", ""]).to eq([nil, nil])
  end

  it "returns itself" do
    if first = subject.first
      expect(subject[first]).to eq first
      expect(subject[first, first]).to eq([first, first])
    end
  end

  it "rejects other argument types" do
    [1.00, true, false, Rational(1), Address.new, Array.new, Hash.new].each do |value|
      expect { subject[value] }.to        raise_error TypeError
      expect { subject[value, value] }.to raise_error TypeError
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
    expect(subject[original.id].name).not_to eq original.name
  end

  it "allows .destroy_all" do
    expect { subject.destroy_all }.to_not raise_error
  end

  it "allows .destroy" do
    instance = subject.create(name: "foo")
    expect(subject.destroy(instance.id)).to eq(instance)
  end

  it "allows .delete_all" do
    expect { subject.delete_all }.to_not raise_error
  end

  it "allows .delete" do
    expect(subject.delete(1)).to eq(0)
  end
end

shared_examples "a cache" do
  it "caches records" do
    was_testing = subject.lookup.testing
    subject.lookup.testing = false

    original = subject.create(name: "original")

    subject.lookup.reload
    subject[original.name]

    subject.update(original.id, subject.lookup.field => "updated")
    expect(subject[original.id].name).to eq "original"

    subject.lookup.testing = was_testing
  end

  it "raises on .destroy_all" do
    expect { subject.destroy_all }.to raise_error NotImplementedError, /destroy_all.*not supported/
  end

  it "raises on .destroy(id)" do
    expect { subject.destroy(1) }.to raise_error NotImplementedError, /destroy.*not supported/
  end

  it "raises on .delete_all" do
    expect { subject.delete_all }.to raise_error NotImplementedError, /delete_all.*not supported/
  end

  it "raises on .delete(id)" do
    expect { subject.delete(1) }.to raise_error NotImplementedError, /delete.*not supported/
  end
end

shared_examples "a strict cache" do
  it "caches .count" do
    expect { subject.create(name: "new") }.to_not change(subject, :count)
  end

  it "caches .all" do
    new = subject.create(name: 'add')
    expect(subject.all.to_a).not_to include(new)
  end

  it "caches .pluck" do
    subject.create(name: "pluck this")
    expect(subject.pluck(:name)).not_to include("pluck this")
  end

  it "returns nil on miss" do
    expect(subject["foo"]).to be_nil
  end

  it "ignores new records" do
    subject.create(name: "new record")

    expect(subject["new record"]).to be_nil
  end
end

shared_examples "a read-through proxy" do
  it "reloads .count" do
    expect { subject.create(name: "new") }.to change(subject, :count)
  end

  it "reloads .all" do
    new = subject.create(name: 'add')
    expect(subject.all.to_a).to include (new)
  end

  it "reloads .pluck" do
    subject.create(name: "pluck this")
    expect(subject.pluck(subject.lookup.field)).to include("pluck this")
  end

  it "finds new records" do
    created = subject.create(name: "new record")
    expect(subject["new record"].id).to eq created.id
  end
end

shared_examples "a read-through cache" do
  it_behaves_like "a read-through proxy"

  it "caches new records" do
    was_testing = subject.lookup.testing
    subject.lookup.testing = false

    created = subject.create(name: "cached")

    subject.lookup.reload
    subject[created.name]

    subject.update(created.id, name: "changed")
    expect(subject[created.id].name).to eq "cached"

    subject.lookup.testing = was_testing
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
    expect(subject[found.id].name).to eq "missing"
  end
end

shared_examples "a lookup for" do |field|
  it { is_expected.to respond_to field }
  it { is_expected.to respond_to "#{field}=" }
  it { is_expected.to respond_to "raw_#{field}" }
  it { is_expected.to respond_to "#{field}_before_type_cast" }

  it "accepts nil" do
    expect { subject.send "#{field}=", nil }.to_not raise_error
  end

  it "converts empty strings to nil" do
    subject.send "#{field}=", ""
    expect(subject.send(field)).to be_nil
  end

  it "rejects other argument types" do
    [1.00, true, false, Address.new].each do |value|
      expect { subject.send "#{field}=", value  }.to raise_error TypeError
    end
  end
end
