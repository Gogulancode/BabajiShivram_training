using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ERPTraining.Core.DTOs;
using ERPTraining.Core.Interfaces;
using System.Security.Claims;

namespace ERPTraining.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ModulesController : ControllerBase
{
    private readonly IModuleService _moduleService;

    public ModulesController(IModuleService moduleService)
    {
        _moduleService = moduleService;
    }

    [HttpGet]
    public async Task<ActionResult<List<ModuleDto>>> GetAllModules()
    {
        var userId = GetCurrentUserId();
        var modules = await _moduleService.GetAllModulesAsync(userId);
        return Ok(modules);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ModuleDto>> GetModuleById(int id)
    {
        var userId = GetCurrentUserId();
        var module = await _moduleService.GetModuleByIdAsync(id, userId);
        
        if (module == null)
            return NotFound();

        return Ok(module);
    }

    [HttpPost]
    [Authorize(Roles = "Admin,QA")]
    public async Task<ActionResult<ModuleDto>> CreateModule([FromBody] CreateModuleDto createModuleDto)
    {
        var module = await _moduleService.CreateModuleAsync(createModuleDto);
        return CreatedAtAction(nameof(GetModuleById), new { id = module.Id }, module);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin,QA")]
    public async Task<ActionResult<ModuleDto>> UpdateModule(int id, [FromBody] UpdateModuleDto updateModuleDto)
    {
        var module = await _moduleService.UpdateModuleAsync(id, updateModuleDto);
        
        if (module == null)
            return NotFound();

        return Ok(module);
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult> DeleteModule(int id)
    {
        var result = await _moduleService.DeleteModuleAsync(id);
        
        if (!result)
            return NotFound();

        return NoContent();
    }

    [HttpGet("my-progress")]
    public async Task<ActionResult<List<ModuleDto>>> GetMyModulesWithProgress()
    {
        var userId = GetCurrentUserId();
        var modules = await _moduleService.GetUserModulesWithProgressAsync(userId);
        return Ok(modules);
    }

    private string GetCurrentUserId()
    {
        return User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? string.Empty;
    }
}