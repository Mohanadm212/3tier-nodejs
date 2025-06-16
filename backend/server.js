const express = require("express");
const cors = require("cors");
const AWS = require("aws-sdk");
const { v4: uuidv4 } = require("uuid");

const port = 3001;
const app = express();

// ✅ AWS-hosted DynamoDB setup (no local fallback)
const dynamodb = new AWS.DynamoDB.DocumentClient({
  region: process.env.AWS_REGION || "us-east-1"
});

const TABLE_NAME = "Todos";

app.use(cors());
app.use(express.json());

// Create Todo
app.post("/api/todos", async (req, res) => {
  const { title, description, due_date } = req.body;

  const newTodo = {
    id: uuidv4(),
    title,
    description,
    due_date,
    is_complete: false,
  };

  const params = {
    TableName: TABLE_NAME,
    Item: newTodo,
  };

  try {
    await dynamodb.put(params).promise();
    res.status(201).json(newTodo);
  } catch (err) {
    console.error("Error creating todo:", err);
    res.status(500).json({ error: "Could not create todo" });
  }
});

// Get All Todos
app.get("/api/todos", async (req, res) => {
  const params = {
    TableName: TABLE_NAME,
  };

  try {
    const data = await dynamodb.scan(params).promise();
    res.json(data.Items);
  } catch (err) {
    console.error("Error fetching todos:", err);
    res.status(500).json({ error: "Could not fetch todos" });
  }
});

// Mark Todo Complete
app.patch("/api/todos/:id", async (req, res) => {
  const { id } = req.params;

  const params = {
    TableName: TABLE_NAME,
    Key: { id },
    UpdateExpression: "set is_complete = :true",
    ExpressionAttributeValues: {
      ":true": true,
    },
    ReturnValues: "UPDATED_NEW",
  };

  try {
    await dynamodb.update(params).promise();
    res.json({ message: "Todo marked as complete" });
  } catch (err) {
    console.error("Error updating todo:", err);
    res.status(500).json({ error: "Could not update todo" });
  }
});

// Start Server
app.listen(port, () => {
  console.log(`Server is listening on port: ${port}`);
});
