// MongoDB Initialization Script for Learning
// This script creates sample data for practicing MongoDB operations

// Switch to learning database
db = db.getSiblingDB('learning_db');

// Create users collection with sample data
db.users.insertMany([
  {
    name: "Alice Johnson",
    age: 28,
    email: "alice@example.com",
    department: "Engineering",
    salary: 75000,
    skills: ["JavaScript", "Python", "MongoDB"],
    address: {
      street: "123 Tech Street",
      city: "San Francisco",
      state: "CA",
      zipcode: "94105"
    },
    joinDate: new Date("2022-01-15"),
    isActive: true
  },
  {
    name: "Bob Smith",
    age: 35,
    email: "bob@example.com",
    department: "Marketing",
    salary: 65000,
    skills: ["Marketing", "Analytics", "Communication"],
    address: {
      street: "456 Business Ave",
      city: "New York",
      state: "NY",
      zipcode: "10001"
    },
    joinDate: new Date("2021-03-20"),
    isActive: true
  },
  {
    name: "Charlie Brown",
    age: 42,
    email: "charlie@example.com",
    department: "Engineering",
    salary: 95000,
    skills: ["Java", "AWS", "DevOps", "MongoDB"],
    address: {
      street: "789 Developer Lane",
      city: "Seattle",
      state: "WA",
      zipcode: "98101"
    },
    joinDate: new Date("2020-07-10"),
    isActive: true
  },
  {
    name: "Diana Prince",
    age: 31,
    email: "diana@example.com",
    department: "Design",
    salary: 70000,
    skills: ["UI/UX", "Figma", "Adobe Creative Suite"],
    address: {
      street: "321 Creative Blvd",
      city: "Los Angeles",
      state: "CA",
      zipcode: "90210"
    },
    joinDate: new Date("2021-11-05"),
    isActive: false
  },
  {
    name: "Eve Wilson",
    age: 26,
    email: "eve@example.com",
    department: "Engineering",
    salary: 68000,
    skills: ["React", "Node.js", "TypeScript"],
    address: {
      street: "654 Frontend Way",
      city: "Austin",
      state: "TX",
      zipcode: "73301"
    },
    joinDate: new Date("2023-02-01"),
    isActive: true
  }
]);

// Create products collection
db.products.insertMany([
  {
    name: "Laptop Pro",
    category: "Electronics",
    price: 1299.99,
    stock: 50,
    tags: ["computer", "laptop", "professional"],
    specifications: {
      cpu: "Intel i7",
      ram: "16GB",
      storage: "512GB SSD"
    },
    ratings: [5, 4, 5, 4, 5],
    createdAt: new Date()
  },
  {
    name: "Wireless Mouse",
    category: "Electronics",
    price: 29.99,
    stock: 200,
    tags: ["mouse", "wireless", "accessory"],
    specifications: {
      connectivity: "Bluetooth",
      battery: "AA",
      dpi: "1600"
    },
    ratings: [4, 4, 3, 5, 4],
    createdAt: new Date()
  },
  {
    name: "Office Chair",
    category: "Furniture",
    price: 249.99,
    stock: 25,
    tags: ["chair", "office", "ergonomic"],
    specifications: {
      material: "Mesh",
      adjustable: true,
      warranty: "5 years"
    },
    ratings: [5, 5, 4, 5, 4],
    createdAt: new Date()
  }
]);

// Create orders collection
db.orders.insertMany([
  {
    orderId: "ORD001",
    customerId: "alice@example.com",
    items: [
      { productName: "Laptop Pro", quantity: 1, price: 1299.99 },
      { productName: "Wireless Mouse", quantity: 2, price: 29.99 }
    ],
    totalAmount: 1359.97,
    status: "delivered",
    orderDate: new Date("2023-12-01"),
    shippingAddress: {
      street: "123 Tech Street",
      city: "San Francisco",
      state: "CA",
      zipcode: "94105"
    }
  },
  {
    orderId: "ORD002",
    customerId: "bob@example.com",
    items: [
      { productName: "Office Chair", quantity: 1, price: 249.99 }
    ],
    totalAmount: 249.99,
    status: "shipped",
    orderDate: new Date("2023-12-05"),
    shippingAddress: {
      street: "456 Business Ave",
      city: "New York",
      state: "NY",
      zipcode: "10001"
    }
  }
]);

// Create some indexes for better performance
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ department: 1, salary: -1 });
db.users.createIndex({ "address.city": 1 });
db.products.createIndex({ category: 1, price: -1 });
db.products.createIndex({ name: "text", tags: "text" });
db.orders.createIndex({ customerId: 1, orderDate: -1 });

print("Sample data and indexes created successfully!");
print("Collections created: users, products, orders");
print("You can now practice MongoDB operations with this data.");