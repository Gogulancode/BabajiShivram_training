using ERPTraining.Core.DTOs;

namespace ERPTraining.Core.Interfaces;

public interface IRoleService
{
    Task<IEnumerable<RoleDto>> GetAllRolesAsync();
    Task<RoleDto?> GetRoleByIdAsync(int id);
    Task<RoleDto> CreateRoleAsync(CreateRoleDto createRoleDto);
    Task<RoleDto?> UpdateRoleAsync(int id, CreateRoleDto updateRoleDto);
    Task<bool> DeleteRoleAsync(int id);
    
    Task<IEnumerable<UserRoleDto>> GetUserRolesAsync(string userId);
    Task<UserRoleDto> AssignUserRoleAsync(AssignUserRoleDto assignUserRoleDto);
    Task<bool> RemoveUserRoleAsync(int userRoleId);
    
    Task<UserPermissionsDto> GetUserPermissionsAsync(string userId);
    Task<bool> HasPermissionAsync(string userId, int moduleId, int sectionId, string permission = "view");
    
    Task<bool> SeedRoleDataAsync();
}
