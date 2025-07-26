using ERPTraining.Core.DTOs;

namespace ERPTraining.Core.Interfaces;

public interface ILessonService
{
    Task<List<LessonDto>> GetLessonsBySectionIdAsync(int sectionId, string userId);
    Task<LessonDto?> GetLessonByIdAsync(int id, string userId);
    Task<LessonDto> CreateLessonAsync(CreateLessonDto createLessonDto);
    Task<LessonDto?> UpdateLessonAsync(int id, UpdateLessonDto updateLessonDto);
    Task<bool> DeleteLessonAsync(int id);
    Task<bool> MarkLessonCompleteAsync(int lessonId, string userId);
}