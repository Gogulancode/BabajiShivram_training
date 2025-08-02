# Role Module Section Mapping Implementation

## Overview
This implementation provides a comprehensive role-based access control system for the ERP Training application, mapping roles to specific modules and sections based on the provided data structure.

## Implementation Details

### 1. Database Schema Updates
- **RoleModuleAccess Entity**: Updated to support the new role mapping structure
- **New Properties**: Added `SectionName`, `CanView`, `CanEdit`, `CanDelete` permissions
- **Identity Integration**: Works with ASP.NET Core Identity roles

### 2. Service Layer
- **IRoleAccessService**: Interface defining role access operations
- **RoleAccessService**: Implementation with seed functionality
- **Seed Method**: `SeedRoleModuleSectionDataAsync()` - Seeds all 70 sections from your data

### 3. API Endpoints
- `GET /api/roleaccess` - Get all role access mappings
- `GET /api/roleaccess/role/{roleId}` - Get access for specific role
- `GET /api/roleaccess/roles-summary` - Get roles with access summary
- `POST /api/roleaccess/seed-data` - Seed the role data from your JSON
- `GET /api/roleaccess/check-access` - Check if user has access to section

### 4. Frontend Component
- **RoleMapping.tsx**: React component to visualize and manage role mappings
- **Organized by Categories**: Groups sections by functional areas
- **Interactive Seeding**: Button to trigger data seeding
- **Real-time Status**: Shows seeding progress and results

## Role-Module-Section Mapping Data

The implementation includes role mappings for multiple roles:

### Role 1 - Admin (70 sections in Module 1)
Complete access to all ERP Training sections with Edit permissions:

### User Setup (100-199)
- 100: User Setup
- 101: BS User
- 102: Department
- 103: BS Group
- 104: Branch
- 105: Port
- 106: Access Role
- 107: CFS Master
- 108: Passing Stages
- 109: Expense Type
- 110: Job Type
- 111: Package Type
- 112: Status Master
- 113: Loading Port

### Customer Setup (200-299)
- 200: Customer Setup
- 202: Customer
- 203: Consignee
- 204: Location
- 205: Checklist Document
- 206: Scheme Type
- 207: Incoterms of Shipment
- 208: Field Master
- 209: Warehouse Master
- 210: Customer Sector Master
- 211: PCD Document Master
- 212: Vehicle Master

### Operations (300-399)
- 300: Operation
- 301: Pre-Alert Received
- 302: Job Creation
- 303: IGM Awaited
- 304: Checklist Preparation
- 305: Checklist Verification IN
- 306: Customer Checklist
- 307: Audit Rejected
- 308: Under Noting
- 309: DO Awaited
- 310: Duty Request
- 311: Under Passing
- 312: 1st Check Examine
- 313: Delivery Planning
- 314: Under Delivery
- 315: Job Expense
- 317: Job Activity
- 318: Job Tracking
- 319: Shipment Cleared
- 320: In General Warehouse
- 321: Pending Document
- 322: Admin Job Tracking
- 323: Copy Job
- 324: Edit invoice
- 329: Inbond Jobs
- 330: Pending ADC/PHO

### General/Administration (400-499)
- 400: General/Administration
- 401: My Detail
- 402: Holiday List

### Reports (500-599)
- 500: Reports
- 508: MIS Port
- 509: MIS Customer
- 510: MIS Ageing
- 512: Report
- 513: Job Expenses Report
- 514: Group User Report
- 516: User Report
- 517: View User Report

### Post Clearance (600-699)
- 600: Post Clearance
- 601: PCA Document
- 602: Billing Scrutiny
- 603: Billing Dept
- 604: Dispatch Dept
- 605: Billing Advice
- 606: Billing Rejected

### Role 10 - Operations (25 sections across Modules 1 & 4)
Limited operational access with View-only permissions:

#### Module 1 Operations (20 sections)
- 304: Checklist Preparation
- 305: Checklist Verification IN
- 307: Audit Rejected
- 308: Under Noting
- 311: Under Passing
- 312: 1st Check Examine
- 318: Job Tracking
- 333: Job Archive
- 340: Other Job
- 344: Provisional BE
- 360: Task Request
- 361: Customer Task Request
- 362: Pending Task
- 363: Completed Task List
- 401: My Detail
- 516: User Report
- 517: View User Report
- 519: Checklist KPI
- 521: BOE KPI
- 605: Billing Advice

#### Module 4 HR & Admin (5 sections)
- 3001: Service Request
- 3021: KPI
- 3040: Circular
- 3041: Circular
- 7001: Manpower Requisition

### Role 100 - Super Admin (126 sections across 7 modules)
Comprehensive system access with full permissions (View, Edit, Delete):

#### Module 1 - Core Operations (26 sections)
- 302: Job Creation
- 303: IGM Awaited
- 304: Checklist Preparation
- 305: Checklist Verification
- 307: Audit Rejected
- 308: Under Noting
- 309: DO Awaited
- 310: Duty Request
- 311: Under Passing
- 312: 1st Check Examine
- 314: Under Delivery
- 315: Job Expense
- 318: Job Tracking
- 320: In General Warehouse
- 330: Pending ADC/PHO
- 333: Job Archive
- 341: Pending OOC
- 345: Cancelled Job
- 516: User Report
- 517: View User Report
- 601: PCA Document
- 604: Dispatch Dept - Billing
- 605: Billing Advice
- 618: LR Pending
- 1024: Pending Bill Dispatch
- 3013: FA Current Job

#### Module 2 - Freight Operations (19 sections)
- 1001: Freight Tracking
- 1002: Freight Executed
- 1004: Freight Awarded
- 1010: Import Operation
- 1011: Awaiting Booking
- 1012: Agent PreAlert
- 1013: Customer PreAlert
- 1014: Cargo Arrival Notice
- 1015: Delivery Order
- 1017: Tracking
- 1019: Billing Advice
- 1025: Bill Status
- 6010: Export Operation
- 6011: Operation
- 6012: VGM-Form13
- 6013: Cust PreAlert
- 6014: Shipped Onboard
- 6015: Awaiting Booking
- 6016: Tracking

#### Module 3 - Transport & Billing (17 sections)
- 2032: Request Received
- 2035: Movement
- 2043: Bill Tracking
- 2047: Job Tracking
- 2050: Vehicle Placed
- 2078: Eway Bill Request
- 2079: Show Eway Bill
- 2080: Update Part B
- 2081: Cancel EWay Bill
- 2082: Reject EWay Bill
- 2083: Extend Validity
- 2090: Eway Tracking
- 4704: Pending Bill
- 4708: Bill Received
- 4710: Bill Rejected
- 4715: Payment Report
- 4716: Tracking

#### Module 4 - Admin & HR (2 sections)
- 3085: Admin Expense
- 3086: Maintenance Expense

#### Module 5 - Export Operations (15 sections)
- 4001: Job Creation
- 4002: SB Preparation
- 4003: SB Filing
- 4004: Custom Process
- 4005: Form 13
- 4008: Shipment Get In
- 4009: Warehouse
- 4011: Shipment Tracking
- 4014: Customer Transport
- 4016: Vehicle Request
- 4050: Post Clearance
- 4051: PCA Document
- 4052: Billing Advice
- 4081: User Reports
- 4082: View User Reports

#### Module 9 - Financial Operations (9 sections)
- 3090: Vendor Invoice
- 3091: New Invoice
- 3094: Invoice Rejected
- 3095: Final Invoice Pending
- 3099: Invoice Tracking
- 4620: Tracking
- 9052: Cheque Issue
- 9053: Cheque Invoice Submission
- 30935: Payment Receipt

#### Module 12 - Transport Service (18 sections)
- 309334: Job Creation -TS
- 309335: Request Received
- 309338: IN - Transit
- 309350: Job Tracking
- 309351: Dispatch - TS/FF
- 309353: Vehicle Placed
- 309362: Eway Bill Request
- 309363: Show Eway Bill
- 309364: Update Part B
- 309365: Cancel EWay Bill
- 309366: Reject EWay Bill
- 309367: Extend Validity
- 309371: Multiple Vehicle
- 309372: Eway Tracking
- 309378: Pending Bill
- 309381: Bill Rejected
- 309383: Tracking
- 309384: HOD Rejected

## How to Use

### 1. Backend Setup
The backend is already configured with the role mapping service. To seed the data:

```bash
# Start the API
cd backend/ERPTraining.API
dotnet run

# The API will be available at http://localhost:5000
```

### 2. Seed Role Data
Make a POST request to seed the role data:

```bash
curl -X POST http://localhost:5000/api/roleaccess/seed-data
```

Or use the frontend component by navigating to `/role-mapping` and clicking "Seed Role Data".

### 3. Verify Data
Check the seeded data:

```bash
# Get all role access mappings
curl http://localhost:5000/api/roleaccess

# Get roles summary
curl http://localhost:5000/api/roleaccess/roles-summary
```

### 4. Frontend Usage
Navigate to `http://localhost:3000/role-mapping` to see the role mapping interface.

## Features

### Permission Levels
- **CanView**: User can view the section
- **CanEdit**: User can modify content in the section
- **CanDelete**: User can delete items in the section

### Role Mapping
- **Role ID 1**: Admin role with access to all 70 sections
- **Module ID 1**: ERP Training Module containing all sections
- **Section IDs**: Match your original data (100-604)

### Database Integration
- Creates module and sections automatically if they don't exist
- Links with ASP.NET Core Identity for user roles
- Maintains referential integrity with foreign keys

## Testing

### API Testing
```bash
# Test basic functionality
curl http://localhost:5000/api/roleaccess/test-roles

# Check if a user has access to a specific section
curl "http://localhost:5000/api/roleaccess/check-access?userId={userId}&moduleId=1&sectionId=100"
```

### Frontend Testing
1. Navigate to `/role-mapping`
2. Click "Seed Role Data"
3. Verify sections are organized by category
4. Check role access summary

## Architecture Benefits

1. **Scalable**: Easy to add new roles, modules, and sections
2. **Flexible**: Supports granular permissions (view, edit, delete)
3. **Integrated**: Works with existing Identity system
4. **Maintainable**: Clear separation of concerns
5. **Extensible**: Can easily add more permission types or features

## Next Steps

1. **User Assignment**: Assign users to the Admin role to test access
2. **Additional Roles**: Create more roles with different section access
3. **Frontend Integration**: Use role checks in other components
4. **Reporting**: Add detailed access reports and analytics
5. **Audit Trail**: Track role assignment changes

This implementation provides a solid foundation for role-based access control in your ERP Training system, with the flexibility to grow and adapt as your requirements evolve.
