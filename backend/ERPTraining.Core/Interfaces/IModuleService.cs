using ERPTraining.Core.DTOs;

namespace ERPTraining.Core.Interfaces;

public interface IModuleService
{
    Task<List<ModuleDto>> GetAllModulesAsync(string userId);
    Task<ModuleDto?> GetModuleByIdAsync(int id, string userId);
    Task<ModuleDto> CreateModuleAsync(CreateModuleDto createModuleDto);
    Task<ModuleDto?> UpdateModuleAsync(int id, UpdateModuleDto updateModuleDto);
    Task<bool> DeleteModuleAsync(int id);
    Task<List<ModuleDto>> GetUserModulesWithProgressAsync(string userId);
}