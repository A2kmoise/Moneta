# FinApp Backend API

A robust Swift Vapor 4 backend for the FinApp iOS application, providing user authentication, transaction management, budget tracking, and AI chat integration.

## 🚀 Features

- **User Authentication**: JWT-based secure authentication with registration and login
- **Transaction Management**: Track income and expenses with full CRUD operations
- **Budget Management**: Create, update, and monitor budgets with automatic status tracking
- **Advanced Filtering**: Filter transactions by date range and category
- **Budget Analytics**: Comprehensive budget summaries with category breakdowns
- **AI Chat Integration**: Mock AI service ready for real AI provider integration
- **Input Validation**: Comprehensive validation for all endpoints
- **CORS Support**: Configured for iOS app connectivity

## 📋 Prerequisites

- **Swift 5.10+** (comes with Xcode)
- **Database**: PostgreSQL 15+ OR Neon (recommended for quick setup)
- **macOS 13+**

## 🛠️ Installation

### ⚡ Quick Start with Neon (Recommended - 5 minutes)

**No PostgreSQL installation needed!** Use Neon's serverless PostgreSQL:

1. **Create free account** at [neon.tech](https://neon.tech)
2. **Create project** named `finapp-backend`
3. **Copy connection string** from dashboard
4. **Configure**:
   ```bash
   cd /Users/rca-lab/Documents/finApp/backend
   cp .env.example .env
   ```
   Add to `.env`:
   ```env
   DATABASE_URL=postgresql://user:pass@ep-xxx.region.aws.neon.tech/neondb?sslmode=require
   ```
5. **Run**:
   ```bash
   swift build
   swift run Run migrate
   swift run Run serve
   ```

✅ Done! See `QUICK_START_NEON.md` for detailed guide.

---

### Alternative: Local PostgreSQL Setup

### 1. Install PostgreSQL

```bash
brew install postgresql@15
brew services start postgresql@15
```

### 2. Create Database

```bash
createdb budget_db
```

### 3. Configure Environment

```bash
cd /Users/rca-lab/Documents/finApp/backend
cp .env.example .env
```

Edit `.env` file with your configuration:
```env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_password
DATABASE_NAME=budget_db
JWT_SECRET=your_super_secret_key_here
```

### 4. Build & Run

```bash
# Build dependencies
swift build

# Run database migrations
swift run Run migrate

# Start server
swift run Run serve
```

Server will start on `http://0.0.0.0:8080`

## 📚 API Documentation

### Base URL
```
http://localhost:8080
```

### Authentication Endpoints

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "fullName": "John Doe",
  "email": "john@example.com",
  "phoneNumber": "+1234567890",
  "password": "securepassword123"
}

Response: 201 Created
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "securepassword123"
}

Response: 200 OK
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Update Profile (Protected)
```http
PUT /auth/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "fullName": "John Smith",
  "password": "newpassword123"
}

Response: 200 OK
```

### Transaction Endpoints (All Protected)

#### Create Income
```http
POST /transactions/income
Authorization: Bearer <token>
Content-Type: application/json

{
  "category": "Salary",
  "amount": 5000.00,
  "date": "2024-01-15T00:00:00Z"
}

Response: 200 OK
{
  "id": "uuid",
  "type": "income",
  "category": "Salary",
  "amount": 5000.00,
  "date": "2024-01-15T00:00:00Z"
}
```

#### Create Expense
```http
POST /transactions/expense
Authorization: Bearer <token>
Content-Type: application/json

{
  "category": "Food",
  "amount": 150.00,
  "date": "2024-01-16T00:00:00Z"
}

Response: 200 OK
```

#### List All Transactions
```http
GET /transactions
Authorization: Bearer <token>

Response: 200 OK
[
  {
    "id": "uuid",
    "type": "income",
    "category": "Salary",
    "amount": 5000.00,
    "date": "2024-01-15T00:00:00Z"
  },
  ...
]
```

#### Get Transactions by Date Range
```http
GET /transactions/date-range?startDate=2024-01-01T00:00:00Z&endDate=2024-01-31T23:59:59Z
Authorization: Bearer <token>

Response: 200 OK
[...]
```

#### Get Transactions by Category
```http
GET /transactions/category?category=Food
Authorization: Bearer <token>

Response: 200 OK
[...]
```

#### Delete Transaction
```http
DELETE /transactions/:id
Authorization: Bearer <token>

Response: 204 No Content
```

#### Get Balance
```http
GET /balance
Authorization: Bearer <token>

Response: 200 OK
{
  "balance": 4850.00
}
```

### Budget Endpoints (All Protected)

#### Create Budget
```http
POST /budgets
Authorization: Bearer <token>
Content-Type: application/json

{
  "budgetName": "Monthly Food Budget",
  "allocatedAmount": 500.00,
  "relatedCategory": "Food"
}

Response: 200 OK
{
  "id": "uuid",
  "name": "Monthly Food Budget",
  "allocatedAmount": 500.00,
  "category": "Food",
  "status": "good"
}
```

#### List All Budgets
```http
GET /budgets
Authorization: Bearer <token>

Response: 200 OK
[
  {
    "id": "uuid",
    "name": "Monthly Food Budget",
    "allocatedAmount": 500.00,
    "category": "Food",
    "status": "good"
  },
  ...
]
```

#### Update Budget
```http
PUT /budgets/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "budgetName": "Updated Food Budget",
  "allocatedAmount": 600.00,
  "relatedCategory": "Food"
}

Response: 200 OK
```

#### Delete Budget
```http
DELETE /budgets/:id
Authorization: Bearer <token>

Response: 204 No Content
```

#### Get Budget Summary
```http
GET /budgets/summary
Authorization: Bearer <token>

Response: 200 OK
{
  "totalIncome": 5000.00,
  "totalExpenses": 150.00,
  "totalAllocated": 500.00,
  "remainingBudget": 4500.00,
  "categoryBreakdown": {
    "Food": {
      "allocated": 500.00,
      "spent": 150.00,
      "remaining": 350.00
    }
  }
}
```

### AI Chat Endpoint (Protected)

#### Send Chat Message
```http
POST /ai/chat
Authorization: Bearer <token>
Content-Type: application/json

{
  "userMessage": "How can I save more money?"
}

Response: 200 OK
{
  "reply": "This is a mock AI response to: How can I save more money?"
}
```

## 📊 Budget Status Logic

Budgets are automatically assigned status based on spending:
- **good**: Spending < 70% of allocated amount
- **within**: Spending 70-90% of allocated amount
- **problem**: Spending > 90% of allocated amount

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Bcrypt password hashing
- **Input Validation**: Comprehensive validation on all endpoints
- **Authorization**: User-specific data access control
- **CORS**: Configured for iOS app connectivity

## 🗄️ Database Schema

### Users Table
- `id` (UUID, Primary Key)
- `full_name` (String)
- `email` (String, Unique)
- `phone_number` (String)
- `password_hash` (String)
- `created_at` (DateTime)

### Transactions Table
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → users)
- `type` (String: "income" | "expense")
- `category` (String)
- `amount` (Double)
- `date` (Date)
- `created_at` (DateTime)

### Budgets Table
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key → users)
- `name` (String)
- `allocated_amount` (Double)
- `category` (String)
- `status` (String: "good" | "within" | "problem")
- `created_at` (DateTime)

## 🧪 Testing

### Test with cURL

```bash
# Register
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Test User","email":"test@example.com","phoneNumber":"+1234567890","password":"password123"}'

# Login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Create Income (replace TOKEN with actual token)
curl -X POST http://localhost:8080/transactions/income \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"category":"Salary","amount":5000,"date":"2024-01-15T00:00:00Z"}'
```

## 🚀 Deployment

### Production Checklist

1. **Change JWT Secret**: Update `JWT_SECRET` in `.env` to a strong random value
2. **Database Security**: Use strong database password
3. **HTTPS**: Deploy behind reverse proxy with SSL (nginx, Caddy)
4. **Environment Variables**: Never commit `.env` file
5. **Database Backups**: Set up automated PostgreSQL backups
6. **Monitoring**: Add logging and monitoring tools

### Deploy to Cloud

#### Heroku
```bash
heroku create finapp-backend
heroku addons:create heroku-postgresql:mini
heroku config:set JWT_SECRET=your_secret_here
git push heroku main
heroku run swift run Run migrate
```

#### Docker
```dockerfile
# Dockerfile example
FROM swift:5.10
WORKDIR /app
COPY . .
RUN swift build -c release
CMD [".build/release/Run", "serve", "--hostname", "0.0.0.0", "--port", "8080"]
```

## 🔧 Troubleshooting

### Database Connection Issues
```bash
# Check PostgreSQL is running
brew services list

# Restart PostgreSQL
brew services restart postgresql@15

# Check database exists
psql -l
```

### Migration Issues
```bash
# Revert all migrations
swift run Run migrate --revert --all

# Run migrations again
swift run Run migrate
```

### Port Already in Use
```bash
# Find process using port 8080
lsof -i :8080

# Kill process
kill -9 <PID>
```

## 📝 Development Notes

### Adding New Features

1. **Create Model**: Add to `Sources/App/Models/`
2. **Create Migration**: Add to `Sources/App/Migrations/`
3. **Create DTOs**: Add to `Sources/App/DTOs/`
4. **Create Service**: Add to `Sources/App/Services/`
5. **Create Controller**: Add to `Sources/App/Controllers/`
6. **Add Routes**: Update `Sources/App/Routes/`
7. **Register Migration**: Update `configure.swift`

### AI Service Integration

To integrate a real AI provider (OpenAI, Anthropic, etc.):

1. Update `AIService.swift` with API client
2. Add API key to `.env`
3. Implement actual API calls in `sendMessage` method

## 📄 License

This backend is part of the FinApp project.

## 👥 Support

For issues or questions, please contact the development team.
