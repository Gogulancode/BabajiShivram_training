using System.Text;
using System.Reflection;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using ERPTraining.Core.Entities;
using ERPTraining.Core.Interfaces;
using ERPTraining.Infrastructure.Data;
using ERPTraining.Infrastructure.Mappings;
using ERPTraining.Infrastructure.Services;

var builder = WebApplication.CreateBuilder(args);

// Force HTTP-only for development
builder.WebHost.UseUrls("http://localhost:5000");

// Add services to the container.
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(builder =>
    {
        builder.WithOrigins("http://localhost:5173")
               .AllowAnyMethod()
               .AllowAnyHeader()
               .AllowCredentials()
               .WithExposedHeaders("Content-Disposition");
    });
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configure Swagger with JWT support and comprehensive documentation
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo 
    { 
        Title = "ERP Training API", 
        Version = "v1",
        Description = @"
            <h2>ERP Training Management System API</h2>
            <p>This API provides comprehensive endpoints for managing ERP training modules, sections, assessments, and user progress tracking.</p>
            
            <h3>Key Features:</h3>
            <ul>
                <li><b>Module Management:</b> Create, read, update, and delete training modules</li>
                <li><b>Section Management:</b> Manage sections within modules with detailed content</li>
                <li><b>Assessment System:</b> Create and manage assessments with questions and scoring</li>
                <li><b>User Progress:</b> Track user learning progress across modules and sections</li>
                <li><b>Authentication:</b> JWT-based authentication with role-based access control</li>
            </ul>
            
            <h3>Authentication:</h3>
            <p>This API uses JWT Bearer token authentication. To access protected endpoints:</p>
            <ol>
                <li>Register a new user or login with existing credentials</li>
                <li>Use the received JWT token in the Authorization header</li>
                <li>Format: <code>Authorization: Bearer {your-jwt-token}</code></li>
            </ol>
            
            <h3>Base URL:</h3>
            <p><code>http://localhost:5000/api</code></p>
        ",
        Contact = new OpenApiContact
        {
            Name = "ERP Training Development Team",
            Email = "support@erptraining.com",
            Url = new Uri("https://github.com/Gogulancode/BabajiShivram_training")
        },
        License = new OpenApiLicense
        {
            Name = "MIT License",
            Url = new Uri("https://opensource.org/licenses/MIT")
        }
    });
    
    // Include XML comments for detailed documentation
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }

    // Also include XML comments from Core project if available
    var coreXmlFile = "ERPTraining.Core.xml";
    var coreXmlPath = Path.Combine(AppContext.BaseDirectory, coreXmlFile);
    if (File.Exists(coreXmlPath))
    {
        c.IncludeXmlComments(coreXmlPath);
    }
    
    // Add JWT Authentication to Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = @"
            <h4>JWT Authorization Header</h4>
            <p>Enter your JWT token in the format: <strong>Bearer {your-token}</strong></p>
            <p>Example: <code>Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...</code></p>
            <h5>How to get a token:</h5>
            <ol>
                <li>Use the <strong>/api/auth/register</strong> endpoint to create a new account</li>
                <li>Or use <strong>/api/auth/login</strong> to login with existing credentials</li>
                <li>Copy the token from the response</li>
                <li>Paste it in the field below (without 'Bearer' prefix)</li>
            </ol>
        ",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "oauth2",
                Name = "Bearer",
                In = ParameterLocation.Header
            },
            new List<string>()
        }
    });

    // Add operation tags for better organization
    c.TagActionsBy(api => new[] { api.GroupName ?? api.ActionDescriptor.RouteValues["controller"] });
    c.DocInclusionPredicate((name, api) => true);
});

// Configure Entity Framework
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Configure Identity
builder.Services.AddIdentity<User, IdentityRole>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireUppercase = true;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequiredLength = 6;
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// Configure JWT Authentication
var jwtSettings = builder.Configuration.GetSection("Jwt");
var key = Encoding.UTF8.GetBytes(jwtSettings["Key"]!);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ClockSkew = TimeSpan.Zero
    };
});

// Configure AutoMapper
builder.Services.AddAutoMapper(typeof(MappingProfile));

// Register services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IModuleService, ModuleService>();
builder.Services.AddScoped<IAssessmentService, AssessmentService>();
builder.Services.AddScoped<IQuestionService, QuestionService>();
builder.Services.AddScoped<ISectionService, SectionService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Configure CORS - must be before other middleware
app.UseCors(builder =>
{
    builder.SetIsOriginAllowed(origin => origin == "http://localhost:5173")
           .AllowAnyMethod()
           .AllowAnyHeader()
           .AllowCredentials()
           .WithExposedHeaders("Content-Disposition");
});

// Disable HTTPS redirection for development
// app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Seed database
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<ApplicationDbContext>();
        var userManager = services.GetRequiredService<UserManager<User>>();
        var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();
        
        await SeedData.Initialize(context, userManager, roleManager);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred seeding the DB.");
    }
}

app.Run();