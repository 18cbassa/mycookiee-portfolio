class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy, :toggle_status]
  before_action :set_sidebar_topics, except: [:update, :create, :destroy, :toggle_status]
  layout "blog"
  access all: [:show, :index], user: {except: [:destroy, :new, :create, :update, :edit, :toggle_status]}, site_admin: :all

  # GET /blogs
  # GET /blogs.json
  def index
    if logged_in?(:site_admin)
     @blogs = Blog.recent.page(params[:page]).per(5)
    else
      @blogs = Blog.published.recent.page(params[:page]).per(5)
    end
    @page_title = "My Portfolio Blog"
  end

  # GET /blogs/1
  # GET /blogs/1.json
  def show
    if logged_in?(:site_admin) || @blog.published?
      @blog = Blog.includes(:comments).friendly.find(params[:id])
      @comment = Comment.new
    
      @page_title = @blog.title
      @seo_keywords = @blog.body
    else
      redirect_to blogs_path, notice: "You are not authorized to access this page haha"
    end
  end

  # GET /blogs/new doesn't actually create a new blog cus it doesn't actually have any parameter; gives the ability to have the layout/making the form available: new blog, title, body
  # it's mapped to the 'form' definition in file folder views, blogs, new.html.ert
  def new
    @blog = Blog.new
  end

  # GET /blogs/1/edit
  # has the abilitity to know wat blog you want to edit, thats why it has it on the before_action
  # makes the form available
  def edit
  end

  # POST /blogs
  # POST /blogs.json
  # actually creates the blog, takes the 'form' parameter
  # 
  def create
    @blog = Blog.new(blog_params)

#format.html makes the new blog post you created avaliable in the browser
    respond_to do |format|
      if @blog.save
        format.html { redirect_to @blog, notice: 'Your post is now live.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /blogs/1
  # PATCH/PUT /blogs/1.json
  # does the actual connections with the database; does the hardwork and goes through and does all the saves/changes you have to the database
  # whenever you see smthing like (blog_params) its either a variable or method
  def update
    respond_to do |format|
      if @blog.update(blog_params)
        format.html { redirect_to @blog, notice: 'Blog was successfully updated.' }
      else 
        format.html { render :edit }
      end
    end
  end

  # DELETE /blogs/1
  # DELETE /blogs/1.json
  # The way you delete a post
  def destroy
    @blog.destroy
    respond_to do |format|
      format.html { redirect_to blogs_url, notice: 'Post was removed.' }
    end
  end
  
    def toggle_status
      if @blog.draft?
         @blog.published!
      elsif @blog.published?
        @blog.draft!
      end
    
      redirect_to blogs_url, notice: 'Post status has been updated.'
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog
      @blog = Blog.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # going through and seeing what was submitted in the form and its making it avaliable to the update and new method(def update and def create @blog = Blog.new(blog_params) )
    def blog_params
      params.require(:blog).permit(:title, :body, :topic_id, :status)
    end
    
    def set_sidebar_topics
      @side_bar_topics = Topic.with_blogs
    end
end
