#!/bin/bash

# Set the project ID
PROJECT_ID="spending-income-tracker"

# Use the specified project
firebase use $PROJECT_ID

# Deploy Firestore rules
echo "Deploying Firestore rules..."
firebase deploy --only firestore:rules

# Enable Email/Password Authentication
echo "Note: You need to manually enable Email/Password Authentication in the Firebase Console."
echo "Visit: https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"

echo "Firebase deployment completed!" 