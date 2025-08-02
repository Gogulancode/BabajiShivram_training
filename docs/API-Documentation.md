# ERP Training Management System - API Documentation

## Overview

The ERP Training Management System API provides comprehensive endpoints for managing enterprise resource planning (ERP) training modules, user progress tracking, assessments, and content management. This RESTful API is built with ASP.NET Core and uses JWT-based authentication.

## Base URL

- **Development**: `http://localhost:5000/api`
- **HTTPS Development**: `https://localhost:5001/api`

## Authentication

### JWT Bearer Token Authentication

All protected endpoints require a valid JWT Bearer token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Getting a Token

1. **Register a new user**: `POST /api/auth/register`
2. **Login with existing credentials**: `POST /api/auth/login`
3. **Use the returned token** in subsequent API calls

### Token Lifespan

- **Validity**: 24 hours
- **Refresh**: Re-authenticate when token expires
- **Storage**: Store securely on client side

## API Endpoints Overview

### Authentication & User Management (`/api/auth`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/login` | User authentication | No |
| POST | `/register` | User registration | No |
| GET | `/me` | Get current user profile | Yes |
| PUT | `/me` | Update user profile | Yes |

### Training Modules (`/api/modules`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/` | Get all modules | Yes |
| GET | `/{id}` | Get module details | Yes |
| POST | `/` | Create new module | Yes (Admin) |
| PUT | `/{id}` | Update module | Yes (Admin) |
| DELETE | `/{id}` | Delete module | Yes (Admin) |

### Module Sections (`/api/sections`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/` | Get all sections | Yes |
| GET | `/{id}` | Get section details | Yes |
| GET | `/module/{moduleId}` | Get sections by module | Yes |
| POST | `/` | Create new section | Yes (Admin) |
| PUT | `/{id}` | Update section | Yes (Admin) |
| DELETE | `/{id}` | Delete section | Yes (Admin) |

### Assessments (`/api/assessments`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/` | Get all assessments | Yes |
| GET | `/{id}` | Get assessment details | Yes |
| POST | `/` | Create assessment | Yes (Admin) |
| PUT | `/{id}` | Update assessment | Yes (Admin) |
| DELETE | `/{id}` | Delete assessment | Yes (Admin) |
| POST | `/{id}/submit` | Submit assessment | Yes |

## Training Module Structure

### Module Hierarchy

The system organizes training content in a hierarchical structure:

```
Module
├── Sections (42-52 per module)
│   ├── Content
│   ├── Learning Objectives
│   └── Prerequisites
├── Assessments
│   ├── Questions
│   └── Scoring Rules
└── Progress Tracking
    ├── Completion Status
    ├── Time Spent
    └── Performance Metrics
```

### Available Training Modules

1. **Data Models & Security** (52 sections)
   - Data structures and relationships
   - Security protocols and access controls
   - Database management fundamentals

2. **SAP Basics & ERP Fundamentals** (48 sections)
   - ERP system overview and benefits
   - SAP navigation and interface
   - Basic configuration principles

3. **Order to Cash Process** (45 sections)
   - Sales order management
   - Billing and invoicing
   - Customer relationship management

4. **Production Planning & Material Management** (50 sections)
   - Production planning strategies
   - Material requirements planning (MRP)
   - Quality management systems

5. **Finance & Controlling** (49 sections)
   - Financial accounting principles
   - Cost center management
   - Asset management and depreciation

6. **Sales & Distribution** (51 sections)
   - Sales process optimization
   - Distribution channel management
   - Pricing and discount strategies

7. **Project Management & Resource Planning** (45 sections)
   - Project lifecycle management
   - Resource allocation and scheduling
   - Time tracking and reporting

8. **Workflow & Business Process Management** (42 sections)
   - Workflow design and automation
   - Business process optimization
   - Change management strategies

9. **Integration & System Management** (48 sections)
   - System integration patterns
   - API management and development
   - Data migration strategies

10. **Mobile Solutions & Cloud Integration** (47 sections)
    - Mobile application development
    - Cloud deployment strategies
    - Digital transformation principles

11. **Analytics & Business Intelligence** (49 sections)
    - Data analysis and reporting
    - Business intelligence tools
    - Performance metrics and KPIs

12. **Training Management & Learning Analytics** (50 sections)
    - Learning management systems
    - Training effectiveness measurement
    - Assessment and evaluation tools

## Response Format

### Standard Response Structure

All API responses follow a consistent format:

```json
{
  "success": boolean,
  "message": string,
  "data": object | array,
  "errors": string[] (optional)
}
```

### Success Response Example

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    "id": 1,
    "title": "Sample Module",
    "description": "Sample description"
  }
}
```

### Error Response Example

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    "Email is required",
    "Password must be at least 6 characters"
  ]
}
```

## HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Authentication required |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists |
| 422 | Unprocessable Entity | Validation errors |
| 500 | Internal Server Error | Server error |

## Data Models

### User Model

```json
{
  "id": "string",
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "department": "string",
  "isActive": boolean,
  "joinDate": "datetime",
  "lastLoginAt": "datetime",
  "roles": ["string"]
}
```

### Module Model

```json
{
  "id": number,
  "title": "string",
  "description": "string",
  "estimatedDuration": "string",
  "difficultyLevel": "string",
  "learningObjectives": ["string"],
  "prerequisites": ["string"],
  "sectionCount": number,
  "completionPercentage": number,
  "isCompleted": boolean,
  "lastAccessedAt": "datetime",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Section Model

```json
{
  "id": number,
  "moduleId": number,
  "title": "string",
  "description": "string",
  "order": number,
  "content": "string",
  "estimatedDuration": "string",
  "isCompleted": boolean,
  "lastAccessedAt": "datetime",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

## Error Handling

### Validation Errors

The API returns detailed validation errors for invalid input:

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    "Email must be a valid email address",
    "Password must contain at least one uppercase letter"
  ]
}
```

### Authentication Errors

```json
{
  "success": false,
  "message": "Authentication failed",
  "errors": ["Invalid or expired token"]
}
```

## Rate Limiting

- **Login attempts**: 5 per minute per IP address
- **API calls**: 1000 per hour per user
- **File uploads**: 10 per minute per user

## Pagination

Large data sets are paginated with the following parameters:

- `page`: Page number (default: 1)
- `pageSize`: Items per page (default: 20, max: 100)
- `sortBy`: Sort field
- `sortOrder`: asc or desc

### Paginated Response

```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [...],
  "pagination": {
    "totalCount": 150,
    "pageNumber": 1,
    "pageSize": 20,
    "totalPages": 8,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

## Security Considerations

### Input Validation

- All inputs are validated and sanitized
- SQL injection protection through parameterized queries
- XSS prevention through output encoding

### Authentication Security

- JWT tokens are signed with HMAC SHA-256
- Passwords are hashed using bcrypt
- Rate limiting prevents brute force attacks

### Authorization

- Role-based access control (RBAC)
- Resource-level permissions
- Audit logging for sensitive operations

## Development Tools

### Swagger/OpenAPI Documentation

- **Development**: http://localhost:5000/swagger
- **Interactive testing**: Available in development environment
- **API exploration**: Browse all endpoints and try requests

### Postman Collection

A Postman collection is available for testing and development:

1. Import the collection from `/docs/postman-collection.json`
2. Set up environment variables for base URL and authentication
3. Test all endpoints with sample data

## Support and Contact

- **Documentation**: This file and Swagger UI
- **Issues**: GitHub repository issues
- **Email**: support@erptraining.com
- **Development Team**: ERP Training Development Team

---

*Last Updated: July 30, 2025*
*API Version: v1.0*
*Documentation Version: 1.0*
