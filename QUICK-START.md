# 🚀 Quick Start Guide - ERP Training Management System (Live Mode)

## ⚠️ Important: Live Mode Only
This application is configured to work **ONLY** with the live backend API server. No demo mode is available. You must start the backend server before using the application.

## Starting the Application

### Option 1: Using Startup Scripts (Easiest)

#### 1. Start Backend API Server
```bash
# Double-click or run in Command Prompt
start-backend.bat
```
**Wait for the message: "Now listening on: http://localhost:5000"**

#### 2. Start Frontend (in a new terminal)
```bash
# Double-click or run in Command Prompt
start-frontend.bat
```

### Option 2: Manual Startup

#### 1. Start Backend API Server
```bash
cd backend/ERPTraining.API
dotnet restore
dotnet run --urls "http://localhost:5000"
```
**Wait for server to start completely before proceeding**

#### 2. Start Frontend Development Server
```bash
# In a new terminal, from the root directory
npm install
npm run dev
```

## 🔧 Server Status & Health Checks

### Backend API Server
- **URL:** http://localhost:5000
- **Health Check:** http://localhost:5000/api/health
- **API Documentation:** http://localhost:5000/swagger

### Frontend Development Server
- **URL:** http://localhost:5173

## ❌ Troubleshooting Connection Issues

### "API Connection Error" Message
This means the backend is not running or not accessible.

**Solution Steps:**
1. **Check if backend is running:** Visit http://localhost:5000
2. **If not running:** Use `start-backend.bat` or manual startup
3. **Wait for complete startup:** Look for "Now listening on: http://localhost:5000"
4. **Click "Retry Connection"** button in the error message

### Common Backend Issues

#### 1. "dotnet command not found"
```bash
# Install .NET 8.0 or later
# Download from: https://dotnet.microsoft.com/download
dotnet --version  # Should show version 8.0 or higher
```

#### 2. "Package restore failed"
```bash
cd backend/ERPTraining.API
dotnet clean
dotnet restore
dotnet build
```

#### 3. "Port 5000 already in use"
```bash
# Find and kill process using port 5000
netstat -ano | findstr :5000
taskkill /PID <PID_NUMBER> /F

# Or use a different port
dotnet run --urls "http://localhost:5001"
# Update API_BASE in src/lib/api.ts to match
```

### Common Frontend Issues

#### 1. "npm command not found"
```bash
# Install Node.js from: https://nodejs.org/
node --version  # Should show version 16 or higher
npm --version
```

#### 2. "Dependencies installation failed"
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

#### 3. "Port 5173 already in use"
The development server will automatically use the next available port.

## 🎯 Testing the Live Application

### 1. **Verify API Connection**
- Visit Settings page
- Should show "Loading modules..." then display empty state or actual data
- No "Demo Mode" or "API Connection Error" should appear

### 2. **Test Module Management**
- **Create Module:** Click "Add Module" → Fill form → Save
- **View Modules:** Should appear in expandable list
- **Edit Module:** Click edit icon → Modify → Save
- **Delete Module:** Click delete icon → Confirm

### 3. **Test Section Management**
- **Create Section:** Go to Section Master → "Add Section" → Fill form → Save
- **Edit Section:** Click edit icon on any section → Modify → Save
- **Delete Section:** Click delete icon → Confirm

### 4. **Test Role Management**
- **Create Role:** Go to Roles tab → "Add Role" → Fill form → Save
- **Edit Role:** Click edit icon → Modify → Save
- **Delete Role:** Click delete icon → Confirm

## � Debugging & Logging

### Frontend Console Logs
Open browser DevTools (F12) → Console tab to see:
- `🔄 Checking API health...`
- `✅ API is healthy, loading data...`
- `📊 Modules loaded: [...]`
- `👥 Roles loaded: [...]`

### Backend Console Logs
In the backend terminal, you should see:
- Entity Framework migrations
- HTTP request logs
- Database operations
- Error messages (if any)

## 🛠️ Development Database

The application uses SQLite database with Entity Framework Core:
- **Database File:** `backend/ERPTraining.API/app.db`
- **Migrations:** Automatically applied on startup
- **Sample Data:** Seeded on first run

### Reset Database (if needed)
```bash
cd backend/ERPTraining.API
rm app.db  # Delete existing database
dotnet run  # Will recreate with migrations and seed data
```

## 📞 Support

### If Connection Still Fails:
1. **Check firewall settings** (allow localhost connections)
2. **Verify no proxy/VPN interference**
3. **Check Windows Defender or antivirus**
4. **Try different ports** (5001, 5002, etc.)
5. **Check backend logs** for detailed error messages

### For Development Issues:
1. Check console logs in both frontend and backend
2. Verify all NuGet packages are restored
3. Ensure database migrations are applied
4. Check Entity Framework configuration

---

🎯 **Goal:** Test all CRUD operations (Create, Read, Update, Delete) for Modules, Sections, and Roles with the live API server and database.
