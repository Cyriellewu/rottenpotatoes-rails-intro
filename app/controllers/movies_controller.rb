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


    ratings_from_params = params[:ratings]&.keys
    sort_from_params    = params[:sort_by]

    @ratings_to_show = ratings_from_params || session[:ratings] || @all_ratings
    @sort_by         = sort_from_params    || session[:sort_by]


    session[:ratings] = @ratings_to_show
    session[:sort_by] = @sort_by

 
    if params[:ratings].blank? || params[:sort_by].blank?
      ratings_hash = @ratings_to_show.to_h { |r| [r, '1'] }  # {"G"=>"1", ...}
      return redirect_to movies_path(ratings: ratings_hash, sort_by: @sort_by)
    end


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
