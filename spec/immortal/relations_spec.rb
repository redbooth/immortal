RSpec.describe Immortal do
  let(:model) { ImmortalModel.create! title: 'testing immortal' }

  context 'many to many with through' do
    let(:node) { ImmortalNode.create! title: 'association' }
    let(:join) do
      ImmortalJoin.create! immortal_model: model, immortal_node: node
    end

    let(:disconnected_node) { ImmortalNode.create! title: 'unnatached' }
    let(:disconnected_join) do
      ImmortalJoin.create! immortal_node: disconnected_node
    end

    before do
      join
      disconnected_join
    end

    context 'with cascade destroy' do
      before { model.destroy }

      it { expect(join.reload).to be_deleted }
      it { expect(node.reload).to be_deleted }

      it { expect(disconnected_node.reload).not_to be_deleted }
      it { expect(disconnected_join.reload).not_to be_deleted }
    end

    context 'removing the join' do
      subject { model }

      before { join.destroy }

      it { expect(node.models.count).to eq(0) }
      its('nodes.count') { is_expected.to eq(0) }
      its('joins.count') { is_expected.to eq(0) }
      its('joins.count_with_deleted') { is_expected.to eq(1) }
      its('joins.count_only_deleted') { is_expected.to eq(1) }
    end

    context 'on a join query' do
      subject { ImmortalNode.joins(:immortal_models).to_sql.gsub(/\"|\`/, '')}

      let(:expected_join) do
        'INNER JOIN immortal_joins ON immortal_joins.immortal_node_id = immortal_nodes.id'
      end
      let(:expected_model_join) do
        'INNER JOIN immortal_models ON immortal_models.id = immortal_joins.immortal_model_id'
      end

      it { is_expected.to include(expected_join) }
      it { is_expected.to include(expected_model_join) }
    end
  end

  context 'on polymorphic associations' do
    subject(:node) { ImmortalNode.create! title: 'the node' }

    context 'when using accessor' do
      let(:target) { ImmortalSomeTarget.create! title: 'target' }

      before { node.update_attributes target: target }

      its(:target) { is_expected.to eq(target) }
      its(:target_with_deleted) { is_expected.to eq(target) }
      its(:target_only_deleted) { is_expected.to be_nil }
    end

    context 'when assigning polymorphic assocaition by attributes' do
      let(:target) { ImmortalSomeOtherTarget.create! title: 'target 2' }

      before do
        node.update_attributes(
          target_id: target.id,
          target_type: target.class.name
        )
      end

      its(:target) { is_expected.to eq(target) }
      its(:target_with_deleted) { is_expected.to eq(target) }
      its(:target_only_deleted) { is_expected.to be_nil }
    end

    context 'after destroying the target' do
      let(:target) { ImmortalSomeTarget.create! title: 'target' }

      before do
        node.update_attributes target: target
        target.destroy
      end

      its('reload.target') { is_expected.to be_nil }
      its(:target_with_deleted) { is_expected.to eq(target) }
      its(:target_only_deleted) { is_expected.to eq(target) }
    end
  end
end
