# frozen_string_literal: true

require 'rails_helper'
RSpec.describe NilClassPolicy, type: :policy do
  subject { described_class.new(nil, nil) }

  describe 'permissions' do
    context 'when the record is nil' do
      it { is_expected.to forbid_actions(%i[show update]) }
    end
  end
end
