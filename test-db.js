// Simple test to check if the database can be initialized
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { readFileSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

console.log('Testing database initialization...');

try {
  // Try to read the database file to check if the modules are properly defined
  const dbFilePath = join(__dirname, 'src', 'lib', 'database.ts');
  const dbContent = readFileSync(dbFilePath, 'utf8');
  
  // Check if our new modules are in the file
  const moduleNames = [
    'CB – Imports',
    'Freight Forwarding',
    'NBCPL',
    'Company Services',
    'CB – Exports',
    'Contracts',
    'SEZ',
    'Ops Accounting',
    'Container Movement',
    'CRM',
    'Babaji Transport',
    'Additional Job',
    'MIS',
    'Essential Certificate',
    'Equipment Hire',
    'Public Notice',
    'Project'
  ];
  
  let foundModules = 0;
  moduleNames.forEach(name => {
    if (dbContent.includes(name)) {
      foundModules++;
      console.log(`✅ Found module: ${name}`);
    } else {
      console.log(`❌ Missing module: ${name}`);
    }
  });
  
  console.log(`\n📊 Summary: Found ${foundModules}/${moduleNames.length} modules in database.ts`);
  
  if (foundModules === moduleNames.length) {
    console.log('🎉 All modules have been successfully added to the database configuration!');
  } else {
    console.log('⚠️  Some modules are missing from the database configuration.');
  }
  
} catch (error) {
  console.error('❌ Error:', error.message);
}
