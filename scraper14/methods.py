from selenium import webdriver
import time
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.action_chains import ActionChains

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

import requests

import urllib.parse

import asyncio

import sys

import globals

# import scraper11

# check if args are met
#args = sys.argv
args = [
    "0",
    "False",
    "Shows_08-05"
]
if len(args) != 3:
    print("Error: Scraper must be run as 'python3 <scraper0> <headless (bool)> <collectionName (string)>'")
    sys.exit(1)

# Settings ------------------

# headless = False
# collectionName = "Shows_05-15"


# ---------------------------

if args[1] == "True":
    headless = True
else:
    headless = False

collectionName = args[2]


# Initialize Firebase SDK
cred = credentials.Certificate("/Users/blakegabriel/Development/Netflix_Tinder/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# Create a Firestore client
db = firestore.client()


# geckodriver_path = './drivers/macos/geckodriver'
geckodriver_path = './drivers/windows/geckodriver.exe'


# Set the options
options = Options()
if (headless == True):
    options.add_argument('-headless')

options.add_argument("--mute-audio")

options.set_preference("media.volume_scale", "0.0")

# Set up the Firefox driver
driver = webdriver.Firefox(executable_path=geckodriver_path, options=options)

# TMDB
api_key = "953f2413b707391bb1754fe9c8754831"
base_url = "https://api.themoviedb.org/3"
headers = {"Authorization": f"Bearer {api_key}"}


def login():
    # Log in to Netflix
    login_url = "https://www.netflix.com/login"
    driver.get(login_url)
    email_field = driver.find_element(By.ID, "id_userLoginId")
    email_field.send_keys("lynnshadlegabriel@yahoo.com")
    password_field = driver.find_element(By.ID, "id_password")
    password_field.send_keys("lamppost21")
    login_button = driver.find_element(By.CSS_SELECTOR, ".btn.login-button.btn-submit.btn-small")
    login_button.click()

def wait_for_element(driver, locator_strategy, locator_value, timeout=10):

    for i in range(5):
        try:
            locator = (locator_strategy, locator_value)
            return WebDriverWait(driver, timeout).until(EC.presence_of_element_located(locator))
        except TimeoutException:
            print("Timed Out")
            break
        except:
            print("Failed. Retrying in 1 second")
            time.sleep(1)
        
        print("Failed to locate element :(")

        # Close the browser
        driver.quit()
        return None

def click_slider_items(div, i):
    # Generate CSS selector for current element
    css_selector = f'.slider-item[class*="slider-item-{i}"]'
    element = wait_for_element(div, By.CSS_SELECTOR, css_selector)

    time.sleep(1)

    #click on thumbnail
    element.click()

    title_el = wait_for_element(driver, By.XPATH, './/div[@class="previewModal--player-titleTreatmentWrapper"]//img[@class="previewModal--player-titleTreatment-logo"]')
    title = title_el.get_attribute("title")
    print(title)
    year_el = wait_for_element(driver, By.CLASS_NAME, 'year')
    year = year_el.get_attribute("innerHTML")
    rating_el = wait_for_element(driver, By.CLASS_NAME, 'maturity-number')
    rating = rating_el.get_attribute("innerHTML")
    duration_el = wait_for_element(driver, By.CLASS_NAME, 'duration')
    duration = duration_el.get_attribute("innerHTML")

    if "Season" in duration or "Episode" in duration or "Series" in duration:
        isShow = True
    else:
        isShow = False

    genres_parent_el = wait_for_element(driver, By.CSS_SELECTOR, '[data-uia="previewModal--tags-genre"]')
    genres_el = wait_for_element(genres_parent_el, By.CLASS_NAME, 'tag-item')
    genres_a_element = wait_for_element(genres_el, By.TAG_NAME, "a")
    genres = genres_a_element.text
    genres = genres.replace(",", "")
    description_el = wait_for_element(driver, By.XPATH, '//*[@id="appMountPoint"]/div/div/div[1]/div[2]/div/div[3]/div/div[1]/div/div/div[1]/p/div')
    description = description_el.get_attribute("innerHTML")

    poster_url = getPoster(title)

    time.sleep(0.5)

    query = db.collection(collectionName).where("Title", "==", title)
    matching_docs = query.get()

    if len(matching_docs) > 0:
        print("A document with the same title already exists.")
    else:
        addToFirestore(title, poster_url, year, rating, duration, description, isShow, genres)

    close_button = wait_for_element(driver, By.CLASS_NAME, "previewModal-close")
    time.sleep(0.5)
    close_button.click()

    actions = ActionChains(driver)
    # netflix_button = wait_for_element(driver, By.CSS_SELECTOR, "a[aria-label=\"Netflix\"]")
    # actions.move_to_element_with_offset(netflix_button, 0, 0)
    actions.move_by_offset(0, 0).perform()

    return title


def addToFirestore(title, poster_url, year, rating, duration, description, isShow, genres):
    doc_ref = db.collection(collectionName).document()
    doc_ref.set({
        'Title': title,
        #'Cover': img_src,
        'Cover': poster_url,
        'Year': year,
        'Rating': rating,
        'Duration': duration,
        'Description': description,

        'Is_Show': isShow,

        'Genres': genres,
    })

# def addToFirestorePosters(index, poster_url):
#     doc_ref = db.collection(collectionName).document("Homepage_posters")
#     doc_ref.set({
#         f'Poster{index}': poster_url,
#     })

def getPoster(title):

    # Set up search query parameters
    query = title
    params = {
        "api_key": api_key,
        "query": query,
        "language": "en-US",
        "include_adult": True,
        "page": 1,
    }

    # Encode query parameter
    params_encoded = urllib.parse.urlencode(params, safe=":")

    # The unencoded URL
    url = f"{base_url}/search/multi?{params_encoded}"

    # Make request to search for movies and TV shows
    response = requests.get(url, headers=headers)
    response.raise_for_status()  # Raise exception if request fails

    # Get first result from search
    results = response.json()["results"]
    if not results:
        # No results found for search query
        poster_url = None
        print("No results found")
    else:
        # Get poster image URL from movie or TV show details
        first_result = results[0]
        media_type = first_result["media_type"]
        if media_type == "movie":
            movie_id = first_result["id"]
            response = requests.get(f"{base_url}/movie/{movie_id}", headers=headers, params=params)
            response.raise_for_status()  # Raise exception if request fails
            poster_url = f"https://image.tmdb.org/t/p/original{response.json()['poster_path']}"
        elif media_type == "tv":
            tv_id = first_result["id"]
            response = requests.get(f"{base_url}/tv/{tv_id}", headers=headers, params=params)
            response.raise_for_status()  # Raise exception if request fails
            poster_url = f"https://image.tmdb.org/t/p/original{response.json()['poster_path']}"
        else:
            poster_url = None

        print(poster_url)
        return poster_url
    
def scrapeRow(div):
    # Click the next button
    next_button = wait_for_element(div, By.XPATH, ".//span[@class='handle handleNext active']")
    next_button.click()
    time.sleep(0.5)

    # Click the prev button
    next_button = wait_for_element(div, By.XPATH, ".//span[@class='handle handlePrev active']")
    next_button.click()
    time.sleep(1)

    notFirstTitle = True
    getFirst = True
    firstTitle = ""
    
    while notFirstTitle == True:
        
        # Loop through 5 times
        for i in range(1, 6):
            globals.counterThing = globals.counterThing + 1
            print(globals.counterThing)
            title = click_slider_items(div, i)

            if title == firstTitle:
                notFirstTitle = False
                globals.counterThing -= 1
                print("Row fully scraped")
                break

            if getFirst == True:
                firstTitle = title
                getFirst = False

        # Click the next button
        time.sleep(1)
        next_button = wait_for_element(div, By.XPATH, ".//span[@class='handle handleNext active']")
        next_button.click()

        actions = ActionChains(driver)
        netflix_button = wait_for_element(driver, By.CSS_SELECTOR, "a[aria-label=\"Netflix\"]")
        actions.move_to_element_with_offset(netflix_button, 0, 0)
        actions.perform()
        
        time.sleep(1)

def findRow(driver, by, value, timeout=5):
    try:
        element = WebDriverWait(driver, timeout).until(
            EC.presence_of_element_located((by, value))
        )
        return element
    except TimeoutException:
        return None

def searchForRows(shows):
    movies_popular_on_netflix = findRow(driver, By.CSS_SELECTOR, "[data-list-context='popularTitles']")
    movies_trending_now = findRow(driver, By.CSS_SELECTOR, "[data-list-context='trendingNow']")
    movies_recently_added = findRow(driver, By.CSS_SELECTOR, "[data-list-context='recentlyAdded']")
    #might not work
    movies_award_winning = findRow(driver, By.XPATH, "//div//h2//a//div[contains(text(),'Award-Winning Films')]")
    movies_new_releases = findRow(driver, By.CSS_SELECTOR, "[data-list-context='newThisWeek']")
    movies_only_on_netflix = findRow(driver, By.CSS_SELECTOR, "[data-list-context='netflixOriginals']")

    MoviesRows = [
        movies_popular_on_netflix,
        movies_trending_now,
        movies_recently_added,
        movies_award_winning,
        movies_new_releases,
        movies_only_on_netflix
    ]

    shows_popular_on_netflix = findRow(driver, By.CSS_SELECTOR, "[data-list-context='popularTitles']")
    shows_trending_now = findRow(driver, By.CSS_SELECTOR, "[data-list-context='trendingNow']")
    shows_recently_added = findRow(driver, By.CSS_SELECTOR, "[data-list-context='recentlyAdded']")
    #might not work
    #shows_award_winning_films = findRow(driver, By.XPATH, "//div//h2//a//div[contains(text(),'Award-Winning Films')]")
    shows_new_releases = findRow(driver, By.CSS_SELECTOR, "[data-list-context='newThisWeek']")
    shows_only_on_netflix = findRow(driver, By.CSS_SELECTOR, "[data-list-context='netflixOriginals']")

    ShowsRows = [
        shows_popular_on_netflix,
        shows_trending_now,
        shows_recently_added,
        #shows_award_winning_films,
        shows_new_releases,
        shows_only_on_netflix
    ]

    if shows:
        return ShowsRows
    else:
        return MoviesRows

def checkForNullValues():
    field_names = ["Cover", "Description", "Duration", "Genres", "Is_Show", "Rating", "Title", "Year"]
    null_docs = []

    queryStuff = db.collection(collectionName)
    for field in field_names:
        query = queryStuff.where(field, '==', None)
        docs = query.get()
        null_docs += docs

    print("Documents with null values:")

    if not null_docs:
        print("No null values")
    else:
        for doc in null_docs:
            print(f'Document ID: {doc.id}')

