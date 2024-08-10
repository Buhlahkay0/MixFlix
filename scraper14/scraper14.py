from selenium import webdriver
import time
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

import requests

import urllib.parse

import asyncio

import methods

import sys


# SETTINGS ----------

# collectionName = "Shows_4-6"
# headless = False

# -------------------


methods.login()

# Check if login was successful
yeetus = methods.wait_for_element(methods.driver, By.CLASS_NAME, "list-profiles")
if "https://www.netflix.com/browse" in methods.driver.current_url:
    print("Login: successful")

    # Select a profile
    select_profile_button = methods.driver.get("https://www.netflix.com/SwitchProfile?tkn=MI2GHKGOTZGBFCUODGKHTSENUE")

    # Check if profile selection was successful
    methods.wait_for_element(methods.driver, By.CLASS_NAME, "tabbed-primary-navigation")
    if "https://www.netflix.com/browse" in methods.driver.current_url:
        print("Profile selection: successful")

        # Select "New & Popular"
        select_new_popular_button = methods.driver.get("https://www.netflix.com/latest")

        # Check if "New & Popular" selection was successful
        methods.wait_for_element(methods.driver, By.ID, "row-1")
        if "https://www.netflix.com/latest" in methods.driver.current_url:
            print("New & popular selection: successful")

            wait = WebDriverWait(methods.driver, 10)
            
            div1 = methods.wait_for_element(methods.driver, By.CSS_SELECTOR, "[data-list-context='windowedNewReleases']")
            div2 = None
            div3 = None

            while div1 is None or div2 is None:
                mostWatchedElements = wait.until(EC.presence_of_all_elements_located((By.CSS_SELECTOR, "div[data-list-context='mostWatched']")))
                if len(mostWatchedElements) >= 2:
                    div2 = mostWatchedElements[0]
                    div3 = mostWatchedElements[1]


            for div in [div1, div2, div3]:
                methods.scrapeRow(div)
            
            print("Trending page scrape: successful")
            
        # Select "Movies"
        select_movie_button = methods.driver.get("https://www.netflix.com/browse/genre/34399")

        # Check if "Movies" selection was successful
        methods.wait_for_element(methods.driver, By.ID, "row-1")
        if "https://www.netflix.com/browse/genre/34399" in methods.driver.current_url:
            print("Movies selection: successful")

            foundRows = methods.searchForRows(False)
            
            for row in foundRows:
                if row is not None:
                    methods.scrapeRow(row)
            
            print("Movies page scrape: successful")
        
        # Select "Shows"
        select_movie_button = methods.driver.get("https://www.netflix.com/browse/genre/83")

        # Check if "Shows" selection was successful
        methods.wait_for_element(methods.driver, By.ID, "row-1")
        if "https://www.netflix.com/browse/genre/83" in methods.driver.current_url:
            print("Shows selection: successful")

            foundRows = methods.searchForRows(True)
            
            for row in foundRows:
                if row is not None:
                    methods.scrapeRow(row)
            
            print("Shows page scrape: successful")

        else:
            print("Movies selection: failed")
            exit(1)

    else:
        print("Profile selection: failed")
        exit(1)

else:
    print("Login: failed")
    exit(1)

print("Scrape completed successfully :D")

methods.checkForNullValues()

# Close the browser
methods.driver.quit()