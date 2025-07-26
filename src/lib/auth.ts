import { dbUtils } from './database';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production';
const JWT_EXPIRES_IN = '7d';

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  department: string;
  role: string;
  avatar?: string;
  isActive: boolean;
  joinDate: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  department: string;
  role?: string;
}

export interface AuthResponse {
  user: User;
  token: string;
  expiresAt: Date;
}

export class AuthService {
  static async login(credentials: LoginCredentials): Promise<AuthResponse | null> {
    try {
      const user = dbUtils.getUserByEmail(credentials.email) as any;
      
      if (!user || !user.is_active) {
        return null;
      }

      // Verify password
      const isValidPassword = await bcrypt.compare(credentials.password, user.password_hash);
      if (!isValidPassword) {
        return null;
      }

      // Generate JWT token
      const token = jwt.sign(
        { 
          userId: user.id, 
          email: user.email, 
          role: user.role 
        },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
      );

      const userResponse: User = {
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        department: user.department,
        role: user.role,
        avatar: user.avatar,
        isActive: user.is_active,
        joinDate: user.join_date
      };

      return {
        user: userResponse,
        token,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
      };
    } catch (error) {
      console.error('Login error:', error);
      return null;
    }
  }

  static async register(userData: RegisterData): Promise<AuthResponse | null> {
    try {
      // Check if user already exists
      const existingUser = dbUtils.getUserByEmail(userData.email);
      if (existingUser) {
        throw new Error('User already exists with this email');
      }

      // Hash password
      const passwordHash = await bcrypt.hash(userData.password, 12);

      // Generate user ID
      const userId = `user-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

      // Create user
      const newUserData = {
        id: userId,
        email: userData.email,
        passwordHash,
        firstName: userData.firstName,
        lastName: userData.lastName,
        department: userData.department,
        role: userData.role || 'User'
      };

      dbUtils.createUser(newUserData);

      // Login the newly created user
      return await this.login({
        email: userData.email,
        password: userData.password
      });
    } catch (error) {
      console.error('Registration error:', error);
      return null;
    }
  }

  static verifyToken(token: string): any {
    try {
      return jwt.verify(token, JWT_SECRET);
    } catch (error) {
      return null;
    }
  }

  static async getCurrentUser(userId: string): Promise<User | null> {
    try {
      const user = dbUtils.getUserByEmail('') as any; // We need to modify this to get by ID
      // For now, let's create a simple query
      const { db } = await import('./database');
      const stmt = db.prepare('SELECT * FROM users WHERE id = ? AND is_active = 1');
      const userData = stmt.get(userId) as any;

      if (!userData) return null;

      return {
        id: userData.id,
        email: userData.email,
        firstName: userData.first_name,
        lastName: userData.last_name,
        department: userData.department,
        role: userData.role,
        avatar: userData.avatar,
        isActive: userData.is_active,
        joinDate: userData.join_date
      };
    } catch (error) {
      console.error('Get current user error:', error);
      return null;
    }
  }
}