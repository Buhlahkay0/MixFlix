import datetime

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore


SessionsCollection = "Sessions"

daysOld = int(input("Max age (days): "))


numDeleted = 0

# Use a service account
cred = credentials.Certificate('/Users/blakegabriel/Development/Netflix_Tinder/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

# Access the Firestore database
db = firestore.client()

time_ago = datetime.datetime.utcnow() - datetime.timedelta(days=daysOld)

print("Find docs...")

query = db.collection(SessionsCollection).where('Creation_Date', '<', time_ago)

print("Deleting docs...")

for doc in query.stream():
    doc.reference.delete()
    numDeleted += 1

print("Number of documents deleted: " + str(numDeleted))