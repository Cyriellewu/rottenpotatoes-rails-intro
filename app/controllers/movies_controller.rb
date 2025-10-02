class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  # def index
  #   @movies = Movie.all
  # end
  def index
    @all_ratings = Movie.all_ratings

    # 1) 取出当前应使用的筛选与排序(优先 params，其次 session，最后默认全选)
    ratings = if params[:ratings].present?
                params[:ratings].keys
              elsif session[:ratings].present?
                session[:ratings]
              else
                @all_ratings
              end

    sort_by = params[:sort_by].presence || session[:sort_by]

    # 2) 如果 URL 里缺少这些参数，但我们有可用值 -> 重定向到带参数的规范 URL
    need_redirect = false
    canonical_params = {}

    unless params[:ratings].present?
      need_redirect = true
      canonical_params[:ratings] = ratings.to_h { |r| [r, '1'] }
    end

    if sort_by.present? && !params[:sort_by].present?
      need_redirect = true
      canonical_params[:sort_by] = sort_by
    end

    return redirect_to movies_path(canonical_params) if need_redirect

    # 3) 保存到 session，供下次返回使用
    session[:ratings] = ratings
    session[:sort_by] = sort_by

    # 4) 供视图使用
    @ratings_to_show = ratings
    @sort_by         = sort_by
    @movies          = Movie.with_ratings(ratings)
    @movies          = @movies.order(@sort_by) if @sort_by.present?
  end


  
  

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
