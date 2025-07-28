using Microsoft.EntityFrameworkCore.Migrations;

namespace ERPTraining.Infrastructure.Data.Migrations
{
    public partial class AddErpIds : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ErpModuleId",
                table: "Modules",
                type: "nvarchar(100)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ErpSectionId",
                table: "Sections",
                type: "nvarchar(100)",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ErpModuleId",
                table: "Modules");

            migrationBuilder.DropColumn(
                name: "ErpSectionId",
                table: "Sections");
        }
    }
}
