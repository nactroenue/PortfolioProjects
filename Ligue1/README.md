# Projet d'analyse Ligue 1 2021-2022

Ce projet Python se concentre sur l'extraction des statistiques de football du site footmercato.net pour la saison 2021-2022 de Ligue 1. Le projet comprend deux parties principales : le classement des équipes et les statistiques des joueurs. De plus, un tableau de bord Power BI est créé pour visualiser les données collectées.

## Partie 1 : Scrape le classement des équipes

Le script scrape_equipes_classement.py récupère et enregistre les données de classement des équipes dans un fichier CSV nommé Ligue1Equipe.csv.

``` 
import requests
from bs4 import BeautifulSoup
import pandas as pd

url = 'https://www.footmercato.net/france/ligue-1/2021-2022/classement'
réponse = requests.get(url)

soup = BeautifulSoup(réponse.content, 'html.parser')

tableau = soup.select_one('#tournamentStandings > div:nth-child(2) > div > div > div > div.rankingTable__table > div.rankingTable__tableScroll > table')

données = []

for ligne in tableau.find_all('tr')[1:]:  # Ignorer la ligne d'en-tête
    # Extraction des informations de la ligne
    classement = ligne.find('td', class_='rankingTable__rank').text.strip()
    nom_équipe = ligne.find('td', class_='rankingTable__team').text.strip()
    points = ligne.find('td', class_='rankingTable__points').text.strip()
    matchs_joués = ligne.find_all('td', class_='rankingTable__acronym')[0].text.strip()
    différences = ligne.find_all('td', class_='rankingTable__acronym')[1].text.strip()
    victoires = ligne.find_all('td', class_='rankingTable__acronym')[2].text.strip()
    matches_nuls = ligne.find_all('td', class_='rankingTable__acronym')[3].text.strip()
    défaites = ligne.find_all('td', class_='rankingTable__acronym')[4].text.strip()
    buts_pour = ligne.find_all('td', class_='rankingTable__acronym')[5].text.strip()
    buts_contre = ligne.find_all('td', class_='rankingTable__acronym')[6].text.strip()

    données.append([classement, nom_équipe, points, matchs_joués, différences, victoires, matches_nuls, défaites, buts_pour, buts_contre])

statsLigue1 = pd.DataFrame(données, columns=['Classement', 'Nom de l\'équipe', 'Points', 'Matchs Joués', 'Différences', 'Victoires', 'Matchs Nuls', 'Défaites', 'Buts Pour', 'Buts Contre'])

statsLigue1.to_csv("Ligue1Equipe.csv", index=False)

print("Le classement a été créé et enregistré sous le nom 'Ligue1Equipe.csv'.")
```
## Partie 2 : Scrape les statistiques des joueurs

Le script scrape_statistiques_joueurs.py extrait les statistiques des joueurs en fonction de leurs positions (Gardien, Défenseur, Milieu, Attaquant) pour toutes les équipes listées dans nom_equipe_dict.

```
# Liste des noms d'équipes avec leur nom officiel sur le site
nom_equipe_dict = {
    "Bordeaux": "fc-girondins-de-bordeaux",
    "PSG": "PSG",
    "Marseille": "om",
    "Monaco": "as-monaco",
    "Rennes": "stade-rennais-fc",
    "Nice": "ogc-nice",
    "Strasbourg": "rc-strasbourg-alsace",
    "Lens": "racing-club-de-lens",
    "Lyon": "ol",
    "Nantes": "fc-nantes",
    "Lille": "losc",
    "Brest": "stade-brestois-29",
    "Reims": "stade-de-reims",
    "Montpellier": "montpellier-hsc",
    "Angers": "angers-sco",
    "Troyes": "estac",
    "Lorient": "fc-lorient",
    "Clermont": "clermont-foot-63",
    "ASSE": "asse",
    "Metz": "fc-metz"
}

# Fonction pour obtenir les informations de l'équipe
def obtenir_informations_equipe(nom_equipe):
    if nom_equipe in nom_equipe_dict:
        nom_officiel = nom_equipe_dict[nom_equipe]
        url_effectif = f'https://www.footmercato.net/club/{nom_officiel}/effectif/2021-2022'
        return nom_officiel, url_effectif
    else:
        return None, None

# Fonction pour obtenir les noms de colonnes en fonction de la position
def obtenir_noms_colonnes(position):
    if position == 'Goalkeeper':
        return ['Numéro Maillot', 'Nom', 'Âge', 'Matchs Joués', 'Buts', 'Passes Décisives', 'Arrêts', 'Penaltys Arrêtés']
    elif position == 'Defender':
        return ['Numéro Maillot', 'Nom', 'Âge', 'Matchs Joués', 'Buts', 'Passes Décisives', 'Tacles Remportés', 'Interceptions']
    elif position == 'Midfielder':
        return ['Numéro Maillot', 'Nom', 'Âge', 'Matchs Joués', 'Buts', 'Passes Décisives', 'Passes Totales', 'Tirs Totaux']
    elif position == 'Striker':
        return ['Numéro Maillot', 'Nom', 'Âge', 'Matchs Joués', 'Buts', 'Passes Décisives', 'Tirs Totaux', 'Dribbles Réussis']

# Fonction pour extraire les informations des joueurs
def extraire_informations_joueur(nom_equipe, position, nom_fichier):
    nom_officiel, url_effectif = obtenir_informations_equipe(nom_equipe)
    if not nom_officiel or not url_effectif:
        print(f"Informations de l'équipe '{nom_equipe}' non disponibles.")
        return

    reponse = requests.get(url_effectif)
    soupe = BeautifulSoup(reponse.content, 'html.parser')

    # Trouver la table en fonction de la position
    id_table = f'squadTable{position}'
    table_joueurs = soupe.find('table', {'id': id_table})

    if not table_joueurs:
        print(f"Aucune information sur les {position}s disponible pour {nom_equipe}.")
        return

    # Créer une liste vide pour stocker les données des joueurs
    donnees_joueurs = []

    # Parcourir chaque ligne dans la table
    for ligne in table_joueurs.find_all('tr')[1:]:
        colonnes = ligne.find_all('td')
        numero_maillot = colonnes[0].text.strip()
        nom = colonnes[1].find('span', class_='personCardCell__name').text.strip()
        age = colonnes[1].find('span', class_='personCardCell__description').text.strip()

        # Obtenir les statistiques spécifiques en fonction de la position
        if position == 'Goalkeeper':
            matchs_joues = colonnes[2].text.strip()
            buts = colonnes[3].text.strip()
            passes_decisives = colonnes[4].text.strip()
            arrets = colonnes[5].text.strip()
            penaltys_arretes = colonnes[6].text.strip()
            donnees_joueurs.append([numero_maillot, nom, age, matchs_joues, buts, passes_decisives, arrets, penaltys_arretes])
        elif position == 'Defender':
            # Extraire les statistiques des défenseurs
            matchs_joues = colonnes[2].text.strip()
            buts = colonnes[3].text.strip()
            passes_decisives = colonnes[4].text.strip()
            tacles_remportes = colonnes[5].text.strip()
            interceptions = colonnes[6].text.strip()
            donnees_joueurs.append([numero_maillot, nom, age, matchs_joues, buts, passes_decisives, tacles_remportes, interceptions])
        elif position == 'Midfielder':
            matchs_joues = colonnes[2].text.strip()
            buts = colonnes[3].text.strip()
            passes_decisives = colonnes[4].text.strip()
            passes_totales = colonnes[5].text.strip()
            tirs_totaux = colonnes[6].text.strip()
            donnees_joueurs.append([numero_maillot, nom, age, matchs_joues, buts, passes_decisives, passes_totales, tirs_totaux])
        elif position == 'Striker':
            matchs_joues = colonnes[2].text.strip()
            buts = colonnes[3].text.strip()
            passes_decisives = colonnes[4].text.strip()
            tirs_totaux = colonnes[5].text.strip()
            dribbles_reussis = colonnes[6].text.strip()
            donnees_joueurs.append([numero_maillot, nom, age, matchs_joues, buts, passes_decisives, tirs_totaux, dribbles_reussis])

    if not donnees_joueurs:
        print(f"Aucune donnée disponible pour les {position}s de {nom_equipe}.")
        return

    # Créer un DataFrame avec les noms de colonnes appropriés en fonction de la position
    df = pd.DataFrame(donnees_joueurs, columns=obtenir_noms_colonnes(position))
    df.to_csv(nom_fichier, index=False)
    print(f"Informations sur les joueurs {position}s de {nom_equipe} enregistrées sous {nom_fichier}.")

# Boucle pour extraire les informations de tous les joueurs de toutes les équipes
for nom_equipe in nom_equipe_dict.keys():
    for position in ['Goalkeeper', 'Defender', 'Midfielder', 'Striker']:
        nom_fichier = f'{nom_equipe}_{position}s_Info.csv'
        extraire_informations_joueur(nom_equipe, position, nom_fichier)

```

## Partie 3 : Power BI Dashboard

Le projet Power BI contient trois diapositives :

**1. Classement:** Affiche les données du classement des équipes de Ligue1Equipe.csv.

![image](https://github.com/nactroenue/Projet-de-statistiques-de-football-de-Ligue-1/assets/142616253/0140c913-7704-454d-9b9b-dc0fe05e3b13)

**2. Comparaison des équipes:** Permet de comparer les statistiques des équipes.

![image](https://github.com/nactroenue/Projet-de-statistiques-de-football-de-Ligue-1/assets/142616253/7fe8221f-1c82-4b20-8c37-c16557ae41bb)


**3. Statistiques des joueurs:** Visualizes player statistics based on their positions.

![image](https://github.com/nactroenue/Projet-de-statistiques-de-football-de-Ligue-1/assets/142616253/e4f17fa8-c852-4db6-b62d-f2951dc38196)

## Usage

1. Assurez-vous que Python 3.x et les bibliothèques requises sont installés sur votre système.
2. Exécutez les scripts scrape_equipes_classement.py et scrape_statistiques_joueurs.py pour extraire les données.
3. Ouvrez le fichier Power BI pour interagir avec le tableau de bord.

## Les fichiers

1. scrape_equipes_classement.py : script Python pour récupérer les classements des équipes.
2. scrape_statistiques_joueurs.py : Script Python pour scraper les statistiques des joueurs.
3. Ligue1.pbix: contient le tableau de bord interactif. Ouvrez-le à l'aide de Power BI Desktop.






---
Créé par Minkov Anton
