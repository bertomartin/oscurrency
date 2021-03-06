# NOTE: We use "posts" for both forum topic posts and blog posts,
# There is some trickery to handle the two in a unified manner.
class PostsController < ApplicationController
  include ApplicationHelper
  
  before_filter :login_required
  before_filter :get_instance_vars
  before_filter :check_blog_mismatch, :only => :show

  # authorize filters for blogs only
  before_filter :authorize_new, :only => [:create, :new]
  before_filter :authorize_change, :only => [:edit, :update]
  before_filter :authorize_destroy, :only => :destroy

  def index
    redirect_to blog_url(@blog) if blog?
    respond_to do |format|
      format.js do
        seconds = global_prefs.topic_refresh_seconds
        @refresh_milliseconds = seconds * 1000
        @topic.update_viewer(current_person)
        # Exclude your own to avoid picking up the one you just posted
        @posts = @topic.posts_since_last_refresh(params[:after].to_i, current_person.id)
        @viewers = @topic.current_viewers(seconds * 2)
      end
      format.html { redirect_to forum_topic_url(@forum, @topic) if forum? }
    end
  end

  # Show a blog post.
  # Forum posts don't get shown individually.
  def show
    @post = BlogPost.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # Used for both forum and blog posts.
  def new
    @post = model.new

    respond_to do |format|
      format.html { render :action => resource_template("new") }
    end
  end

  # Used for both forum and blog posts.
  def edit
    respond_to do |format|
      format.html { render :action => resource_template("edit") }
    end
  end

  # Used for both forum and blog posts.
  def create
    @post = new_resource_post
    authorize! :create, @post
    
    respond_to do |format|
      if @post.save
        flash[:success] = t('success_post_created')
        format.html { redirect_to post_url }
        format.js
      else
        format.html { render :action => resource_template("new") }
        format.js {render :action => 'new'}
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = t('notice_post_updated')
        format.html { redirect_to post_url }
      else
        format.html { render :action => resource_template("edit") }
      end
    end
  end

  def destroy
    @post = model.find(params[:id])
    authorize! :destroy, @post
    @post.destroy
    flash[:notice] = t('success_post_destroyed')

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.js
    end
  end
  
  private
  
    ## Before filters
  
    def get_instance_vars
      @post = model.find(params[:id]) unless params[:id].nil?
      if forum?
        #@forum = Forum.find(:first)
        @topic = Topic.find(params[:topic_id])
        @forum = @topic.forum
        @body = "forum"
      elsif blog?
        @blog = Blog.find(params[:blog_id])
        @body = "blog"
      end
    end
    
    def check_blog_mismatch
      redirect_to home_url unless @post.blog == @blog
    end

    def authorize_new
      if blog?
        redirect_to home_url unless current_person?(@blog.person)
      end
    end

    def authorize_change
      if blog?
        authorized = current_person?(@blog.person) && valid_post?
        redirect_to home_url unless authorized
      end
    end
    
    # A post is valid if its blog is the current blog.
    def valid_post?
      @post.blog == @blog
    end
    
    # Only blog owners can destroy blog posts.
    def authorize_destroy
      if blog?
        authorize_change
      end
    end

    ## Handle forum and blog posts in a uniform manner.
    
    # Return the appropriate model corresponding to the type of post.
    def model
      if forum?
        ForumPost
      elsif blog?
        BlogPost
      end
    end
    
    # Return the posts array for the given resource.
    def resource_posts
      if forum?
        @topic.posts
      elsif blog?
        @blog.posts.paginate(:page => params[:page])
      end  
    end
    
    # Return a new post for the given resource.
    def new_resource_post
      if forum?
        post = @topic.posts.build(params[:post])
        post.person = current_person
      elsif blog?
        post = @blog.posts.new(params[:post])
      end
      post
    end
    
    # Return the template for the current resource given the name.
    # For example, on a blog resource_template("new") gives "blog_new"
    def resource_template(name)
      "#{resource}_#{name}"
    end

    # Return a string for the resource.
    def resource
      if forum?
        "forum"
      elsif blog?
        "blog"
      end
    end
    
    # Return URL to redirect to after post creation.
    def post_url
      if forum?
        # By using including :posts, we ensure that the user's browser
        # will display the link as 'followed' when he makes a post,
        # so the link color will only change back to 'unfollowed' 
        # if someone *else* makes a post.
        forum_topic_url(@forum, @topic, :posts => @topic.posts.count)
      elsif blog?
        blog_post_url(@blog, @post)
      end
    end

    # Return the URL for the resource posts (forum topic or blog).
    def posts_url
      if forum?
       forum_topic_url(@forum, @topic)
      elsif blog?
        blog_url(@blog)
      end      
    end

    # True if resource lives in a discussion forum.
    # We reserve the right to suppress forum_id since there's only one forum,
    # so use topic_id to tell that it's a forum.
    def forum?
      !params[:topic_id].nil?
    end

    # True if resource lives in a blog.
    def blog?
      !params[:blog_id].nil?
    end
end
