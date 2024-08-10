import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore


nameOfCollection = input("Collection name: ")

# Use a service account
cred = credentials.Certificate('/Users/blakegabriel/Development/Netflix_Tinder/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

# Initialize Firestore database
db = firestore.client()

# Get the collection reference
collection_ref = db.collection(nameOfCollection)

# Get the documents in the collection and count them
documents = collection_ref.get()
num_documents = len(documents)

print(f'The number of documents in the collection is {num_documents}.')
