using ERPTraining.Core.DTOs;
using ERPTraining.Core.Entities;

namespace ERPTraining.Core.Interfaces;

public interface ISectionService
{
    Task<IEnumerable<SectionDto>> GetAllSectionsAsync();
    Task<IEnumerable<SectionDto>> GetSectionsByModuleAsync(int moduleId);
    Task<List<SectionDto>> GetSectionsByModuleIdAsync(int moduleId, string userId);
    Task<SectionDto?> GetSectionByIdAsync(int id, string userId);
    Task<SectionDto?> GetSectionByIdAsync(int id);
    Task<SectionDto> CreateSectionAsync(CreateSectionDto createSectionDto);
    Task<SectionDto?> UpdateSectionAsync(int id, UpdateSectionDto updateSectionDto);
    Task<bool> DeleteSectionAsync(int id);
    Task<bool> SectionExistsAsync(int id);
}