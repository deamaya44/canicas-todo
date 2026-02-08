const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand, GetCommand, UpdateCommand, DeleteCommand, ScanCommand, QueryCommand } = require('@aws-sdk/lib-dynamodb');

const clientConfig = {
  region: process.env.AWS_REGION || 'us-east-1'
};

// Use local DynamoDB if endpoint is provided
if (process.env.DYNAMODB_ENDPOINT) {
  clientConfig.endpoint = process.env.DYNAMODB_ENDPOINT;
  clientConfig.credentials = {
    accessKeyId: 'dummy',
    secretAccessKey: 'dummy'
  };
}

const client = new DynamoDBClient(clientConfig);
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.TABLE_NAME || 'tasks';

const dynamodb = {
  async create(item) {
    const command = new PutCommand({
      TableName: TABLE_NAME,
      Item: item
    });
    await docClient.send(command);
    return item;
  },

  async get(id) {
    const command = new GetCommand({
      TableName: TABLE_NAME,
      Key: { id }
    });
    const result = await docClient.send(command);
    return result.Item;
  },

  async getAll() {
    const command = new ScanCommand({
      TableName: TABLE_NAME
    });
    const result = await docClient.send(command);
    return result.Items || [];
  },

  async getAllByUser(userId) {
    const command = new QueryCommand({
      TableName: TABLE_NAME,
      IndexName: 'UserIdIndex',
      KeyConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: {
        ':userId': userId
      }
    });
    const result = await docClient.send(command);
    return result.Items || [];
  },

  async update(id, updates) {
    const updateExpression = [];
    const expressionAttributeNames = {};
    const expressionAttributeValues = {};

    Object.keys(updates).forEach((key, index) => {
      const attrName = `#attr${index}`;
      const attrValue = `:val${index}`;
      updateExpression.push(`${attrName} = ${attrValue}`);
      expressionAttributeNames[attrName] = key;
      expressionAttributeValues[attrValue] = updates[key];
    });

    const command = new UpdateCommand({
      TableName: TABLE_NAME,
      Key: { id },
      UpdateExpression: `SET ${updateExpression.join(', ')}`,
      ExpressionAttributeNames: expressionAttributeNames,
      ExpressionAttributeValues: expressionAttributeValues,
      ReturnValues: 'ALL_NEW'
    });

    const result = await docClient.send(command);
    return result.Attributes;
  },

  async delete(id) {
    const command = new DeleteCommand({
      TableName: TABLE_NAME,
      Key: { id }
    });
    await docClient.send(command);
    return { id };
  }
};

module.exports = dynamodb;
