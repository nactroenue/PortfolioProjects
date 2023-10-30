-- Détails album
SELECT albumuri, albumname, albumreleasedate, albumimageurl, albumartisturi, insertdate
FROM album;

-- Détails artiste
SELECT artisturi, artistname
FROM artist;

-- Relations artiste-genre et détails genre
SELECT ag.artisturi, ag.genreid, ag.insertdate, g.genrename
FROM artistgenre ag
JOIN genre g ON ag.genreid = g.genreid;

-- Infos décennies
SELECT decadeid, startyear, endyear
FROM decade;

-- Infos genre
SELECT genreid, genrename
FROM genre;

-- Détails piste avec attributs pertinents
SELECT trackuri, trackname, artisturi, albumuri, popularity, isrc, danceability, energy,
       "Key", loudness, mode, speechiness, acousticness, instrumentalness, liveness,
       valence, tempo, timesignature, genreid, decadeid, label, copyrights,
       albumreleasedate, trackduration
FROM song;
