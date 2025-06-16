const express = require("express");
const { v4: uuidv4 } = require("uuid");
const AWS = require("aws-sdk");

const router = express.Router();

// ✅ Use AWS cloud config only (no endpoint)
const dynamodb = new AWS.DynamoDB.DocumentClient({
  region: process.env.AWS_REGION
});

const TABLE_NAME = "Todos";

// GET all todos
router.get("/", async (req, res) => {
  try {
    const data = await dynamodb.scan({ TableName: TABLE_NAME }).promise();
    const todos = data.Items.filter(todo => !todo.is_complete);
    res.json(todos);
  } catch (err) {
    console.error("Error fetching todos:", err);
    res.status(500).json({ error: "Could not fetch todos" });
  }
});

// GET todo by ID
router.get("/:id", async (req, res) => {
  try {
    const data = await dynamodb.get({
      TableName: TABLE_NAME,
      Key: { id: req.params.id }
    }).promise();

    if (!data.Item) {
      return res.status(404).json({ error: "Todo not found" });
    }

    res.json(data.Item);
  } catch (err) {
    console.error("Error fetching todo:", err);
    res.status(500).json({ error: "Could not fetch todo" });
  }
});

// POST create new todo
router.post("/", async (req, res) => {
  const todo = {
    id: uuidv4(),
    title: req.body.title,
    description: req.body.description,
    is_complete: false,
    due_date: req.body.due_date
  };

  try {
    await dynamodb.put({
      TableName: TABLE_NAME,
      Item: todo
    }).promise();

    res.status(201).json(todo);
  } catch (err) {
    console.error("Error saving todo:", err);
    res.status(500).json({ error: "Could not save todo" });
  }
});

// PATCH update todo
router.patch("/:id", async (req, res) => {
  const updateExpr = [];
  const exprAttrNames = {};
  const exprAttrValues = {};

  if (req.body.title) {
    updateExpr.push("#t = :t");
    exprAttrNames["#t"] = "title";
    exprAttrValues[":t"] = req.body.title;
  }
  if (req.body.description) {
    updateExpr.push("#d = :d");
    exprAttrNames["#d"] = "description";
    exprAttrValues[":d"] = req.body.description;
  }
  if (typeof req.body.is_complete === "boolean") {
    updateExpr.push("#c = :c");
    exprAttrNames["#c"] = "is_complete";
    exprAttrValues[":c"] = req.body.is_complete;
  }
  if (req.body.due_date) {
    updateExpr.push("#due = :due");
    exprAttrNames["#due"] = "due_date";
    exprAttrValues[":due"] = req.body.due_date;
  }

  if (updateExpr.length === 0) {
    return res.status(400).json({ error: "No valid fields provided to update" });
  }

  try {
    const result = await dynamodb.update({
      TableName: TABLE_NAME,
      Key: { id: req.params.id },
      UpdateExpression: "SET " + updateExpr.join(", "),
      ExpressionAttributeNames: exprAttrNames,
      ExpressionAttributeValues: exprAttrValues,
      ReturnValues: "ALL_NEW"
    }).promise();

    res.json(result.Attributes);
  } catch (err) {
    console.error("Error updating todo:", err);
    res.status(500).json({ error: "Could not update todo" });
  }
});

// DELETE todo
router.delete("/:id", async (req, res) => {
  try {
    await dynamodb.delete({
      TableName: TABLE_NAME,
      Key: { id: req.params.id }
    }).promise();
    res.status(204).send();
  } catch (err) {
    console.error("Error deleting todo:", err);
    res.status(500).json({ error: "Could not delete todo" });
  }
});

module.exports = router;
