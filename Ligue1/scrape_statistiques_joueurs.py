import requests
from bs4 import BeautifulSoup
import pandas as pd

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