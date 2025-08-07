# MongoDB Hands-On Exercises

## Prerequisites
1. Start MongoDB using Docker: `docker-compose up -d`
2. Access MongoDB shell: `docker exec -it mongodb_learning mongosh -u admin -p password123`
3. Switch to learning database: `use learning_db`

## Exercise 1: Basic CRUD Operations (Beginner)

### 1.1 Find Operations
```javascript
// Find all users
db.users.find();

// Find users in Engineering department
db.users.find({ department: "Engineering" });

// Find users older than 30
db.users.find({ age: { $gt: 30 } });

// Find active users with projection (only name and email)
db.users.find({ isActive: true }, { name: 1, email: 1, _id: 0 });

// Find users sorted by age (descending)
db.users.find().sort({ age: -1 });

// Find first 3 users
db.users.find().limit(3);
```

### 1.2 Insert Operations
```javascript
// Insert a new user
db.users.insertOne({
  name: "Frank Miller",
  age: 29,
  email: "frank@example.com",
  department: "Sales",
  salary: 55000,
  skills: ["Sales", "CRM", "Communication"],
  address: {
    street: "789 Sales St",
    city: "Chicago",
    state: "IL",
    zipcode: "60601"
  },
  joinDate: new Date(),
  isActive: true
});

// Insert multiple products
db.products.insertMany([
  {
    name: "Mechanical Keyboard",
    category: "Electronics",
    price: 89.99,
    stock: 75,
    tags: ["keyboard", "mechanical", "gaming"],
    specifications: {
      switches: "Cherry MX Blue",
      backlight: "RGB",
      connectivity: "USB-C"
    },
    ratings: [5, 4, 5],
    createdAt: new Date()
  },
  {
    name: "Standing Desk",
    category: "Furniture",
    price: 399.99,
    stock: 15,
    tags: ["desk", "standing", "adjustable"],
    specifications: {
      material: "Bamboo",
      adjustable: true,
      maxHeight: "48 inches"
    },
    ratings: [5, 5, 4, 5],
    createdAt: new Date()
  }
]);
```

### 1.3 Update Operations
```javascript
// Update a user's salary
db.users.updateOne(
  { email: "frank@example.com" },
  { $set: { salary: 60000 } }
);

// Add a skill to all Engineering users
db.users.updateMany(
  { department: "Engineering" },
  { $addToSet: { skills: "Problem Solving" } }
);

// Increment all product prices by 10%
db.products.updateMany(
  {},
  { $mul: { price: 1.1 } }
);
```

### 1.4 Delete Operations
```javascript
// Delete inactive users
db.users.deleteMany({ isActive: false });

// Delete a specific product
db.products.deleteOne({ name: "Wireless Mouse" });
```

## Exercise 2: Query Operators (Intermediate)

### 2.1 Comparison Operators
```javascript
// Find users with salary between 60000 and 80000
db.users.find({ salary: { $gte: 60000, $lte: 80000 } });

// Find products that are NOT in Electronics category
db.users.find({ category: { $ne: "Electronics" } });

// Find users in specific departments
db.users.find({ department: { $in: ["Engineering", "Design"] } });

// Find products with stock not in specific range
db.products.find({ stock: { $nin: [25, 50, 75] } });
```

### 2.2 Logical Operators
```javascript
// Find users who are active AND in Engineering
db.users.find({
  $and: [
    { isActive: true },
    { department: "Engineering" }
  ]
});

// Find users who are either young (< 30) OR have high salary (> 80000)
db.users.find({
  $or: [
    { age: { $lt: 30 } },
    { salary: { $gt: 80000 } }
  ]
});

// Find users who are NOT in Marketing department
db.users.find({ department: { $not: { $eq: "Marketing" } } });
```

### 2.3 Element Operators
```javascript
// Find users who have an address field
db.users.find({ address: { $exists: true } });

// Find products where stock is a number
db.products.find({ stock: { $type: "number" } });
```

### 2.4 Array Operators
```javascript
// Find users who have MongoDB skill
db.users.find({ skills: { $in: ["MongoDB"] } });

// Find users who have both JavaScript AND Python skills
db.users.find({ skills: { $all: ["JavaScript", "Python"] } });

// Find users with exactly 3 skills
db.users.find({ skills: { $size: 3 } });

// Find products with rating of 5
db.products.find({ ratings: 5 });
```

## Exercise 3: Aggregation Framework (Intermediate)

### 3.1 Basic Aggregation
```javascript
// Count users by department
db.users.aggregate([
  { $group: { _id: "$department", count: { $sum: 1 } } }
]);

// Average salary by department
db.users.aggregate([
  { $group: { 
    _id: "$department", 
    avgSalary: { $avg: "$salary" },
    count: { $sum: 1 }
  }}
]);

// Total stock value by category
db.products.aggregate([
  { $group: {
    _id: "$category",
    totalValue: { $sum: { $multiply: ["$price", "$stock"] } },
    totalProducts: { $sum: 1 }
  }}
]);
```

### 3.2 Aggregation Pipeline
```javascript
// Find top 3 highest paid active users
db.users.aggregate([
  { $match: { isActive: true } },
  { $sort: { salary: -1 } },
  { $limit: 3 },
  { $project: { name: 1, department: 1, salary: 1, _id: 0 } }
]);

// Calculate age groups and their average salaries
db.users.aggregate([
  { $project: {
    name: 1,
    department: 1,
    salary: 1,
    ageGroup: {
      $cond: {
        if: { $lt: ["$age", 30] },
        then: "Young",
        else: { $cond: {
          if: { $lt: ["$age", 40] },
          then: "Middle",
          else: "Senior"
        }}
      }
    }
  }},
  { $group: {
    _id: "$ageGroup",
    avgSalary: { $avg: "$salary" },
    count: { $sum: 1 }
  }},
  { $sort: { avgSalary: -1 } }
]);
```

### 3.3 Advanced Aggregation
```javascript
// Product analysis with ratings
db.products.aggregate([
  { $unwind: "$ratings" },
  { $group: {
    _id: "$name",
    avgRating: { $avg: "$ratings" },
    totalRatings: { $sum: 1 },
    price: { $first: "$price" },
    category: { $first: "$category" }
  }},
  { $match: { avgRating: { $gte: 4.0 } } },
  { $sort: { avgRating: -1 } }
]);

// Order analysis by customer
db.orders.aggregate([
  { $group: {
    _id: "$customerId",
    totalOrders: { $sum: 1 },
    totalSpent: { $sum: "$totalAmount" },
    avgOrderValue: { $avg: "$totalAmount" }
  }},
  { $sort: { totalSpent: -1 } }
]);
```

## Exercise 4: Text Search and Indexing

### 4.1 Text Search
```javascript
// Search products by text
db.products.find({ $text: { $search: "laptop computer" } });

// Search with score
db.products.find(
  { $text: { $search: "wireless mouse" } },
  { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } });
```

### 4.2 Index Management
```javascript
// View all indexes
db.users.getIndexes();

// Create compound index
db.users.createIndex({ department: 1, salary: -1 });

// Create partial index (only for active users)
db.users.createIndex(
  { email: 1 },
  { partialFilterExpression: { isActive: true } }
);

// Create sparse index
db.users.createIndex({ "address.zipcode": 1 }, { sparse: true });

// Analyze query performance
db.users.find({ department: "Engineering", salary: { $gt: 70000 } })
  .explain("executionStats");
```

## Exercise 5: Advanced Operations

### 5.1 Array Updates
```javascript
// Add a new skill to a specific user
db.users.updateOne(
  { email: "alice@example.com" },
  { $push: { skills: "Leadership" } }
);

// Remove a skill from all users
db.users.updateMany(
  {},
  { $pull: { skills: "Marketing" } }
);

// Update array element
db.products.updateOne(
  { name: "Laptop Pro" },
  { $set: { "specifications.ram": "32GB" } }
);
```

### 5.2 Embedded Document Operations
```javascript
// Update nested address field
db.users.updateOne(
  { email: "bob@example.com" },
  { $set: { "address.street": "789 New Business Ave" } }
);

// Find by nested field
db.users.find({ "address.city": "San Francisco" });
```

### 5.3 Bulk Operations
```javascript
// Bulk write operations
db.users.bulkWrite([
  {
    updateOne: {
      filter: { department: "Engineering" },
      update: { $inc: { salary: 5000 } }
    }
  },
  {
    insertOne: {
      document: {
        name: "Grace Hopper",
        age: 32,
        email: "grace@example.com",
        department: "Engineering",
        salary: 85000,
        skills: ["Programming", "Innovation"],
        isActive: true
      }
    }
  }
]);
```

## Challenge Exercises

### Challenge 1: E-commerce Analytics
Create aggregation pipelines to answer:
1. Which customer has spent the most money?
2. What's the average order value by month?
3. Which products are most frequently ordered together?

### Challenge 2: HR Analytics
Create queries to find:
1. Department with highest average salary
2. Skills most in demand across the company
3. Employee retention by join year

### Challenge 3: Performance Optimization
1. Identify slow queries using explain()
2. Create appropriate indexes
3. Optimize aggregation pipelines

## Practice Tips
1. Always use `explain()` to understand query performance
2. Practice with different data types and nested documents
3. Try to solve problems using multiple approaches
4. Use MongoDB Compass for visual query building
5. Experiment with different aggregation stages

## Next Steps
1. Practice with larger datasets
2. Learn MongoDB drivers for your preferred programming language
3. Explore MongoDB Atlas features
4. Study real-world schema design patterns
5. Practice backup and restore operations