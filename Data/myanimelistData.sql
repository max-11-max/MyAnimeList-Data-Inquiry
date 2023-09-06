-- Dropping temporary tables in case they exist prior
DROP TABLE IF EXISTS TempUser CASCADE;
DROP TABLE IF EXISTS TempFavorites CASCADE;
DROP TABLE IF EXISTS TempReview CASCADE;
DROP TABLE IF EXISTS TempScores CASCADE;
DROP VIEW IF EXISTS JoinedFavorites CASCADE;
DROP VIEW IF EXISTS JoinedReviews CASCADE;
DROP VIEW IF EXISTS JoinedScores CASCADE;

-- Importing Data

\COPY Anime from anime.csv with csv HEADER

\COPY Genre from genre.csv with csv HEADER

-- Creating temporary table to hold users from maluser.csv because it also holds usernames
-- in order to join with data from other csv files that contain usernames, not uID integers
CREATE TABLE TempUser (
	username TEXT,
	uID INT,
	gender Gender NOT NULL,
	dateOfBirth DATE NOT NULL CHECK (dateOfBirth < CURRENT_DATE),
	PRIMARY KEY (username, uID)
);

\COPY TempUser from maluser.csv with csv HEADER

INSERT INTO MALUser (uID, gender, dateOfBirth)
SELECT uID, gender, dateOfBirth
FROM TempUser;

-- Creating temporary table to hold favorites.csv values because favorite.csv is extracted
-- from a newer dataset with only usernames and not uID integers
CREATE TABLE TempFavorites (
	username TEXT,
	aID INT
);

\COPY TempFavorites from favorites.csv with csv HEADER

-- Creating view to hold favorites and filter to only have uIDs that are in MALUser
-- and aIDs that are in Anime (favorite.csv is extracted from a newer dataset)
CREATE VIEW JoinedFavorites AS
SELECT DISTINCT TempUser.uID, TempFavorites.aID
FROM TempUser JOIN TempFavorites ON TempUser.username = TempFavorites.username
	JOIN Anime ON TempFavorites.aID = Anime.aID;

INSERT INTO Favorites (uID, aID)
SELECT uID, aID
FROM JoinedFavorites;

-- Creating temporary table to hold review.csv values because review.csv is extracted
-- from a newer dataset with only usernames and not uID integers
CREATE TABLE TempReview (
	rID INT,
	username TEXT NOT NULL,
	aID INT NOT NULL,
	overallScore UserScore NOT NULL,
	PRIMARY KEY (rID)
);

\COPY TempReview from review.csv with csv HEADER

-- Creating view to hold reviews and filter to only have uIDs that are in MALUser
-- and aIDs that are in Anime (review.csv is extracted from a newer dataset)
CREATE VIEW JoinedReviews AS
SELECT TempReview.rID, TempUser.uID, TempReview.aID, TempReview.overallScore
FROM TempReview JOIN TempUser ON TempReview.username = TempUser.username
	JOIN Anime ON TempReview.aID = Anime.aID;

INSERT INTO Review (rID, uID, aID, overallScore)
SELECT rID, uID, aID, overallScore
FROM JoinedReviews;

-- Creating temporary table to hold scores.csv values because scores.csv needs to be filtered
-- to only have valid rIDs from Review
CREATE TABLE TempScores (
	rID INT,
	category CategoryName,
	score UserScore NOT NULL
);

\COPY TempScores from scores.csv with csv HEADER

-- Creating view to hold scores and filter to only have rIDs that are in Review
CREATE VIEW JoinedScores AS
SELECT DISTINCT TempScores.rID, TempScores.category, TempScores.score
FROM TempScores JOIN Review ON TempScores.rID = Review.rID;

INSERT INTO Scores (rID, category, score)
SELECT rID, category, score
FROM JoinedScores;

-- Dropping temporary tables and views
DROP TABLE IF EXISTS TempUser CASCADE;
DROP TABLE IF EXISTS TempFavorites CASCADE;
DROP TABLE IF EXISTS TempReview CASCADE;
DROP TABLE IF EXISTS TempScores CASCADE;