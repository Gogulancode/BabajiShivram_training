# Role Import System Documentation

## Overview
The Role Import System allows you to import roles and their permissions from JSON files or direct JSON content. This system automatically creates roles in ASP.NET Identity and assigns module/section permissions.

## API Endpoints

### 1. Import from JSON Content
**POST** `/api/RoleImport/import-from-json`

**Request Body**: Raw JSON string containing the role data

**Example**:
```json
{
  "roles": [
    {
      "roleName": "Sample Role",
      "erpRoleId": "1",
      "description": "Sample description",
      "moduleAccess": [...]
    }
  ]
}
```

### 2. Import from File Upload
**POST** `/api/RoleImport/import-from-file`

**Request**: Form-data with a JSON file upload

### 3. Get Template
**GET** `/api/RoleImport/template`

Returns a sample JSON structure for reference.

## JSON Structure

### Root Object
```json
{
  "roles": [
    // Array of role objects
  ]
}
```

### Role Object
```json
{
  "roleName": "Role Name",           // Required: Name of the role in Identity system
  "erpRoleId": "1",                 // Required: Your original role ID for reference
  "description": "Role description", // Optional: Description of the role
  "moduleAccess": [                 // Required: Array of module access objects
    // Module access objects
  ]
}
```

### Module Access Object
```json
{
  "moduleId": 1,                    // Required: Database ID of the module
  "moduleName": "Module Name",      // Optional: For reference only
  "canEdit": false,                 // Optional: Default module edit permission
  "canDelete": false,               // Optional: Default module delete permission
  "sections": [                     // Optional: Array of section access objects
    // Section access objects
    // If null or empty, grants access to entire module
  ]
}
```

### Section Access Object
```json
{
  "sectionId": 1,                   // Required: Database ID of the section
  "sectionName": "Section Name",    // Required: Name of the section
  "description": "Description",     // Optional: Section description
  "erpSectionId": "1.1",           // Optional: Your original section ID
  "order": 1,                      // Optional: Display order (default: 1)
  "canView": true,                 // Optional: View permission (default: true)
  "canEdit": false,                // Optional: Edit permission (default: false)
  "canDelete": false               // Optional: Delete permission (default: false)
}
```

## Permission Logic

### Module-Level Access
- If `sections` is `null` or empty array, the role gets access to the **entire module**
- Module-level `canEdit` and `canDelete` apply to the whole module

### Section-Level Access
- If `sections` array contains items, access is **section-specific**
- Each section has individual `canView`, `canEdit`, `canDelete` permissions
- Sections are created automatically if they don't exist

## Available Modules

Based on your current system, these are the available modules:

| Module ID | Module Name | Description |
|-----------|-------------|-------------|
| 1 | ERP Training Module | Complete ERP Training Module |
| 2 | Freight Operations Module | Import/Export freight operations |
| 3 | Transport & Billing Module | Transportation and billing |
| 4 | HR & Administrative Module | Human Resources functions |
| 5 | Export Operations Module | Export shipment processing |
| 9 | Financial Operations Module | Invoice and financial management |
| 12 | Transport Service Module | Specialized transport services |

## Import Process

1. **Role Creation**: If the role doesn't exist in ASP.NET Identity, it's created automatically
2. **Permission Cleanup**: Existing permissions for the role are cleared
3. **Module Access**: New module permissions are created based on the JSON
4. **Section Creation**: Missing sections are created automatically
5. **Transaction Safety**: The entire import is wrapped in a database transaction

## Example Usage

### Full Module Access (Super Admin style)
```json
{
  "roleName": "Super Admin",
  "erpRoleId": "100",
  "moduleAccess": [
    {
      "moduleId": 1,
      "canEdit": true,
      "canDelete": true,
      "sections": null
    }
  ]
}
```

### Section-Specific Access
```json
{
  "roleName": "Limited User",
  "erpRoleId": "5",
  "moduleAccess": [
    {
      "moduleId": 1,
      "canEdit": false,
      "canDelete": false,
      "sections": [
        {
          "sectionId": 1,
          "sectionName": "Introduction",
          "canView": true,
          "canEdit": false,
          "canDelete": false
        }
      ]
    }
  ]
}
```

## Testing the Import

1. **Start the API server** (should be running on http://localhost:5001)
2. **Use the template endpoint**: `GET /api/RoleImport/template`
3. **Modify the template** with your role data
4. **Import using**: `POST /api/RoleImport/import-from-json`
5. **Verify results**: Use `/api/RoleAccess/roles-summary` to see imported roles

## Error Handling

- **Invalid JSON**: Returns 400 Bad Request
- **Missing required fields**: Returns 400 Bad Request  
- **Database errors**: Returns 500 Internal Server Error with details
- **Transaction rollback**: If any part fails, all changes are rolled back

## Notes

- **Case Sensitivity**: Property names are case-insensitive
- **Automatic Creation**: Missing sections are created automatically
- **Permission Overwrite**: Existing permissions are completely replaced
- **Identity Integration**: Roles are created in ASP.NET Identity system
- **Reference Preservation**: Original ERP IDs are preserved for reference
