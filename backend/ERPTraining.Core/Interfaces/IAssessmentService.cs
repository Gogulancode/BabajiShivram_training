using ERPTraining.Core.DTOs;

namespace ERPTraining.Core.Interfaces;

public interface IAssessmentService
{
    Task<List<AssessmentDto>> GetAllAssessmentsAsync(string userId);
    Task<List<AssessmentDto>> GetAssessmentsByModuleIdAsync(int moduleId, string userId);
    Task<AssessmentDto?> GetAssessmentByIdAsync(int id, string userId);
    Task<AssessmentDto> CreateAssessmentAsync(CreateAssessmentDto createAssessmentDto);
    Task<AssessmentDto?> UpdateAssessmentAsync(int id, UpdateAssessmentDto updateAssessmentDto);
    Task<bool> DeleteAssessmentAsync(int id);
    Task<bool> ToggleAssessmentStatusAsync(int id);
}

public interface IQuestionService
{
    Task<List<QuestionDto>> GetQuestionsByAssessmentIdAsync(int assessmentId);
    Task<QuestionDto?> GetQuestionByIdAsync(int id);
    Task<QuestionDto> CreateQuestionAsync(CreateQuestionDto createQuestionDto);
    Task<QuestionDto?> UpdateQuestionAsync(int id, UpdateQuestionDto updateQuestionDto);
    Task<bool> DeleteQuestionAsync(int id);
}