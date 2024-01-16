--Requête SELECT de base
SELECT *
FROM maison_information
LIMIT 10;


-- Statistiques descriptives du prix
SELECT 
    COUNT(*) as Ventestotales,
    ROUND(AVG(prix),2) as Prix​​moyen,
    MIN(prix) as Prixminimum,
    MAX(prix) as Prixmaximum,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY prix) as Prixmédian,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY prix) as Premierquartile,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY prix) as Troisièmequartile
FROM maison_information;

--Statistiques descriptives des chambres
SELECT 
  COUNT(*) as Propriétéstotales,
  ROUND(AVG(chambres),2) as Chambresmoyennes,
  MIN(chambres) as Nomminchambres,
  MAX(chambres) as Nommaxchambres,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY chambres) as Chambresmédianes,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY chambres) as Premierquartile,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY chambres) as Troisièmequartile
FROM maison_information;

--Date de pointe des ventes
SELECT date_vente, COUNT(*) as Nombreventes
FROM maison_information
GROUP BY date_vente
ORDER BY Nombreventes DESC
LIMIT 1;

--Deuxième date de vente la plus élevée
SELECT date_vente, COUNT(*) as Nombreventes
FROM maison_information
GROUP BY date_vente
ORDER BY Nombreventes DESC
LIMIT 1 OFFSET 1;

--Jours de la semaine avec les ventes les plus élevées
SELECT 
  EXTRACT(DAY FROM TO_DATE(date_vente, 'YYYY-MM-DD')) AS JourDeVentesSemaine,
  COUNT(*) AS Nombreventes
FROM maison_information
GROUP BY JourDeVentesSemaine
ORDER BY JourDeVentesSemaine DESC;


--Code postal avec le prix moyen le plus élevé
SELECT code_postal, Round(AVG(prix),2) as prixmoyenne
FROM maison_information
GROUP BY code_postal
ORDER BY prixmoyenne DESC
LIMIT 1;

--Code postal avec le prix moyen le plus bas
SELECT code_postal, Round(AVG(prix),2) as prixmoyenne
FROM maison_information
GROUP BY code_postal
ORDER BY prixmoyenne
LIMIT 1;

--le code postal avec la plus grande variabilité de prix
SELECT code_postal, round(STDDEV(prix),2) as Variabilitéprix
FROM maison_information
GROUP BY code_postal
ORDER BY Variabilitéprix DESC
LIMIT 1;

--Prix moyen par nombre de chambres pour le code postal supérieur
SELECT chambres, ROUND(AVG(prix),2) as Prixmoyenne
FROM maison_information
WHERE code_postal = (
    SELECT code_postal 
    FROM maison_information
    GROUP BY code_postal
    ORDER BY AVG(prix) DESC
    LIMIT 1
)
GROUP BY chambres
ORDER BY chambres;

--Codes postaux avec appréciation rapide des prix
SELECT 
  code_postal,
  ROUND(AVG(prix),2) as prixmoyenne,
  ROUND(AVG(prix) - (SELECT AVG(prix) FROM maison_information),2) as Différencedeprix
FROM maison_information
GROUP BY code_postal
HAVING AVG(prix) > (SELECT AVG(prix) FROM maison_information)
ORDER BY Différencedeprix DESC;

--Répartition des propriétés par chambres dans le code postal supérieur
SELECT 
  chambres,
  COUNT(*) as Nompropriétés
FROM maison_information 
WHERE code_postal = (
    SELECT code_postal
    FROM maison_information
    GROUP BY code_postal
    ORDER BY AVG(prix) DESC
    LIMIT 1
)
GROUP BY chambres 
ORDER BY chambres;
 
--L'année avec le plus petit nombre de ventes
SELECT 
  EXTRACT(YEAR FROM TO_DATE(date_vente, 'YYYY-MM-DD')) AS Année_vente,
  COUNT(*) AS Nombre_ventes
FROM maison_information
GROUP BY Année_vente
ORDER BY Nombre_ventes
LIMIT 1;

--L'année avec les ventes totales les plus élevées
SELECT 
  EXTRACT(YEAR FROM TO_DATE(date_vente, 'YYYY-MM-DD')) AS Année_vente,
  COUNT(*) AS Nombre_ventes
FROM maison_information
GROUP BY Année_vente
ORDER BY Nombre_ventes DESC
LIMIT 1;

--Tendance annuelle des prix moyens
SELECT EXTRACT(YEAR FROM TO_DATE(date_vente, 'YYYY-MM-DD')) AS Année_vente, 
	   ROUND(AVG(Prix),2) AS Prixmoyen
FROM maison_information
GROUP BY Année_vente
ORDER BY Année_vente;

--Propriétés vendues chaque mois de l'année de vente la plus basse
SELECT 
  EXTRACT(MONTH FROM TO_DATE(date_vente, 'YYYY-MM-DD')) AS Mois_ventes,
  COUNT(*) AS Nombre_ventes
FROM maison_information
WHERE EXTRACT(YEAR FROM TO_DATE(date_vente, 'YYYY-MM-DD')) = (
  SELECT EXTRACT(YEAR FROM TO_DATE(date_vente, 'YYYY-MM-DD')) AS Année_vente
  FROM maison_information
  GROUP BY Année_vente
  ORDER BY COUNT(*) ASC
  LIMIT 1
)
GROUP BY Mois_ventes
ORDER BY Mois_ventes;

--Pourcentage de croissance annuelle des ventes
SELECT 
  Annéevente,
  Ventestotales,
  Ventesannéprécédente,
  CASE 
    WHEN Ventesannéprécédente IS NOT NULL THEN
      CONCAT(
        ROUND(((Ventestotales - Ventesannéprécédente)::numeric / Ventesannéprécédente) * 100, 2),
        '%')
    ELSE 
      NULL
  END AS Pourcentagecroissanceventes
FROM (
  SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_vente, 'YYYY-MM-DD')) AS Annéevente,
    COUNT(*) AS Ventestotales,
    LAG(COUNT(*)) OVER (ORDER BY EXTRACT(YEAR FROM TO_DATE(date_vente, 'YYYY-MM-DD'))) AS Ventesannéprécédente
  FROM maison_information
  GROUP BY Annéevente
) subquerySTDDE
ORDER BY Annéevente;


--Trois principaux codes postaux par prix annuel
WITH codes_postaux_classés AS (
  SELECT
    EXTRACT(YEAR FROM TO_DATE(date_vente,'YYYY-MM-DD')) AS Annéevente,
    code_postal,
    prix,
    ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM TO_DATE(date_vente,'YYYY-MM-DD')) ORDER BY prix DESC) AS Rang
  FROM maison_information
)
SELECT
  Annéevente,
  Code_postal,
  prix
FROM codes_postaux_classés
WHERE Rang <= 3
ORDER BY Annéevente, Rang;

--Codes postaux avec la plus grande répartition des prix
WITH écart_prix AS (
  SELECT
    code_postal,
    MAX(prix) - MIN(prix) AS écartprix
  FROM maison_information
  GROUP BY code_postal
)
SELECT
  code_postal ,
  écartprix
FROM écart_prix
ORDER BY écartprix DESC
LIMIT 5;

--Codes postaux avec appréciation rapide des prix
WITH prix_croissance AS (
  SELECT
    code_postal,
    (MAX(prix) - MIN(prix)) / MIN(prix) * 100 AS Pourcentagecroissanceprix
  FROM maison_information
  GROUP BY code_postal
)
SELECT
  code_postal,
  Pourcentagecroissanceprix
FROM prix_croissance
ORDER BY Pourcentagecroissanceprix DESC
LIMIT 5;

--Identifier les propriétés vendues en dessous de la valeur marchande
SELECT *
FROM maison_information
WHERE prix < (
    SELECT AVG(prix) * 0.8
    FROM maison_information
);

--Le code postal le plus rentable
SELECT 
  code_postal,
  ROUND(SUM(prix) - (SELECT AVG(prix) FROM maison_information), 2) AS Profit
FROM maison_information
GROUP BY code_postal
ORDER BY Profit DESC
LIMIT 1;

--Tendance des prix par code postal au fil du temps
SELECT 
  code_postal,
  EXTRACT(YEAR FROM TO_DATE(date_vente,'YYYY-MM-DD')) AS Annéevente,
  AVG(prix) AS Prix​​moyen
FROM maison_information
GROUP BY code_postal, Annéevente
ORDER BY code_postal, Annéevente;

--Pourcentage d'appréciation du prix
SELECT 
  *,
  (Prix - (SELECT Prix FROM maison_information AS Prev WHERE Prev.date_vente < maison_information.date_vente ORDER BY date_vente DESC LIMIT 1)) 
  / (SELECT prix FROM maison_information AS Prev WHERE Prev.date_vente < maison_information.date_vente ORDER BY date_vente  DESC LIMIT 1) * 100 AS PrixAppréciationPourcentage
FROM maison_information;

--Codes postaux avec des tendances de prix similaires
SELECT DISTINCT
  A.code_postal,
  B.code_postal AS Codepostalsimilaire
FROM (
  SELECT 
    code_postal,
    AVG(prix) AS prixmoyen
  FROM maison_information
  GROUP BY code_postal
) A
JOIN (
  SELECT 
    code_postal,
    AVG(prix) AS prixmoyen
  FROM maison_information
  GROUP BY code_postal
) B ON A.code_postal != B.code_postal
WHERE ABS(A.prixmoyen - B.prixmoyen) / A.prixmoyen < 0.05;

--Prix moyens mobiles par code postal
SELECT 
  date_vente, 
  code_postal,
  prix,
  AVG(prix) OVER (
    PARTITION BY code_postal
    ORDER BY date_vente
    ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
  ) AS Prixmoyenmobile
FROM maison_information;





