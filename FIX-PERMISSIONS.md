# 🚨 Auth0 Permission Fix Guide

## Problem
Your Terraform deployment is failing with "access_denied" "Unauthorized" errors because your Auth0 Management API application doesn't have the required scopes.

## ✅ Solution Steps

### 1. Go to your Auth0 Dashboard
Visit: https://manage.auth0.com/dashboard/us/dev-ttiw0oehq6nnv2jk/

### 2. Navigate to Applications
- Click **Applications** in the left sidebar
- Find your Machine to Machine application (the one with client ID: `oKs0PcU5MhzDnKQqalf1xQKYLE4YsCOK`)

### 3. Authorize for Management API
- Click on your M2M application
- Go to the **APIs** tab
- Find **Auth0 Management API** and click the toggle to authorize it
- If it's already authorized, click on the dropdown arrow to expand it

### 4. Grant Required Scopes
Check/select ALL these scopes:

**Client Management:**
- ✅ `read:clients`
- ✅ `create:clients` 
- ✅ `update:clients`
- ✅ `delete:clients`

**Resource Server Management:**
- ✅ `read:resource_servers`
- ✅ `create:resource_servers`
- ✅ `update:resource_servers` 
- ✅ `delete:resource_servers`

**Connection Management:**
- ✅ `read:connections`
- ✅ `create:connections`
- ✅ `update:connections`
- ✅ `delete:connections`

**Role Management:**
- ✅ `read:roles`
- ✅ `create:roles`
- ✅ `update:roles`
- ✅ `delete:roles`

**Action Management:**
- ✅ `read:actions`
- ✅ `create:actions`
- ✅ `update:actions`
- ✅ `delete:actions`

**Client Grant Management:**
- ✅ `read:client_grants`
- ✅ `create:client_grants`
- ✅ `update:client_grants`
- ✅ `delete:client_grants`

### 5. Save Changes
Click **Update** to save the scope changes.

### 6. Wait a Few Minutes
Auth0 permissions can take 1-2 minutes to propagate.

### 7. Retry Terraform
```bash
terraform apply
```

## 🔍 How to Check Your Current Scopes

You can verify your current scopes by:
1. Going to your M2M app in Auth0 Dashboard
2. Click on **APIs** tab
3. Expand **Auth0 Management API**
4. Review the granted scopes

## 🚨 If You Still Get Errors

If you continue getting unauthorized errors:

1. **Double-check the client credentials** in terraform.tfvars
2. **Verify the domain** is correct: `dev-ttiw0oehq6nnv2jk.us.auth0.com`
3. **Wait 5 minutes** for permissions to fully propagate
4. **Try creating a new M2M application** with all scopes from the start

## 📞 Need Help?

The Auth0 Dashboard URL for your tenant:
https://manage.auth0.com/dashboard/us/dev-ttiw0oehq6nnv2jk/

Direct link to Applications:
https://manage.auth0.com/dashboard/us/dev-ttiw0oehq6nnv2jk/applications
