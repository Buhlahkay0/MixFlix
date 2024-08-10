import requests
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Replace YOUR_API_KEY with your actual TMDB API key
TMDB_API_KEY = "953f2413b707391bb1754fe9c8754831"

# Replace YOUR_FIREBASE_CREDENTIALS_FILE with the path to your Firebase credentials JSON file
cred = credentials.Certificate("/Users/blakegabriel/Development/Netflix_Tinder/serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def fetch_posters(movie_titles):
    posters = {}
    base_url = "https://api.themoviedb.org/3/search/movie"

    for idx, title in enumerate(movie_titles):
        params = {
            "api_key": TMDB_API_KEY,
            "query": title,
        }

        response = requests.get(base_url, params=params)
        if response.status_code == 200:
            data = response.json()
            results = data.get("results", [])
            if results:
                poster_path = results[0].get("poster_path")
                if poster_path:
                    posters[f"Poster{idx+1}"] = f"https://image.tmdb.org/t/p/w500{poster_path}"
            else:
                print(f"Poster not found for {title}")

    return posters

def write_to_firestore(posters):
    doc_ref = db.collection("Resources").document("Homepage_Posters")
    doc_ref.set(posters)

if __name__ == "__main__":
    movie_titles = [
        "Fatale",
        "Hidden Strike",
        "the fast and the furious",
        "Puss In Boots The Last Wish",
        "happiness for beginners"
    ]

    posters = fetch_posters(movie_titles)
    if posters:
        write_to_firestore(posters)
        print("Posters written to Firestore successfully!")
    else:
        print("No posters found.")

