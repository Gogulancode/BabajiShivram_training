import { initializeDatabase } from './database';

// Initialize database when the module is imported
try {
  initializeDatabase();
  console.log('✅ SQLite database initialized successfully!');
} catch (error) {
  console.error('❌ Failed to initialize database:', error);
}

export { db, dbUtils } from './database';