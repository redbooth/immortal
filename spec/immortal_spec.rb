require File.dirname(__FILE__) + '/spec_helper'

describe Immortal do
  before do
    @m = ImmortalModel.create! :title => 'testing immortal'
  end

  it "should not be deleted from the database using #destroy" do
    expect {
      @m.destroy
    }.to_not change(ImmortalModel, :count_with_deleted)
  end

  it "should be frozen using #destroy" do
    @m.destroy
    @m.should be_frozen
  end

  it "should not be dirty using #destroy" do
    @m.destroy
    @m.should_not be_changed
  end

  it "should be deleted from the database using #destroy!" do
    expect {
      @m.destroy!
    }.to change(ImmortalModel, :count_with_deleted)
  end

  it "should find non deleted records" do
    ImmortalModel.first.should == @m
    ImmortalModel.all.should include(@m)
  end

  it "should not find deleted records" do
    @m.destroy
    ImmortalModel.first.should be_nil
    ImmortalModel.all.should be_empty
  end

  it "should find deleted records using the old method" do
    ImmortalModel.find_with_deleted(@m.id).should == @m
    @m.destroy
    ImmortalModel.find_with_deleted(@m.id).should == @m
  end

  it "should count undeleted records by default" do
    @m2 = ImmortalModel.create! :title => 'testing immortal again'
    ImmortalModel.count_only_deleted.should == 0

    @m.destroy

    ImmortalModel.count_only_deleted.should == 1
  end

  it "should find only deleted records" do
    @m2 = ImmortalModel.create! :title => 'testing immortal again'
    expect {
      ImmortalModel.find_only_deleted(@m.id)
    }.to raise_error(ActiveRecord::RecordNotFound)

    @m.destroy

    ImmortalModel.find_only_deleted(@m.id).should == @m
    expect {
      ImmortalModel.find_only_deleted(@m2.id)
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "should be able to count undeleted records" do
    @m2 = ImmortalModel.create! :title => 'testing immortal again'
    ImmortalModel.count.should == 2

    @m.destroy

    ImmortalModel.count.should == 1
  end

  it "should be able to count all the records including deleted" do
    @m2 = ImmortalModel.create! :title => 'testing immortal again'
    @m.destroy
    ImmortalModel.count_with_deleted.should == 2
  end

  it "should not exist if deleted" do
    ImmortalModel.exists?(@m.id).should be_true
    @m.destroy
    ImmortalModel.exists?(@m.id).should be_false
  end

  it "should calculate without deleted" do
    @m2 = ImmortalModel.create! :value => 10
    @m3 = ImmortalModel.create! :value => 20
    ImmortalModel.calculate(:sum, :value).should == 30
    @m2.destroy
    ImmortalModel.calculate(:sum, :value).should == 20
  end

  it "should execute the before_destroy callback when immortally destroyed" do
    @m.destroy
    @m.before_d.should be_true
  end

  it "should execute the after_destroy callback when immortally destroyed" do
    @m.destroy
    @m.after_d.should be_true
  end

  it "should not execute the before_update callback when immortally destroyed" do
    @m.destroy
    @m.before_u.should be_nil
  end

  it "should not execute the after_update callback when immortally destroyed" do
    @m.destroy
    @m.after_u.should be_nil
  end

  it "should not execute the before_destroy callback when immortally destroyed without callbacks" do
    @m.destroy_without_callbacks
    @m.before_d.should be_nil
  end

  it "should not execute the after_destroy callback when immortally destroyed without callbacks" do
    @m.destroy_without_callbacks
    @m.after_d.should be_nil
  end

  it "should immortally delete all records with delete_all" do
    expect {
      ImmortalModel.delete_all
    }.to change(ImmortalModel, :count).by(-1)
    ImmortalModel.count_with_deleted.should == 1
  end

  it "should immortally delete all records with delete_all!" do
    expect {
      ImmortalModel.delete_all!
    }.to change(ImmortalModel, :count_with_deleted).by(-1)
  end

  it "should know if it's deleted" do
    @m.should_not be_deleted
    @m.destroy
    @m.should be_deleted
  end

  it "should be recoverable" do
    @m.destroy
    @m = ImmortalModel.find_with_deleted(@m.id)
    @m.recover!
    @m.should_not be_frozen
    @m.should_not be_changed
    ImmortalModel.first.should == @m
  end

  it "should consider an object with deleted = nil as not deleted" do
    @m2 = ImmortalModel.create! :deleted => nil
    @m2.deleted.should be_nil
    @m2.should_not be_deleted
    ImmortalModel.count.should == 2
  end

  it "should consider an Many-to-many association with through as deleted when the join is deleted." do
    @n = ImmortalNode.create! :title => 'testing association'
    @join = ImmortalJoin.create! :immortal_model => @m, :immortal_node => @n

    @m.nodes.count.should == 1
    @n.models.count.should == 1

    @join.destroy

    @m.nodes.count.should == 0
    @n.models.count.should == 0
  end

  it "should only immortally delete scoped associations, NOT ALL RECORDS" do
    n1 = ImmortalNode.create! :title => 'testing association 1'
    j1 = ImmortalJoin.create! :immortal_model => @m, :immortal_node => n1

    n2 = ImmortalNode.create! :title => 'testing association 2'
    j2 = ImmortalJoin.create! :immortal_model => @m, :immortal_node => n2

    n3 = ImmortalNode.create! :title => 'testing association 3'
    j3 = ImmortalJoin.create! :immortal_node => n3

    @m.destroy

    [n1,n2,j1,j2].all? {|r| r.reload.deleted?}.should be_true
    [n3,j3].all? {|r| !r.reload.deleted?}.should be_true
  end

  it "should properly generate joins" do
    join_sql1 = 'INNER JOIN "immortal_joins" ON "immortal_joins"."immortal_node_id" = "immortal_nodes"."id"'
    join_sql2 = 'INNER JOIN "immortal_models" ON "immortal_models"."id" = "immortal_joins"."immortal_model_id"'
    generated_sql = ImmortalNode.joins(:immortal_models).to_sql
    generated_sql.should include(join_sql1)
    generated_sql.should include(join_sql2)
  end

  it "should reload immortal polymorphic associations using default reader" do
    node = ImmortalNode.create! :title => 'testing association 1'
    target_1 = ImmortalSomeTarget.create! :title => 'target 1'
    target_2 = ImmortalSomeOtherTarget.create! :title => 'target 2'

    node.target.should be_nil
    node.target = target_1
    node.target.should == target_1

    node.target_id = target_2.id
    node.target_type = target_2.class.name

    target_2.destroy
    node.target.should be_nil
  end

  it "should reload immortal polymorphic associations using deleted reader" do
    #setup
    node = ImmortalNode.create! :title => 'testing association 1'
    target_1 = ImmortalSomeTarget.create! :title => 'target 1'
    target_2 = ImmortalSomeOtherTarget.create! :title => 'target 2'

    #confirm initial state
    node.target.should be_nil

    #load target & confirm
    node.target = target_1
    node.target.should == target_1

    #switch target indirectly
    node.target_id = target_2.id
    node.target_type = target_2.class.name

    #don't assign directly and destroy new target
    target_2.destroy

    #Respect what's expected
    node.target.should be_nil

    #Ask for deleted target (or not deleted). Will NOT cache
    node.target_with_deleted.should == target_2

    #Ask only for deleted target. Will NOT cache
    node.target_only_deleted.should == target_2

    #Confirm we haven't invaded the target namespace
    node.target.should be_nil
  end

end
