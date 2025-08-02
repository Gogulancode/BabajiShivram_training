namespace ERPTraining.Core.DTOs;

public class RoleAccessDto
{
    public int Id { get; set; }
    public string RoleId { get; set; } = string.Empty;
    public string RoleName { get; set; } = string.Empty;
    public int ModuleId { get; set; }
    public string ModuleName { get; set; } = string.Empty;
    public int SectionId { get; set; }
    public string SectionName { get; set; } = string.Empty;
    public string? ErpRoleId { get; set; }
    public string? ErpModuleId { get; set; }
    public string? ErpSectionId { get; set; }
}

public class UpdateRoleAccessDto
{
    public List<ModuleAccessDto> ModuleAccess { get; set; } = new();
}

public class ModuleAccessDto
{
    public int ModuleId { get; set; }
    public List<int> SectionIds { get; set; } = new();
}

public class BulkRoleAccessDto
{
    public string RoleId { get; set; } = string.Empty;
    public List<ModuleAccessDto> ModuleAccess { get; set; } = new();
}

public class ModuleWithSectionsDto
{
    public int ModuleId { get; set; }
    public string ModuleName { get; set; } = string.Empty;
    public List<SectionAccessDto> Sections { get; set; } = new();
}

public class SectionAccessDto
{
    public int SectionId { get; set; }
    public string SectionName { get; set; } = string.Empty;
    public bool HasAccess { get; set; }
}

public class RoleWithAccessDto
{
    public string RoleId { get; set; } = string.Empty;
    public string RoleName { get; set; } = string.Empty;
    public int? OriginalRoleId { get; set; }
    public List<ModuleAccessSummaryDto> ModuleAccess { get; set; } = new();
}

public class ModuleAccessSummaryDto
{
    public int ModuleId { get; set; }
    public string ModuleName { get; set; } = string.Empty;
    public int TotalSections { get; set; }
    public int AccessibleSections { get; set; }
    public List<string> AccessibleSectionNames { get; set; } = new();
}
