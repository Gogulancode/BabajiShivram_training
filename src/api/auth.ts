import { NextApiRequest, NextApiResponse } from 'next';
import { AuthService } from '../lib/auth';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'POST') {
    const { action } = req.query;

    try {
      if (action === 'login') {
        const { email, password } = req.body;
        
        if (!email || !password) {
          return res.status(400).json({ error: 'Email and password are required' });
        }

        const result = await AuthService.login({ email, password });
        
        if (!result) {
          return res.status(401).json({ error: 'Invalid credentials' });
        }

        return res.status(200).json(result);
      }

      if (action === 'register') {
        const { email, password, firstName, lastName, department, role } = req.body;
        
        if (!email || !password || !firstName || !lastName) {
          return res.status(400).json({ error: 'Required fields missing' });
        }

        const result = await AuthService.register({
          email,
          password,
          firstName,
          lastName,
          department: department || '',
          role: role || 'User'
        });
        
        if (!result) {
          return res.status(400).json({ error: 'Registration failed' });
        }

        return res.status(201).json(result);
      }

      return res.status(400).json({ error: 'Invalid action' });
    } catch (error) {
      console.error('Auth API error:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  }

  if (req.method === 'GET') {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'No token provided' });
      }

      const token = authHeader.substring(7);
      const decoded = AuthService.verifyToken(token);
      
      if (!decoded) {
        return res.status(401).json({ error: 'Invalid token' });
      }

      const user = await AuthService.getCurrentUser(decoded.userId);
      
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      return res.status(200).json({ user });
    } catch (error) {
      console.error('Auth verification error:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}