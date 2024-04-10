require "sqlite3"

# Module for all of the sql commands
module Model
    # Finds all of the users in the database
    #
    # @return [Array] array of all the user data
    def get_users()
        get_db().execute("SELECT * FROM users")
    end 

    # Adds a new user to the database
    #
    # @param [String] username the users username
    # @param [String] password_digest the users encrypted password
    def add_user(username, password_digest)
        get_db().execute("INSERT INTO users (username, password_digest) VALUES (?, ?)", username, password_digest)
    end

    # Finds the user with the given name
    #
    # @param [String] username the username to look for
    #
    # @return [Hash] the user data
    def find_user_by_name(username)
        get_db().execute("SELECT * FROM users WHERE username IS ?", username).first()
    end

    # Finds the user with the given id
    #
    # @param [Integer] user_id the id to look for
    #
    # @return [Hash] the user data
    def find_user_by_id(user_id)
        get_db().execute("SELECT * FROM users WHERE id IS ?", user_id).first()
    end

    # Removes the user with the given id
    #
    # @param [Integer] user_id the id to look for
    def remove_user(user_id)
        get_db().execute("DELETE FROM users WHERE id IS ?", user_id)
    end

    # Finds all of the movies in the database
    #
    # @return [Array] array of all the movie data 
    def get_movies()
        get_db().execute("SELECT * FROM movies")
    end

    # Finds a the movie with the given id
    #
    # @param [Integer] movie_id the id to look for
    #
    # @return [Hash] the movie data
    def find_movie_by_id(movie_id)
        get_db().execute("SELECT * FROM movies WHERE id IS ?", movie_id).first()
    end

    # Updates the value of a specific user rating
    #
    # @param [Integer] movie_id the movie to update
    # @param [Integer] rating  the new rating
    def update_user_rating(movie_id, rating)
        get_db().execute("UPDATE movies SET user_rating = ? WHERE id IS ?", rating, movie_id)
    end

    # Finds movies saved by given user
    #
    # @param [Integer] user_id the id of the user to look for
    #
    # @return [Void]
    def find_saved_movies_by_user_id(user_id)
        get_db().execute("SELECT * FROM saved_movies WHERE user_id IS ?", user_id)
    end

    # Finds the a specific user rating for a specific movie
    #
    # @param [Integer] user_id the id of the user to look for
    # @param [Integer] movie_id the id of the movie to look for
    # 
    # @return [Void]
    def find_saved_movies_by_user_id_and_movie_id(user_id, movie_id)
        get_db().execute("SELECT * FROM saved_movies WHERE user_id IS ? AND movie_id IS ?", user_id, movie_id)
    end

    # Adds a saved movie for a user
    #
    # @param [Integer] user_id the id of the user to save to
    # @param [Integer] movie_id the id of the movie to save

    def add_saved_movie(user_id, movie_id)
        get_db().execute("INSERT INTO saved_movies (user_id, movie_id) VALUES (?, ?)", user_id, movie_id)
    end

    # Removes a saved movie from a user
    # 
    # @param [Integer] user_id the id of the user to remove from
    # @param [Integer] movie_id the id of the movie to remove
    #
    # @return [Void]
    def remove_saved_movie(user_id, movie_id)
        get_db().execute("DELETE FROM saved_movies WHERE user_id IS ? AND movie_id IS ?", user_id, movie_id)
    end

    # Finds the reviews of a movie
    #
    # @param [Integer] movie_id the id of the movie to look for
    #
    # @return [Array] the review data of the movie
    def find_reviews_by_movie(movie_id)
        get_db().execute("SELECT * FROM reviews WHERE movie_id IS ?", movie_id)
    end

    # Finds the reviews made by as specific user on a specific movie
    # 
    # @param [Integer] user_id the id of the user to look for
    # @param [Integer] movie_id the id of the movie to look for
    # 
    # @return [Array] the review data
    def find_reviews_by_user_id_and_movie_id(user_id, movie_id)
        get_db().execute("SELECT * FROM reviews WHERE user_id IS ? AND movie_id IS ?", user_id, movie_id)
    end

    # Adds a new rating to a movie
    # 
    # @param [Integer] user_id the id of the user giving the rating
    # @param [Integer] movie_id the id of the movie to review
    # @param [Integer] rating the rating to give
    # 
    # @return [Void]
    def add_rating(user_id, movie_id, rating)
        get_db().execute("INSERT INTO reviews (user_id, movie_id, rating) VALUES (?, ?, ?)", user_id, movie_id, rating)
    end

    # Changes the user rating of a movie
    #
    # @param [Integer] user_id the id of the user chaning the rating
    # @param [Integer] movie_id the id of the movie to change the rating of
    # @param [Integer] rating the new rating
    #
    # @return [Void]
    def change_rating(user_id, movie_id, rating)
        get_db().execute("UPDATE reviews SET rating = ? WHERE user_id IS ? AND movie_id IS ?", rating, user_id, movie_id)
    end
end

def get_db()
    db = SQLite3::Database.new("db/data.db")
    db.results_as_hash = true
    return db
end
