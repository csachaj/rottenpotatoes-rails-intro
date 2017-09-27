class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #flash.keep                                                                       # Instructions said I might need this, but when I tested the corner case it wasn't needed. Here for reference
                                                                                      # Redirect conditions below, checks instance of params not existing and session params not existing
    if params[:ratings].nil? and params[:sort_by].nil? and !session[:ratings].nil? and !session[:sort_by].nil?
      redirect_to movies_path(ratings: session[:ratings], sort_by: session[:sort_by])
    elsif !session[:sort_by].nil? and params[:sort_by].nil?
      redirect_to movies_path(sort_by: session[:sort_by], ratings: params[:ratings])
    elsif !session[:ratings].nil? and params[:ratings].nil?
      redirect_to movies_path(ratings: session[:ratings], sort_by: params[:sort_by])
    end
    
    @all_ratings = ['G','PG','PG-13','R']                                             # Enumeration of possible movie ratings
    @selected_ratings = !params[:ratings].nil? ? params[:ratings] : @all_ratings      # Logic to pre-populate checkboxs correctly
    
    query = "Movie"                                                                   # Initialize query build string
    
    query << ".where({ rating: params[:ratings]})" unless params[:ratings].nil?       # Check if the query has filters enabled. If so, add them to the query
    else query << ".all"                                                              # If no filters are used, return all rows

    if params[:sort_by] == "title"                                                    # Check if the query should be sorted
      query << ".order(title: :asc)"                                                  # Sort the query by title
      @titleStyle = "hilite"                                                          # Apply the "hilite" css class to the title header
    elsif params[:sort_by] == "date"                                                  # Check if the query should be sorted
      query << ".order(release_date: :asc)"                                           # Sort the query by title
      @dateStyle = "hilite"                                                           # Apply the "hilite" css class to the release date header
    end
    
    @movies = eval(query)                                                             # Evaluate query and assign returned value to @movies
    
    session[:sort_by] = params[:sort_by]                                              # Save sort_by params to session
    session[:ratings] = params[:ratings]                                              # Save rating params to session
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

end
