--Top 10 des Artistes par Nombre de Chansons
SELECT
    a.ArtistName,
    COUNT(*) AS song_count
FROM Song s
JOIN Artist a ON s.ArtistURI = a.ArtistURI
GROUP BY a.ArtistName
ORDER BY song_count DESC
LIMIT 10;

--Analyse par Décennie : Danseabilité, Énergie, Positivité
SELECT
    d.StartYear || '-' || d.EndYear as Decade,
    ROUND(AVG(CAST(s.Danceability as numeric)), 3) AS avg_danceability,
    ROUND(AVG(CAST(s.energy as numeric)), 3) AS avg_energy,
    ROUND(AVG(CAST(s.valence as numeric)), 3) AS avg_valence
From Song s
JOIN Decade d ON s.DecadeID = d.DecadeID
GROUP BY Decade
ORDER BY Decade;

--Analyse de Corrélation : Attributs Musicaux
SELECT
   	ROUND(CORR(Danceability, Energy)::NUMERIC, 3) AS corr_danceability_energy,
    ROUND(CORR(Danceability, Valence)::NUMERIC, 3) AS corr_danceability_valence,
    ROUND(CORR(Danceability, Tempo)::NUMERIC, 3) AS corr_danceability_tempo,
    ROUND(CORR(Energy, Valence)::NUMERIC, 3) AS corr_energy_valence,
    ROUND(CORR(Energy, Tempo)::NUMERIC, 3) AS corr_energy_tempo,
    ROUND(CORR(Valence, Tempo)::NUMERIC, 3) AS corr_valence_tempo
FROM Song;

--Top 5 des Genres les Plus Populaires par Décennie
With RankedGenres as (
    select 
    g.GenreName,
    d.StartYear || '-' || d.EndYear as Decade,
    RANK() over (partition  by d.DecadeID order  by AVG(s.Popularity) desc) as GenreRank
from  Song s
join Genre g ON s.GenreID = g.GenreID
join Decade d ON s.DecadeID = d.DecadeID
group by g.GenreName, Decade, d.decadeid 
)
select  Decade,
    array_agg(GenreName) AS TopGenres
from RankedGenres
where GenreRank <= 5
group by Decade
order  by Decade;


