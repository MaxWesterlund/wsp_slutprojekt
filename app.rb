require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "bcrypt"

require_relative "module"

enable(:sessions)

include Model

before("/p/*") do
    # User not logged in
    if session[:user_id] == nil
        redirect("/")
    end
end

before("/a/*") do
    if session[:is_admin] != true
        redirect("/")
    end
end

get("/") do
    slim(:start, locals: { message:session[:message], message_position:session[:message_position] })
end

post("/try_sign_up") do
    username = params[:username]
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    if username == ""
        change_start_message("You need to have a name", "sign up")
        redirect("/")
    end

    # Passwords don't match
    if password != password_confirmation
        change_start_message("The passwords do not match", "sign up")
        redirect("/")
    end

    # Username is taken
    if username_taken?(username)
        change_start_message("That username is already taken", "sign up")
        redirect("/")
    end

    password_digest = BCrypt::Password.create(password)

    add_user(username, password_digest)

    change_start_message("User #{username} was successfully created!", "top")
    redirect("/")
end

post("/try_log_in") do
    username = params[:username]
    password = params[:password]

    user = find_user_by_name(username)

    # User doesn't exist
    if user == nil
        change_start_message("User does not exist", "log in")
        redirect("/")
    end

    password_digest = user["password_digest"]

    # Incorrect password
    if BCrypt::Password.new(password_digest) != password
        change_start_message("The password is incorrect", "log in")
        redirect("/")
    end

    user_id = user["id"]
    session[:user_id] = user_id

    session[:is_admin] = username == "admin"

    change_start_message(nil, nil)
    redirect("/p/movies")
end

post("/log_out") do
    session[:user_id] = nil
    redirect("/")
end

get("/p/user/:user_id") do
    user_id = params[:user_id]

    user = find_user_by_id(user_id)

    slim(:user_page, locals: { user:user })
end

get("/p/movies") do
    movies = get_movies()
    slim(:movies, locals: { movies:movies })
end

get("/p/movies/movie/:movie_id") do
    movie_id = params[:movie_id]
    user_id = session[:user_id]

    movie = find_movie_by_id(movie_id)
    is_in_list = !find_saved_movies_by_user_id_and_movie_id(user_id, movie_id).empty?()
    reviews = find_reviews_by_user_id_and_movie_id(user_id, movie_id)
    rating = reviews.empty? ? "unset" : reviews[0]["rating"]

    slim(:movie_info, locals: { movie:movie, is_in_list:is_in_list, rating:rating })
end

post("/p/movies/movie/save/:id") do
    movie_id = params[:id]
    user_id = session[:user_id]

    add_saved_movie(user_id, movie_id)

    redirect("/p/movies/movie/#{movie_id}")
end

post("/p/movies/movie/remove/:id") do
    movie_id = params[:id]
    user_id = session[:user_id]

    remove_saved_movie(user_id, movie_id)

    redirect("/p/movies/movie/#{movie_id}")
end

post("/p/movies/movie/add_rating/:id") do
    rating = params[:rating]
    movie_id = params[:id]

    user_id = session[:user_id]

    if find_reviews_by_user_id_and_movie_id(user_id, movie_id).empty?()
        add_rating(user_id, movie_id, rating)
    else
        change_rating(user_id, movie_id, rating)
    end

    all_ratings = find_reviews_by_movie(movie_id)
    avg_rating = 0
    all_ratings.each do |ra|
        avg_rating += ra["rating"].to_i()   
    end

    avg_rating = avg_rating.to_f() / all_ratings.length
    update_user_rating(movie_id, avg_rating)

    redirect("p/movies/movie/#{movie_id}")
end

get("/p/watch_list") do
    user_id = session[:user_id]

    saved_movies = find_saved_movies_by_user_id(user_id)

    movies = []
    saved_movies.each do |saved_movie|
        movie_id = saved_movie["movie_id"]
        movies << find_movie_by_id(movie_id)
    end

    slim(:watch_list, locals: { movies:movies })
end

get("/a/admin_page") do
    users = get_users()
    slim(:admin_page, locals: { users:users })
end

post("/a/remove_user/:id") do
    user_id = params[:id]
    remove_user(user_id)
    redirect("/a/admin_page")
end

def username_taken?(username)
    return !find_user_by_name(username).nil?()
end

def change_start_message(message, position)
    session[:message] = message
    session[:message_position] = position
end
