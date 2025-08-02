using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ERPTraining.Core.Interfaces;

namespace ERPTraining.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RolesController : ControllerBase
{
    private readonly RoleManager<IdentityRole> _roleManager;

    public RolesController(RoleManager<IdentityRole> roleManager)
    {
        _roleManager = roleManager;
    }

    /// <summary>
    /// Get all available roles
    /// </summary>
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<string>>> GetAllRoles()
    {
        var roles = await _roleManager.Roles.Select(r => r.Name).ToListAsync();
        return Ok(roles);
        {
            {"Admin", -1}, {"QA", -2}, // System roles
            {"HOD", 1}, {"IGM", 2}, {"Checklist Preparation", 3}, {"KAM Assistant-Air", 4},
            {"KAM Assistant-Sea", 5}, {"KAM-Sea", 6}, {"KAM-Air", 7}, {"Checklist Approval", 8},
            {"Delivery Order", 9}, {"Operations-Sea", 10}, {"Operations-Air", 11}, {"Transport", 12},
            {"Post Clearance Advice-Sea", 13}, {"Billing Scrutiny", 14}, {"Billing", 15}, {"Dispatch", 16},
            {"Billing HOD", 17}, {"Branch KAM", 18}, {"Post Clearance Advice-Branches", 19},
            {"Operations-Sea-Shed", 20}, {"Warehousing", 21}, {"Freight User", 22}, {"Feedback", 23},
            {"CFS", 24}, {"Reports", 25}, {"ITADMIN", 26}, {"Super Admin", 27}, {"Documentation", 28},
            {"Custom HOD", 29}, {"Express User", 30}, {"Sea Export", 31}, {"Quotation", 32},
            {"Air Export", 33}, {"Sea Import", 34}, {"Air Import", 35}, {"Consolidation Export", 36},
            {"Consolidation Import", 37}, {"Delete Approved", 38}, {"EDIT APPROVED ROLE", 39},
            {"Credit Vendor", 40}, {"Cheque Printing", 41}, {"Daily Collection and Charges", 42},
            {"Payment Audit", 43}, {"TDS Computation", 44}, {"Office Manager", 45}, {"Expense Scrutiny", 46},
            {"Expense HOD", 47}, {"Transport Operations", 48}, {"Vessel Management", 49},
            {"Transport_Accounts", 50}, {"CC_Reports", 51}, {"CC_Operations", 52}, {"CC_Collection", 53},
            {"CC_Upload", 54}, {"View", 55}, {"CC_Collection_Report", 56}, {"Billing Manager", 57},
            {"Post Clearance Advice-Air", 58}, {"ICD Management", 59}, {"ICD_IT", 60}, {"MIS", 61},
            {"Executive", 62}, {"Document Print", 63}, {"Customer Enquiry", 64}, {"Transport Expense", 65},
            {"File Handling", 66}, {"Sales Coordinator", 67}, {"Manager", 68}, {"Operations Manager", 69},
            {"Project", 70}, {"AP Manager", 71}, {"AP L2", 72}, {"AP L1", 73}, {"Expense Audit", 74},
            {"CRM", 75}, {"Job Approval", 76}, {"AP_Expense", 77}, {"AP_Expense L2", 78},
            {"Cheque Audit", 79}, {"Memo Audit", 80}, {"AP_Freight", 81}, {"AR", 82},
            {"Freight Operation", 83}, {"KAM", 84}, {"BD", 85}, {"Marine", 86}, {"Customs", 87},
            {"File Management", 88}, {"Sales", 89}, {"Consolidation", 90}, {"C&F", 91},
            {"General Admin", 92}, {"Export", 93}, {"Import", 94}, {"Transport HOD", 95},
            {"Billing_Job_Access", 96}, {"AP_Transport", 97}, {"Billing_Dispatch", 98},
            {"Billing_Scrutiny_Dispatch", 99}, {"Billing_Scrutiny_HOD", 100}, {"Freight", 101},
            {"User", 103}, {"CRM_Admin", 104}, {"CRM_AP_Access", 105}, {"AP_Vitwo_Management", 106},
            {"AP_Vitwo_L1", 107}, {"PN Movement Admin", 108}, {"Billing_Current Job", 109},
            {"Assistant Role", 110}, {"Presentation Role", 111}, {"Transport_AP_Audit", 112},
            {"Stamp_Duty", 113}, {"Transport and Vendor AP Access", 114}, {"IT_Developer", 115},
            {"Blank Cheque Update", 116}, {"Invoice_Tracking", 117}, {"Customer_Implant", 118},
            {"Checklist_JOb_Opening", 119}, {"Contract_Role", 120}, {"Maintenance Transport_Exp", 121},
            {"EC User", 122}, {"Warehouse User", 123}, {"Project User", 124}, {"Marine User", 125},
            {"Implant_Fujifilms", 126}, {"CRM_TransAP", 127}, {"Role For Vitwo", 128},
            {"CRM_Freight", 129}, {"Branch_DO", 130}, {"Payment-Credit Vendor Memo", 131},
            {"Transport AP Module L1 and L2 and Memo", 132}, {"Project_Operation", 133},
            {"Credit Control HOD", 134}, {"Training", 135}, {"Dubai", 136}
        };

        var roles = await _roleManager.Roles
            .Select(r => new RoleDto
            {
                Id = r.Id,
                Name = r.Name ?? string.Empty,
                Description = string.Empty,
                OriginalRoleId = roleIdMapping.ContainsKey(r.Name ?? "") ? roleIdMapping[r.Name ?? ""] : (int?)null,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Permissions = new List<PermissionDto>() // Empty for now - will be loaded separately
            })
            .ToListAsync();

        return Ok(roles);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<RoleDto>> GetRoleById(string id)
    {
        var role = await _roleManager.FindByIdAsync(id);
        
        if (role == null)
            return NotFound();

        // Same mapping as above - in a real application, this would be in a service or static class
        var roleIdMapping = new Dictionary<string, int>
        {
            {"Admin", -1}, {"QA", -2}, // System roles
            {"HOD", 1}, {"IGM", 2}, {"Checklist Preparation", 3}, {"KAM Assistant-Air", 4},
            {"KAM Assistant-Sea", 5}, {"KAM-Sea", 6}, {"KAM-Air", 7}, {"Checklist Approval", 8},
            {"Delivery Order", 9}, {"Operations-Sea", 10}, {"Operations-Air", 11}, {"Transport", 12},
            {"Post Clearance Advice-Sea", 13}, {"Billing Scrutiny", 14}, {"Billing", 15}, {"Dispatch", 16},
            {"Billing HOD", 17}, {"Branch KAM", 18}, {"Post Clearance Advice-Branches", 19},
            {"Operations-Sea-Shed", 20}, {"Warehousing", 21}, {"Freight User", 22}, {"Feedback", 23},
            {"CFS", 24}, {"Reports", 25}, {"ITADMIN", 26}, {"Super Admin", 27}, {"Documentation", 28},
            {"Custom HOD", 29}, {"Express User", 30}, {"Sea Export", 31}, {"Quotation", 32},
            {"Air Export", 33}, {"Sea Import", 34}, {"Air Import", 35}, {"Consolidation Export", 36},
            {"Consolidation Import", 37}, {"Delete Approved", 38}, {"EDIT APPROVED ROLE", 39},
            {"Credit Vendor", 40}, {"Cheque Printing", 41}, {"Daily Collection and Charges", 42},
            {"Payment Audit", 43}, {"TDS Computation", 44}, {"Office Manager", 45}, {"Expense Scrutiny", 46},
            {"Expense HOD", 47}, {"Transport Operations", 48}, {"Vessel Management", 49},
            {"Transport_Accounts", 50}, {"CC_Reports", 51}, {"CC_Operations", 52}, {"CC_Collection", 53},
            {"CC_Upload", 54}, {"View", 55}, {"CC_Collection_Report", 56}, {"Billing Manager", 57},
            {"Post Clearance Advice-Air", 58}, {"ICD Management", 59}, {"ICD_IT", 60}, {"MIS", 61},
            {"Executive", 62}, {"Document Print", 63}, {"Customer Enquiry", 64}, {"Transport Expense", 65},
            {"File Handling", 66}, {"Sales Coordinator", 67}, {"Manager", 68}, {"Operations Manager", 69},
            {"Project", 70}, {"AP Manager", 71}, {"AP L2", 72}, {"AP L1", 73}, {"Expense Audit", 74},
            {"CRM", 75}, {"Job Approval", 76}, {"AP_Expense", 77}, {"AP_Expense L2", 78},
            {"Cheque Audit", 79}, {"Memo Audit", 80}, {"AP_Freight", 81}, {"AR", 82},
            {"Freight Operation", 83}, {"KAM", 84}, {"BD", 85}, {"Marine", 86}, {"Customs", 87},
            {"File Management", 88}, {"Sales", 89}, {"Consolidation", 90}, {"C&F", 91},
            {"General Admin", 92}, {"Export", 93}, {"Import", 94}, {"Transport HOD", 95},
            {"Billing_Job_Access", 96}, {"AP_Transport", 97}, {"Billing_Dispatch", 98},
            {"Billing_Scrutiny_Dispatch", 99}, {"Billing_Scrutiny_HOD", 100}, {"Freight", 101},
            {"User", 103}, {"CRM_Admin", 104}, {"CRM_AP_Access", 105}, {"AP_Vitwo_Management", 106},
            {"AP_Vitwo_L1", 107}, {"PN Movement Admin", 108}, {"Billing_Current Job", 109},
            {"Assistant Role", 110}, {"Presentation Role", 111}, {"Transport_AP_Audit", 112},
            {"Stamp_Duty", 113}, {"Transport and Vendor AP Access", 114}, {"IT_Developer", 115},
            {"Blank Cheque Update", 116}, {"Invoice_Tracking", 117}, {"Customer_Implant", 118},
            {"Checklist_JOb_Opening", 119}, {"Contract_Role", 120}, {"Maintenance Transport_Exp", 121},
            {"EC User", 122}, {"Warehouse User", 123}, {"Project User", 124}, {"Marine User", 125},
            {"Implant_Fujifilms", 126}, {"CRM_TransAP", 127}, {"Role For Vitwo", 128},
            {"CRM_Freight", 129}, {"Branch_DO", 130}, {"Payment-Credit Vendor Memo", 131},
            {"Transport AP Module L1 and L2 and Memo", 132}, {"Project_Operation", 133},
            {"Credit Control HOD", 134}, {"Training", 135}, {"Dubai", 136}
        };

        var roleDto = new RoleDto
        {
            Id = role.Id,
            Name = role.Name ?? string.Empty,
            OriginalRoleId = roleIdMapping.ContainsKey(role.Name ?? "") ? roleIdMapping[role.Name ?? ""] : (int?)null
        };

        return Ok(roleDto);
    }

    [HttpPost]
    public async Task<ActionResult<RoleDto>> CreateRole([FromBody] CreateRoleDto createRoleDto)
    {
        if (await _roleManager.RoleExistsAsync(createRoleDto.Name))
        {
            return BadRequest($"Role '{createRoleDto.Name}' already exists.");
        }

        var role = new IdentityRole(createRoleDto.Name);
        var result = await _roleManager.CreateAsync(role);

        if (!result.Succeeded)
        {
            return BadRequest(result.Errors);
        }

        var roleDto = new RoleDto
        {
            Id = role.Id,
            Name = role.Name ?? string.Empty
        };

        return CreatedAtAction(nameof(GetRoleById), new { id = role.Id }, roleDto);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<RoleDto>> UpdateRole(string id, [FromBody] UpdateRoleDto updateRoleDto)
    {
        var role = await _roleManager.FindByIdAsync(id);
        
        if (role == null)
            return NotFound();

        if (await _roleManager.RoleExistsAsync(updateRoleDto.Name) && role.Name != updateRoleDto.Name)
        {
            return BadRequest($"Role '{updateRoleDto.Name}' already exists.");
        }

        role.Name = updateRoleDto.Name;
        var result = await _roleManager.UpdateAsync(role);

        if (!result.Succeeded)
        {
            return BadRequest(result.Errors);
        }

        var roleDto = new RoleDto
        {
            Id = role.Id,
            Name = role.Name ?? string.Empty
        };

        return Ok(roleDto);
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteRole(string id)
    {
        var role = await _roleManager.FindByIdAsync(id);
        
        if (role == null)
            return NotFound();

        // Prevent deletion of system roles
        var systemRoles = new[] { "Admin", "QA", "User", "Manager", "Supervisor" };
        if (systemRoles.Contains(role.Name))
        {
            return BadRequest($"Cannot delete system role '{role.Name}'.");
        }

        var result = await _roleManager.DeleteAsync(role);

        if (!result.Succeeded)
        {
            return BadRequest(result.Errors);
        }

        return NoContent();
    }

    [HttpGet("stats")]
    public async Task<ActionResult<RoleStatsDto>> GetRoleStats()
    {
        var totalRoles = await _roleManager.Roles.CountAsync();
        var activeRoles = totalRoles; // In this simple case, all roles are considered "active"
        var inactiveRoles = 0;
        var rolesWithPermissions = totalRoles; // Assuming all roles have some permissions

        var stats = new RoleStatsDto
        {
            TotalRoles = totalRoles,
            ActiveRoles = activeRoles,
            InactiveRoles = inactiveRoles,
            RolesWithPermissions = rolesWithPermissions
        };

        return Ok(stats);
    }
}

public class RoleDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int? OriginalRoleId { get; set; } // The lRoleId from your JSON
    public bool IsActive { get; set; } = true;
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public List<PermissionDto> Permissions { get; set; } = new List<PermissionDto>();
}

public class PermissionDto
{
    public string Id { get; set; } = string.Empty;
    public string ModuleName { get; set; } = string.Empty;
    public string SectionName { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
}

public class CreateRoleDto
{
    public string Name { get; set; } = string.Empty;
    public int? OriginalRoleId { get; set; } // Optional: allow setting original role ID
}

public class UpdateRoleDto
{
    public string Name { get; set; } = string.Empty;
}

public class RoleStatsDto
{
    public int TotalRoles { get; set; }
    public int ActiveRoles { get; set; }
    public int InactiveRoles { get; set; }
    public int RolesWithPermissions { get; set; }
}
