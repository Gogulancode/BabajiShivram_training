-- Create QuickTemplates table for dynamic quick start templates
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'QuickTemplates')
BEGIN
    CREATE TABLE QuickTemplates (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(255) NOT NULL,
        Label NVARCHAR(255) NOT NULL,
        TitleTemplate NVARCHAR(500) NOT NULL DEFAULT '',
        DescriptionTemplate NVARCHAR(MAX) NOT NULL DEFAULT '',
        IconName NVARCHAR(100) NOT NULL DEFAULT 'FileText',
        Category NVARCHAR(100) NOT NULL DEFAULT 'general-inquiry',
        Priority INT NOT NULL DEFAULT 1,
        CategoryId INT NULL,
        SubcategoryId INT NULL,
        DepartmentId INT NULL,
        DisplayOrder INT NOT NULL DEFAULT 0,
        IsActive BIT NOT NULL DEFAULT 1,
        IsDeleted BIT NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );

    -- Create indexes
    CREATE INDEX IX_QuickTemplates_IsActive ON QuickTemplates(IsActive);
    CREATE INDEX IX_QuickTemplates_DisplayOrder ON QuickTemplates(DisplayOrder);

    PRINT 'QuickTemplates table created successfully';
END
ELSE
BEGIN
    PRINT 'QuickTemplates table already exists';
END

-- Insert default templates (optional)
IF NOT EXISTS (SELECT 1 FROM QuickTemplates WHERE Label = 'IT - Bug Report')
BEGIN
    INSERT INTO QuickTemplates (Name, Label, TitleTemplate, DescriptionTemplate, IconName, Category, Priority, DisplayOrder, IsActive)
    VALUES 
    ('bug-report', 'IT - Bug Report', 'Bug Report: ', 'I encountered a bug with the following:

• What happened:
• Expected behavior:
• Steps to reproduce:
1. 
2. 
3. 

• Browser/System info:', 'Bug', 'bug-report', 2, 0, 1),

    ('technical-issue', 'IT - Technical Issue', 'Technical Support: ', 'I need technical assistance with:

• Issue description:
• Error messages (if any):
• When did this start:
• What I''ve tried:', 'Zap', 'technical-support', 1, 1, 1),

    ('leave-request', 'HR - Leave Request', 'Leave Request: ', 'I would like to request leave for:

• Leave type (Annual/Sick/Personal):
• Start date:
• End date:
• Number of days:
• Reason:
• Contact during leave:', 'Users', 'general-inquiry', 0, 2, 1),

    ('payroll-issue', 'HR - Payroll Issue', 'Payroll Inquiry: ', 'I have a payroll-related issue:

• Issue description:
• Pay period affected:
• Expected amount vs received:
• Supporting documents attached:', 'Users', 'general-inquiry', 2, 3, 1),

    ('expense-claim', 'Finance - Expense Claim', 'Expense Reimbursement: ', 'I would like to claim reimbursement for:

• Expense type:
• Amount:
• Date incurred:
• Business purpose:
• Receipts attached:', 'DollarSign', 'general-inquiry', 1, 4, 1),

    ('invoice-query', 'Finance - Invoice Query', 'Invoice Inquiry: ', 'I have a question about an invoice:

• Invoice number:
• Vendor/Client name:
• Issue description:
• Amount in question:
• Required action:', 'DollarSign', 'general-inquiry', 1, 5, 1),

    ('campaign-request', 'Marketing - Campaign Request', 'Marketing Campaign: ', 'I would like to request marketing support for:

• Campaign objective:
• Target audience:
• Timeline:
• Budget (if applicable):
• Required deliverables:
• Success metrics:', 'Megaphone', 'feature-request', 0, 6, 1),

    ('design-request', 'Marketing - Design Request', 'Design/Creative Request: ', 'I need design/creative support for:

• Type (Banner/Poster/Social media/Email):
• Purpose:
• Deadline:
• Dimensions/Specifications:
• Brand guidelines:
• Reference materials:', 'Megaphone', 'feature-request', 1, 7, 1),

    ('document-request', 'General - Document Request', 'Document Request: ', 'I need the following document(s):

• Document type:
• Purpose:
• Required by (date):
• Delivery format (PDF/Word/Email):
• Additional notes:', 'FileText', 'general-inquiry', 0, 8, 1),

    ('general-question', 'General - Question', 'General Inquiry: ', 'I have a question about:

• Department/Topic:
• Specific question:
• Context or background:
• Urgency level:', 'HelpCircle', 'general-inquiry', 0, 9, 1);

    PRINT 'Default quick templates inserted successfully';
END
GO
