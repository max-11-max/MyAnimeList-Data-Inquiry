DROP SCHEMA IF EXISTS Myanimelist CASCADE;
CREATE SCHEMA Myanimelist;
SET SEARCH_PATH TO Myanimelist;

CREATE DOMAIN Type AS varchar(7)
	CHECK (VALUE IN ('TV', 'Movie', 'OVA', 'Special', 'ONA', 'Music', 'Unknown'));

CREATE DOMAIN Rating AS varchar(5)
	CHECK (VALUE IN ('G', 'PG-13', 'PG', 'R', 'Rx', 'R+'));

CREATE DOMAIN AnimeScore AS FLOAT
	CHECK (VALUE >= 0 and VALUE <= 10);

-- An anime from MAL
-- aID is the anime’s ID on MAL, title is obvious, the type is the form of 
-- media the anime is (e.g. TV, movie, OVA,), episodes is obvious, source is 
-- the source material origin (e.g. manga, light novel, original, etc), 
-- rating is the age rating for the anime (e.g. G, PG, R, etc), score is a 
-- weighted value for the anime (more details here 
-- https://myanimelist.net/info.php?go=topanime), scoredBy is the number of 
-- users the anime has been scored by, rank is the rank of the anime against all 
-- other anime (based on score), popularity is the rank based upon the number of 
-- users who have added the anime to their list, members is the number of users 
-- who have added the anime to their list, favorites is the number of users who 
-- have favorited the anime.
CREATE TABLE Anime (
	aID INT,
	title TEXT NOT NULL,
	type Type NOT NULL,
	episodes INT NOT NULL CHECK (episodes >= 0),
	source TEXT NOT NULL,
	rating Rating NOT NULL,
	score AnimeScore NOT NULL,
	scoredBy INT NOT NULL CHECK (scoredBy >= 0),
	members INT NOT NULL CHECK (members >= 0),
	favorites INT NOT NULL CHECK (favorites >= 0),
	PRIMARY KEY (aID)
);

-- A genre of the corresponding anime.
-- aID is the anime’s ID on MAL, genre is the name of the genre, theme, 
-- demographic, or explicit genre.
CREATE TABLE Genre (
	aID INT,
	genre TEXT,
	PRIMARY KEY(aID, genre),
	FOREIGN KEY (aID) REFERENCES Anime(aID)
);

CREATE DOMAIN Gender AS varchar(10)
	CHECK (VALUE IN ('Male', 'Female', 'Non-Binary'));

-- A user on MAL.
-- uID is the ID of the user, gender is obvious (includes male, female, 
-- non-binary), and dateOfBirth is obvious.
CREATE TABLE MALUser (
	uID INT,
	gender Gender NOT NULL,
	dateOfBirth DATE NOT NULL CHECK (dateOfBirth < CURRENT_DATE),
	PRIMARY KEY (uID)
);

-- An anime that is favorited by the corresponding user.
-- uID is the user’s ID on MAL, and aID is the ID of the anime that was
-- favorited by the user.
CREATE TABLE Favorites (
	uID INT,
	aID INT,
	PRIMARY KEY(uID, aID),
	FOREIGN KEY (uID) REFERENCES MALUser(uID),
	FOREIGN KEY (aID) REFERENCES Anime(aID)
);

CREATE DOMAIN UserScore AS INT
	CHECK (VALUE >= 0 AND VALUE <= 10);

-- A review form MAL.
-- rID is the review’s ID on MAL, uID is the user’s ID on MAL, aID is the
-- anime’s ID on MAL, overallScore is the number value of the overall score
-- of the review for the anime.
CREATE TABLE Review (
	rID INT,
	uID INT NOT NULL,
	aID INT NOT NULL,
	overallScore UserScore NOT NULL,
	PRIMARY KEY (rID),
	FOREIGN KEY (uID) REFERENCES MALUser(uID),
	FOREIGN KEY (aID) REFERENCES Anime(aID)
);

CREATE DOMAIN CategoryName AS varchar(9)
	CHECK (VALUE IN ('Story', 'Animation', 'Sound', 'Character', 'Enjoyment'));

-- A score of a specific category of the corresponding anime.
-- rID is the review ID on MAL, category is obvious (includes story, animation,
-- sound, character, enjoyment), and score is obvious.
CREATE TABLE Scores (
	rID INT,
	category CategoryName,
	score UserScore NOT NULL,
	PRIMARY KEY(rID, category),
	FOREIGN KEY (rID) REFERENCES Review(rID)
);

