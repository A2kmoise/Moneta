# ⚡ Quick Start with Neon (5 Minutes)

Get your backend running in 5 minutes using Neon's serverless PostgreSQL - no local database installation needed!

## Step 1: Create Neon Database (2 minutes)

1. Go to **[neon.tech](https://neon.tech)** and sign up (free, no credit card)
2. Click **"Create a project"**
3. Name it `finapp-backend` and click **"Create"**
4. Copy your connection string (looks like this):
   ```
   postgresql://user:pass@ep-xxx-123.region.aws.neon.tech/neondb?sslmode=require
   ```

## Step 2: Configure Backend (1 minute)

```bash
cd /Users/rca-lab/Documents/finApp/backend

# Create .env file
cp .env.example .env

# Open .env and add your Neon connection string
nano .env
```

In `.env`, uncomment and update this line:
```env
DATABASE_URL=postgresql://user:pass@ep-xxx-123.region.aws.neon.tech/neondb?sslmode=require
```

Save and exit (Ctrl+X, then Y, then Enter)

## Step 3: Run Backend (2 minutes)

```bash
# Build
swift build

# Run migrations (creates tables)
swift run Run migrate

# Start server
swift run Run serve
```

✅ **Done!** Server running at `http://localhost:8080`

## Test It Works

Open a new terminal and test:

```bash
# Test health check
curl http://localhost:8080/

# Register a user
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Test User",
    "email": "test@example.com",
    "phoneNumber": "+1234567890",
    "password": "password123"
  }'

# Login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

You should get a JWT token back! 🎉

## View Your Data

Go to [console.neon.tech](https://console.neon.tech) → Your Project → SQL Editor

Run:
```sql
SELECT * FROM users;
```

You'll see your test user!

## Next Steps

1. ✅ Backend is running
2. 📱 Integrate with iOS app (see `INTEGRATION_GUIDE.md`)
3. 📚 Read API docs (see `README.md`)

## Troubleshooting

**Error: "Connection refused"**
- Check your DATABASE_URL is correct
- Ensure `?sslmode=require` is at the end

**Error: "Swift not found"**
- Install Xcode Command Line Tools: `xcode-select --install`

**Error: "Migration failed"**
- Delete and recreate your Neon database
- Or run: `swift run Run migrate --revert --all` then `swift run Run migrate`

## Why Neon?

✅ No PostgreSQL installation needed  
✅ Free tier (perfect for development)  
✅ Setup in 2 minutes  
✅ Access from anywhere  
✅ Automatic backups  
✅ Production-ready when you need it  

---

**Need help?** Check `NEON_SETUP.md` for detailed instructions.
