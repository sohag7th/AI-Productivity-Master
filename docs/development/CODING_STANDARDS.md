# Coding Standards & Best Practices

## Table of Contents
1. [General Principles](#general-principles)
2. [JavaScript/TypeScript Standards](#javascripttypescript-standards)
3. [React Best Practices](#react-best-practices)
4. [Backend/Node.js Standards](#backendnodejs-standards)
5. [Database Guidelines](#database-guidelines)
6. [Git & Version Control](#git--version-control)
7. [Testing Standards](#testing-standards)
8. [Documentation Requirements](#documentation-requirements)

## General Principles

### Code Quality Principles
1. **Readability**: Code should be self-documenting and easy to understand
2. **Maintainability**: Write code that can be easily modified and extended
3. **Performance**: Consider performance implications of your code
4. **Security**: Follow security best practices
5. **Consistency**: Follow established patterns and conventions

### SOLID Principles
- **S**ingle Responsibility Principle
- **O**pen/Closed Principle
- **L**iskov Substitution Principle
- **I**nterface Segregation Principle
- **D**ependency Inversion Principle

## JavaScript/TypeScript Standards

### Naming Conventions
```javascript
// Variables and functions: camelCase
const userName = 'john_doe';
const getUserData = () => {};

// Constants: UPPER_SNAKE_CASE
const API_BASE_URL = 'https://api.example.com';
const MAX_RETRY_ATTEMPTS = 3;

// Classes: PascalCase
class UserService {}
class TaskManager {}

// Files: kebab-case
// user-service.js
// task-manager.ts
// api-client.test.js

// Interfaces (TypeScript): PascalCase with 'I' prefix (optional)
interface IUserRepository {}
interface UserData {}

// Types (TypeScript): PascalCase
type TaskStatus = 'todo' | 'in_progress' | 'done';
type ApiResponse<T> = {
  data: T;
  success: boolean;
  message?: string;
};
```

### Function Design
```javascript
// Good: Pure functions when possible
const calculateTotal = (items) => {
  return items.reduce((sum, item) => sum + item.price, 0);
};

// Good: Clear function names
const isUserAuthenticated = (user) => {
  return user && user.token && !isTokenExpired(user.token);
};

// Good: Single responsibility
const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

// Avoid: Complex nested functions
// Bad
const processUserData = (userData) => {
  if (userData) {
    if (userData.email) {
      if (validateEmail(userData.email)) {
        // ... more nested logic
      }
    }
  }
};

// Good: Early returns
const processUserData = (userData) => {
  if (!userData) return null;
  if (!userData.email) return null;
  if (!validateEmail(userData.email)) return null;
  
  // Main logic here
  return processedData;
};
```

### Error Handling
```javascript
// Good: Explicit error handling
const fetchUserData = async (userId) => {
  try {
    const response = await api.get(`/users/${userId}`);
    return { data: response.data, error: null };
  } catch (error) {
    logger.error('Failed to fetch user data', { userId, error });
    return { data: null, error: error.message };
  }
};

// Good: Custom error classes
class ValidationError extends Error {
  constructor(message, field) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}

// Good: Error boundaries for React
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    logger.error('React Error Boundary caught an error', { error, errorInfo });
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback />;
    }
    return this.props.children;
  }
}
```

### TypeScript Specific
```typescript
// Good: Use interfaces for object shapes
interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  createdAt: Date;
}

// Good: Use union types for constrained values
type TaskPriority = 'low' | 'medium' | 'high' | 'urgent';
type TaskStatus = 'todo' | 'in_progress' | 'review' | 'done';

// Good: Generic types for reusability
interface ApiResponse<T> {
  data: T;
  success: boolean;
  message?: string;
  timestamp: Date;
}

// Good: Utility types
type CreateUserRequest = Omit<User, 'id' | 'createdAt'>;
type UpdateUserRequest = Partial<Pick<User, 'name' | 'avatar'>>;

// Good: Use enums for related constants
enum TaskPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent'
}
```

## React Best Practices

### Component Structure
```tsx
// Good: Functional components with hooks
import React, { useState, useEffect, useCallback } from 'react';
import { User } from '../types/user';

interface UserProfileProps {
  userId: string;
  onUserUpdate?: (user: User) => void;
}

export const UserProfile: React.FC<UserProfileProps> = ({ 
  userId, 
  onUserUpdate 
}) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Memoize callbacks to prevent unnecessary re-renders
  const handleUserUpdate = useCallback((updatedUser: User) => {
    setUser(updatedUser);
    onUserUpdate?.(updatedUser);
  }, [onUserUpdate]);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        setLoading(true);
        const userData = await userService.getUser(userId);
        setUser(userData);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId]);

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error} />;
  if (!user) return <UserNotFound />;

  return (
    <div className="user-profile">
      {/* Component JSX */}
    </div>
  );
};
```

### Hooks Best Practices
```tsx
// Good: Custom hooks for reusable logic
const useApi = <T>(url: string) => {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await fetch(url);
        if (!response.ok) throw new Error('Network response was not ok');
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [url]);

  return { data, loading, error };
};

// Good: Use useCallback for event handlers
const TaskItem: React.FC<TaskItemProps> = ({ task, onUpdate }) => {
  const handleStatusChange = useCallback((newStatus: TaskStatus) => {
    onUpdate({ ...task, status: newStatus });
  }, [task, onUpdate]);

  const handlePriorityChange = useCallback((newPriority: TaskPriority) => {
    onUpdate({ ...task, priority: newPriority });
  }, [task, onUpdate]);

  return (
    <div className="task-item">
      {/* Component JSX */}
    </div>
  );
};
```

### State Management
```tsx
// Good: Context for shared state
interface AppState {
  user: User | null;
  theme: 'light' | 'dark';
  notifications: Notification[];
}

const AppContext = React.createContext<{
  state: AppState;
  dispatch: React.Dispatch<AppAction>;
} | null>(null);

const useAppContext = () => {
  const context = React.useContext(AppContext);
  if (!context) {
    throw new Error('useAppContext must be used within AppProvider');
  }
  return context;
};

// Good: React Query for server state
const useUserTasks = (userId: string) => {
  return useQuery(['user-tasks', userId], () => 
    taskService.getUserTasks(userId), {
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
  });
};
```

## Backend/Node.js Standards

### Project Structure
```
src/
├── controllers/         # Route handlers
├── services/           # Business logic
├── models/            # Data models
├── middleware/        # Custom middleware
├── routes/            # Route definitions
├── utils/             # Utility functions
├── config/            # Configuration
├── types/             # TypeScript types
└── tests/             # Test files
```

### Controller Pattern
```javascript
// Good: Thin controllers, fat services
class TaskController {
  async createTask(req, res, next) {
    try {
      const taskData = req.body;
      const userId = req.user.id;
      
      const task = await taskService.createTask(taskData, userId);
      
      res.status(201).json({
        success: true,
        data: task,
        message: 'Task created successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  async getTasks(req, res, next) {
    try {
      const { teamId, status, priority } = req.query;
      const userId = req.user.id;
      
      const tasks = await taskService.getUserTasks(userId, {
        teamId,
        status,
        priority
      });
      
      res.json({
        success: true,
        data: tasks,
        meta: {
          count: tasks.length,
          page: req.query.page || 1
        }
      });
    } catch (error) {
      next(error);
    }
  }
}
```

### Service Layer
```javascript
// Good: Business logic in services
class TaskService {
  constructor(taskRepository, userRepository, activityService) {
    this.taskRepository = taskRepository;
    this.userRepository = userRepository;
    this.activityService = activityService;
  }

  async createTask(taskData, userId) {
    // Validate input
    const validatedData = await this.validateTaskData(taskData);
    
    // Check permissions
    await this.checkTeamMembership(userId, validatedData.teamId);
    
    // Create task
    const task = await this.taskRepository.create({
      ...validatedData,
      createdBy: userId,
      status: 'todo'
    });
    
    // Log activity
    await this.activityService.logActivity({
      userId,
      teamId: task.teamId,
      action: 'task_created',
      entityType: 'task',
      entityId: task.id,
      details: { taskTitle: task.title }
    });
    
    return task;
  }

  async validateTaskData(taskData) {
    const schema = Joi.object({
      title: Joi.string().min(3).max(255).required(),
      description: Joi.string().max(1000).optional(),
      teamId: Joi.string().uuid().required(),
      assignedTo: Joi.string().uuid().optional(),
      priority: Joi.string().valid('low', 'medium', 'high', 'urgent').default('medium'),
      dueDate: Joi.date().min('now').optional()
    });

    const { error, value } = schema.validate(taskData);
    if (error) {
      throw new ValidationError(error.details[0].message);
    }

    return value;
  }
}
```

### Middleware
```javascript
// Good: Reusable middleware
const authMiddleware = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ 
        success: false, 
        message: 'No token provided' 
      });
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId);
    
    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Invalid token' 
      });
    }
    
    req.user = user;
    next();
  } catch (error) {
    res.status(401).json({ 
      success: false, 
      message: 'Invalid token' 
    });
  }
};

const validateSchema = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      errors: error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }))
    });
  }
  next();
};
```

## Database Guidelines

### Query Optimization
```sql
-- Good: Use appropriate indexes
CREATE INDEX idx_tasks_team_status ON tasks(team_id, status);
CREATE INDEX idx_tasks_assigned_user ON tasks(assigned_to, status);

-- Good: Use LIMIT for large datasets
SELECT t.*, u.name as assigned_name 
FROM tasks t 
LEFT JOIN users u ON t.assigned_to = u.id 
WHERE t.team_id = $1 
ORDER BY t.created_at DESC 
LIMIT 20 OFFSET $2;

-- Good: Use EXISTS instead of IN for large datasets
SELECT * FROM teams t 
WHERE EXISTS (
  SELECT 1 FROM team_members tm 
  WHERE tm.team_id = t.id AND tm.user_id = $1
);
```

### Migration Best Practices
```sql
-- Good: Always use transactions
BEGIN;

-- Add new column with default value
ALTER TABLE tasks ADD COLUMN estimated_hours INTEGER DEFAULT 0;

-- Update existing data if needed
UPDATE tasks SET estimated_hours = 1 WHERE estimated_hours IS NULL;

-- Add constraints after data is updated
ALTER TABLE tasks ALTER COLUMN estimated_hours SET NOT NULL;

COMMIT;
```

## Git & Version Control

### Commit Messages
```bash
# Good: Conventional commit format
feat: add task comments functionality
fix: resolve authentication token expiration issue
docs: update API documentation for task endpoints
refactor: extract user validation logic into service
test: add unit tests for task creation

# Good: Detailed commit messages
feat: implement real-time notifications

- Add WebSocket connection for live updates
- Create notification component with toast display
- Integrate with activity feed for team updates
- Add user preferences for notification types

Closes #123
```

### Branch Naming
```bash
# Feature branches
feature/task-comments
feature/user-notifications
feature/team-permissions

# Bug fixes
fix/authentication-token-refresh
fix/task-assignment-validation

# Hotfixes
hotfix/security-vulnerability-patch

# Release branches
release/v1.2.0
```

### Pull Request Guidelines
1. **Clear Title**: Summarize the change in the title
2. **Description**: Explain what and why, not just how
3. **Testing**: Include testing instructions
4. **Screenshots**: For UI changes
5. **Breaking Changes**: Highlight any breaking changes
6. **Checklist**: Use PR template checklist

## Testing Standards

### Unit Testing
```javascript
// Good: Test behavior, not implementation
describe('TaskService', () => {
  describe('createTask', () => {
    it('should create a task with valid data', async () => {
      // Arrange
      const taskData = {
        title: 'Test Task',
        teamId: 'team-123',
        priority: 'high'
      };
      const userId = 'user-456';

      // Act
      const result = await taskService.createTask(taskData, userId);

      // Assert
      expect(result).toHaveProperty('id');
      expect(result.title).toBe(taskData.title);
      expect(result.createdBy).toBe(userId);
      expect(result.status).toBe('todo');
    });

    it('should throw ValidationError for invalid data', async () => {
      // Arrange
      const invalidTaskData = { title: '' };
      const userId = 'user-456';

      // Act & Assert
      await expect(
        taskService.createTask(invalidTaskData, userId)
      ).rejects.toThrow(ValidationError);
    });
  });
});
```

### Integration Testing
```javascript
// Good: Test API endpoints
describe('POST /api/tasks', () => {
  it('should create a task when authenticated', async () => {
    const taskData = {
      title: 'Integration Test Task',
      teamId: testTeam.id,
      priority: 'medium'
    };

    const response = await request(app)
      .post('/api/tasks')
      .set('Authorization', `Bearer ${authToken}`)
      .send(taskData)
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.data.title).toBe(taskData.title);
  });
});
```

## Documentation Requirements

### Code Documentation
```javascript
/**
 * Creates a new task with the provided data
 * @param {Object} taskData - The task data
 * @param {string} taskData.title - Task title (3-255 characters)
 * @param {string} taskData.teamId - Team UUID
 * @param {string} [taskData.assignedTo] - User UUID to assign task to
 * @param {string} [taskData.priority='medium'] - Task priority
 * @param {Date} [taskData.dueDate] - Task due date
 * @param {string} userId - ID of user creating the task
 * @returns {Promise<Object>} The created task
 * @throws {ValidationError} When task data is invalid
 * @throws {PermissionError} When user lacks team access
 */
async function createTask(taskData, userId) {
  // Implementation
}
```

### API Documentation
```yaml
# OpenAPI documentation
/api/tasks:
  post:
    summary: Create a new task
    description: Creates a new task within a team
    tags:
      - Tasks
    security:
      - bearerAuth: []
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/CreateTaskRequest'
    responses:
      201:
        description: Task created successfully
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/TaskResponse'
```

### README Requirements
Every significant feature/module should have:
1. **Purpose**: What does this module do?
2. **Setup**: How to run/install
3. **Usage**: Basic usage examples
4. **Configuration**: Environment variables/config options
5. **Testing**: How to run tests
6. **Contributing**: How to contribute to the module

## Code Review Checklist

### Before Submitting PR
- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] No console.log or debugging code
- [ ] Error handling implemented
- [ ] Performance considerations addressed
- [ ] Security implications reviewed
- [ ] Documentation updated

### Reviewer Checklist
- [ ] Code is readable and maintainable
- [ ] Logic is correct and handles edge cases
- [ ] Tests adequately cover the changes
- [ ] No security vulnerabilities introduced
- [ ] Performance impact is acceptable
- [ ] Breaking changes are documented
- [ ] Code follows established patterns