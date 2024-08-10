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


collectionName = input("Collection name: ")

# ---------------------------


# Initialize Firebase SDK
cred = credentials.Certificate("/Users/blakegabriel/Development/Netflix_Tinder/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# Create a Firestore client
db = firestore.client()



def checkForNullValues():
    field_names = ["Cover", "Description", "Duration", "Genres", "Is_Show", "Rating", "Title", "Year"]
    null_docs = []

    queryStuff = db.collection(collectionName)
    for field in field_names:
        query = queryStuff.where(field, '==', None)
        docs = query.get()
        null_docs += docs

    if not null_docs:
        print("No null values")
    else: 
        for doc in null_docs:
            print(f'Document ID: {doc.id}')



checkForNullValues()