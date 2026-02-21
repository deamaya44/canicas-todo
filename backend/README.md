# Backend API

Node.js Lambda function with DynamoDB for task management.

## API Endpoints

```
GET    /tasks          - List all tasks
POST   /tasks          - Create task
GET    /tasks/{id}     - Get task by ID
PUT    /tasks/{id}     - Update task
DELETE /tasks/{id}     - Delete task
```

## Local Development

```bash
# With Docker
docker-compose up backend

# Without Docker
cd backend
npm install
npm start
```

API runs on http://localhost:3001

## Environment Variables

```bash
TABLE_NAME=tasks-3d-tasks
AWS_REGION=us-east-1
NODE_ENV=development
```

## Deployment

Automatic via CodePipeline when pushing to CodeCommit.

Manual:
```bash
cd /path/to/project
./deploy-to-codecommit.sh
```
