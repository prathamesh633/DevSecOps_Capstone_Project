# 💸 Expense Tracker

A full-stack personal finance application to track income and expenses, built with **React**, **Flask**, and **SQLite**.

---

## 📸 Screenshots

### 🔐 Login
![Login Page](screenshots/login.png)

### 📝 Register
![Register Page](screenshots/register.png)

### 📊 Dashboard
![Dashboard](screenshots/dashboard.png)

### ➕ Add Transaction
![Add Transaction](screenshots/add_transaction.png)

### 📈 Dashboard with Data
![Dashboard with Transactions](screenshots/dashboard_with_data.png)

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 19, Bootstrap 5, Axios |
| Backend | Python Flask, Flask-JWT-Extended, SQLAlchemy |
| Database | SQLite (dev) / PostgreSQL (prod) |
| Auth | JWT (JSON Web Tokens) |

---

## 🗂️ Project Structure

```
expense-tracker/
├── backend/
│   ├── app.py             # Flask app factory
│   ├── config.py          # Config (env vars)
│   ├── models.py          # User & Transaction models
│   ├── routes/
│   │   ├── auth.py        # Register & Login APIs
│   │   └── transactions.py# CRUD + Summary APIs
│   ├── requirements.txt
│   └── .env
├── frontend/
│   ├── public/
│   │   └── index.html     # Bootstrap 5 CDN included
│   └── src/
│       ├── App.js         # Router + Navbar
│       ├── api.js         # Axios instance with JWT interceptor
│       ├── context/
│       │   └── AuthContext.js
│       └── pages/
│           ├── Login.js
│           ├── Register.js
│           ├── Dashboard.js   # Summary cards + transaction table
│           └── AddTransaction.js
└── screenshots/
```

---

## 🚀 Getting Started

### Prerequisites
- Python 3.10+
- Node.js 18+

### Backend Setup

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

Backend runs on **http://localhost:5000**

> SQLite database (`expenses.db`) is auto-created on first run.

### Frontend Setup

```bash
cd frontend
npm install
npm start
```

Frontend runs on **http://localhost:3000**

---

## 🔑 Environment Variables

Create `backend/.env`:

```env
SECRET_KEY=supersecret
JWT_SECRET_KEY=jwtsecret
DATABASE_URL=sqlite:///expenses.db
```

For PostgreSQL:
```env
DATABASE_URL=postgresql://user:password@localhost/expenses
```

---

## 📡 API Reference

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/register` | No | Register new user |
| POST | `/auth/login` | No | Login, returns JWT |
| GET | `/transactions/` | ✅ JWT | List all transactions |
| POST | `/transactions/` | ✅ JWT | Add transaction |
| DELETE | `/transactions/:id` | ✅ JWT | Delete transaction |
| GET | `/transactions/summary?month=YYYY-MM` | ✅ JWT | Monthly summary |

---

## ✅ Features

- 🔐 JWT-based authentication (register & login)
- 💰 Add income & expense transactions
- 📋 View all transactions with type badge
- 📊 Live balance summary (Income − Expense = Balance)
- 🗑️ Delete transactions
- 📅 Monthly summary filter
- 🔒 All transaction routes are JWT protected
- 🌐 CORS enabled for local dev

---

## 🐳 Docker (Optional)

```bash
# From expense-tracker root
docker-compose up --build
```

- Backend: http://localhost:5000
- Frontend: http://localhost:3000
