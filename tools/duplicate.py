import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore


collectionToDuplicate = input("Collection to duplicate: ")
nameOfNewCollection = input("Name of new collection: ")


# initialize Firebase Admin SDK
cred = credentials.Certificate("/Users/blakegabriel/Development/Netflix_Tinder/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# get reference to Firestore database
db = firestore.client()

# get reference to "ref1" collection
ref1 = db.collection(collectionToDuplicate)

# create "ref2" collection
ref2 = db.collection(nameOfNewCollection)

# query all documents in "Shows" collection
docs = ref1.get()

# loop through each document and add to "Test1" collection
for doc in docs:
    doc_data = doc.to_dict()
    ref2.add(doc_data)

print("Duplicated \"" + collectionToDuplicate + "\" as \"" + nameOfNewCollection + "\"")