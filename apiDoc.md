# BabyCare API Documentation

**Version:** 1.1.0  
**Date:** March 2026  
**Base URL:** https://babycare-api-0prm.onrender.com  
**Confidential — For Internal Use Only**

---

## Overview
The BabyCare API is a RESTful backend service that powers the BabyCare mobile and web applications. It connects parents with verified babysitters through a secure, role-based platform. All endpoints return JSON. Authentication uses Bearer JWT tokens issued on login.

---

## Authentication
Protected endpoints require an Authorization header with a Bearer token obtained from the login endpoint.

```
Authorization: Bearer <your_token>
```

Tokens are valid for 90 days.

---

## User Roles

| Role | Description | Access |
|------|------------|--------|
| admin | Platform administrator | Full access to all admin endpoints |
| parent | Parent looking for a babysitter | Browse babysitters, save, message, manage profile |
| babysitter | Babysitter offering services | Manage profile, set work status, respond to messages |

---

## Standard Error Response

```json
{ "error": "descriptive error message" }
```

---

## All Endpoints at a Glance

| Method | Endpoint | Auth | Role |
|--------|---------|------|------|
| GET | /health | No | Any |
| POST | /api/v1/auth/register/parent | No | — |
| POST | /api/v1/auth/register/babysitter | No | — |
| POST | /api/v1/auth/login | No | — |
| POST | /api/v1/auth/logout | Yes | Any |
| GET | /api/v1/admin/users | Yes | Admin |
| GET | /api/v1/admin/users/:id | Yes | Admin |
| PUT | /api/v1/admin/babysitters/:id/approve | Yes | Admin |
| PUT | /api/v1/admin/users/:id/suspend | Yes | Admin |
| DELETE | /api/v1/admin/users/:id | Yes | Admin |
| POST | /api/v1/admin/create | Yes | Admin |
| GET | /api/v1/admin/activity | Yes | Admin |
| GET | /api/v1/babysitters | No | — |
| GET | /api/v1/babysitters/:id | Yes | Parent, Babysitter |
| PUT | /api/v1/babysitters/profile | Yes | Babysitter |
| GET | /api/v1/babysitters/profile/views | Yes | Babysitter |
| GET | /api/v1/babysitters/profile/weekly-views | Yes | Babysitter |
| PUT | /api/v1/babysitters/work-status | Yes | Babysitter |
| GET | /api/v1/parents/profile | Yes | Parent |
| PUT | /api/v1/parents/profile | Yes | Parent |
| POST | /api/v1/parents/saved-babysitters | Yes | Parent |
| DELETE | /api/v1/parents/saved-babysitters/:babysitter_id | Yes | Parent |
| GET | /api/v1/parents/saved-babysitters | Yes | Parent |
| POST | /api/v1/conversations | Yes | Parent |
| GET | /api/v1/conversations | Yes | Parent, Babysitter |
| POST | /api/v1/conversations/:id/messages | Yes | Parent, Babysitter |
| GET | /api/v1/conversations/:id/messages | Yes | Parent, Babysitter |

---

# 1. Health Check

### GET /health (Any)
Verify the API server is running. No authentication required.

**Response**
```json
{
  "service": "babycare-api",
  "status": "ok"
}
```

---

# 2. Authentication

## POST /api/v1/auth/register/parent
Register a new parent account.

**Request Body**
```json
{
  "full_name": "Ochieng Samuel",
  "email": "samuel.ochieng@gmail.com",
  "phone": "+256772445566",
  "location": "Jinja, Uganda",
  "primary_location": "Ntinda, Kampala",
  "occupation": "Project Manager",
  "preferred_hours": "Flexible",
  "password": "OchiengSecure2026!"
}
```

| Field | Required | Notes |
|------|----------|------|
| full_name | Yes | |
| email | Yes | Must be unique |
| phone | No | |
| location | Yes | General area |
| primary_location | No | Specific home/work location |
| occupation | Yes | |
| preferred_hours | Yes | |
| password | Yes | Minimum 8 characters |

**Response 201 Created**
```json
{
  "id": "6590a01c-aaf6-47f1-b28b-cf75de37e263",
  "full_name": "Ochieng Samuel",
  "email": "samuel.ochieng@gmail.com",
  "phone": "+256772445566",
  "role": "parent",
  "status": "active",
  "created_at": "2026-03-19T18:30:08.210148Z"
}
```

---

## POST /api/v1/auth/register/babysitter
Register a new babysitter account. Uses multipart/form-data.

**Request Body — Content-Type: multipart/form-data**

| Field | Type | Required | Notes |
|------|------|----------|------|
| full_name | text | Yes | |
| email | text | Yes | Must be unique |
| phone | text | No | |
| location | text | Yes | |
| languages | text | Yes | Comma-separated e.g. English,Luganda |
| password | text | Yes | Minimum 8 characters |
| gender | text | Yes | male or female |
| availability | text | No | Comma-separated days e.g. Mon,Tue |
| rate_type | text | No | hourly, daily, weekly, or monthly |
| rate_amount | text | No | Numeric string e.g. 25000 |
| currency | text | No | Defaults to UGX |
| payment_method | text | No | Mobile Money, Cash, or Bank/Visa Card |
| national_id | file | Yes | Image |
| lci_letter | file | Yes | PDF |
| cv | file | Yes | PDF |
| profile_picture | file | Yes | Image |

**Response 201 Created**
```json
{
  "id": "9c7f5648-0059-46ce-91a1-d7826d5fc937",
  "full_name": "Mary Nakato",
  "email": "marynakato@example.com",
  "phone": "+256700000002",
  "role": "babysitter",
  "status": "active",
  "created_at": "2026-03-19T18:37:38.172614Z"
}
```

**Note:** Account is inactive until an admin approves it. Login returns 403 until approval.

---

## POST /api/v1/auth/login
Login for all user types (admin, parent, babysitter).

**Request Body**
```json
{
  "email": "kato.emma@outlook.com",
  "password": "Agumya2022!"
}
```

**Response**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2026-06-17T18:40:19.090884234Z",
  "user": {
    "id": "11b14ba7-d5bc-43cd-812b-a8fa8aecdb74",
    "full_name": "Kato Emmanuel",
    "email": "kato.emma@outlook.com",
    "phone": "+256702112233",
    "role": "parent",
    "status": "active",
    "created_at": "2026-03-19T15:49:14.301273Z"
  }
}
```

**Note:** Store the token securely (Flutter Secure Storage). Token expires in 90 days. Babysitters must be approved before login succeeds.

---

## POST /api/v1/auth/logout (Any)
Logout the currently authenticated user. Auth: Bearer token required.

**Response**
```json
{ "message": "logged out successfully" }
```

**Note:** Discard the token on the client side after calling this endpoint.

---

# 3. Admin
All admin endpoints require a valid admin Bearer token. Non-admin tokens receive 403 Forbidden.

## GET /api/v1/admin/users (Admin)
List all parent and babysitter accounts (admin accounts excluded).

**Response**
```json
[
  {
    "id": "b80b2ffd-c78f-43af-a67b-924b2b6746ee",
    "full_name": "Erina Ahabwe",
    "email": "edrina@gmail.com",
    "phone": "+1987654321",
    "role": "babysitter",
    "status": "active",
    "created_at": "2026-03-19T15:50:26.796082Z"
  }
]
```

## GET /api/v1/admin/users/:id (Admin)
Get full details of a single user including their profile.

**Response**
```json
{
  "id": "11b14ba7-d5bc-43cd-812b-a8fa8aecdb74",
  "full_name": "Kato Emmanuel",
  "email": "kato.emma@outlook.com",
  "phone": "+256702112233",
  "role": "parent",
  "status": "active",
  "created_at": "2026-03-19T15:49:14.301273Z",
  "location": "Queens, NY",
  "occupation": "Teacher",
  "preferred_hours": "Weekday mornings"
}
```

## PUT /api/v1/admin/babysitters/:id/approve
Approve a babysitter account.

```json
{ "message": "babysitter approved successfully" }
```

## PUT /api/v1/admin/users/:id/suspend
Suspend a user account.

```json
{ "message": "user suspended successfully" }
```

## DELETE /api/v1/admin/users/:id
Soft delete a user.

```json
{ "message": "user deleted successfully" }
```

## POST /api/v1/admin/create

```json
{
  "full_name": "Timo Mugumya",
  "email": "timo.mugumya@gmail.com",
  "password": "admin123"
}
```

## GET /api/v1/admin/activity

```json
[
  {
    "user_id": "b80b2ffd-c78f-43af-a67b-924b2b6746ee",
    "full_name": "Erina Ahabwe",
    "role": "babysitter",
    "activity_label": "Low",
    "message_count": 1
  }
]
```

---

# 4. Babysitters

## GET /api/v1/babysitters
List all approved, active, and available babysitters.

**Note:** Cached for 5 minutes.

---

## GET /api/v1/babysitters/:id
Get a single babysitter profile.

**Note:** Records a profile view automatically.

---

## PUT /api/v1/babysitters/profile
Update profile (multipart).

---

## PUT /api/v1/babysitters/work-status

```json
{ "is_available": false }
```

---

## GET /api/v1/babysitters/profile/views

## GET /api/v1/babysitters/profile/weekly-views

---

# 5. Parents

## GET /api/v1/parents/profile

## PUT /api/v1/parents/profile

## POST /api/v1/parents/saved-babysitters

## DELETE /api/v1/parents/saved-babysitters/:babysitter_id

## GET /api/v1/parents/saved-babysitters

---

# 6. Messaging
Messaging is powered by Stream Chat. Only parents can initiate conversations.

## POST /api/v1/conversations

## GET /api/v1/conversations

## POST /api/v1/conversations/:id/messages

## GET /api/v1/conversations/:id/messages

---

# 7. Error Code Reference

| HTTP Code | Meaning | Common Cause |
|----------|--------|--------------|
| 400 | Bad Request | Missing fields |
| 401 | Unauthorized | Invalid token |
| 403 | Forbidden | Role issues / not approved |
| 404 | Not Found | Missing resource |
| 409 | Conflict | Duplicate email |
| 500 | Server Error | Internal error |

---

# 8. Integration Notes for Flutter Team

## Token Storage
Store JWT in Flutter Secure Storage.

## Babysitter Registration
Use multipart/form-data.

## Messaging Flow
Poll messages endpoint.

## Profile View Recording
Automatic on GET profile.

## Caching
- Babysitters: 5 min
- Profiles: 10 min

## Phone Format
```
+256XXXXXXXXX
```

## Availability Format
```
Mon,Tue,Wed
```

## Currency
Defaults to UGX. Always display currency with rate.

