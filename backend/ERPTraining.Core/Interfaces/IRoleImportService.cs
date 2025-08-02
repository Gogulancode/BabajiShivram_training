namespace ERPTraining.Core.Interfaces;

public interface IRoleImportService
{
    Task<bool> ImportRolesFromJsonAsync(string jsonContent);
}
