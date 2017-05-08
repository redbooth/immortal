RSpec.describe Immortal do
  before do
    @m = ImmortalModel.create! title: 'testing immortal', value: 1
  end

  it 'considers an Many-to-many association with through as deleted when the join is deleted.' do
    @n = ImmortalNode.create! title: 'testing association'
    @join = ImmortalJoin.create! immortal_model: @m, immortal_node: @n

    model.nodes.count.should == 1
    @n.models.count.should == 1

    @join.destroy

    model.nodes.count.should == 0
    @n.models.count.should == 0
  end

  it 'onlies immortally delete scoped associations, NOT ALL RECORDS' do
    n1 = ImmortalNode.create! title: 'testing association 1'
    j1 = ImmortalJoin.create! immortal_model: @m, immortal_node: n1

    n2 = ImmortalNode.create! title: 'testing association 2'
    j2 = ImmortalJoin.create! immortal_model: @m, immortal_node: n2

    n3 = ImmortalNode.create! title: 'testing association 3'
    j3 = ImmortalJoin.create! immortal_node: n3

    model.destroy

    [n1, n2, j1, j2].all? { |r| r.reload.deleted? }.should be_true
    [n3, j3].all? { |r| !r.reload.deleted? }.should be_true
  end

  it 'properlies generate joins' do
    join_sql1 = 'INNER JOIN "immortal_joins" ON "immortal_joins"."immortal_node_id" = "immortal_nodes"."id"'
    join_sql2 = 'INNER JOIN "immortal_models" ON "immortal_models"."id" = "immortal_joins"."immortal_model_id"'
    generated_sql = ImmortalNode.joins(:immortal_models).to_sql
    generated_sql.should include(join_sql1)
    generated_sql.should include(join_sql2)
  end

  it 'reloads immortal polymorphic associations using default reader' do
    node = ImmortalNode.create! title: 'testing association 1'
    target_1 = ImmortalSomeTarget.create! title: 'target 1'
    target_2 = ImmortalSomeOtherTarget.create! title: 'target 2'

    node.target.should be_nil
    node.target = target_1
    node.target.should == target_1

    node.target_id = target_2.id
    node.target_type = target_2.class.name

    target_2.destroy
    node.target.should be_nil
  end

  it 'reloads immortal polymorphic associations using deleted reader' do
    # setup
    node = ImmortalNode.create! title: 'testing association 1'
    target_1 = ImmortalSomeTarget.create! title: 'target 1'
    target_2 = ImmortalSomeOtherTarget.create! title: 'target 2'

    # confirm initial state
    node.target.should be_nil

    # load target & confirm
    node.target = target_1
    node.target.should == target_1

    # switch target indirectly
    node.target_id = target_2.id
    node.target_type = target_2.class.name

    # don't assign directly and destroy new target
    target_2.destroy

    # Ask for deleted target (or not deleted). Will NOT cache
    # Run this before default accessor to test scope has been reset.
    node.target_with_deleted.should == target_2

    # Respect what's expected
    node.target.should be_nil

    # Ask only for deleted target. Will NOT cache
    node.target_only_deleted.should == target_2

    # Confirm we haven't invaded the target namespace
    node.target.should be_nil
  end

  it 'reloads immortal polymorphic associations using deleted reader (direct assignment)' do
    # setup
    node = ImmortalNode.create! title: 'testing association 1'
    target_1 = ImmortalSomeTarget.create! title: 'target 1'
    target_2 = ImmortalSomeOtherTarget.create! title: 'target 2'

    # confirm initial state
    node.target.should be_nil

    # load target & confirm
    node.target = target_1
    node.target.should == target_1

    # switch target directly
    node.target = target_2

    node.target.should == target_2
    node.target_with_deleted.should == target_2

    # don't assign directly and destroy new target
    target_2.destroy

    # Respect what's expected
    node.target(true).should be_nil

    # Ask for deleted target (or not deleted). Will NOT cache
    node.target_with_deleted.should == target_2

    # Confirm we haven't invaded the target namespace
    node.target.should be_nil
  end

  it 'deleted readers should respect staleness' do
    # setup
    node = ImmortalNode.create! title: 'testing association 1'
    target_1 = ImmortalSomeTarget.create! title: 'target 1'
    target_2 = ImmortalSomeOtherTarget.create! title: 'target 2'

    # confirm initial state
    node.target.should be_nil
    node.target_with_deleted.should be_nil
    node.target_only_deleted.should be_nil

    # load target & confirm
    node.target = target_1
    node.target.should == target_1
    node.target_with_deleted.should == target_1
    node.target_only_deleted.should be_nil

    # switch target directly
    node.target = target_2

    node.target.should == target_2
    node.target_with_deleted.should == target_2

    # don't assign directly and destroy new target
    target_2.destroy

    # Respect what's expected
    node.target(true).should be_nil

    # Ask for deleted target (or not deleted).
    node.target_with_deleted.should == target_2
    node.target_only_deleted.should == target_2

    # Confirm we haven't invaded the target namespace
    node.target.should be_nil

    node.target_id = target_1.id
    node.target_type = target_1.class.name
    node.target.should == target_1
    node.target_with_deleted.should == target_1
    node.target_only_deleted.should be_nil
  end

  it 'does not unscope associations when using with_deleted scope' do
    m1 = ImmortalModel.create! title: 'previously created model'
    n1 = ImmortalNode.create! title: 'previously created association'
    ImmortalJoin.create! immortal_model: m1, immortal_node: n1

    @n = ImmortalNode.create! title: 'testing association'
    @join = ImmortalJoin.create! immortal_model: @m, immortal_node: @n

    @join.destroy

    model.nodes.count.should == 0
    @n.joins.count.should == 0

    model.nodes.count_with_deleted.should == 1
    @n.joins.count_with_deleted.should == 1
  end

  it 'does not unscope associations when using only_deleted scope' do
    m1 = ImmortalModel.create! title: 'previously created model'
    n1 = ImmortalNode.create! title: 'previously created association'
    ImmortalJoin.create! immortal_model: m1, immortal_node: n1

    @n = ImmortalNode.create! title: 'testing association'
    @join = ImmortalJoin.create! immortal_model: @m, immortal_node: @n

    @join.destroy

    model.nodes.count.should == 0
    @n.joins.count.should == 0

    model.nodes.count_only_deleted
    model.nodes.count_only_deleted.should == 1
    @n.joins.count_only_deleted.should == 1
  end
end
