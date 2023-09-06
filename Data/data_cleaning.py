import pandas as pd
from ast import literal_eval
from datetime import datetime

anime = pd.read_csv("anime_filtered.csv", usecols=["anime_id", "title", "type", "episodes", "source", "rating", "score", "scored_by", "members", "favorites", "genre"])

anime = anime.dropna(how="any")
anime = anime[anime.rating != "None"]

anime = anime.rename(columns={"anime_id": "aID", "scored_by": "scoredBy"})

genre = anime[['aID', 'genre']]
anime = anime[["aID", "title", "type", "episodes", "source", "rating", "score", "scoredBy", "members", "favorites"]]

anime.loc[anime['rating'] == "G - All Ages", 'rating'] = "G"
anime.loc[anime['rating'] == "PG - Children", 'rating'] = "PG"
anime.loc[anime['rating'] == "R - 17+ (violence & profanity)", 'rating'] = "R"
anime.loc[anime['rating'] == "PG-13 - Teens 13 or older", 'rating'] = "PG-13"
anime.loc[anime['rating'] == "Rx - Hentai", 'rating'] = "Rx"
anime.loc[anime['rating'] == "R+ - Mild Nudity", 'rating'] = "R+"

genre['genre'] = genre['genre'].str.split(pat=",")
genre = genre.explode('genre')

# USERS

user = pd.read_csv("users_filtered.csv", usecols=["username", "user_id", "gender", "birth_date"])
user = user.rename(columns={"user_id": "uID", "birth_date": "dateOfBirth"})
user = user.dropna(how="any")

user['dateOfBirth'] = pd.to_datetime(user['dateOfBirth'], errors='coerce')
user = user.dropna(how="any")
user = user[(user['dateOfBirth'] < datetime.now())]

favorites = pd.read_csv("profiles.csv", usecols=["profile", "favorites_anime"])

favorites = favorites.rename(columns={"profile": "username", "favorites_anime": "aID"})

favorites['aID'] = favorites['aID'].apply(lambda x: literal_eval(str(x)))
favorites = favorites.explode('aID')
favorites = favorites.dropna(how="any")

#REVIEWS

review = pd.read_csv("review_data.csv", usecols=["uid", "profile", "anime_uid", "score", "scores"])

review = review.rename(columns={"uid": "rID", "profile": "username", "anime_uid": "aID", "score": "overallScore", "scores": "score"})

scores = review[['rID', 'score']]
review = review[['rID', 'username', 'aID', 'overallScore']]
review = review.drop_duplicates()
review = review[review.overallScore <= 10]
review = review[review.overallScore >= 0]

scores['score'] = scores['score'].apply(literal_eval)

scores = pd.DataFrame([(n, k, v) for (n,d) in scores.values for k, v in d.items()])
scores.columns = ['rID', 'category', 'score']
scores = scores[scores.category != 'Overall']
scores['score'] = scores['score'].apply(literal_eval)
scores = scores[scores.score <= 10]
scores = scores[scores.score >= 0]


anime.to_csv("anime.csv", index=False)
genre.to_csv("genre.csv", index=False)

user.to_csv("maluser.csv", index=False)
favorites.to_csv("favorites.csv", index=False)

review.to_csv("review.csv", index=False)
scores.to_csv("scores.csv", index=False)

