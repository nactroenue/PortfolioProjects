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