require 'spec_helper'

describe LookupBy, 'querying' do
  let(:illinois) { State['Illinois'] }
  let(:new_york) { State['New York'] }

  before do
    State.lookup.seed('Illinois', 'New York')
    State.lookup.reload
  end

  context 'where' do
    specify 'state = ?' do
      scope = Address.where(state: 'Illinois')
      expect(scope.to_sql).to eq Address.where(state_id: illinois.id).to_sql
    end

    specify 'state IN (?)' do
      scope = Address.where(state: ['Illinois'])
      expect(scope.to_sql).to eq Address.where(state_id: [illinois.id]).to_sql
    end

    specify 'state IN (?, ?)' do
      scope = Address.where(state: ['Illinois', 'New York'])
      expect(scope.to_sql).to eq Address.where(state_id: [illinois.id, new_york.id]).to_sql
    end

    specify 'state <> ?' do
      scope = Address.where.not(state: 'Illinois')
      expect(scope.to_sql).to eq Address.where.not(state_id: illinois.id).to_sql
    end
  end

  context 'rewhere' do
    specify 'state = ?' do
      scope   = Address.where(state: 'Illinois')
      rescope = scope.rewhere(state: 'New York')
      expect(rescope.to_sql).to eq Address.where(state_id: new_york.id).to_sql
    end
  end

  specify 'group(:state)' do
    scope = Address.group(:state)
    expect(scope.to_sql).to eq Address.group(:state_id).to_sql
  end

  context 'order' do
    xit 'rewrite to joins(:state).order("states.state"), maybe?'
  end
end
