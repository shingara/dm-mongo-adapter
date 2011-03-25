require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::Resource do
  before :all do
    class ::Post
      include DataMapper::Mongo::Resource

      property :id, ObjectId
      property :comment_count, Integer
      property :body, Text
    end

    Post.all.destroy!
  end

  describe "#increment" do
    before :all do
      @post = Post.create(:comment_count => 1)
    end

    context "with 2 args" do
      before :all do
        @post.increment(:comment_count, 2)
      end

      it "should update the given property with the incremented value" do
        @post.comment_count.should == 3
        Post.get(@post.id).comment_count.should == 3
      end

      it "should reload the updated resource" do
        @post.dirty?.should be_false
      end
    end

    context "with 1 arg" do
      before :all do
        @post.increment(:comment_count)
      end
      it "should update the given property with the incremented by one" do
        @post.comment_count.should == 2
        Post.get(@post.id).comment_count.should == 2
      end

      it "should reload the updated resource" do
        @post.dirty?.should be_false
      end
    end
  end

  describe "#decrement" do
    before :all do
      @post = Post.create(:comment_count => 10)
    end

    context "with 2 args" do
      before :all do
        @post.decrement(:comment_count, 5)
      end

      it "should update the given property with the decremented value" do
        @post.comment_count.should == 5
        Post.get(@post.id).comment_count.should == 5
      end

      it "should reload the updated resource" do
        @post.dirty?.should be_false
      end
    end

    context "with 1 args" do
      before :all do
        @post.decrement(:comment_count)
      end

      it "should update the given property with the decremented value" do
        @post.comment_count.should == 9
        Post.get(@post.id).comment_count.should == 9
      end

      it "should reload the updated resource" do
        @post.dirty?.should be_false
      end
    end
  end

  describe "#set" do
    it "should set the value of a property" do
      post = Post.create(:body => "This needs to be edited", :comment_count => 2)

      post.set(:body => "This was edited", :comment_count => 3)
      post.body.should == "This was edited"
      post.comment_count.should == 3
      fresh_post = Post.get(post.id)
      fresh_post.body.should == "This was edited"
      fresh_post.comment_count.should == 3
    end
  end

  describe "#unset" do
    it "should unset the value of a property" do
      post = Post.create(:body => "This needs to be removed", :comment_count => 2)

      post.unset(:body, :comment_count)
      post.body.should be_nil
      post.comment_count.should be_nil
      fresh_post = Post.get(post.id)
      fresh_post.body.should be_nil
      fresh_post.comment_count.should be_nil
    end
  end

  describe "#push" do
    it "should be implemented" do
      pending
    end
  end

  describe "#push_all" do
    it "should be implemented" do
      pending
    end
  end

  describe "#pop" do
    it "should be implemented" do
      pending
    end
  end

  describe "#pull" do
    it "should be implemented" do
      pending
    end
  end

  describe "#pull_all" do
    it "should be implemented" do
      pending
    end
  end
end
