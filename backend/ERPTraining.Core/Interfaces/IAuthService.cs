using ERPTraining.Core.DTOs;

namespace ERPTraining.Core.Interfaces;

public interface IAuthService
{
    Task<AuthResponseDto?> LoginAsync(LoginDto loginDto);
    Task<AuthResponseDto?> RegisterAsync(RegisterDto registerDto);
    Task<UserDto?> GetCurrentUserAsync(string userId);
    Task<bool> AssignRoleAsync(string userId, string role);
    Task<List<string>> GetUserRolesAsync(string userId);
}