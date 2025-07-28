
using ERPTraining.Core.DTOs;
using ERPTraining.Core.Entities;
using ERPTraining.Core.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace ERPTraining.Infrastructure.Services;

public class AuthService : IAuthService
{

    private readonly IConfiguration _config;

    // For demo, use in-memory users
    private static readonly List<User> DummyUsers = new()
    {
        new User { Id = "1", UserName = "admin", Email = "admin@erptraining.com", FirstName = "Admin", LastName = "User", Department = "IT", IsActive = true },
        new User { Id = "2", UserName = "qa", Email = "qa@erptraining.com", FirstName = "QA", LastName = "User", Department = "QA", IsActive = true },
        new User { Id = "3", UserName = "manager", Email = "manager@erptraining.com", FirstName = "Manager", LastName = "User", Department = "Management", IsActive = true }
    };
    private static readonly Dictionary<string, string> DummyPasswords = new()
    {
        { "admin@erptraining.com", "admin123" },
        { "qa@erptraining.com", "qa123" },
        { "manager@erptraining.com", "manager123" }
    };
    private static readonly Dictionary<string, List<string>> DummyRoles = new()
    {
        { "admin@erptraining.com", new List<string> { "Admin" } },
        { "qa@erptraining.com", new List<string> { "QA" } },
        { "manager@erptraining.com", new List<string> { "Manager" } }
    };

    public AuthService(IConfiguration config)
    {
        _config = config;
    }

    public Task<AuthResponseDto?> LoginAsync(LoginDto loginDto)
    {
        var user = DummyUsers.FirstOrDefault(u => u.Email == loginDto.UserName && u.IsActive);
        if (user == null) return Task.FromResult<AuthResponseDto?>(null);
        if (!DummyPasswords.TryGetValue(loginDto.UserName, out var pwd) || pwd != loginDto.Password)
            return Task.FromResult<AuthResponseDto?>(null);

        var roles = DummyRoles.TryGetValue(loginDto.UserName, out var r) ? r : new List<string> { "User" };
        var token = GenerateJwtToken(user, roles);
        var userDto = new UserDto
        {
            Id = user.Id,
            UserName = user.UserName ?? string.Empty,
            Email = user.Email ?? string.Empty,
            FirstName = user.FirstName,
            LastName = user.LastName,
            FullName = user.FullName,
            Department = user.Department,
            JoinDate = user.JoinDate,
            Avatar = user.Avatar,
            IsActive = user.IsActive,
            Roles = roles
        };
        return Task.FromResult<AuthResponseDto?>(new AuthResponseDto
        {
            Token = token,
            User = userDto,
            Expires = DateTime.UtcNow.AddDays(7)
        });
    }

    public Task<AuthResponseDto?> RegisterAsync(RegisterDto registerDto)
    {
        // For demo, just add to DummyUsers and DummyPasswords
        var user = new User
        {
            Id = Guid.NewGuid().ToString(),
            UserName = registerDto.UserName,
            Email = registerDto.Email,
            FirstName = registerDto.FirstName,
            LastName = registerDto.LastName,
            Department = registerDto.Department,
            IsActive = true
        };
        DummyUsers.Add(user);
        DummyPasswords[registerDto.UserName] = registerDto.Password;
        DummyRoles[registerDto.UserName] = new List<string> { "User" };
        var token = GenerateJwtToken(user, DummyRoles[registerDto.UserName]);
        var userDto = new UserDto
        {
            Id = user.Id,
            UserName = user.UserName ?? string.Empty,
            Email = user.Email ?? string.Empty,
            FirstName = user.FirstName,
            LastName = user.LastName,
            FullName = user.FullName,
            Department = user.Department,
            JoinDate = user.JoinDate,
            Avatar = user.Avatar,
            IsActive = user.IsActive,
            Roles = DummyRoles[registerDto.UserName]
        };
        return Task.FromResult<AuthResponseDto?>(new AuthResponseDto
        {
            Token = token,
            User = userDto,
            Expires = DateTime.UtcNow.AddDays(7)
        });
    }

    private string GenerateJwtToken(User user, List<string> roles)
    {
        var jwtSection = _config.GetSection("Jwt");
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSection["Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id),
            new Claim(ClaimTypes.Name, user.UserName ?? ""),
            new Claim(ClaimTypes.Email, user.Email ?? ""),
            new Claim("FullName", user.FullName ?? ""),
            new Claim("Department", user.Department ?? ""),
        };
        foreach (var role in roles)
        {
            claims.Add(new Claim(ClaimTypes.Role, role));
        }
        var token = new JwtSecurityToken(
            issuer: jwtSection["Issuer"],
            audience: jwtSection["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddDays(7),
            signingCredentials: creds
        );
        return new JwtSecurityTokenHandler().WriteToken(token);
    }


    public Task<UserDto?> GetCurrentUserAsync(string userId)
    {
        var user = DummyUsers.FirstOrDefault(u => u.Id == userId);
        if (user == null) return Task.FromResult<UserDto?>(null);
        var roles = DummyRoles.TryGetValue(user.UserName ?? string.Empty, out var r) ? r : new List<string> { "User" };
        var userDto = new UserDto
        {
            Id = user.Id,
            UserName = user.UserName ?? string.Empty,
            Email = user.Email ?? string.Empty,
            FirstName = user.FirstName,
            LastName = user.LastName,
            FullName = user.FullName,
            Department = user.Department,
            JoinDate = user.JoinDate,
            Avatar = user.Avatar,
            IsActive = user.IsActive,
            Roles = roles
        };
        return Task.FromResult<UserDto?>(userDto);
    }

    public Task<UserDto?> UpdateProfileAsync(string userId, UserDto updateDto)
    {
        // Dummy: just echo back the updated data for UAT/demo
        updateDto.Id = userId;
        return Task.FromResult<UserDto?>(updateDto);
    }

    public Task<bool> AssignRoleAsync(string userId, string role)
    {
        // Always return true
        return Task.FromResult(true);
    }

    public Task<List<string>> GetUserRolesAsync(string userId)
    {
        // Always return Admin
        return Task.FromResult(new List<string> { "Admin" });
    }
}
