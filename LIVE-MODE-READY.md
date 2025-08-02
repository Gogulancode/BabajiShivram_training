# 🎯 LIVE MODE SETUP - Ready for Testing

## ✅ **Configuration Complete**

The ERP Training Management System is now configured for **LIVE MODE ONLY**:
- ❌ **Demo mode removed** - No fallback to mock data
- ✅ **Live API connection required** - Real database operations
- ✅ **Health check system** - Automatic API status monitoring
- ✅ **Retry mechanism** - Easy reconnection if API goes down
- ✅ **Enhanced error handling** - Clear debugging information

## 🚀 **Start the System**

### **Step 1: Start Backend API Server**
```bash
# Option A: Use the batch file (Recommended)
start-backend.bat

# Option B: Manual start
cd backend/ERPTraining.API
dotnet run --urls "http://localhost:5000"
```

**✅ Wait for this message:**
```
Now listening on: http://localhost:5000
```

### **Step 2: Start Frontend Development Server**
```bash
# Option A: Use the batch file (Recommended)
start-frontend.bat

# Option B: Manual start
npm run dev
```

**✅ Frontend will be available at:**
```
http://localhost:5173
```

## 🧪 **Testing Checklist**

### **1. Connection Testing**
- [ ] Visit http://localhost:5173
- [ ] Navigate to Settings page
- [ ] **Should NOT see:** "Demo Mode" or "API Connection Error"
- [ ] **Should see:** Loading indicator followed by empty state or data

### **2. Module Master Testing**
- [ ] **Create Module:** Add Module → Fill required fields → Save
- [ ] **View Module:** Module appears in list with expandable chevron
- [ ] **Expand Module:** Click chevron → See sections (if any)
- [ ] **Edit Module:** Click edit icon → Modify → Save
- [ ] **Delete Module:** Click delete icon → Confirm → Module removed

### **3. Section Master Testing**
- [ ] **Create Section:** Section Master tab → Add Section → Select module → Fill form → Save
- [ ] **View Section:** Section appears under correct module
- [ ] **Edit Section:** Click edit icon → Modify inline → Save Changes
- [ ] **Delete Section:** Click delete icon → Confirm → Section removed

### **4. Role Management Testing**
- [ ] **Create Role:** Roles tab → Add Role → Fill name → Save
- [ ] **View Roles:** Role appears in list
- [ ] **Edit Role:** Click edit icon → Modify name → Update Role
- [ ] **Delete Role:** Click delete icon → Confirm → Role removed

### **5. Error Handling Testing**
- [ ] **Stop Backend:** Press Ctrl+C in backend terminal
- [ ] **Refresh Frontend:** Should show "API Connection Error"
- [ ] **Restart Backend:** Run `start-backend.bat` again
- [ ] **Click "Retry Connection":** Should connect successfully

## 🐛 **If Issues Occur**

### **Frontend Shows "API Connection Error"**
1. **Check backend terminal:** Should show "Now listening on: http://localhost:5000"
2. **Test API directly:** Visit http://localhost:5000/swagger
3. **Check browser console:** F12 → Console tab → Look for red errors
4. **Click "Retry Connection"** button

### **Backend Won't Start**
1. **Check .NET version:** `dotnet --version` (should be 8.0+)
2. **Restore packages:** `cd backend/ERPTraining.API && dotnet restore`
3. **Check port availability:** Make sure port 5000 is free
4. **Check backend logs:** Look for error messages in terminal

### **Database Issues**
1. **Reset database:** Delete `backend/ERPTraining.API/app.db` and restart backend
2. **Check migrations:** Backend logs should show migration application
3. **Manual migration:** `dotnet ef database update` in backend directory

## 📊 **Expected Database Operations**

The live system will perform these real database operations:
- **CREATE:** Insert new modules/sections/roles into SQLite database
- **READ:** Query database for existing data
- **UPDATE:** Modify existing records in database
- **DELETE:** Remove records from database with cascade deletes

## 🎯 **Testing Goals**

**Primary Goal:** Verify all CRUD operations work with real API and database
**Secondary Goal:** Test error handling when API connection fails
**Tertiary Goal:** Verify data persistence across frontend restarts

## 📈 **Success Criteria**

✅ **System is working correctly when:**
- All modules/sections/roles can be created, edited, and deleted
- Data persists when refreshing the browser
- Forms validate properly and show appropriate error messages
- API connection errors are handled gracefully with retry options
- No demo mode or mock data appears anywhere in the interface

---

**🚀 You're now ready to test the live ERP Training Management System!**

Start with `start-backend.bat`, then `start-frontend.bat`, and begin testing the Module Master functionality.
