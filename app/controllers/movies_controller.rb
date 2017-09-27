class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def getRatings
    ['G','PG','PG-13','R']                                                            # Enumeration of possible movie ratings
  end

  def index
    @all_ratings, @titleStyle, @dateStyle = getRatings, nil, nil
    @selected_ratings = !params[:ratings].nil? ? params[:ratings] : getRatings
    
    query = "Movie"                                                                   # Initialize query build string
    
    query << ".where({ rating: params[:ratings]})" unless params[:ratings].nil?       # Check if the query has filters enabled. If so, add them to the query
    else query << ".all"                                                              # If no filters are used, return all rows

    if params[:sort_by] == "title"                                                    # Check if the query should be sorted
      query << ".order(title: :asc)"                                                  # Sort the query by title
      @titleStyle = "hilite"                                                          # Apply the "hilite" css class to the title header
    elsif params[:sort_by] == "date"                                                  # Check if the query should be sorted
      query << ".order(release_date: :desc)"                                          # Sort the query by title
      @dateStyle = "hilite"                                                           # Apply the "hilite" css class to the release date header
    end
    
    @movies = eval(query)                                                             # Evaluate query and assign returned value to @movies
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
