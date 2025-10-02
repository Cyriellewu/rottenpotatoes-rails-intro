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

    incoming_ratings = params[:ratings]&.keys
    incoming_sort    = params[:sort_by]

    saved_ratings = session[:ratings]
    saved_sort    = session[:sort_by]

    need_redirect = false
    target_ratings = incoming_ratings
    target_sort    = incoming_sort

    if incoming_ratings.blank? && saved_ratings.present?
      need_redirect = true
      target_ratings = saved_ratings
    end

    if incoming_sort.blank? && saved_sort.present?
      need_redirect = true
      target_sort = saved_sort
    end

    if need_redirect
      ratings_hash = target_ratings.to_h { |r| [r, '1'] }
      redirect_to movies_path(sort_by: target_sort, ratings: ratings_hash) and return
    end

    @ratings_to_show = (incoming_ratings.presence || saved_ratings.presence || @all_ratings)
    @sort_by         = (incoming_sort.presence    || saved_sort.presence    || nil)


    session[:ratings] = @ratings_to_show
    session[:sort_by] = @sort_by

    @movies = Movie.with_ratings(@ratings_to_show)
    @movies = @movies.order(@sort_by) if @sort_by.present?
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
