using AutoMapper;
using ERPTraining.Core.DTOs;
using ERPTraining.Core.Entities;

namespace ERPTraining.Infrastructure.Mappings;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // User mappings
        CreateMap<User, UserDto>()
            .ForMember(dest => dest.FullName, opt => opt.MapFrom(src => src.FullName));
        CreateMap<RegisterDto, User>();

        // Module mappings
        CreateMap<Module, ModuleDto>()
            .ForMember(dest => dest.Progress, opt => opt.Ignore())
            .ForMember(dest => dest.IsLocked, opt => opt.Ignore());
        CreateMap<CreateModuleDto, Module>();
        CreateMap<UpdateModuleDto, Module>();

        // Section mappings
        CreateMap<Section, SectionDto>();
        CreateMap<CreateSectionDto, Section>();
        CreateMap<UpdateSectionDto, Section>();

        // Lesson mappings
        CreateMap<Lesson, LessonDto>()
            .ForMember(dest => dest.IsCompleted, opt => opt.Ignore())
            .ForMember(dest => dest.IsLocked, opt => opt.Ignore());
        CreateMap<CreateLessonDto, Lesson>();
        CreateMap<UpdateLessonDto, Lesson>();

        // Assessment mappings
        CreateMap<Assessment, AssessmentDto>()
            .ForMember(dest => dest.ModuleName, opt => opt.MapFrom(src => src.Module.Title))
            .ForMember(dest => dest.SectionName, opt => opt.MapFrom(src => src.Section != null ? src.Section.Title : null))
            .ForMember(dest => dest.TotalQuestions, opt => opt.MapFrom(src => src.Questions.Count))
            .ForMember(dest => dest.TotalPoints, opt => opt.MapFrom(src => src.Questions.Sum(q => q.Points)))
            .ForMember(dest => dest.UserProgress, opt => opt.Ignore());
        CreateMap<CreateAssessmentDto, Assessment>();
        CreateMap<UpdateAssessmentDto, Assessment>();

        // Question mappings
        CreateMap<Question, QuestionDto>();
        CreateMap<CreateQuestionDto, Question>();
        CreateMap<UpdateQuestionDto, Question>();

        // Assessment attempt mappings
        CreateMap<AssessmentAttempt, AssessmentUserProgress>()
            .ForMember(dest => dest.Attempts, opt => opt.Ignore())
            .ForMember(dest => dest.LastScore, opt => opt.MapFrom(src => src.Score))
            .ForMember(dest => dest.BestScore, opt => opt.Ignore())
            .ForMember(dest => dest.Status, opt => opt.Ignore())
            .ForMember(dest => dest.LastAttempt, opt => opt.MapFrom(src => src.StartedAt));
    }
}