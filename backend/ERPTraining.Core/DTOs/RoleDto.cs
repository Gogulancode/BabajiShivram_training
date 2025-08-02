namespace ERPTraining.Core.DTOs;

public class RoleDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public List<RoleModuleSectionDto> ModuleSections { get; set; } = new List<RoleModuleSectionDto>();
}

public class RoleModuleSectionDto
{
    public int Id { get; set; }
    public int RoleId { get; set; }
    public int ModuleId { get; set; }
    public int SectionId { get; set; }
    public string SectionName { get; set; } = string.Empty;
    public string ModuleName { get; set; } = string.Empty;
    public bool CanView { get; set; }
    public bool CanEdit { get; set; }
    public bool CanDelete { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class UserRoleDto
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public int RoleId { get; set; }
    public string RoleName { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public string UserFullName { get; set; } = string.Empty;
    public DateTime AssignedAt { get; set; }
    public bool IsActive { get; set; }
}

public class CreateRoleDto
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public List<RoleModuleSectionCreateDto> ModuleSections { get; set; } = new List<RoleModuleSectionCreateDto>();
}

public class RoleModuleSectionCreateDto
{
    public int ModuleId { get; set; }
    public int SectionId { get; set; }
    public string SectionName { get; set; } = string.Empty;
    public bool CanView { get; set; } = true;
    public bool CanEdit { get; set; } = false;
    public bool CanDelete { get; set; } = false;
}

public class AssignUserRoleDto
{
    public string UserId { get; set; } = string.Empty;
    public int RoleId { get; set; }
}

public class UserPermissionsDto
{
    public string UserId { get; set; } = string.Empty;
    public List<RoleDto> Roles { get; set; } = new List<RoleDto>();
    public List<ModulePermissionDto> ModulePermissions { get; set; } = new List<ModulePermissionDto>();
}

public class ModulePermissionDto
{
    public int ModuleId { get; set; }
    public string ModuleName { get; set; } = string.Empty;
    public List<SectionPermissionDto> SectionPermissions { get; set; } = new List<SectionPermissionDto>();
}

public class SectionPermissionDto
{
    public int SectionId { get; set; }
    public string SectionName { get; set; } = string.Empty;
    public bool CanView { get; set; }
    public bool CanEdit { get; set; }
    public bool CanDelete { get; set; }
}
