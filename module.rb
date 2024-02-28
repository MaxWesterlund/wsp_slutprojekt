require "sqlite3"

def add_user(username, password_digest)
    get_db().execute("INSERT INTO users (username, password_digest) VALUES (?, ?)", username, password_digest)
end

def find_user_by_name(username)
    get_db().execute("SELECT * FROM users WHERE username IS ?", username).first()
end

def find_user_by_id(user_id)
    get_db().execute("SELECT * FROM users WHERE username IS ?", user_id).first()
end

def get_movies()
    get_db().execute("SELECT * FROM movies")
end

def find_movie_by_id(movie_id)
    get_db().execute("SELECT * FROM movies WHERE id IS ?", movie_id).first()
end

def find_saved_movies_by_user_id(user_id)
    get_db().execute("SELECT * FROM saved_movies WHERE user_id IS ?", user_id)
end

def find_saved_movies_by_user_id_and_movie_id(user_id, movie_id)
    get_db().execute("SELECT * FROM saved_movies WHERE user_id IS ? AND movie_id IS ?", user_id, movie_id)
end

def add_saved_movie(user_id, movie_id)
    get_db().execute("INSERT INTO saved_movies (user_id, movie_id) VALUES (?, ?)", user_id, movie_id)
end

def remove_saved_movie(user_id, movie_id)
    get_db().execute("DELETE FROM saved_movies WHERE user_id IS ? AND movie_id IS ?", user_id, movie_id)
end

def get_db()
    db = SQLite3::Database.new("db/data.db")
    db.results_as_hash = true
    return db
end