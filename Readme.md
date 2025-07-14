```markdown
# 🔐 Full-Stack Auth System: JWT Auth + User & Task APIs (Dockerized)

This project is a **microservices-based authentication system** using:

- `auth-api`: Generates and verifies hashed passwords & JWT tokens
- `users-api`: Handles signup & login with credential hashing and token issuance
- `tasks-api`: Handles protected task CRUD operations (requires Bearer token)
- **JWT Bearer authentication**, password hashing (dummy logic), and API authorization
- Fully containerized using **Docker Compose**

---

## 📦 Microservices Overview

| Service     | Description                                    | Port   |
|-------------|------------------------------------------------|--------|
| `auth-api`  | Hash password, issue and verify tokens         | 80     |
| `users-api` | Signup/login users, talk to auth-api           | 8080   |
| `tasks-api` | CRUD for tasks, protected with JWT auth        | 8000   |

---

## 🗂️ Project Structure

```

auth-jwt-microservices/
├── auth-api/          # Token generation & password hashing
│   └── app.js
├── users-api/         # Signup & login API
│   └── app.js
├── tasks-api/         # Tasks API (protected by token)
│   └── app.js
├── docker-compose.yml
└── README.md

````

---

## 🔧 Features

- 🆔 **Signup/Login** with password hashing
- 🔐 **JWT Bearer Token** generation/validation
- ✅ **Token-protected endpoints**
- 📁 **Task storage** via local file (simulated DB)
- 🐳 **Docker Compose orchestration**
- 🌱 Easily extensible for real production apps

---

## 🚀 Getting Started

### 1. Clone and Navigate

```bash
git clone https://github.com/yourusername/auth-jwt-microservices.git
cd auth-jwt-microservices
````

---

### 2. Start the Stack

```bash
docker-compose up --build
```

All services will be up:

* Users API: [http://localhost:8080](http://localhost:8080)
* Tasks API: [http://localhost:8000](http://localhost:8000)

---

## 🔐 Auth Flow Overview

1. **Signup**

   * User registers via `/signup` (in `users-api`)
   * Password is hashed via `auth-api` and stored (simulated)

2. **Login**

   * Password is verified via `auth-api`
   * Token is returned from `auth-api`

3. **Access Tasks**

   * Tasks API extracts Bearer token
   * Verifies token via `auth-api`
   * Grants or denies access to `/tasks`

---

## 🧪 API Testing Examples

### ✅ Signup

```bash
curl -X POST http://localhost:8080/signup \
-H "Content-Type: application/json" \
-d '{"email":"user@example.com","password":"pass123"}'
```

### 🔐 Login & Get Token

```bash
curl -X POST http://localhost:8080/login \
-H "Content-Type: application/json" \
-d '{"email":"user@example.com","password":"pass123"}'
```

→ Response: `{ "token": "abc" }`

### 📋 Get Tasks (Protected)

```bash
curl http://localhost:8000/tasks \
-H "Authorization: Bearer abc"
```

---

## 📦 Docker Compose Config

```yaml
version: "3"
services:

  auth:
    build: ./auth-api

  users:
    build: ./users-api
    environment:
      AUTH_ADDRESS: auth
      AUTH_SERVICE_SERVICE_HOST: auth
    ports:
      - "8080:8080"

  tasks:
    build: ./tasks-api
    environment:
      TASKS_FOLDER: tasks
      AUTH_ADDRESS: auth
    ports:
      - "8000:8000"
```

---

## 🔐 Internal Auth Mechanisms

### Password Hashing

* Uses dummy logic: `hashed = password + '_hash'`

### Token Generation

* Dummy static token: `'abc'`
* Replace with `jsonwebtoken` (Node.js) in production

### Authorization

* Bearer token extracted from headers
* Verified via call to `/verify-token/:token` in `auth-api`

---

## 🔍 Internals

### `users-api`

* `/signup`: Receives email & password, requests hashed password from `auth-api`
* `/login`: Requests token from `auth-api` using entered + hashed password

### `auth-api`

* `/hashed-password/:password`: Returns dummy hashed password
* `/token/:hashed/:entered`: Validates password and issues token
* `/verify-token/:token`: Returns UID if token is valid

### `tasks-api`

* `/tasks` GET/POST: Requires valid Bearer token to read/write local `tasks.txt`

---

## ✅ Future Improvements

* 🔁 Replace dummy token system with real JWT (`jsonwebtoken`)
* 🔐 Use MongoDB or PostgreSQL for user & task storage
* 📜 Add proper error logging and validation
* 🧪 Add unit and integration tests

---

## 📚 References

* [Express.js Docs](https://expressjs.com/)
* [JWT Auth Concepts](https://jwt.io/introduction)
* [Docker Compose](https://docs.docker.com/compose/)

---
