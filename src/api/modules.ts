import { NextApiRequest, NextApiResponse } from 'next';
import { dbUtils } from '../lib/database';
import { AuthService } from '../lib/auth';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    // Verify authentication
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.substring(7);
    const decoded = AuthService.verifyToken(token);
    
    if (!decoded) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    if (req.method === 'GET') {
      const modules = dbUtils.getAllModules();
      
      // Add progress information for each module
      const modulesWithProgress = modules.map((module: any) => {
        const progress = dbUtils.getUserModuleProgress(decoded.userId, module.id);
        return {
          ...module,
          progress: progress?.completion_percentage || 0,
          isCompleted: progress?.is_completed || false,
          prerequisites: JSON.parse(module.prerequisites || '[]'),
          learningObjectives: JSON.parse(module.learning_objectives || '[]')
        };
      });

      return res.status(200).json(modulesWithProgress);
    }

    if (req.method === 'POST') {
      // Check if user has permission to create modules
      if (!['Admin', 'QA'].includes(decoded.role)) {
        return res.status(403).json({ error: 'Insufficient permissions' });
      }

      const { title, description, icon, estimatedTime, difficulty, prerequisites, learningObjectives, orderIndex } = req.body;
      
      if (!title || !description || !icon) {
        return res.status(400).json({ error: 'Required fields missing' });
      }

      const { db } = await import('../lib/database');
      const stmt = db.prepare(`
        INSERT INTO modules (title, description, icon, estimated_time, difficulty, prerequisites, learning_objectives, order_index)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `);

      const result = stmt.run(
        title,
        description,
        icon,
        estimatedTime || '1 hour',
        difficulty || 'Beginner',
        JSON.stringify(prerequisites || []),
        JSON.stringify(learningObjectives || []),
        orderIndex || 999
      );

      return res.status(201).json({ id: result.lastInsertRowid, message: 'Module created successfully' });
    }

    return res.status(405).json({ error: 'Method not allowed' });
  } catch (error) {
    console.error('Modules API error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}