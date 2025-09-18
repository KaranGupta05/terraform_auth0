#!/bin/bash

# Auth0 Permissions Verification Script
# This script helps verify your Management API permissions

set -e

echo "🔍 Auth0 Management API Permissions Checker"
echo "============================================"
echo ""

# Read credentials from terraform.tfvars
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found. Please ensure you're in the correct directory."
    exit 1
fi

# Extract values from terraform.tfvars
DOMAIN=$(grep 'auth0_domain' terraform.tfvars | cut -d'"' -f2)
CLIENT_ID=$(grep 'auth0_client_id' terraform.tfvars | cut -d'"' -f2)
CLIENT_SECRET=$(grep 'auth0_client_secret' terraform.tfvars | cut -d'"' -f2)

echo "📋 Configuration:"
echo "   Domain: $DOMAIN"
echo "   Client ID: $CLIENT_ID"
echo "   Client Secret: ${CLIENT_SECRET:0:10}..."
echo ""

# Get access token
echo "🔑 Getting access token..."
TOKEN_RESPONSE=$(curl -s --request POST \
  --url "https://$DOMAIN/oauth/token" \
  --header 'content-type: application/json' \
  --data "{
    \"client_id\":\"$CLIENT_ID\",
    \"client_secret\":\"$CLIENT_SECRET\",
    \"audience\":\"https://$DOMAIN/api/v2/\",
    \"grant_type\":\"client_credentials\"
  }")

# Check if we got an access token
ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ Failed to get access token. Response:"
    echo "$TOKEN_RESPONSE"
    echo ""
    echo "🔧 This usually means:"
    echo "   1. Your client credentials are incorrect"
    echo "   2. Your M2M app is not authorized for Auth0 Management API"
    echo "   3. Your domain is incorrect"
    echo ""
    echo "📍 Please check your Auth0 Dashboard:"
    echo "   https://manage.auth0.com/dashboard/us/$(echo $DOMAIN | cut -d'.' -f1 | cut -d'-' -f2-)/applications"
    exit 1
fi

echo "✅ Successfully obtained access token!"
echo ""

# Test API endpoints that Terraform needs
echo "🧪 Testing API permissions..."

# Test clients endpoint
echo "   Testing clients endpoint..."
CLIENTS_RESPONSE=$(curl -s -w "%{http_code}" --request GET \
  --url "https://$DOMAIN/api/v2/clients" \
  --header "authorization: Bearer $ACCESS_TOKEN" \
  --header 'content-type: application/json')

HTTP_CODE="${CLIENTS_RESPONSE: -3}"
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Clients API access: OK"
else
    echo "   ❌ Clients API access: FAILED (HTTP $HTTP_CODE)"
fi

# Test resource servers endpoint
echo "   Testing resource servers endpoint..."
RS_RESPONSE=$(curl -s -w "%{http_code}" --request GET \
  --url "https://$DOMAIN/api/v2/resource-servers" \
  --header "authorization: Bearer $ACCESS_TOKEN" \
  --header 'content-type: application/json')

HTTP_CODE="${RS_RESPONSE: -3}"
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Resource Servers API access: OK"
else
    echo "   ❌ Resource Servers API access: FAILED (HTTP $HTTP_CODE)"
fi

# Test connections endpoint
echo "   Testing connections endpoint..."
CONN_RESPONSE=$(curl -s -w "%{http_code}" --request GET \
  --url "https://$DOMAIN/api/v2/connections" \
  --header "authorization: Bearer $ACCESS_TOKEN" \
  --header 'content-type: application/json')

HTTP_CODE="${CONN_RESPONSE: -3}"
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Connections API access: OK"
else
    echo "   ❌ Connections API access: FAILED (HTTP $HTTP_CODE)"
fi

# Test roles endpoint
echo "   Testing roles endpoint..."
ROLES_RESPONSE=$(curl -s -w "%{http_code}" --request GET \
  --url "https://$DOMAIN/api/v2/roles" \
  --header "authorization: Bearer $ACCESS_TOKEN" \
  --header 'content-type: application/json')

HTTP_CODE="${ROLES_RESPONSE: -3}"
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Roles API access: OK"
else
    echo "   ❌ Roles API access: FAILED (HTTP $HTTP_CODE)"
fi

echo ""
echo "🎯 Summary:"
echo "   If all tests show ✅ OK, your permissions are correctly configured!"
echo "   If any tests show ❌ FAILED, please follow the instructions in FIX-PERMISSIONS.md"
echo ""
echo "📍 Auth0 Dashboard: https://manage.auth0.com/dashboard/us/$(echo $DOMAIN | cut -d'.' -f1 | cut -d'-' -f2-)/applications"
