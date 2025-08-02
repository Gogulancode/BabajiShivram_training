using ERPTraining.Core.DTOs;

namespace ERPTraining.Core.Interfaces;

public interface IRoleAccessService
{
    Task<IEnumerable<RoleAccessDto>> GetRoleAccessByRoleIdAsync(string roleId);
    Task<IEnumerable<RoleAccessDto>> GetAllRoleAccessAsync();
    Task<bool> UpdateRoleAccessAsync(string roleId, UpdateRoleAccessDto updateRoleAccessDto);
    Task<bool> BulkUpdateRoleAccessAsync(List<BulkRoleAccessDto> bulkRoleAccessDtos);
    Task<IEnumerable<ModuleWithSectionsDto>> GetModulesWithSectionsForRoleAsync(string roleId);
    Task<IEnumerable<RoleWithAccessDto>> GetRolesWithAccessAsync();
    Task<bool> HasAccessToSectionAsync(string userId, int moduleId, int sectionId);
    Task<IEnumerable<object>> GetAllRolesAsync(); // Temporary for testing
    Task<bool> SeedRoleModuleSectionDataAsync(); // New method to seed your data
}
