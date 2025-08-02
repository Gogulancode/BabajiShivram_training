# Role-Based Access Control List (ACL) System

## Overview

The ERP Training Portal now includes a comprehensive Role-Based Access Control List (ACL) system that allows administrators to manage granular permissions for modules and sections across different roles. This system provides enterprise-level access control capabilities for managing 6500+ role-module-permission relationships.

## Key Features

### 🎯 Granular Permission Management
- **Module-Level Access**: Grant or deny access to entire training modules
- **Section-Level Access**: Fine-grained control over individual sections within modules
- **Hierarchical Permissions**: Module access automatically includes all sections, but sections can be individually managed

### 🔍 Advanced Permission Interface
- **Interactive ACL Editor**: Visual interface for managing permissions
- **Search & Filter**: Quickly find modules and sections
- **Bulk Operations**: Select all or deselect all permissions at once
- **Real-time Statistics**: See permission counts and coverage

### 🏢 Enterprise Integration
- **ERP System Mapping**: Link roles to existing ERP role IDs
- **Module Mapping**: Connect training modules to ERP modules
- **Section Mapping**: Map training sections to ERP sections

## How to Use the ACL System

### 1. Accessing Role Management
1. Navigate to **Settings** in the main menu
2. Click on the **"Roles"** tab
3. You'll see a list of all roles with their current permission counts

### 2. Managing Permissions for a Role
1. Find the role you want to manage
2. Click the expand arrow (▶) next to the role name
3. Click **"Edit Permissions"** or **"Assign Permissions"** button
4. The Permission Manager modal will open

### 3. Using the Permission Manager

#### Interface Components
- **Header**: Shows role name and total permission count
- **Search Bar**: Filter modules/sections by name
- **Filter Options**: Show only granted permissions
- **Bulk Actions**: Select All / Deselect All buttons

#### Setting Permissions
1. **Module Level**: Click the checkbox next to a module name
   - Granting module access automatically grants all section access
   - Removing module access removes all section access

2. **Section Level**: Expand a module and click individual section checkboxes
   - Granting any section access automatically grants module access
   - You can have partial access (some sections but not all)

#### Permission Indicators
- **Green checkmark** (✓): Permission granted
- **Gray square** (□): Permission denied
- **Status badges**: Show "Module Access", "Granted", "Denied" status

### 4. Saving Changes
1. Review your changes in the permission list
2. Check the total count at the bottom
3. Click **"Save Permissions"** to apply changes
4. The system will update the backend and refresh the role list

## Permission Hierarchy

### Module Permissions
```
Module Access = True
├── All sections automatically granted
└── Can be overridden at section level
```

### Section Permissions
```
Section Access = True
├── Module access automatically granted
├── Other sections remain independent
└── Can be mixed (some granted, some denied)
```

### Examples

#### Full Module Access
```
"Sales & Distribution" Module: ✓ Granted
├── "Order Processing": ✓ Granted (auto)
├── "Customer Management": ✓ Granted (auto)
└── "Pricing & Contracts": ✓ Granted (auto)
```

#### Partial Module Access
```
"Finance & Controlling" Module: ✓ Granted (auto)
├── "General Ledger": ✓ Granted
├── "Accounts Receivable": ✓ Granted
└── "Fixed Assets": ✗ Denied
```

## API Integration

### Backend Endpoints Used
- `GET /api/roleaccess/role/{roleId}/modules-sections` - Get permissions
- `PUT /api/roleaccess/role/{roleId}` - Update role permissions
- `GET /api/roles` - Get all roles
- `GET /api/roleaccess/roles-summary` - Get role statistics

### Data Flow
1. **Load Permissions**: Fetch current permissions from backend
2. **Transform Data**: Convert backend DTOs to frontend models
3. **User Interaction**: Allow permission modifications in UI
4. **Save Changes**: Convert back to backend format and save
5. **Refresh Data**: Update UI with latest permissions

## Technical Implementation

### Frontend Components
- **PermissionManager.tsx**: Main ACL management interface
- **RoleMaster.tsx**: Role listing and management
- **roles.ts**: API integration layer

### Key Features
- **Real-time Updates**: Changes reflected immediately in UI
- **Error Handling**: Comprehensive error management
- **Performance Optimized**: Handles large datasets efficiently
- **Responsive Design**: Works on all screen sizes

### State Management
```typescript
interface ModulePermission {
  moduleId: string;
  moduleName: string;
  hasAccess: boolean;
  sections: SectionPermission[];
}

interface SectionPermission {
  sectionId: string;
  sectionName: string;
  hasAccess: boolean;
}
```

## Security Considerations

### Authorization
- **Admin Only**: Role management requires Admin privileges
- **JWT Authentication**: All API calls require valid tokens
- **Role Validation**: Backend validates role assignments

### Audit Trail
- All permission changes are logged
- User actions are tracked
- System maintains change history

## Best Practices

### Role Design
1. **Principle of Least Privilege**: Grant minimum necessary access
2. **Role Hierarchies**: Design logical role structures
3. **Regular Reviews**: Periodically audit role permissions

### Permission Management
1. **Start with Modules**: Grant module-level access when possible
2. **Selective Sections**: Use section-level for fine-grained control
3. **Test Access**: Verify permissions work as expected

### Maintenance
1. **Regular Cleanup**: Remove unused roles and permissions
2. **Documentation**: Keep role definitions documented
3. **Training**: Ensure administrators understand the system

## Troubleshooting

### Common Issues

#### Permissions Not Saving
- Check network connectivity
- Verify JWT token is valid
- Ensure admin privileges
- Check browser console for errors

#### Missing Modules/Sections
- Verify modules are active in Module Master
- Check section status in Section Master
- Ensure backend API is running

#### Performance Issues
- Use search filters for large datasets
- Avoid selecting all permissions at once
- Check backend database performance

### Support
For technical support or questions about the ACL system:
1. Check the browser console for error messages
2. Verify backend API endpoints are accessible
3. Review role and module configurations
4. Contact the development team for complex issues

## Future Enhancements

### Planned Features
- **Permission Templates**: Pre-defined permission sets
- **Bulk Role Management**: Manage multiple roles simultaneously
- **Permission Inheritance**: Role-based permission inheritance
- **Advanced Reporting**: Detailed permission analytics

### Integration Possibilities
- **LDAP/AD Integration**: Sync with enterprise directories
- **SSO Integration**: Single sign-on support
- **Workflow Approvals**: Permission change approvals
- **Real-time Notifications**: Permission change alerts

---

*This ACL system provides enterprise-grade access control for the ERP Training Portal, ensuring secure and manageable access to training resources across your organization.*
