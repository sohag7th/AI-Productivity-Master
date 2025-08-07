# Getting Started with MongoDB - Quick Start Guide

## 🚀 Welcome to Your MongoDB Learning Journey!

This guide will help you set up MongoDB and start learning from basic to advanced concepts.

## 📋 Prerequisites

- Docker installed on your system
- Basic understanding of databases (helpful but not required)
- A terminal/command prompt
- A code editor (VS Code recommended)

## 🛠️ Step 1: Environment Setup

### Option A: Using Docker (Recommended for Learning)

1. **Clone or create the learning environment:**
   ```bash
   # Navigate to your learning directory
   cd /workspace
   
   # Start MongoDB with Docker Compose
   docker-compose up -d
   ```

2. **Verify MongoDB is running:**
   ```bash
   # Check if containers are running
   docker ps
   
   # You should see containers: mongodb_learning and mongo_express
   ```

3. **Access MongoDB Shell:**
   ```bash
   # Connect to MongoDB shell
   docker exec -it mongodb_learning mongosh -u admin -p password123
   ```

4. **Access Web Interface (Optional):**
   - Open browser: `http://localhost:8081`
   - This gives you a visual interface to explore your data

### Option B: Local Installation

1. **Download MongoDB Community Edition:**
   - Visit: https://www.mongodb.com/try/download/community
   - Follow installation instructions for your OS

2. **Start MongoDB:**
   ```bash
   # On Linux/Mac
   sudo systemctl start mongod
   
   # On Windows
   net start MongoDB
   ```

## 📚 Step 2: Your Learning Path

### Week 1-2: Fundamentals
**Goal:** Understand basic concepts and CRUD operations

1. **Read the basics:**
   - Open `mongodb-learning-guide.md`
   - Focus on "Basic Concepts" and "CRUD Operations" sections

2. **Hands-on practice:**
   - Open `mongodb-exercises.md`
   - Complete Exercise 1: Basic CRUD Operations
   - Work with the sample data that's already loaded

3. **Daily practice (30 minutes):**
   ```javascript
   // Connect to learning database
   use learning_db
   
   // Practice these operations daily:
   db.users.find()                    // View all users
   db.users.find({age: {$gt: 30}})   // Find users over 30
   db.products.find({category: "Electronics"})  // Find electronics
   ```

### Week 3-4: Intermediate Concepts
**Goal:** Master queries, indexing, and aggregation

1. **Study topics:**
   - Query operators and complex queries
   - Indexing strategies
   - Aggregation framework

2. **Practice exercises:**
   - Complete Exercises 2-3 in `mongodb-exercises.md`
   - Focus on aggregation pipelines

3. **Build a small project:**
   - Create a blog database with posts and comments
   - Practice different relationship patterns

### Week 5-6: Advanced Topics
**Goal:** Performance optimization and scaling

1. **Study advanced concepts:**
   - Open `advanced-mongodb.md`
   - Focus on schema design patterns
   - Learn performance optimization techniques

2. **Advanced practice:**
   - Complete Exercises 4-5 in `mongodb-exercises.md`
   - Work on Challenge Exercises

## 🎯 Step 3: First Hands-On Session

Let's start with your first MongoDB session:

### 1. Connect to MongoDB
```bash
# Start the containers if not already running
docker-compose up -d

# Connect to MongoDB shell
docker exec -it mongodb_learning mongosh -u admin -p password123

# Switch to learning database
use learning_db
```

### 2. Explore Sample Data
```javascript
// See what collections we have
show collections

// Look at users
db.users.find().pretty()

// Count documents
db.users.countDocuments()
db.products.countDocuments()
db.orders.countDocuments()
```

### 3. Try Basic Queries
```javascript
// Find Engineering department users
db.users.find({department: "Engineering"})

// Find products under $100
db.products.find({price: {$lt: 100}})

// Find active users, show only name and email
db.users.find({isActive: true}, {name: 1, email: 1, _id: 0})
```

### 4. Your First Insert
```javascript
// Add yourself as a user
db.users.insertOne({
  name: "Your Name",
  age: 25,
  email: "your.email@example.com",
  department: "Learning",
  salary: 50000,
  skills: ["MongoDB", "Learning"],
  address: {
    street: "123 Learning St",
    city: "Knowledge City",
    state: "Education",
    zipcode: "12345"
  },
  joinDate: new Date(),
  isActive: true
})

// Find your record
db.users.findOne({email: "your.email@example.com"})
```

## 📖 Step 4: Study Resources

### Files in Your Learning Environment:
1. **`mongodb-learning-guide.md`** - Complete theoretical guide
2. **`mongodb-exercises.md`** - Hands-on exercises with solutions
3. **`advanced-mongodb.md`** - Advanced topics and patterns
4. **`docker-compose.yml`** - Environment setup
5. **`mongo-init/init.js`** - Sample data initialization

### External Resources:
1. **MongoDB University** - Free online courses
2. **MongoDB Documentation** - Official reference
3. **MongoDB Compass** - Visual database tool
4. **Stack Overflow** - Community support

## 🎯 Weekly Goals and Milestones

### Week 1: Foundation
- [ ] Set up MongoDB environment
- [ ] Understand document structure
- [ ] Master basic CRUD operations
- [ ] Complete Exercise 1

### Week 2: Queries
- [ ] Learn query operators
- [ ] Practice complex queries
- [ ] Understand projections and sorting
- [ ] Complete Exercise 2

### Week 3: Aggregation
- [ ] Master aggregation framework
- [ ] Build complex pipelines
- [ ] Practice grouping and calculations
- [ ] Complete Exercise 3

### Week 4: Indexing
- [ ] Understand index types
- [ ] Create and analyze indexes
- [ ] Learn performance optimization
- [ ] Complete Exercise 4

### Week 5: Advanced Patterns
- [ ] Study schema design patterns
- [ ] Learn about relationships
- [ ] Practice with real-world scenarios
- [ ] Complete Exercise 5

### Week 6: Production Ready
- [ ] Security best practices
- [ ] Monitoring and troubleshooting
- [ ] Backup and recovery
- [ ] Complete Challenge Exercises

## 🔧 Troubleshooting

### Common Issues:

1. **Docker container won't start:**
   ```bash
   # Check if ports are in use
   docker-compose down
   docker-compose up -d
   ```

2. **Can't connect to MongoDB:**
   ```bash
   # Check container status
   docker ps
   
   # Check logs
   docker logs mongodb_learning
   ```

3. **Forgot to switch to learning database:**
   ```javascript
   // Always use learning_db for exercises
   use learning_db
   ```

4. **Lost sample data:**
   ```bash
   # Recreate containers to reload sample data
   docker-compose down -v
   docker-compose up -d
   ```

## 📝 Tips for Effective Learning

1. **Practice daily:** Even 15-30 minutes of practice is better than long irregular sessions
2. **Use explain():** Always analyze your queries to understand performance
3. **Experiment:** Try variations of examples to deepen understanding
4. **Build projects:** Apply concepts to real-world scenarios
5. **Join communities:** MongoDB community forums, Discord, Reddit
6. **Take notes:** Document your learning journey and key insights

## 🎉 Ready to Start?

You now have everything you need to begin your MongoDB journey! 

**Next steps:**
1. Set up your environment using the Docker setup
2. Complete your first hands-on session above
3. Start with Week 1 goals
4. Work through the exercises systematically

**Remember:** Learning MongoDB is a journey, not a race. Take your time, practice regularly, and don't hesitate to revisit concepts as needed.

Happy learning! 🚀

---

## Quick Reference Commands

```bash
# Environment
docker-compose up -d                    # Start MongoDB
docker-compose down                     # Stop MongoDB
docker exec -it mongodb_learning mongosh -u admin -p password123  # Connect

# In MongoDB Shell
use learning_db                         # Switch database
show collections                        # List collections
db.users.find().pretty()              # View data nicely formatted
db.users.find().explain()             # Analyze query performance
exit                                   # Exit MongoDB shell
```