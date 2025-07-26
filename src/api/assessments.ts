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
      const { assessmentId, action } = req.query;

      if (assessmentId && action === 'questions') {
        // Get questions for a specific assessment
        const questions = dbUtils.getQuestionsByAssessment(Number(assessmentId));
        const questionsWithParsedData = questions.map((q: any) => ({
          ...q,
          options: JSON.parse(q.options || '[]'),
          correctAnswers: JSON.parse(q.correct_answers || '[]')
        }));
        return res.status(200).json(questionsWithParsedData);
      }

      if (assessmentId) {
        // Get specific assessment
        const { db } = await import('../lib/database');
        const stmt = db.prepare(`
          SELECT a.*, m.title as module_name, s.title as section_name,
                 COUNT(q.id) as question_count,
                 SUM(q.points) as total_points
          FROM assessments a
          JOIN modules m ON a.module_id = m.id
          LEFT JOIN sections s ON a.section_id = s.id
          LEFT JOIN questions q ON a.id = q.assessment_id
          WHERE a.id = ? AND a.is_active = 1
          GROUP BY a.id
        `);
        
        const assessment = stmt.get(Number(assessmentId)) as any;
        if (!assessment) {
          return res.status(404).json({ error: 'Assessment not found' });
        }

        // Get user progress for this assessment
        const attemptsStmt = db.prepare(`
          SELECT * FROM assessment_attempts 
          WHERE user_id = ? AND assessment_id = ? 
          ORDER BY started_at DESC
        `);
        const attempts = attemptsStmt.all(decoded.userId, assessment.id);

        const userProgress = attempts.length > 0 ? {
          attempts: attempts.length,
          lastScore: attempts[0].status === 'completed' ? attempts[0].score : null,
          bestScore: Math.max(...attempts.filter(a => a.status === 'completed').map(a => a.score), 0),
          status: attempts[0].status === 'completed' ? (attempts[0].passed ? 'completed' : 'failed') : 'not-started',
          lastAttempt: attempts[0].started_at
        } : null;

        return res.status(200).json({
          ...assessment,
          userProgress
        });
      }

      // Get all assessments
      const assessments = dbUtils.getAllAssessments();
      
      // Add user progress for each assessment
      const { db } = await import('../lib/database');
      const assessmentsWithProgress = assessments.map((assessment: any) => {
        const attemptsStmt = db.prepare(`
          SELECT * FROM assessment_attempts 
          WHERE user_id = ? AND assessment_id = ? 
          ORDER BY started_at DESC
        `);
        const attempts = attemptsStmt.all(decoded.userId, assessment.id);

        const userProgress = attempts.length > 0 ? {
          attempts: attempts.length,
          lastScore: attempts[0].status === 'completed' ? attempts[0].score : null,
          bestScore: Math.max(...attempts.filter((a: any) => a.status === 'completed').map((a: any) => a.score), 0),
          status: attempts[0].status === 'completed' ? (attempts[0].passed ? 'completed' : 'failed') : 'not-started',
          lastAttempt: attempts[0].started_at
        } : null;

        return {
          ...assessment,
          userProgress
        };
      });

      return res.status(200).json(assessmentsWithProgress);
    }

    if (req.method === 'POST') {
      // Check permissions
      if (!['Admin', 'QA'].includes(decoded.role)) {
        return res.status(403).json({ error: 'Insufficient permissions' });
      }

      const { action, assessmentId } = req.query;

      if (action === 'questions' && assessmentId) {
        // Create a new question
        const { type, questionText, options, correctAnswers, explanation, points, orderIndex } = req.body;
        
        if (!type || !questionText) {
          return res.status(400).json({ error: 'Question type and text are required' });
        }

        const questionData = {
          assessmentId: Number(assessmentId),
          type,
          questionText,
          options: options || [],
          correctAnswers: correctAnswers || [],
          explanation: explanation || '',
          points: points || 1,
          orderIndex: orderIndex || 1
        };

        const result = dbUtils.createQuestion(questionData);
        return res.status(201).json({ id: result.lastInsertRowid, message: 'Question created successfully' });
      }

      // Create new assessment
      const { title, description, moduleId, sectionId, passingScore, timeLimit, maxAttempts, isRequired, triggerType } = req.body;
      
      if (!title || !description || !moduleId) {
        return res.status(400).json({ error: 'Title, description, and module are required' });
      }

      const assessmentData = {
        title,
        description,
        moduleId: Number(moduleId),
        sectionId: sectionId ? Number(sectionId) : null,
        passingScore: passingScore || 70,
        timeLimit: timeLimit || 30,
        maxAttempts: maxAttempts || 3,
        isRequired: isRequired || false,
        triggerType: triggerType || 'section_completion'
      };

      const result = dbUtils.createAssessment(assessmentData);
      return res.status(201).json({ id: result.lastInsertRowid, message: 'Assessment created successfully' });
    }

    if (req.method === 'DELETE') {
      // Check permissions
      if (!['Admin', 'QA'].includes(decoded.role)) {
        return res.status(403).json({ error: 'Insufficient permissions' });
      }

      const { questionId } = req.query;

      if (questionId) {
        // Delete question
        const result = dbUtils.deleteQuestion(Number(questionId));
        if (result.changes === 0) {
          return res.status(404).json({ error: 'Question not found' });
        }
        return res.status(200).json({ message: 'Question deleted successfully' });
      }

      return res.status(400).json({ error: 'Question ID required' });
    }

    return res.status(405).json({ error: 'Method not allowed' });
  } catch (error) {
    console.error('Assessments API error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}