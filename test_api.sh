#!/bin/bash
BASE_URL="http://localhost:5000"
EMAIL="test@example.com"
PASSWORD="password123"

echo "Registering user..."
curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}"

echo -e "\nLogging in..."
TOKEN=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "Login failed"
  exit 1
fi

echo "Token received: $TOKEN"

echo -e "\nAdding transaction..."
curl -s -X POST $BASE_URL/transactions/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "type": "income", "category": "Salary", "date": "2023-10-27"}'

echo -e "\nGetting transactions..."
curl -s -X GET $BASE_URL/transactions/ \
  -H "Authorization: Bearer $TOKEN"

echo -e "\nGetting summary..."
curl -s -X GET $BASE_URL/transactions/summary \
  -H "Authorization: Bearer $TOKEN"

echo -e "\nDone."
