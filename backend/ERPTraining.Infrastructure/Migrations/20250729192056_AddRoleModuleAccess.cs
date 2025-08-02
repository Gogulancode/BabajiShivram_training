using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ERPTraining.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddRoleModuleAccess : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "RoleModuleAccess",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RoleId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ModuleId = table.Column<int>(type: "int", nullable: false),
                    SectionId = table.Column<int>(type: "int", nullable: true),
                    ErpRoleId = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    ErpModuleId = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    ErpSectionId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RoleModuleAccess", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RoleModuleAccess_Modules_ModuleId",
                        column: x => x.ModuleId,
                        principalTable: "Modules",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_RoleModuleAccess_Sections_SectionId",
                        column: x => x.SectionId,
                        principalTable: "Sections",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_RoleModuleAccess_ErpModuleId",
                table: "RoleModuleAccess",
                column: "ErpModuleId");

            migrationBuilder.CreateIndex(
                name: "IX_RoleModuleAccess_ErpRoleId",
                table: "RoleModuleAccess",
                column: "ErpRoleId");

            migrationBuilder.CreateIndex(
                name: "IX_RoleModuleAccess_ModuleId",
                table: "RoleModuleAccess",
                column: "ModuleId");

            migrationBuilder.CreateIndex(
                name: "IX_RoleModuleAccess_RoleId_ModuleId_SectionId",
                table: "RoleModuleAccess",
                columns: new[] { "RoleId", "ModuleId", "SectionId" },
                unique: true,
                filter: "[SectionId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_RoleModuleAccess_SectionId",
                table: "RoleModuleAccess",
                column: "SectionId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RoleModuleAccess");
        }
    }
}
