require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

# @done
describe "updates with mongodb modifiers" do
  # @done
  before :all do
    $db.drop_collection("posts")
    class ::Post
      include DataMapper::Mongo::Resource
      property :id, ObjectID
      property :comment_count, Integer
      property :body, Text
    end
  end

  # @done
  it "should increment" do
    post = Post.create(:comment_count => 1)
    post.increment(:comment_count, 1)
    post.comment_count.should == 2
    Post.get(post.id).comment_count.should == 2
  end

  # @done
  it "should decrement" do
    post = Post.create(:comment_count => 10)
    post.decrement(:comment_count, 5)
    post.comment_count.should == 5
    Post.get(post.id).comment_count.should == 5
  end

  # @done
  it "should set" do
#    post = Post.create(:body => "This needs to be edited", :comment_count => 2)
#    post.set(:body => "This was edited", :comment_count => 3)
#    post.body.should == "This was edited"
#    post.comment_count.should == 3
#    fresh_post = Post.get(post.id)
#    fresh_post.body.should == "This was edited"
#    fresh_post.comment_count.should == 3
    pending
  end

  # @done
  it "should unset" do
    #post = Post.create(:body => "This needs to be removed", :comment_count => 2)
    #post.unset(:body, :comment_count)
    #post.body.should be_nil
    #post.comment_count.should be_nil
    #fresh_post = Post.get(post.id)
    #fresh_post.body.should be_nil
    #fresh_post.comment_count.should be_nil
    pending
  end

  # @done
  it "should push" do
    pending
  end

  # @done
  it "should push_all" do
    pending
  end

  # @done
  it "should pop" do
    pending
  end

  # @done
  it "should pull" do
    pending
  end

  # @done
  it "should pull_all" do
    pending
  end

end
