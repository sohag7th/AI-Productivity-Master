# Advanced MongoDB: Schema Design, Performance, and Scaling

## Table of Contents
1. [Schema Design Patterns](#schema-design-patterns)
2. [Performance Optimization](#performance-optimization)
3. [Replication and High Availability](#replication-and-high-availability)
4. [Sharding and Horizontal Scaling](#sharding-and-horizontal-scaling)
5. [Security Best Practices](#security-best-practices)
6. [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)
7. [Backup and Recovery](#backup-and-recovery)

## Schema Design Patterns

### 1. One-to-One Relationships

#### Embedded Documents Pattern
```javascript
// User profile embedded in user document
{
  _id: ObjectId("..."),
  name: "John Doe",
  email: "john@example.com",
  profile: {
    bio: "Software Engineer with 5 years experience",
    website: "https://johndoe.dev",
    location: "San Francisco, CA",
    avatarUrl: "https://example.com/avatar.jpg"
  },
  preferences: {
    theme: "dark",
    notifications: true,
    language: "en"
  }
}
```

#### Extended Reference Pattern
```javascript
// When documents might exceed 16MB limit
// User document
{
  _id: ObjectId("user123"),
  name: "John Doe",
  email: "john@example.com"
}

// Separate profile document
{
  _id: ObjectId("profile123"),
  userId: ObjectId("user123"),
  bio: "Very long biography...",
  portfolio: [ /* large array of projects */ ],
  detailedHistory: { /* extensive work history */ }
}
```

### 2. One-to-Many Relationships

#### Embedded Array Pattern
```javascript
// Blog post with comments (limited growth)
{
  _id: ObjectId("..."),
  title: "Introduction to MongoDB",
  content: "MongoDB is a document database...",
  author: "john@example.com",
  publishDate: ISODate("2023-12-01"),
  comments: [
    {
      author: "alice@example.com",
      text: "Great article!",
      timestamp: ISODate("2023-12-02"),
      likes: 5
    },
    {
      author: "bob@example.com",
      text: "Very helpful, thanks!",
      timestamp: ISODate("2023-12-03"),
      likes: 3
    }
  ],
  tags: ["mongodb", "database", "nosql"]
}
```

#### Reference Pattern
```javascript
// Order with order items (many items per order)
// Order document
{
  _id: ObjectId("order123"),
  customerId: ObjectId("customer123"),
  orderDate: ISODate("2023-12-01"),
  status: "shipped",
  shippingAddress: {
    street: "123 Main St",
    city: "Boston",
    state: "MA",
    zipcode: "02101"
  },
  totalAmount: 299.98
}

// OrderItem documents
{
  _id: ObjectId("item1"),
  orderId: ObjectId("order123"),
  productId: ObjectId("product456"),
  productName: "Laptop",
  quantity: 1,
  price: 299.99
}
```

#### Bucket Pattern
```javascript
// IoT sensor data bucketed by time
{
  _id: ObjectId("bucket123"),
  sensorId: "sensor_001",
  date: ISODate("2023-12-01"),
  hour: 14,
  readings: [
    { minute: 0, temperature: 22.5, humidity: 45 },
    { minute: 1, temperature: 22.7, humidity: 44 },
    { minute: 2, temperature: 22.6, humidity: 45 }
    // ... up to 60 readings per hour
  ],
  count: 60,
  avgTemperature: 22.8,
  maxTemperature: 23.2,
  minTemperature: 22.1
}
```

### 3. Many-to-Many Relationships

#### Array of References Pattern
```javascript
// Student-Course relationship
// Student document
{
  _id: ObjectId("student123"),
  name: "Alice Johnson",
  email: "alice@university.edu",
  enrolledCourses: [
    ObjectId("course1"),
    ObjectId("course2"),
    ObjectId("course3")
  ]
}

// Course document
{
  _id: ObjectId("course1"),
  title: "Database Systems",
  instructor: "Dr. Smith",
  credits: 3,
  enrolledStudents: [
    ObjectId("student123"),
    ObjectId("student456")
  ]
}
```

#### Intermediate Collection Pattern
```javascript
// For additional metadata in relationships
// Enrollment collection
{
  _id: ObjectId("enrollment123"),
  studentId: ObjectId("student123"),
  courseId: ObjectId("course1"),
  enrollmentDate: ISODate("2023-09-01"),
  grade: "A",
  attendance: 95,
  status: "completed"
}
```

### 4. Advanced Patterns

#### Polymorphic Pattern
```javascript
// Different product types in same collection
{
  _id: ObjectId("..."),
  name: "MacBook Pro",
  type: "laptop",
  price: 1999,
  // Laptop-specific fields
  screenSize: "14 inch",
  processor: "M2 Pro",
  memory: "16GB",
  storage: "512GB SSD"
}

{
  _id: ObjectId("..."),
  name: "iPhone 15",
  type: "smartphone",
  price: 799,
  // Smartphone-specific fields
  screenSize: "6.1 inch",
  carrier: "unlocked",
  storage: "128GB",
  color: "blue"
}
```

#### Attribute Pattern
```javascript
// For products with varying attributes
{
  _id: ObjectId("..."),
  name: "Samsung Galaxy S23",
  category: "smartphone",
  price: 899,
  attributes: [
    { name: "color", value: "phantom black", type: "string" },
    { name: "storage", value: 256, type: "number", unit: "GB" },
    { name: "screen_size", value: 6.1, type: "number", unit: "inch" },
    { name: "5g_enabled", value: true, type: "boolean" },
    { name: "release_date", value: ISODate("2023-02-17"), type: "date" }
  ]
}

// Create index for efficient attribute queries
db.products.createIndex({ "attributes.name": 1, "attributes.value": 1 });
```

## Performance Optimization

### 1. Query Optimization

#### Use Explain to Analyze Queries
```javascript
// Analyze query execution
db.users.find({ department: "Engineering", salary: { $gt: 70000 } })
  .explain("executionStats");

// Key metrics to look for:
// - executionTimeMillis
// - totalDocsExamined vs totalDocsReturned
// - executionStages (IXSCAN vs COLLSCAN)
// - indexesUsed
```

#### Query Hints
```javascript
// Force use of specific index
db.users.find({ department: "Engineering" })
  .hint({ department: 1, salary: -1 });

// Disable index for testing
db.users.find({ department: "Engineering" })
  .hint({ $natural: 1 });
```

### 2. Indexing Strategies

#### Compound Index Order
```javascript
// ESR Rule: Equality, Sort, Range
// Good: Equality first, then sort, then range
db.users.createIndex({ 
  department: 1,    // Equality
  joinDate: -1,     // Sort
  salary: 1         // Range
});

// Query that benefits from this index
db.users.find({ 
  department: "Engineering",    // Equality
  salary: { $gt: 70000 }       // Range
}).sort({ joinDate: -1 });     // Sort
```

#### Partial Indexes
```javascript
// Index only active users
db.users.createIndex(
  { email: 1 },
  { partialFilterExpression: { isActive: true } }
);

// Index only high-value orders
db.orders.createIndex(
  { customerId: 1, orderDate: -1 },
  { partialFilterExpression: { totalAmount: { $gt: 1000 } } }
);
```

#### Sparse Indexes
```javascript
// Index only documents with the field
db.users.createIndex({ phoneNumber: 1 }, { sparse: true });
```

#### Text Indexes with Weights
```javascript
// Weighted text search
db.articles.createIndex({
  title: "text",
  content: "text",
  tags: "text"
}, {
  weights: {
    title: 10,
    content: 5,
    tags: 1
  }
});
```

### 3. Aggregation Optimization

#### Pipeline Optimization
```javascript
// Bad: Match after group
db.orders.aggregate([
  { $group: { _id: "$customerId", total: { $sum: "$amount" } } },
  { $match: { total: { $gt: 1000 } } }  // This can't use indexes
]);

// Good: Match early
db.orders.aggregate([
  { $match: { amount: { $gt: 100 } } },  // This can use indexes
  { $group: { _id: "$customerId", total: { $sum: "$amount" } } },
  { $match: { total: { $gt: 1000 } } }
]);
```

#### Use $lookup Efficiently
```javascript
// Inefficient: Looking up all orders
db.customers.aggregate([
  {
    $lookup: {
      from: "orders",
      localField: "_id",
      foreignField: "customerId",
      as: "orders"
    }
  }
]);

// Better: Filter before lookup
db.customers.aggregate([
  { $match: { registrationDate: { $gte: ISODate("2023-01-01") } } },
  {
    $lookup: {
      from: "orders",
      let: { customerId: "$_id" },
      pipeline: [
        { $match: { 
          $expr: { $eq: ["$customerId", "$$customerId"] },
          status: "completed"
        }}
      ],
      as: "completedOrders"
    }
  }
]);
```

## Replication and High Availability

### 1. Replica Set Configuration

#### Initialize Replica Set
```javascript
// Connect to primary server
// Configure replica set
rs.initiate({
  _id: "myReplicaSet",
  members: [
    { _id: 0, host: "mongo1:27017", priority: 1 },
    { _id: 1, host: "mongo2:27017", priority: 0.5 },
    { _id: 2, host: "mongo3:27017", priority: 0.5 }
  ]
});
```

#### Add/Remove Members
```javascript
// Add a new member
rs.add("mongo4:27017");

// Add with specific configuration
rs.add({
  host: "mongo4:27017",
  priority: 0,
  hidden: true,
  buildIndexes: false
});

// Remove a member
rs.remove("mongo4:27017");
```

#### Read Preferences
```javascript
// Primary only (default)
db.users.find().readPref("primary");

// Primary preferred
db.users.find().readPref("primaryPreferred");

// Secondary only
db.users.find().readPref("secondary");

// Secondary preferred
db.users.find().readPref("secondaryPreferred");

// Nearest (lowest latency)
db.users.find().readPref("nearest");
```

### 2. Write Concerns
```javascript
// Wait for acknowledgment from majority
db.users.insertOne(
  { name: "John", email: "john@example.com" },
  { writeConcern: { w: "majority", j: true, wtimeout: 5000 } }
);

// Custom write concern
db.users.updateOne(
  { _id: ObjectId("...") },
  { $set: { status: "active" } },
  { writeConcern: { w: 2, j: true } }
);
```

## Sharding and Horizontal Scaling

### 1. Shard Key Selection

#### Good Shard Keys
```javascript
// High cardinality, even distribution
// User ID with good distribution
sh.shardCollection("myapp.users", { "userId": 1 });

// Compound shard key
sh.shardCollection("myapp.orders", { "customerId": 1, "orderDate": 1 });

// Hashed shard key for even distribution
sh.shardCollection("myapp.events", { "eventId": "hashed" });
```

#### Bad Shard Keys
```javascript
// Avoid these patterns:
// - Monotonically increasing (timestamps, ObjectId)
// - Low cardinality (status, category)
// - Non-uniform distribution
```

### 2. Sharding Commands
```javascript
// Enable sharding on database
sh.enableSharding("myapp");

// Shard a collection
sh.shardCollection("myapp.products", { "category": 1, "_id": 1 });

// Check shard status
sh.status();

// Find which shard contains a document
db.products.find({ _id: ObjectId("...") }).explain();

// Move a chunk manually
sh.moveChunk("myapp.products", { category: "Electronics" }, "shard02");
```

### 3. Zone Sharding
```javascript
// Assign ranges to specific shards
sh.addShardTag("shard01", "US");
sh.addShardTag("shard02", "EU");

sh.addTagRange("myapp.users",
  { country: "US" },
  { country: "US\uffff" },
  "US"
);

sh.addTagRange("myapp.users",
  { country: "DE" },
  { country: "GB\uffff" },
  "EU"
);
```

## Security Best Practices

### 1. Authentication and Authorization
```javascript
// Create admin user
use admin
db.createUser({
  user: "admin",
  pwd: "securePassword123",
  roles: [
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "readWriteAnyDatabase", db: "admin" }
  ]
});

// Create application user
use myapp
db.createUser({
  user: "appUser",
  pwd: "appPassword123",
  roles: [
    { role: "readWrite", db: "myapp" }
  ]
});

// Custom role
db.createRole({
  role: "dataAnalyst",
  privileges: [
    {
      resource: { db: "myapp", collection: "users" },
      actions: ["find"]
    },
    {
      resource: { db: "myapp", collection: "orders" },
      actions: ["find", "listIndexes"]
    }
  ],
  roles: []
});
```

### 2. Field-Level Encryption
```javascript
// Client-side field level encryption
const clientEncryption = new ClientEncryption(keyVault, {
  keyVaultNamespace: "encryption.__keyVault",
  kmsProviders: {
    local: {
      key: Buffer.from("your-96-byte-master-key", "base64")
    }
  }
});

// Encrypt sensitive data
const encryptedSSN = await clientEncryption.encrypt("123-45-6789", {
  algorithm: "AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic",
  keyId: dataKey
});
```

### 3. Network Security
```bash
# Enable TLS
mongod --tlsMode requireTLS --tlsCertificateKeyFile server.pem

# IP whitelisting in mongod.conf
net:
  bindIp: 127.0.0.1,10.0.0.5
  port: 27017
```

## Monitoring and Troubleshooting

### 1. Database Profiler
```javascript
// Enable profiler for slow operations (>100ms)
db.setProfilingLevel(2, { slowms: 100 });

// Query profiler collection
db.system.profile.find().sort({ ts: -1 }).limit(5);

// Find slow queries
db.system.profile.find({
  "command.find": { $exists: true },
  "millis": { $gt: 1000 }
}).sort({ millis: -1 });
```

### 2. Database Statistics
```javascript
// Database stats
db.stats();

// Collection stats
db.users.stats();

// Index stats
db.users.aggregate([{ $indexStats: {} }]);

// Current operations
db.currentOp();

// Kill long-running operation
db.killOp(123456);
```

### 3. Monitoring Commands
```javascript
// Server status
db.serverStatus();

// Replica set status
rs.status();

// Connection info
db.hello();

// Lock info
db.currentOp({"waitingForLock": true});
```

## Backup and Recovery

### 1. mongodump and mongorestore
```bash
# Backup entire database
mongodump --host localhost:27017 --db myapp --out /backup/

# Backup with authentication
mongodump --host localhost:27017 --username admin --password --authenticationDatabase admin --db myapp --out /backup/

# Restore database
mongorestore --host localhost:27017 --db myapp /backup/myapp/

# Restore specific collection
mongorestore --host localhost:27017 --db myapp --collection users /backup/myapp/users.bson
```

### 2. Point-in-Time Recovery
```bash
# Enable oplog
mongod --replSet rs0 --oplogSize 1024

# Backup with oplog
mongodump --host localhost:27017 --oplog --out /backup/

# Restore to specific point in time
mongorestore --host localhost:27017 --oplogReplay --oplogLimit 1640995200:1 /backup/
```

### 3. Atlas Backup (Cloud)
```javascript
// Automated backups in MongoDB Atlas
// - Continuous backup with point-in-time recovery
// - Scheduled snapshots
// - Cross-region backup copies
// - Backup retention policies
```

## Performance Monitoring Tools

### 1. MongoDB Compass
- Visual query performance analysis
- Index recommendation
- Real-time performance metrics
- Schema visualization

### 2. MongoDB Atlas Monitoring
- Performance advisor
- Real-time metrics
- Custom alerts
- Query profiler

### 3. Third-party Tools
- Percona Monitoring and Management (PMM)
- New Relic MongoDB monitoring
- DataDog MongoDB integration

## Production Checklist

### Pre-deployment
- [ ] Schema design review
- [ ] Index strategy planned
- [ ] Shard key selected (if sharding)
- [ ] Security configuration
- [ ] Backup strategy
- [ ] Monitoring setup

### Post-deployment
- [ ] Performance baseline established
- [ ] Alerting configured
- [ ] Backup tested
- [ ] Disaster recovery plan
- [ ] Capacity planning
- [ ] Regular maintenance scheduled

## Advanced Topics for Further Learning

1. **Change Streams** - Real-time data changes
2. **Time Series Collections** - Optimized for time-series data
3. **GridFS** - File storage system
4. **Full-Text Search** - Advanced text search capabilities
5. **Geospatial Queries** - Location-based queries
6. **MongoDB Stitch/Realm** - Backend-as-a-Service platform
7. **Custom Aggregation Operators** - Extending aggregation framework
8. **MongoDB Charts** - Data visualization platform