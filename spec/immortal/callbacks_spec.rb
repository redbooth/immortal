RSpec.describe Immortal, '#callbacks' do
  subject(:model) { ImmortalModel.create! title: 'testing immortal', value: 1 }

  context 'when deleting' do
    before { model.destroy }

    its(:before_destroy_probe) { is_expected.to be_truthy }
    its(:after_destroy_probe) { is_expected.to be_truthy }
    its(:after_commit_probe) { is_expected.to be_truthy }
    its(:before_update_probe) { is_expected.to be_nil }
    its(:after_update_probe) { is_expected.to be_nil }
  end

  context 'when `before` callback halts' do
    before { model.before_return = false }

    it 'does not return true' do
      expect(model.destroy).to be_falsey
    end

    it 'does not run after_commit' do
      model.destroy
      expect(model.after_commit_probe).to be_falsey
    end
  end

  context 'when deleting without callbacks' do
    before { model.destroy_without_callbacks }

    its(:before_destroy_probe) { is_expected.to be_nil }
    its(:after_destroy_probe) { is_expected.to be_nil }
    its(:after_commit_probe) { is_expected.to be_nil }
  end
end
