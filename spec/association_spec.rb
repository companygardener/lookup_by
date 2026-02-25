require "rails_helper"
require "lookup_by"

describe ::ActiveRecord::Base do
  describe "macro methods" do
    subject { described_class }

    it { is_expected.to respond_to :lookup_for }
  end

  describe ".lookup_for" do
    subject { Address }

    it "doesn't clobber methods" do
      class << subject
        public :define_method, :remove_method
      end

      [:foo, :foo=, :raw_foo, :foo_before_type_cast, :foo?].each do |method|
        subject.define_method(method) { }

        expect { subject.lookup_for :foo }.to raise_error LookupBy::Error, /already exists/

        subject.remove_method(method)
      end

      class << subject.singleton_class
        public :define_method, :remove_method
      end

      subject.singleton_class.define_method(:with_foo) {}
      expect { subject.lookup_for :foo }.to raise_error LookupBy::Error, /already exists/
      subject.singleton_class.remove_method(:with_foo)
    end

    it "requires a foreign key" do
      expect(Rails.logger).to receive(:error)

      subject.lookup_for :missing, class_name: 'city'
    end

    it 'requires a class' do
      expect { subject.lookup_for :uninitialized }.to raise_error LookupBy::Error, /uninitialized constant/
    end

    it "rejects unsaved lookup values" do
      expect { subject.new.city = City.new(name: "Toronto") }.to raise_error ArgumentError, /must be saved/
    end

    it "requires the lookup model to be using lookup_by" do
      expect { subject.lookup_for :country }.to raise_error LookupBy::Error, /Country does not use lookup_by/
    end

    it "better include the association under test in lookups" do
      expect(subject.lookups).to include(:city)
    end
  end
end

describe LookupBy::Association do
  before do
    City.create(name: "New York")
  end

  subject { Address.new }

  context "Address.lookup_for :city, strict: false" do
    it_behaves_like "a lookup for", :city

    it "accepts Integers" do
      subject.city = City["New York"].id
      expect(subject.city).to eq "New York"
    end

    it "rejects symbols" do
      expect { subject.city = :invalid }.to raise_error ArgumentError
    end

    it "returns strings" do
      subject.city = "New York"
      expect(subject.city).to eq "New York"
    end

    it "allows missing values" do
      subject.city = "Chicago"
      expect(subject.city).to be_nil
    end
  end

  context "Address.lookup_for :state, symbolize: true" do
    it_behaves_like "a lookup for", :state

    it "allows symbols" do
      subject.state = :AL
      expect(subject.state).to eq :AL
    end

    it "returns symbols" do
      subject.state = "AL"
      expect(subject.state).to eq :AL
    end

    it "rejects missing values" do
      expect { subject.state = "FOO" }.to raise_error LookupBy::Error, /not in the .* lookup cache/
    end
  end

  context "Address.lookup_for :street" do
    it_behaves_like "a lookup for", :street

    it "accepts write-through values" do
      expect { subject.street = "Dearborn Street" }.to change(Street, :count)
    end
  end

  # spec/internal/lib/missing.rb
  context "Missing.lookup_for :city" do
    it "does not raise foreign key error when table hasn't been created" do
      expect { require "missing" }.to_not raise_error
    end
  end
end

describe LookupBy::Association, 'scopes' do
  subject(:klass) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'addresses'
    end
  end

  describe 'nomenclature' do
    context 'default of :with_<foreign_key>' do
      before { klass.lookup_for :city }
      it { is_expected.to respond_to(:with_city) }
    end

    context 'scope: false' do
      before { klass.lookup_for :city, scope: false }
      it { is_expected.not_to respond_to(:with_city) }
    end

    context 'scope: :with_alternate_name' do
      before { klass.lookup_for :city, scope: :with_home }
      it { is_expected.to respond_to(:with_home) }
    end

    context 'scope: "with_alternate_name"' do
      before { klass.lookup_for :city, scope: "with_home" }
      it { is_expected.to respond_to(:with_home) }
    end

    context 'default inverse scope of :without_<foreign_key>' do
      before { klass.lookup_for :city }
      it { is_expected.to respond_to(:without_city) }
    end

    context 'inverse_scope: false' do
      before { klass.lookup_for :city, inverse_scope: false }
      it { is_expected.not_to respond_to(:without_city) }
    end

    context 'inverse_scope: true' do
      before { klass.lookup_for :city, inverse_scope: true }
      it { is_expected.to respond_to(:without_city) }
    end

    context 'inverse_scope: :with_alternate_name' do
      before { klass.lookup_for :city, inverse_scope: :foreign_to }
      it { is_expected.to respond_to(:foreign_to) }
    end
  end

  context 'functionality' do
    before do
      City.create!(city: 'Chicago')
      City.create!(city: 'Madison')
      klass.lookup_for :city, scope: :inside_city, inverse_scope: :outside_city
    end

    let(:chicago) { City['Chicago'] }
    let(:madison) { City['Madison'] }

    specify 'with_city(a)' do
      scope = klass.inside_city('Chicago')
      expect(scope.to_sql).to eq klass.where(city_id: chicago.id).to_sql
    end

    specify 'with_city(a, b)' do
      scope = klass.inside_city('Chicago', 'Madison')
      expect(scope.to_sql).to eq klass.where(city_id: [chicago.id, madison.id]).to_sql
    end

    specify 'without_city(a)' do
      scope = klass.outside_city('Chicago')
      expect(scope.to_sql).to eq klass.where('city_id <> ?', chicago.id).to_sql
    end

    specify 'without_city(a, b)' do
      scope = klass.outside_city('Chicago', 'Madison')
      expect(scope.to_sql).to eq klass.where('city_id NOT IN (?)', [chicago.id, madison.id]).to_sql
    end
  end
end

describe LookupBy::Association, '.where' do
  before do
    City.create!(city: 'Chicago')
    City.create!(city: 'Madison')
    State.seed('Illinois', 'Wisconsin')
  end

  let!(:chicago_il) do
    Address.create!(
      address:        '100 Main St, Chicago, IL',
      city_id:        City['Chicago'].id,
      state_id:       State['Illinois'].id,
      street_id:      Street.create!(street: '100 Main St').id,
      postal_code_id: PostalCode.create!(postal_code: '60601').id
    )
  end

  let!(:madison_wi) do
    Address.create!(
      address:        '200 State St, Madison, WI',
      city_id:        City['Madison'].id,
      state_id:       State['Wisconsin'].id,
      street_id:      Street.create!(street: '200 State St').id,
      postal_code_id: PostalCode.create!(postal_code: '53703').id
    )
  end

  it 'resolves a single lookup value' do
    expect(Address.where(city: 'Chicago')).to eq [chicago_il]
  end

  it 'resolves an array of lookup values' do
    expect(Address.where(city: ['Chicago', 'Madison'])).to match_array [chicago_il, madison_wi]
  end

  it 'resolves multiple lookup attributes' do
    expect(Address.where(city: 'Chicago', state: 'Illinois')).to eq [chicago_il]
  end

  it 'passes through foreign key columns unchanged' do
    expect(Address.where(city_id: City['Chicago'].id)).to eq [chicago_il]
  end

  it 'passes through string conditions unchanged' do
    expect(Address.where('city_id = ?', City['Chicago'].id)).to eq [chicago_il]
  end

  it 'supports chaining' do
    expect(Address.where(city: 'Chicago').where(state: 'Illinois')).to eq [chicago_il]
  end

  it 'resolves where.not with a single lookup value' do
    expect(Address.where.not(city: 'Chicago')).to eq [madison_wi]
  end

  it 'resolves where.not with an array of lookup values' do
    expect(Address.where.not(city: ['Chicago', 'Madison'])).to eq []
  end

  it 'resolves group with a lookup symbol' do
    expect(Address.group(:city).to_sql).to eq Address.group(:city_id).to_sql
  end

  it 'resolves group chained with where' do
    expect(Address.where(state: 'Illinois').group(:city).to_sql).to eq(
      Address.where(state_id: State['Illinois'].id).group(:city_id).to_sql
    )
  end
end

context 'validation' do
  subject { Account.new(phone_number: "invalid") }

  # it { is_expected.to have(2).errors_on(:phone_number) }
  # it { expect(subject).to have(2).errors_on(:phone_number) }

  # it 'bubbles errors' do
  #   expect(subject).to have(2).errors_on(:phone_number)
  # end

  it 'bubbles errors' do
    expect(subject.errors[:phone_number].size).to eq(2)
  end
end
