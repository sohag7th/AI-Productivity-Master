# MongoDB Learning Guide: Basic to Advanced

## Table of Contents
1. [Getting Started](#getting-started)
2. [Basic Concepts](#basic-concepts)
3. [CRUD Operations](#crud-operations)
4. [Intermediate Topics](#intermediate-topics)
5. [Advanced Topics](#advanced-topics)
6. [Practical Projects](#practical-projects)
7. [Resources](#resources)

## Getting Started

### What is MongoDB?
MongoDB is a NoSQL document database that stores data in flexible, JSON-like documents. It's designed for scalability, performance, and ease of development.

### Key Features:
- Document-oriented storage
- Dynamic schemas
- Rich query language
- Horizontal scaling
- High availability
- Flexible data model

### Installation Options:
1. **Local Installation** - Download from MongoDB website
2. **Docker** - Use containerized MongoDB (recommended for learning)
3. **MongoDB Atlas** - Cloud-hosted MongoDB service
4. **Package Managers** - brew, apt, yum, etc.

## Basic Concepts

### 1. Database Structure
```
Database
├── Collections (like tables in SQL)
│   ├── Documents (like rows in SQL)
│   │   ├── Fields (like columns in SQL)
│   │   └── Values
```

### 2. Document Structure
Documents in MongoDB are BSON (Binary JSON) objects:
```json
{
  "_id": ObjectId("..."),
  "name": "John Doe",
  "age": 30,
  "email": "john@example.com",
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "zipcode": "10001"
  },
  "hobbies": ["reading", "swimming", "coding"]
}
```

### 3. Data Types
- String
- Number (Integer, Float, Decimal)
- Boolean
- Date
- ObjectId
- Array
- Object/Document
- null

## CRUD Operations

### Create (Insert)
```javascript
// Insert one document
db.users.insertOne({
  name: "Alice",
  age: 25,
  email: "alice@example.com"
});

// Insert multiple documents
db.users.insertMany([
  { name: "Bob", age: 30, email: "bob@example.com" },
  { name: "Charlie", age: 35, email: "charlie@example.com" }
]);
```

### Read (Find)
```javascript
// Find all documents
db.users.find();

// Find with criteria
db.users.find({ age: { $gte: 30 } });

// Find one document
db.users.findOne({ name: "Alice" });

// Projection (select specific fields)
db.users.find({}, { name: 1, email: 1, _id: 0 });

// Limit and sort
db.users.find().sort({ age: -1 }).limit(5);
```

### Update
```javascript
// Update one document
db.users.updateOne(
  { name: "Alice" },
  { $set: { age: 26 } }
);

// Update multiple documents
db.users.updateMany(
  { age: { $lt: 30 } },
  { $set: { category: "young" } }
);

// Upsert (insert if not exists)
db.users.updateOne(
  { email: "dave@example.com" },
  { $set: { name: "Dave", age: 28 } },
  { upsert: true }
);
```

### Delete
```javascript
// Delete one document
db.users.deleteOne({ name: "Alice" });

// Delete multiple documents
db.users.deleteMany({ age: { $lt: 25 } });
```

## Intermediate Topics

### 1. Query Operators
```javascript
// Comparison operators
db.users.find({ age: { $gt: 25, $lt: 35 } });
db.users.find({ name: { $in: ["Alice", "Bob"] } });
db.users.find({ age: { $ne: 30 } });

// Logical operators
db.users.find({
  $and: [
    { age: { $gte: 25 } },
    { age: { $lt: 35 } }
  ]
});

db.users.find({
  $or: [
    { age: { $lt: 25 } },
    { age: { $gt: 35 } }
  ]
});

// Element operators
db.users.find({ email: { $exists: true } });
db.users.find({ age: { $type: "number" } });

// Array operators
db.users.find({ hobbies: { $in: ["reading"] } });
db.users.find({ hobbies: { $all: ["reading", "coding"] } });
db.users.find({ hobbies: { $size: 3 } });
```

### 2. Indexing
```javascript
// Create index
db.users.createIndex({ email: 1 }); // ascending
db.users.createIndex({ age: -1 }); // descending
db.users.createIndex({ name: 1, age: -1 }); // compound index

// Text index for search
db.users.createIndex({ name: "text", email: "text" });
db.users.find({ $text: { $search: "alice" } });

// View indexes
db.users.getIndexes();

// Drop index
db.users.dropIndex({ email: 1 });
```

### 3. Aggregation Framework
```javascript
// Basic aggregation pipeline
db.users.aggregate([
  { $match: { age: { $gte: 25 } } },
  { $group: { 
    _id: "$department", 
    avgAge: { $avg: "$age" },
    count: { $sum: 1 }
  }},
  { $sort: { avgAge: -1 } }
]);

// Common aggregation stages
db.users.aggregate([
  { $project: { name: 1, age: 1, ageGroup: {
    $cond: { if: { $gte: ["$age", 30] }, then: "senior", else: "junior" }
  }}},
  { $group: { _id: "$ageGroup", count: { $sum: 1 } }}
]);
```

## Advanced Topics

### 1. Schema Design Patterns
```javascript
// One-to-One: Embedded documents
{
  _id: ObjectId("..."),
  name: "John Doe",
  profile: {
    bio: "Software developer",
    website: "johndoe.com"
  }
}

// One-to-Many: Array of subdocuments
{
  _id: ObjectId("..."),
  title: "Blog Post",
  comments: [
    { author: "Alice", text: "Great post!", date: ISODate() },
    { author: "Bob", text: "Thanks for sharing", date: ISODate() }
  ]
}

// Many-to-Many: References
{
  _id: ObjectId("..."),
  name: "John Doe",
  skills: [ObjectId("skill1"), ObjectId("skill2")]
}
```

### 2. Performance Optimization
```javascript
// Use explain() to analyze queries
db.users.find({ age: 30 }).explain("executionStats");

// Create efficient indexes
db.users.createIndex({ age: 1, name: 1 }); // compound index

// Use projection to limit returned fields
db.users.find({}, { name: 1, email: 1 });

// Limit results
db.users.find().limit(100);

// Use aggregation for complex operations
db.users.aggregate([
  { $match: { age: { $gte: 25 } } },
  { $limit: 1000 }
]);
```

### 3. Transactions (MongoDB 4.0+)
```javascript
// Multi-document transactions
const session = db.getMongo().startSession();
session.startTransaction();

try {
  db.accounts.updateOne(
    { _id: "account1" },
    { $inc: { balance: -100 } },
    { session }
  );
  
  db.accounts.updateOne(
    { _id: "account2" },
    { $inc: { balance: 100 } },
    { session }
  );
  
  session.commitTransaction();
} catch (error) {
  session.abortTransaction();
} finally {
  session.endSession();
}
```

### 4. Replication and Sharding
```javascript
// Replica Set configuration
rs.initiate({
  _id: "myReplicaSet",
  members: [
    { _id: 0, host: "localhost:27017" },
    { _id: 1, host: "localhost:27018" },
    { _id: 2, host: "localhost:27019" }
  ]
});

// Sharding
sh.enableSharding("myDatabase");
sh.shardCollection("myDatabase.users", { "userId": 1 });
```

## Learning Path Recommendations

### Beginner (Weeks 1-2)
1. Install MongoDB and learn basic concepts
2. Practice CRUD operations
3. Understand document structure and data types
4. Learn basic query operators

### Intermediate (Weeks 3-4)
1. Master aggregation framework
2. Learn indexing strategies
3. Understand schema design patterns
4. Practice with real-world datasets

### Advanced (Weeks 5-6)
1. Performance optimization techniques
2. Replication and high availability
3. Sharding for horizontal scaling
4. Security best practices

### Expert Level
1. MongoDB administration
2. Backup and recovery strategies
3. Monitoring and troubleshooting
4. Custom MongoDB drivers and tools

## Best Practices

1. **Schema Design**: Design for your query patterns
2. **Indexing**: Create indexes for frequently queried fields
3. **Data Validation**: Use schema validation rules
4. **Security**: Enable authentication and use roles
5. **Performance**: Monitor slow queries and optimize
6. **Backup**: Regular backups and disaster recovery plans

## Next Steps
1. Set up your development environment
2. Work through practical examples
3. Build real projects
4. Join MongoDB community and forums
5. Consider MongoDB certification