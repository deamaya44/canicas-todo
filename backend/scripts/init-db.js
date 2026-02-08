const { DynamoDBClient, CreateTableCommand, ListTablesCommand } = require('@aws-sdk/client-dynamodb');

const clientConfig = {
  region: process.env.AWS_REGION || 'us-east-1',
  endpoint: process.env.DYNAMODB_ENDPOINT || 'http://localhost:8000',
  credentials: {
    accessKeyId: 'dummy',
    secretAccessKey: 'dummy'
  }
};

const client = new DynamoDBClient(clientConfig);
const TABLE_NAME = process.env.TABLE_NAME || 'tasks';

async function initDB() {
  try {
    // Check if table exists
    const listCommand = new ListTablesCommand({});
    const tables = await client.send(listCommand);
    
    if (tables.TableNames.includes(TABLE_NAME)) {
      console.log(`✅ Table "${TABLE_NAME}" already exists`);
      return;
    }

    // Create table with GSI for userId
    const createCommand = new CreateTableCommand({
      TableName: TABLE_NAME,
      KeySchema: [
        { AttributeName: 'id', KeyType: 'HASH' }
      ],
      AttributeDefinitions: [
        { AttributeName: 'id', AttributeType: 'S' },
        { AttributeName: 'userId', AttributeType: 'S' }
      ],
      GlobalSecondaryIndexes: [
        {
          IndexName: 'UserIdIndex',
          KeySchema: [
            { AttributeName: 'userId', KeyType: 'HASH' }
          ],
          Projection: {
            ProjectionType: 'ALL'
          }
        }
      ],
      BillingMode: 'PAY_PER_REQUEST'
    });

    await client.send(createCommand);
    console.log(`✅ Table "${TABLE_NAME}" created successfully with UserIdIndex GSI`);
  } catch (error) {
    console.error('❌ Error initializing database:', error);
    process.exit(1);
  }
}

initDB();
