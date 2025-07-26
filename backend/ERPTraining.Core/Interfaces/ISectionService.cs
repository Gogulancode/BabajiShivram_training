using ERPTraining.Core.DTOs;

namespace ERPTraining.Core.Interfaces;

public interface ISectionService
{
    Task<List<SectionDto>> GetSectionsByModuleIdAsync(int moduleId, string userId);
    Task<SectionDto?> GetSectionByIdAsync(int id, string userId);
    Task<SectionDto> CreateSectionAsync(CreateSectionDto createSectionDto);
    Task<SectionDto?> UpdateSectionAsync(int id, UpdateSectionDto updateSectionDto);
    Task<bool> DeleteSectionAsync(int id);
}