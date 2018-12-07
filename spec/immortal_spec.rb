RSpec.describe Immortal do
  subject(:model) { ImmortalModel.create! title: 'testing immortal', value: 1 }

  before { model }

  it { is_expected.not_to be_deleted }

  context 'when column is nullable' do
    before do
      allow(Kernel).to receive(:warn)

      class ImmortalNullableDeleted
        include Immortal
      end
    end

    it 'raises a warn when column is nullable' do
      expect(Kernel).to have_received(:warn)
    end
  end

  context 'after deleting' do
    before { model.destroy }

    subject { model }

    it { is_expected.to be_deleted }
  end

  describe '#count_with_deleted' do
    subject { ImmortalModel.count_with_deleted }

    it { is_expected.to eq(1) }

    context 'with deleted records' do
      before { model.destroy }

      it { is_expected.to eq(1) }
    end
  end

  describe '#where_with_deleted' do
    subject { ImmortalModel.where_with_deleted(id: model.id) }

    context 'before soft delete' do
      it 'finds deleted records' do
        is_expected.to include(model)
      end
    end

    context 'after soft delete' do
      before { model.destroy }

      it 'finds deleted records' do
        is_expected.to include(model)
      end
    end
  end

  describe '#count_only_deleted' do
    subject { ImmortalModel.count_only_deleted }

    before do
      model.destroy
      ImmortalModel.create! title: 'second'
    end

    it 'includes only non deleted records' do
      is_expected.to eq(1)
    end
  end

  describe '#where_only_deleted' do
    subject(:where_only_deleted) do
      ImmortalModel.where_only_deleted(id: model.id)
    end

    context 'with a non deleted record' do
      it 'finds nothing' do
        is_expected.to be_empty
      end
    end

    context 'with a deleted record' do
      before { model.destroy }
      it { is_expected.to include(model) }
    end
  end

  context 'ActiveRecord methods' do
    describe '#destroy' do
      subject(:destroy_model) { model.destroy }

      before { model.update(updated_at: 1.minute.ago) }

      it 'does not delete from the database' do
        expect { destroy_model }
          .not_to change(ImmortalModel, :count_with_deleted)
      end

      it 'changes deleted' do
        expect { destroy_model }
          .to change(model, :deleted)
      end

      it 'changes updated_at' do
        expect { destroy_model }
          .to change(model, :updated_at)
      end

      it { is_expected.to be_frozen }
      it { is_expected.not_to be_changed }
    end

    describe '#destroy!' do
      it 'deletes from the database' do
        expect do
          model.destroy!
        end.to change(ImmortalModel, :count_with_deleted)
      end
    end

    describe '#find' do
      it 'finds first record' do
        expect(ImmortalModel.first).to eq(model)
      end

      it 'finds record in collection' do
        expect(ImmortalModel.all).to include(model)
      end

      context 'when soft deleted' do
        before { model.destroy }

        it 'does not find first record' do
          expect(ImmortalModel.first).to be_nil
        end

        it 'does not find record in collection' do
          expect(ImmortalModel.all).not_to include(model)
        end
      end
    end

    describe '#count' do
      subject { ImmortalModel.count }

      it { is_expected.to eq(1) }

      context 'with deleted records' do
        before do
          model.destroy
          ImmortalModel.create! title: 'second'
        end

        it { is_expected.to eq(1) }
      end
    end

    describe '#exists?' do
      subject { ImmortalModel.exists?(model.id) }

      it { is_expected.to be_truthy }

      context 'with deleted records' do
        before { model.destroy }

        it { is_expected.to be_falsey }
      end
    end

    describe '#calculate' do
      subject { ImmortalModel.calculate(:sum, :value) }

      it { is_expected.to eq(1) }

      context 'with deleted records' do
        before do
          model.destroy
          ImmortalModel.create! title: 'second', value: 2
        end

        it { is_expected.to eq(2) }
      end
    end
  end

  describe '#delete_all' do
    it 'deletes' do
      expect { ImmortalModel.delete_all }
        .to change(ImmortalModel, :count).by(-1)
    end

    it 'soft deletes' do
      expect { ImmortalModel.delete_all }
        .not_to change(ImmortalModel, :count_with_deleted)
    end
  end

  describe '#delete_all!' do
    it 'deletes' do
      expect { ImmortalModel.delete_all! }
        .to change(ImmortalModel, :count).by(-1)
    end

    it 'does not soft delete' do
      expect { ImmortalModel.delete_all! }
        .to change(ImmortalModel, :count_with_deleted).by(-1)
    end
  end

  describe '#recover!' do
    subject(:recover_model) { deleted_model.recover! }

    let(:model_id) { model.id }
    let(:deleted_model) { ImmortalModel.where_with_deleted(id: model_id).first }

    before do
      model.destroy
      deleted_model.update(updated_at: 1.minute.ago)
    end

    it { is_expected.not_to be_frozen }
    it { is_expected.not_to be_changed }

    it 'changes deleted' do
      expect { recover_model }.to change(deleted_model, :deleted)
    end

    it 'changes updated_at' do
      expect { recover_model }.to change(deleted_model, :updated_at)
    end

    it 'can be found' do
      recover_model
      expect(ImmortalModel.first).to eq(model)
    end
  end
end
